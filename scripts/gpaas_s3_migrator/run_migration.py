#!/usr/bin/env python3
import collections
import json
import re
import time
import sys

import boto3
import click


def locate_resources(tag_name, tag_value):
    state_machine_arn = get_resource_arn_by_tag(
        "states:stateMachine", tag_name, tag_value
    )
    dynamo_table_arn = get_resource_arn_by_tag("dynamodb:table", tag_name, tag_value)
    dynamo_table_name = re.search("table/(.+)$", dynamo_table_arn)[1]
    return state_machine_arn, dynamo_table_name


def get_resource_arn_by_tag(resource_type, tag_name, tag_value):
    tagging_client = boto3.client("resourcegroupstaggingapi")
    # We not bother to paginate because the result set should always be small
    resources = tagging_client.get_resources(
        ResourceTypeFilters=[resource_type],
        TagFilters=[{"Key": tag_name, "Values": [tag_value]}],
    )["ResourceTagMappingList"]
    if len(resources) == 0:
        raise KeyError(f"{tag_name}={tag_value}")
    return resources[0]["ResourceARN"]


def get_counts(ddb_client, progress_query_base_kwargs):
    # N.B. GSI queries are eventually consistent
    copied_count = ddb_client.query(
        **(
            progress_query_base_kwargs
            | {
                "ExpressionAttributeValues": {":status": {"S": "copied"}},
                "Select": "COUNT",
            }
        )
    )["Count"]
    waiting_count = ddb_client.query(
        **(
            progress_query_base_kwargs
            | {
                "ExpressionAttributeValues": {":status": {"S": "waiting"}},
                "Select": "COUNT",
            }
        )
    )["Count"]
    return copied_count, waiting_count


def all_waiting_keys(ddb_client, progress_query_base_kwargs):
    paginator = ddb_client.get_paginator("query")
    pages = paginator.paginate(
        **(
            progress_query_base_kwargs
            | {
                "ExpressionAttributeValues": {":status": {"S": "waiting"}},
                "Select": "ALL_PROJECTED_ATTRIBUTES",
            }
        )
    )
    for page in pages:
        for obj in page["Items"]:
            yield obj["Key"]["S"]


@click.command()
@click.argument("migrator_name")
def run_migration(migrator_name):
    """
    Run a 'GPaaS bucket to native S3' migration.

    MIGRATOR_NAME should match the value of `migrator_name` as defined in your environment's
    invocation of the `gpaas-s3-migrator` Terraform module. This is used to locate the relevant
    AWS resources using tags.

    Example use:
        run_migration.py MIGRATOR_NAME

    Note that certain IAM permissions are required to run this. For convenience an IAM Group has
    been set up already with the required permissions. Its name is:
      "run-MIGRATOR_NAME-s3-migrator" where MIGRATOR_NAME is as described above.

    """
    print("Starting migration")
    sfn_client = boto3.client("stepfunctions")
    ddb_client = boto3.client("dynamodb")

    print(f'Looking for migrator with name "{migrator_name}"')
    state_machine_arn, dynamo_table_name = locate_resources(
        "GPaasS3MigratorName", migrator_name
    )

    print(f"Starting SFN: {state_machine_arn}")
    execution_response = sfn_client.start_execution(
        stateMachineArn=state_machine_arn,
    )
    execution_arn = execution_response["executionArn"]
    print(f"Started execution {execution_arn}")
    execution_status = None

    print(f"Monitoring migration via Dynamo table {dynamo_table_name}")
    print(
        "  ..note that the counts are eventually consistent and so will be running 'behind' the progress slightly"
    )

    progress_query_base_kwargs = {
        "TableName": dynamo_table_name,
        "IndexName": "CopyStatusIndex",
        "KeyConditionExpression": "#status = :status",
        "ExpressionAttributeNames": {"#status": "Status"},
    }
    # Now we loop until the "waiting" count hits zero or appears to stagnate
    last_five_counts = collections.deque([None] * 5, maxlen=5)
    while True:
        time.sleep(10)
        # Handle possible failure of kickoff SFN - Note if the SFN succeeds it will be
        # long before the migration finishes - so we don't bother to check it again
        # if we see it has already succeeded.
        if execution_status != "SUCCEEDED":
            execution_info = sfn_client.describe_execution(executionArn=execution_arn)
            execution_status = execution_info["status"]
            if execution_status in ["FAILED", "TIMED_OUT", "ABORTED"]:
                print(f"GPaaS bucket scan job {execution_status}")
                if "cause" in execution_info:
                    print(f"cause: {json.loads(execution_info['cause'])}")
                sys.exit(2)

        copied_count, waiting_count = get_counts(ddb_client, progress_query_base_kwargs)
        print(
            f"Objects in migration list: {copied_count + waiting_count}; objects waiting: {waiting_count}"
        )
        if waiting_count == 0:
            print("Migration completed successfully")
            sys.exit(0)

        current_count = {"copied": copied_count, "waiting": waiting_count}
        if all(current_count == c for c in last_five_counts):
            print("Migration appears to have stagnated; stopping.")
            for key in all_waiting_keys(ddb_client, progress_query_base_kwargs):
                print(f"Not migrated: {key}")
            sys.exit(1)

        last_five_counts.append(current_count)


if __name__ == "__main__":
    run_migration()

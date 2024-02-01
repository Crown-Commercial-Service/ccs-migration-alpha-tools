#!/usr/bin/env python3
import collections
import json
import time
import sys

import boto3
import click


def locate_resource_by_tag(resource_type, tag_name, tag_value):
    tagging_client = boto3.client("resourcegroupstaggingapi")
    # We do not bother to paginate because the result set should always be small
    resources = tagging_client.get_resources(
        ResourceTypeFilters=[resource_type],
        TagFilters=[{"Key": tag_name, "Values": [tag_value]}],
    )["ResourceTagMappingList"]
    if len(resources) == 0:
        raise KeyError(f"{tag_name}={tag_value}")
    return resources[0]["ResourceARN"]


@click.command()
@click.argument("restore_name")
def run_restore(restore_name):
    """
    Run a 'GPaaS RDS to native RDS' PostgreSQL restore.

    RESTORE_NAME should match the value of `restore_name` as defined in your environment's
    invocation of the `postgres-restore` Terraform module. This is used to locate the
    relevant AWS resources using tags.

    Example use:
        run_restore.py RESTORE_NAME

    Note that certain IAM permissions are required to run this. For convenience an IAM Group has
    been set up already with the required permissions. Its name is:
      "run-RESTORE_NAME-postgres-restore" where RESTORE_NAME is as described above.

    """
    click.echo("Starting restore")
    sfn_client = boto3.client("stepfunctions")

    click.echo(f'Looking for restore with name "{restore_name}"')
    state_machine_arn = locate_resource_by_tag(
        "states:stateMachine", "S3PostgresRestoreName", restore_name
    )

    click.echo(f"Starting SFN: {state_machine_arn}")
    execution_response = sfn_client.start_execution(
        stateMachineArn=state_machine_arn,
    )
    execution_arn = execution_response["executionArn"]
    click.echo(f"Started execution {execution_arn}; waiting for termination.")

    started = time.time()
    while True:
        time.sleep(30)
        execution_info = sfn_client.describe_execution(executionArn=execution_arn)
        execution_status = execution_info["status"]
        click.echo(f"Execution status: {execution_status}")
        if execution_status != "RUNNING":
            break
        # Stop watching the Step Function after two minutes. The security token times out after
        # one hour and we don't want to keep Jenkins agents hanging around either.
        if time.time() >= started + 120:
            print('Task has been running for two minutes, please monitor Step Function in the AWS Console. Detaching...')
            sys.exit(0)

    if execution_status == "SUCCEEDED":
        click.echo("Success.")
        sys.exit(0)


if __name__ == "__main__":
    run_restore()

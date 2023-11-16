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
@click.argument("migrator_name")
def run_migration(migrator_name):
    """
    Run a 'GPaaS RDS to native RDS' PostgreSQL migration.

    MIGRATOR_NAME should match the value of `migrator_name` as defined in your environment's
    invocation of the `gpaas-postgres-migrator` Terraform module. This is used to locate the
    relevant AWS resources using tags.

    Example use:
        run_migration.py MIGRATOR_NAME

    Note that certain IAM permissions are required to run this. For convenience an IAM Group has
    been set up already with the required permissions. Its name is:
      "run-MIGRATOR_NAME-postgres-migrator" where MIGRATOR_NAME is as described above.

    """
    click.echo("Starting migration")
    sfn_client = boto3.client("stepfunctions")

    click.echo(f'Looking for migrator with name "{migrator_name}"')
    state_machine_arn = locate_resource_by_tag(
        "states:stateMachine", "GPaasPostgresMigratorName", migrator_name
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
        # Stop watching the Step Function after five minutes. The security token times out after 
        # one hour and we don't want to keep Jenkins agents hanging around either.
        if time.time() >= started + 300:
            print('Task has been running for five minutes, please monitor Step Function in the AWS Console. Detaching...')
            break

    if execution_status == "SUCCEEDED":
        click.echo("Success.")
        sys.exit(0)

    click.echo("Migration failed. The 'run once only' lock is still in place.")
    sys.exit(1)


if __name__ == "__main__":
    run_migration()

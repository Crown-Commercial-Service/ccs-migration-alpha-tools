#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import sys
import time

import boto3
import click

STEP_FUNCTION_POLL_INTERVAL_SECONDS = 5


def _get_client_for_role(client_type, role_arn, session_name):
    print(f"Obtaining session credentials for role {role_arn}")
    client = boto3.client("sts")
    role_creds = client.assume_role(RoleArn=role_arn, RoleSessionName=session_name)[
        "Credentials"
    ]
    return boto3.client(
        client_type,
        aws_access_key_id=role_creds["AccessKeyId"],
        aws_secret_access_key=role_creds["SecretAccessKey"],
        aws_session_token=role_creds["SessionToken"],
    )


@click.command()
@click.argument("tf-outputs-json", type=click.File("rb"), default=sys.stdin)
def migrate_cf_postgres_db(tf_outputs_json):
    """
    Migrate CloudFoundry PostgreSQL database to RDS.

    The migration is performed via a SQL dump as per GPaaS Migration Guidance:
    https://www.cloud.service.gov.uk/migration-guidance/

    This utility should be executed under the AWS profile of an IAM user in the CCS
    Management account. (Probably the same user who performs Terraform operations in the Project
    account - the "deployment agent"), since access to the State file for that environment is
    required for this utility to function correctly.

    The utility will then assume the same role in the Project account as is assumed by the Terraform
    deployment agent.

    This script expects the output from `terraform output -json` to be piped in as stdin, e.g:
    `terraform -chdir=infrastructure/environments/dev output -json | scripts/migrate_cf_postgres_db.py`

    """
    print(
        f"Started with params {click.get_current_context().params}",
    )

    tf_outputs = json.loads(tf_outputs_json.read())
    deployment_agent_role_to_assume_arn = tf_outputs[
        "deployment_agent_role_to_assume_arn"
    ]["value"]
    migrate_postgres_sfn_arn = tf_outputs["migrate_postgres_sfn_arn"]["value"]

    sfn_client = _get_client_for_role(
        "stepfunctions", deployment_agent_role_to_assume_arn, "pg-migrate"
    )

    print(f"Starting execution of SFN {migrate_postgres_sfn_arn}")
    execution_response = sfn_client.start_execution(
        stateMachineArn=migrate_postgres_sfn_arn
    )
    execution_arn = execution_response["executionArn"]
    print(f"Execution started: {execution_arn}")

    while True:
        response = sfn_client.describe_execution(executionArn=execution_arn)
        if response["status"] != "RUNNING":
            print("Step function execution result:", response)
            break
        print(
            "Waiting for non-RUNNING status of execution (this will take several minutes)..."
        )
        time.sleep(STEP_FUNCTION_POLL_INTERVAL_SECONDS)


if __name__ == "__main__":
    migrate_cf_postgres_db()

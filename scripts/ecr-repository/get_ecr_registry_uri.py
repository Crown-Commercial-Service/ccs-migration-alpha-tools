#!/usr/bin/env python3
import sys

import boto3
import click


@click.command()
def get_ecr_registry_uri():
    """
    Get the URI for the ECR registry for this AWS account.

    To call this AWS API, the acting IAM user needs to have the following
    permission:
      - ecr:DescribeRegistry

    The URI is written to stdout without a newline, so you may incorporate it into other
    commands.

    Example use, logging into Docker automatically via get_login_password.py:
        get_login_password.py | docker login --username AWS --password-stdin `get_ecr_registry_uri.py`

    """
    ecr_client = boto3.client("ecr")

    registry_response = ecr_client.describe_registry()
    account_id = registry_response["registryId"]
    region = ecr_client.meta.region_name
    registry_uri = f"{account_id}.dkr.ecr.{region}.amazonaws.com"
    click.echo(registry_uri, nl=False)


if __name__ == "__main__":
    get_ecr_registry_uri()

#!/usr/bin/env python3
import json
import sys

import boto3
import click


@click.command()
@click.argument("tf-outputs-json", type=click.File("rb"), default=sys.stdin)
@click.argument("service_name")
def wait(tf_outputs_json, service_name):
    """
    Waits for an ECS service to become stable.

    It's a very, very thin wrapper around the ECS wait API method, to
    ensure that (e.g.) a CI pipeline can be confident of moving on to a next step.

    This script was added so that a CI pipeline can perform the wait in a distinct step from the
    update, which is useful when multiple services are being updated in parallel.

    TF_OUTPUTS_JSON is a streamed JSON string of outputs object from `terraform output -json`

    SERVICE_NAME is the name of a service as defined in an `aws_ecs_service` resource.

    Permissions required by the calling IAM principal:

    - "ecs:DescribeServices" on the ECS Service to be updated (this is used by the `waiter.wait()`
      function in this script to detect the end of the update process)

    For convenience, an IAM policy has been created with the required permissions, as well as an
    IAM group into which you may add users to give them the rights to operate this script.
    """
    tf_outputs = json.loads(tf_outputs_json.read())
    ecs_cluster_arn = tf_outputs["ecs_cluster_arn"]["value"]
    ecs_client = boto3.client("ecs")

    waiter = ecs_client.get_waiter("services_stable")
    waiter.wait(
        cluster=ecs_cluster_arn,
        services=[service_name],
        WaiterConfig={"Delay": 10, "MaxAttempts": 90},
    )
    click.echo("Done")

if __name__ == "__main__":
    wait()

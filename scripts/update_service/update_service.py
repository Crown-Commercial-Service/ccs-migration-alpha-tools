#!/usr/bin/env python3
import json
import sys

import boto3
import click


def _validate_scale_to(ctx, param, value):
    if value and value < 0:
        raise click.BadParameter("must be greater than or equal to zero")
    return value


@click.command()
@click.argument("tf-outputs-json", type=click.File("rb"), default=sys.stdin)
@click.argument("service_name")
@click.option(
    "--scale-to",
    type=int,
    help="Desired count of service tasks (>=0)",
    callback=_validate_scale_to,
)
@click.option(
    "--redeploy",
    is_flag=True,
    show_default=True,
    default=False,
    help="Force new deployment from current ECR image",
)
@click.option(
    "--skip-wait",
    is_flag=True,
    show_default=True,
    default=False,
    help="Do not wait for ECS operation to complete",
)
def update_service(tf_outputs_json, service_name, scale_to, redeploy, skip_wait):
    """
    Update the number of instances and / or force redeployment of an ECS service.

    It's a very, very thin wrapper around the ECS update-service API method, with a waiter to
    ensure that (e.g.) a CI pipeline can be confident of moving on to a next step. Note that
    the waiter can be bypassed with the `--skip-wait` switch if (for example) you intend to
    scale multiple services at the same time and waiting would be an undesirable overhead.

    TF_OUTPUTS_JSON is a streamed JSON string of outputs object from `terraform output -json`

    SERVICE_NAME is the name of a service as defined in an `aws_ecs_service` resource.

    Permissions required by the calling IAM principal:

    - "ecs:DescribeServices" on the ECS Service to be updated (this is used by the `waiter.wait()`
      function in this script to detect the end of the update process)
    - "ecs:UpdateService" on the ECS service to be updated

    For convenience, an IAM policy has been created with the required permissions, as well as an
    IAM group into which you may add users to give them the rights to operate this script.

    Both the IAM policy and IAM group are named `run-update-service`. Note that for simplicity,
    the policy allows the use of this script against all the ECS services within the app's
    cluster.
    """
    if scale_to is None and redeploy is False:
        click.echo("Neither --scale_to nor --redeploy specified; no action. Quitting.")
        sys.exit(0)

    tf_outputs = json.loads(tf_outputs_json.read())
    ecs_cluster_arn = tf_outputs["ecs_cluster_arn"]["value"]
    ecs_client = boto3.client("ecs")

    update_kwargs = {"cluster": ecs_cluster_arn, "service": service_name}
    if redeploy:
        update_kwargs["forceNewDeployment"] = True

    if scale_to is not None:
        update_kwargs["desiredCount"] = scale_to

    click.echo(f"Updating service: {update_kwargs}")

    ecs_client.update_service(**update_kwargs)
    if skip_wait:
        click.echo(
            "Request issued; --skip-wait requested; ECS operation will continue independently."
        )
        sys.exit(0)

    click.echo("Request issued; waiting for stable services")

    waiter = ecs_client.get_waiter("services_stable")
    waiter.wait(
        cluster=ecs_cluster_arn,
        services=[service_name],
        WaiterConfig={"Delay": 10, "MaxAttempts": 60},
    )
    click.echo("Done")


if __name__ == "__main__":
    update_service()

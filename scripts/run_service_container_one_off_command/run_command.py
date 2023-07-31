#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import sys

import boto3
import click


@click.command()
@click.argument("tf-outputs-json", type=click.File("rb"), default=sys.stdin)
@click.argument("service_name")
@click.argument("container_name")
@click.argument("command", nargs=-1)
def run_command(tf_outputs_json, service_name, container_name, command):
    """
    Run one-off shell command within an ECS task container.

    TF_OUTPUTS_JSON is a streamed JSON string of outputs object from `terraform output -json`

    SERVICE_NAME is the name of a service as defined in an `aws_ecs_service` resource. The one-
    off command will run with the same subnet and security group settings as that service. It will
    run using the same task role as prescribed in the task definition for that service (unless
    this is overridden using the `override_role_arn` argument).

    CONTAINER_NAME is the name given to the container within the task defined for the service.
    The container will run the one-off command in an environment with the same environment
    variables - AND SECRETS - as the normal container operation (and also with any extra env
    vars specified in the `extra_environment_vars` argument).

    The final argument(s) sent to this script are taken as the command to be run inside the
    container.

    Permissions required by the calling IAM principal:

    - "ecs:DescribeServices" on all ECS services within the appropriate cluster
    - "ecs:DescribeTasks" on all ECS tasks which might be running or stopped in the appropriate
      ECS cluster (this is used by the `waiter.wait()` function in this script to detect the
      end of the task run)
    - "iam:GetRole" and "iam:PassRole" on the ECS Execution role (i.e. the role assigned for the
      setup and configuration of ECS tasks - *NOT* the Task Role)
    - "ecs:RunTask" on the ECS task whose definition holds the container as which to run the
      one-off command

    For convenience, an IAM policy has been created with the required permissions, as well as an
    IAM group into which you may add users to give them the rights to operate this script.

    Both the IAM policy and IAM group are named `run-SERVICE_NAME-service-command` where SERVICE_NAME
    is the name of the service resource passed in to the Terraform module invocation. Naturally that
    SERVICE_NAME must match the `service_name` argument passed to this command.

    Permissions PS:
      - (Note that the IAM user will also require the ability to read the Terraform state file in
        S3 because this script relies upon the output from `terraform output`).

    Example use (single command, two lines):
        $ terraform -chdir=infrastructure/environments/development output -json | \
             scripts/core/run_service_container_one_off_command/run_command.py - uploader_web web bin/rails db:migrate

    Note:
        * Use of "-" after script name; this is to direct the stdout of `terraform output` into the script
        * The command you wish to run within the task is a series of space-separated strings (as per Docker)

    """
    print(
        f"Started with params {click.get_current_context().params}",
    )

    tf_outputs = json.loads(tf_outputs_json.read())
    ecs_cluster_arn = tf_outputs["ecs_cluster_arn"]["value"]
    ecs_client = boto3.client("ecs")

    completed_task_arn = run_and_wait_for_ecs_task(
        ecs_client,
        ecs_cluster_arn,
        service_name,
        container_name,
        command,
    )

    print(f"Task {completed_task_arn} done.")


def _get_ecs_service(client, cluster_arn, service_name):
    """
    Get an ECS service by name.
    """
    matching_services = client.describe_services(
        cluster=cluster_arn, services=[service_name]
    )["services"]
    if len(matching_services) == 0:
        click.echo(
            f"Could not find service '{service_name}' for cluster '{cluster_arn}'",
            err=True,
        )
        sys.exit(1)

    return matching_services[0]


def run_and_wait_for_ecs_task(
    client,
    cluster_arn,
    service_name,
    container_name,
    command,
    extra_environment_vars=None,
    override_role_arn=None,
):
    ecs_service = _get_ecs_service(client, cluster_arn, service_name)
    task_definition_arn = ecs_service["taskDefinition"]
    awsvpc_configuration = ecs_service["deployments"][0]["networkConfiguration"][
        "awsvpcConfiguration"
    ]
    security_group_ids = awsvpc_configuration["securityGroups"]
    subnet_ids = awsvpc_configuration["subnets"]

    run_task_params = dict(
        cluster=cluster_arn,
        count=1,
        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": subnet_ids,
                "securityGroups": security_group_ids,
                "assignPublicIp": "DISABLED",
            }
        },
        overrides={
            "containerOverrides": [{"name": container_name, "command": command}]
        },
        taskDefinition=task_definition_arn,
    )

    if extra_environment_vars is not None:
        print(f"Adding environment vars {extra_environment_vars}")
        run_task_params["overrides"]["containerOverrides"][0]["environment"] = [
            {"name": k, "value": v} for k, v in extra_environment_vars.items()
        ]

    if override_role_arn is not None:
        print(f"Overriding task role to {override_role_arn}")
        run_task_params["overrides"]["taskRoleArn"] = override_role_arn

    response = client.run_task(**run_task_params)

    task_arn = response["tasks"][0]["taskArn"]
    print(f"Waiting for completion of task {task_arn}")
    waiter = client.get_waiter("tasks_stopped")
    waiter.config.delay = 5
    waiter.config.max_attempts = 50
    waiter.wait(cluster=cluster_arn, tasks=[task_arn])
    return task_arn


if __name__ == "__main__":
    run_command()

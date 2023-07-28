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

    SERVICE_NAME is the name of the service as defined in the particular invocation of
    the `ecs-service` Terraform module for the desired service.

    CONTAINER_NAME is the name given to the container within the task defined for the service.

    Permissions required by the calling agent:
      - "ecs:RunTask" on the ARN of the "uploader_web" task definition. (*Control assignment of
        this permission _very_ carefully* since it allows the agent to act with the authority
        of the app itself).
      - "ecs:DescribeTasks" to retrieve info about the running task
      - "iam:GetRole" and "iam:PassRole" on the ECS execution role

    Required Permissions:
    The calling agent will require permission "ecs:RunTask" on the specific ARN of the
    task definition to be invoked. The task definition's ARN is looked up by this script
    in the Terraform outputs map `service_task_definition_arns` using a key of the
    `service_name` you passed into this script.

    For convenience, an IAM group named "run-arbitrary-ecs-task-command" has been created to
    assign the above permissions to use this tool. (Note that the IAM user will also require
    the ability to read the Terraform state file in S3 because this script relies upon the
    output from `terraform output`).

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
    ecs_client = boto3.client("ecs")

    completed_task_arn = run_and_wait_for_ecs_task(
        ecs_client,
        tf_outputs,
        service_name,
        container_name,
        command,
    )

    print(f"Task {completed_task_arn} done.")


def run_and_wait_for_ecs_task(
    client,
    tf_outputs,
    service_name,
    container_name,
    command,
    extra_environment_vars=None,
    override_role_arn=None,
):
    ecs_cluster_arn = tf_outputs["ecs_cluster_arn"]["value"]
    task_definition_arn = tf_outputs["service_task_definition_arns"]["value"][
        service_name
    ]
    security_group_ids = tf_outputs[
        "service_task_minimum_operation_security_group_ids"
    ]["value"][service_name]
    subnet_ids = tf_outputs["arbitrary_task_execution_subnet_ids"]["value"]

    run_task_params = dict(
        cluster=ecs_cluster_arn,
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
    waiter.wait(cluster=ecs_cluster_arn, tasks=[task_arn])
    return task_arn


if __name__ == "__main__":
    run_command()

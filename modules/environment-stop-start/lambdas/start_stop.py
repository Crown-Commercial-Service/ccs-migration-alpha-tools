import boto3
import botocore.exceptions
import json
import logging
import os

logging.getLogger().setLevel(logging.INFO)


def create_boto3_clients():
    logging.debug("Creating ECS/RDS Boto3 Client(s)")
    try:
        ecs_client = boto3.client("ecs", region_name=os.getenv("AWS_REGION"))
        ecs_waiter = ecs_client.get_waiter("services_stable")
        rds_client = boto3.client("rds", region_name=os.getenv("AWS_REGION"))
        rds_waiter = rds_client.get_waiter("db_instance_available")
        logging.debug("Successfully created ECS/RDS Boto3 Client(s)")
        return ecs_client, ecs_waiter, rds_client, rds_waiter
    except botocore.exceptions.ClientError as e:
        logging.error(f"Unable to create ECS/RDS Clients: {e}")
        exit(1)


def get_compute_resources():
    logging.debug("Obtaining the full list of compute resources to manage")
    try:
        compute_resources = json.loads(os.getenv("RESOURCES"))
        logging.debug("Obtained the full list of compute resources to manage")
        return compute_resources
    except Exception as e:
        logging.error(
            f"Failed to obtain the full list of compute resources to manage: {e}"
        )
        exit(1)


def get_current_ecs_task_count(ecs_client, ecs_resource):
    try:
        response = ecs_client.describe_services(
            cluster=ecs_resource["clusterName"], services=[ecs_resource["serviceName"]]
        )
        service = response["services"][0]
        current_ecs_task_count = service["desiredCount"]
        logging.info(
            f"Current task count for {ecs_resource['serviceName']} is: {current_ecs_task_count}"
        )
        return current_ecs_task_count
    except botocore.exceptions.ClientError as e:
        logging.error(
            f"Failed to get current task count for {ecs_resource['serviceName']}: {e}"
        )
        exit(1)


def get_rds_instance_status(rds_client, rds_instance_identifier):
    try:
        response = rds_client.describe_db_instances(
            DBInstanceIdentifier=rds_instance_identifier
        )
        db_instance = response["DBInstances"][0]
        status = db_instance["DBInstanceStatus"]
        logging.debug(f"Current state of {rds_instance_identifier} is {status}")
        return status
    except botocore.exceptions.ClientError as e:
        logging.error(f"Unable to obtain RDS Instance Status: {e}")
        exit(1)


def lambda_handler(event, context):
    # Check the 'action' is 'start' or 'stop'
    action = os.getenv("ACTION")
    if action == "start":
        return start_stop(action=action)
    elif action == "stop":
        return start_stop(action=action)
    else:
        return f"Invalid action: {action}"


def rds_start_waiter(rds_resource_identifier, rds_waiter):
    try:
        rds_waiter.wait(
            DBInstanceIdentifier=rds_resource_identifier,
            WaiterConfig={"Delay": 10, "MaxAttempts": 90},
        )
        logging.info(f"Successfully started RDS Instance {rds_resource_identifier}")
    except Exception as e:
        logging.error(
            f"Error encountered with RDS Waiter whilst waiting for RDS Instance {rds_resource_identifier} to start: {e}"
        )
        exit(1)


def rds_stop_waiter(desired_state, rds_client, rds_resource_identifier):
    retries = 0
    max_retries = 90

    while desired_state != get_rds_instance_status(
        rds_client=rds_client, rds_instance_identifier=rds_resource_identifier
    ):
        status = get_rds_instance_status(
            rds_client=rds_client, rds_instance_identifier=rds_resource_identifier
        )
        retries = retries + 1
        logging.info(
            f"RDS Instance {rds_resource_identifier} has not yet reached the desired state of {desired_state}, currently in state of {status}, total retries thus far = {retries}"
        )
        if retries == max_retries:
            logging.error(
                f"Reached maximum number of retries, RDS Instance failed to reach the desired state of {desired_state}, currently in {status} after {retries} retries, exiting..."
            )
            exit(1)
        else:
            os.system(
                "sleep 30"
            )  # RDS Instances take longer to shut down than ECS Tasks, so being graceful...

    status = get_rds_instance_status(
        rds_client=rds_client, rds_instance_identifier=rds_resource_identifier
    )

    if desired_state == status:
        logging.info(
            f"RDS Instance {rds_resource_identifier} has reached the state of {status}"
        )


def start_rds_instance(desired_state, rds_client, rds_instance_identifier, rds_waiter):
    status = get_rds_instance_status(
        rds_client=rds_client, rds_instance_identifier=rds_instance_identifier
    )
    if status == "stopped" and desired_state == "available":
        logging.info(f"Starting stopped RDS Instance {rds_instance_identifier}")
        try:
            rds_client.start_db_instance(DBInstanceIdentifier=rds_instance_identifier)
        except botocore.exceptions.ClientError as e:
            logging.error(f"Unable to start instance {rds_instance_identifier}: {e}")
            exit(1)
        rds_start_waiter(
            rds_resource_identifier=rds_instance_identifier, rds_waiter=rds_waiter
        )
    elif status == "stopping" and desired_state == "available":
        logging.error(
            f"RDS Instance {rds_instance_identifier} is currently in a state of {status} and cannot be started until fully stopped"
        )
        exit(1)
    elif status == "starting" and desired_state == "available":
        logging.info(
            f"RDS Instance {rds_instance_identifier} is already starting, monitoring..."
        )
        rds_start_waiter(
            rds_resource_identifier=rds_instance_identifier, rds_waiter=rds_waiter
        )
    elif status == desired_state:
        logging.info(
            f"RDS Instance {rds_instance_identifier} is already in desired state of {status}"
        )
    else:
        logging.error(
            f"RDS Instance is in state of {status}, no action to be performed..."
        )
        exit(1)


def start_stop(action):
    ecs_client, ecs_waiter, rds_client, rds_waiter = create_boto3_clients()
    compute_resources = get_compute_resources()
    if action == "start":
        for compute_resource in compute_resources:
            if compute_resource["type"] == "rds_db_instance":
                start_rds_instance(
                    desired_state="available",
                    rds_client=rds_client,
                    rds_instance_identifier=compute_resource["identifier"],
                    rds_waiter=rds_waiter,
                )
            if compute_resource["type"] == "ecs_service":
                update_ecs_task_count(
                    desired_ecs_task_count=int(compute_resource["desiredCount"]),
                    ecs_client=ecs_client,
                    ecs_resource=compute_resource,
                    ecs_waiter=ecs_waiter,
                )
    elif action == "stop":
        for compute_resource in compute_resources:
            if compute_resource["type"] == "ecs_service":
                update_ecs_task_count(
                    desired_ecs_task_count=0,
                    ecs_client=ecs_client,
                    ecs_resource=compute_resource,
                    ecs_waiter=ecs_waiter,
                )
            if compute_resource["type"] == "rds_db_instance":
                stop_rds_instance(
                    desired_state="stopped",
                    rds_client=rds_client,
                    rds_instance_identifier=compute_resource["identifier"],
                )


def stop_rds_instance(desired_state, rds_client, rds_instance_identifier):
    status = get_rds_instance_status(
        rds_client=rds_client, rds_instance_identifier=rds_instance_identifier
    )
    if status == "available" and desired_state == "stopped":
        logging.info(f"Stopping started RDS Instance {rds_instance_identifier}")
        try:
            rds_client.stop_db_instance(DBInstanceIdentifier=rds_instance_identifier)
        except botocore.exceptions.ClientError as e:
            logging.error(f"Unable to stop instance {rds_instance_identifier}: {e}")
            exit(1)
        rds_stop_waiter(
            desired_state=desired_state,
            rds_client=rds_client,
            rds_resource_identifier=rds_instance_identifier,
        )
    elif status == "starting" and desired_state == "stopped":
        logging.error(
            f"RDS Instance {rds_instance_identifier} is currently in a state of {status} and cannot be stopped until fully started"
        )
        exit(1)
    elif status == "stopping" and desired_state == "stopped":
        logging.info(
            f"RDS Instance {rds_instance_identifier} is already stopping, monitoring..."
        )
        rds_stop_waiter(
            desired_state=desired_state,
            rds_client=rds_client,
            rds_resource_identifier={rds_instance_identifier},
        )
    elif status == desired_state:
        logging.info(
            f"RDS Instance {rds_instance_identifier} is already in desired state of {status}"
        )
    else:
        logging.error(
            f"RDS Instance is in state of {status}, no action to be performed..."
        )
        exit(1)


def update_ecs_task_count(desired_ecs_task_count, ecs_client, ecs_resource, ecs_waiter):
    current_ecs_task_count = get_current_ecs_task_count(
        ecs_client=ecs_client, ecs_resource=ecs_resource
    )
    if current_ecs_task_count == desired_ecs_task_count:
        logging.info(
            f"{ecs_resource['serviceName']} current task count is {current_ecs_task_count}, which matches desired task count of {desired_ecs_task_count}"
        )
    else:
        logging.info(
            f"Scaling {ecs_resource['serviceName']} task count from {current_ecs_task_count} to {desired_ecs_task_count}..."
        )
        try:
            ecs_client.update_service(
                cluster=ecs_resource["clusterName"],
                service=ecs_resource["serviceName"],
                desiredCount=desired_ecs_task_count,
            )
            logging.debug(
                f"ECS Update service command issued, ECS Waiter is monitoring to ensure tasks are scaled down..."
            )
            ecs_waiter.wait(
                cluster=ecs_resource["clusterName"],
                services=[ecs_resource["serviceName"]],
                WaiterConfig={"Delay": 10, "MaxAttempts": 90},
            )
            logging.info(
                f"Successfully scaled {ecs_resource['serviceName']} from {current_ecs_task_count} to {desired_ecs_task_count} tasks"
            )
        except botocore.exceptions.ClientError as e:
            logging.error(
                f"Failed to scale {ecs_resource['serviceName']} from {current_ecs_task_count} to {desired_ecs_task_count} tasks: {e}"
            )

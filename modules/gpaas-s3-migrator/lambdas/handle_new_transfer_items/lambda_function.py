"""
Handle new transfer items

Receive a batch of new Transfer Item records and pass them on to a new
State Machine execution.

"""
import json
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

sfn_client = boto3.client("stepfunctions")

transfer_objects_state_machine_arn = os.environ["TRANSFER_OBJECTS_STATE_MACHINE_ARN"]


def lambda_handler(event, context):
    records = event["Records"]
    logger.info(f"Received record count: {len(records)}")

    def convert(stream_record):
        new_image = stream_record["dynamodb"]["NewImage"]
        return {
            "Bucket": new_image["Bucket"]["S"],
            "Key": new_image["Key"]["S"],
            "PK": new_image["PK"]["S"],
        }

    sfn_input = list(map(convert, records))
    logger.debug(f"sfn_input: {sfn_input}")

    response = sfn_client.start_execution(
        stateMachineArn=transfer_objects_state_machine_arn,
        input=json.dumps(sfn_input),
    )

    logger.info(f"Started SFN execution: {response}")

"""
Compile transfer list

Reads the complete list of objects to be transferred from a GPaaS-bound S3 bucket
and writes their details to a Dynamo DB table for later processing.

For information on setting this up and providing service keys for GPaaS, please see the
README.md in this folder.

"""
import json
import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb_client = boto3.client("dynamodb")
ssm_client = boto3.client("ssm")


def lambda_handler(event, context):
    gpaas_service_key_ssm_param_name = event["gpaas_service_key_ssm_param_name"]
    transfer_list_table_name = event["transfer_list_table_name"]

    # Load the SSM param at runtime in case it's necessary to alter the param to fix
    # connection errors, etc. (If it were loaded at module load time, you'd need to
    # re-deploy the Lambda to pick up any changes).
    #
    # This Lambda is used rarely and so we do not need to set up a cache to minimise
    # SSM API calls.
    gpaas_service_key_ssm_param = ssm_client.get_parameter(
        Name=gpaas_service_key_ssm_param_name, WithDecryption=True
    )
    gpaas_service_key = json.loads(gpaas_service_key_ssm_param["Parameter"]["Value"])

    s3_client = boto3.client(
        "s3",
        aws_access_key_id=gpaas_service_key["aws_access_key_id"],
        aws_secret_access_key=gpaas_service_key["aws_secret_access_key"],
        region_name=gpaas_service_key["aws_region"],
    )
    source_bucket_name = gpaas_service_key["bucket_name"]

    key_count = 0
    s3_paginator = s3_client.get_paginator("list_objects_v2")
    pages = s3_paginator.paginate(Bucket=source_bucket_name)
    for page in pages:
        page_key_count = page["KeyCount"]
        logger.info(f"Writing {page_key_count} key(s)")
        key_count += page_key_count
        for s3_object in page["Contents"]:
            object_key = s3_object["Key"]
            dynamodb_client.put_item(
                TableName=transfer_list_table_name,
                Item={
                    "PK": {"S": f"OBJECT#{source_bucket_name}#{object_key}"},
                    "Bucket": {"S": source_bucket_name},
                    "Key": {"S": object_key},
                    "Status": {"S": "waiting"},
                },
            )
    logger.info(f"Total count of objects compiled: {key_count}")

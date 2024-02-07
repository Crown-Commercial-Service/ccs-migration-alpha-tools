"""
Migrate batch of objects.

Read a batch of new "objects to migrate" records from a Dynamo stream (via SQS)
and copy the corresponding objects from the S3 bucket to the native
AWS bucket.

For information on setting this up and providing service keys for GPaaS, please see the
README.md in this folder.

"""
import functools
import json
import logging
import os
import tempfile

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb_client = boto3.client("dynamodb")
ssm_client = boto3.client("ssm")
# We need two S3 clients - The GPaaS bucket is in a different account and
# setting up IAM roles for a user from this native account is not possible.
target_s3_client = boto3.client("s3")

s3_service_key_ssm_param_name = os.environ["S3_SERVICE_KEY_SSM_PARAM_NAME"]
target_bucket_id = os.environ["TARGET_BUCKET_ID"]
transfer_list_table_name = os.environ["TRANSFER_LIST_TABLE_NAME"]

OBJECT_SIZE_MEMORY_COPY_THRESHOLD = 500 * 1024 * 1024  # 500MB
OBJECT_SIZE_ABSOLUTE_THRESHOLD = 5 * 1024 * 1024 * 1024  # 5GB
PROPERTIES_TO_COPY = [
    "ContentLength",
    "CacheControl",
    "ContentType",
    "Expires",
    "ServerSideEncryption",
    "Metadata",
]


class ObjectTooLargeError(Exception):
    pass


def with_caching_source_s3_client(fn):
    """
    Set up the Source S3 Client only once.

    We avoid setting the source S3 client during module load. This is in case manual error is
    introduced during the setup process. (If it were set up incorrectly at module load time,
    you'd need to re-deploy the Lambda to pick up any changes).

    We cache the source S3 client (if it works) so that we are not calling SSM for every invocation
    of this function.
    """

    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        if wrapper.source_s3_client:
            logger.info("Using cached s3 client")
            source_s3_client = wrapper.source_s3_client
        else:
            logger.info(
                f"Setting up source s3 client via service key creds in SSM param {s3_service_key_ssm_param_name}"
            )
            s3_service_key_ssm_param = ssm_client.get_parameter(
                Name=s3_service_key_ssm_param_name, WithDecryption=True
            )
            s3_service_key = json.loads(
                s3_service_key_ssm_param["Parameter"]["Value"]
            )
            source_s3_client = boto3.client(
                "s3",
                region_name=s3_service_key["aws_region"],
            )

        result = fn(source_s3_client, *args, **kwargs)

        # If we succeeded (didn't crash out) then set the cached source S3 client if not yet set
        if not wrapper.source_s3_client:
            logger.info("Caching source S3 client")
            wrapper.source_s3_client = source_s3_client

        return result

    wrapper.source_s3_client = None
    return wrapper


def copy_one_object(source_s3_client, source_bucket_id, key):
    logger.info(f"Started transfer of {key}")

    source_object = source_s3_client.get_object(Bucket=source_bucket_id, Key=key)
    logger.info(f"Retrieved source object {source_object}")

    content_length = source_object["ContentLength"]
    if content_length > OBJECT_SIZE_ABSOLUTE_THRESHOLD:
        raise ObjectTooLargeError(f"{key} has size {content_length:,}")

    target_object_kwargs = {
        p: source_object[p] for p in PROPERTIES_TO_COPY if p in source_object
    }
    target_object_kwargs["Bucket"] = target_bucket_id
    target_object_kwargs["Key"] = key
    logger.debug(f"Putting target object {target_object_kwargs}")

    if content_length <= OBJECT_SIZE_MEMORY_COPY_THRESHOLD:
        copy_via_memory(source_object, target_object_kwargs)
    else:
        copy_via_tmpfile(source_object, target_object_kwargs)

    logging.info(f"Completed transfer of {key}")


def copy_via_memory(source_object, target_object_kwargs):
    print("Copying via memory")
    target_object_kwargs["Body"] = source_object["Body"].read()
    target_s3_client.put_object(**target_object_kwargs)


def copy_via_tmpfile(source_object, target_object_kwargs):
    print("Copying via tmpfile")

    with tempfile.NamedTemporaryFile() as body_file:
        chunks = 0
        for chunk in source_object["Body"].iter_chunks():
            body_file.write(chunk)
            chunks += 1
        print(f"Wrote out {chunks:,} chunks")

        body_file.seek(0)
        target_object_kwargs["Body"] = body_file
        target_s3_client.put_object(**target_object_kwargs)


def update_object_to_migrate_record(pk):
    dynamodb_client.update_item(
        TableName=transfer_list_table_name,
        Key={"PK": {"S": pk}},
        UpdateExpression="SET #status = :status",
        ExpressionAttributeNames={"#status": "Status"},
        ExpressionAttributeValues={":status": {"S": "copied"}},
    )


@with_caching_source_s3_client
def lambda_handler(source_s3_client, event, context):
    records = event["Records"]
    logger.info(f"Records received: {len(records)}")

    for record in records:
        logger.debug(f"Record: {record}")
        dynamo_stream_event = json.loads(record["body"])
        object_item = dynamo_stream_event["dynamodb"]["NewImage"]

        key = object_item["Key"]["S"]
        pk = object_item["PK"]["S"]
        source_bucket_id = object_item["Bucket"]["S"]

        copy_one_object(source_s3_client, source_bucket_id, key)
        update_object_to_migrate_record(pk)

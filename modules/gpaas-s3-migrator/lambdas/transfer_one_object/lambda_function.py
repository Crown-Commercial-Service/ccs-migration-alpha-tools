"""
Transfer one object

Read a single object from the GPaaS-bound S3 bucket and copy it into the native AWS
bucket.

For information on setting this up and providing service keys for GPaaS, please see the
README.md in this folder.

"""
import json
import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

ssm_client = boto3.client("ssm")
# We need two S3 clients - The GPaaS bucket is in a different account and
# setting up IAM roles for a user from this native account is not possible atm.
cached_source_s3_client = None
target_s3_client = boto3.client("s3")

PROPERTIES_TO_COPY = [
    "ContentLength",
    "CacheControl",
    "ContentType",
    "Expires",
    "ServerSideEncryption",
    "Metadata",
]


def lambda_handler(event, context):
    gpaas_service_key_ssm_param_name = event["gpaas_service_key_ssm_param_name"]
    key = event["key"]
    source_bucket_id = event["source_bucket_id"]
    target_bucket_id = event["target_bucket_id"]

    logger.info(f"Started transfer of {key}")

    # If there's no cached source S3 client then set it up. We do this at runtime rather than during
    # module load in case it's necessary to alter the param to fix connection errors, etc. (If it
    # were loaded at module load time, you'd need to re-deploy the Lambda to pick up any changes).
    global cached_source_s3_client
    if cached_source_s3_client is not None:
        logger.debug("Using cached s3 client")
        source_s3_client = cached_source_s3_client
    else:
        logger.debug(
            f"Setting up source s3 client via service key creds in SSM param {gpaas_service_key_ssm_param_name}"
        )
        gpaas_service_key_ssm_param = ssm_client.get_parameter(
            Name=gpaas_service_key_ssm_param_name, WithDecryption=True
        )
        gpaas_service_key = json.loads(
            gpaas_service_key_ssm_param["Parameter"]["Value"]
        )
        source_s3_client = boto3.client(
            "s3",
            aws_access_key_id=gpaas_service_key["aws_access_key_id"],
            aws_secret_access_key=gpaas_service_key["aws_secret_access_key"],
            region_name=gpaas_service_key["aws_region"],
        )

    source_object = source_s3_client.get_object(Bucket=source_bucket_id, Key=key)
    logger.debug(f"Retrieved source object {source_object}")

    target_object_kwargs = {
        p: source_object[p] for p in PROPERTIES_TO_COPY if p in source_object
    }
    target_object_kwargs["Body"] = source_object["Body"].read()
    target_object_kwargs["Bucket"] = target_bucket_id
    target_object_kwargs["Key"] = key
    logger.debug(f"Putting target object {target_object_kwargs}")
    target_s3_client.put_object(**target_object_kwargs)

    logging.info(f"Completed transfer of {key}")

    # If we succeeded (didn't crash out) then set the cached source S3 client if needed
    if cached_source_s3_client is None:
        logger.debug("Caching source S3 client")
        cached_source_s3_client = source_s3_client

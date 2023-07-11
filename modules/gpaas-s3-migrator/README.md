# GPaaS S3 Migrator

## Description

Collection of resources to duplicate the contents of a GPaaS-bound S3 bucket completely into a natively owned S3 bucket.

Note that the objects in the source bucket are left untouched.

## Properties

For each source object, the following properties are copied to the target:

* ContentLength
* CacheControl
* ContentType
* Expires
* ServerSideEncryption (`'AES256'|'aws:kms'|'aws:kms:dsse'`)
* Metadata
* Body (the actual contents)

The following are NOT explicitly copied:
* LastModified
* ETag (although this should remain the same because it is calculated as the MD5 hash of the Body)

Note that if your application relies upon either of the properties which are not copied, you should analyse this solution carefully before depending upon it.

## Setting up a GPaaS S3 Service Key

Most of the setup is done automatically by Terraform; the manual part is setting up a Service Key in GPaaS and making that available to this migrator.

_For details, see [the original GOV.UK docs](my-app-s3-service)._

1. Locate the name of the service which represents the bucket:
   ```bash
   $ cf services | grep bucket
   my-app-s3-service                                  aws-s3-bucket
   ```   
2. Create the service key:
   ```bash
   $ cf service-key my-app-s3-service s3_key_name
   ```
3. Retrieve the key's JSON data:
   ```bash
   $ cf service-key my-app-s3-service s3_key_name
   {
     "aws_access_key_id": "AKXXXXXXXXXX",
     "aws_region": "eu-west-2",
     "aws_secret_access_key": "XXXXXXXXX",
     "bucket_name": "paas-s3-broker-prod-lon-12345674-1234-4bfa-8a36-b5fa0f8b7fdb",
     "deploy_env": ""
   }
   ```
4. Locate the existing (but blank) SSM Parameter which will be called `gpaas-s3-service-key-MIGRATOR_NAME` where `MIGRATOR_NAME` is the name you give to his module when invoking it from your environment Terraform.
5. Copy the JSON output verbatim into the *Value* field, completely replacing the existing contents.
6. Hit "Save changes"

## Running the Migration

(tbc)

## Deleting the GPaaS S3 Service Key

It's good practice to delete the Service Key once the migration is complete:

```bash
$ cf delete-service-key my-app-s3-service s3_key_name
```

# GPaaS S3 Migrator

## Description

Collection of resources to duplicate the contents of a GPaaS-bound S3 bucket completely into a natively owned S3 bucket.

Note that the objects in the source bucket are left untouched.

## Properties

For each source object, the following properties are copied to the target:

* Body (the actual contents)
* ContentLength
* CacheControl
* ContentType
* Expires
* ServerSideEncryption (`'AES256'|'aws:kms'|'aws:kms:dsse'`)
* Metadata

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

The migrator comes with a script to initiate, monitor and report the results of the migration. It requires no configuration.

[The script itself](scripts/run_migration/run_migration.py) contains the instructions for its operation. You should consult these before proceeding.

Note that the script only starts the migration process and then monitors the worklist. The migrations will continue independently of the script. So even if you cancel the script, the migrations thus far initiated will continue.

Starting the script again will allow you to pick up on the progress monitoring without interfering with the migration itself.

### Idempotency

The migrator is, by design, idempotent. If run more than once it will only perform the migration of objects in the source GPaaS-bound S3 bucket which were not present in any of its previous runs.

_(Note that it detects "newness" based only on an object's Key. If you care about idempotency in your operations of this tool then you will have to analyse the application to determine whether or not it may inadvertently reuse S3 Keys for different objects.)_

The migrator persists state within a Dynamo DB and so this idempotency is applicable between invocations, different sessions, etc.

### Object size limit

The act of actually copying an object from the GPaaS-bound bucket to the native bucket is performed by the [migrate_batch_of_objects Lambda](lambdas/migrate_batch_of_objects/lambda_function.py).

By default S3 objects are copied via memory for speed, however if they exceed the size value within the `OBJECT_SIZE_MEMORY_COPY_THRESHOLD` constant then they are copied via a tmpfile (which is obviously slower than a memory copy).

If the object to be copied is larger than the `OBJECT_SIZE_ABSOLUTE_THRESHOLD` constant then the copy will be terminated with an error (`ObjectTooLargeError`) and the object will remain in the state "waiting" and will be listed at the end of the "run_migrator" script as "not migrated".


## Deleting the GPaaS S3 Service Key

It's good practice to delete the Service Key once the migration is complete:

```bash
$ cf delete-service-key my-app-s3-service s3_key_name
```

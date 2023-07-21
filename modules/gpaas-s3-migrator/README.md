# GPaaS S3 Migrator

## Description

Collection of resources to duplicate the contents of a GPaaS-bound S3 bucket completely into a natively owned S3 bucket.

Note that the objects in the source bucket are left unchanged.

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

> Note that if your application relies upon either of the properties which are not copied, you should analyse this solution carefully before depending upon it.

> Note also that if your application is using customer-managed keys to encrypt the bucket, this migrator will not work since we do not transfer the name of any KMS key as part of the migration.

## Using the Migrator in your project

This module is designed to be reusable and temporary. To optimise on both these attributes it's advised to implement it as follows:

### Locate the module invocation separately

Invoke the GPaaS-S3-migrator module using the typical Terraform `module` construct. At time of writing this requires only five variables to be provided. Each is documented clearly in [the module variables file](variables.tf) as you would expect.

It's advised to put this block into the top-level of your environment folder, as a separate file with a name such as `s3_migration.tf` (so, for example, `environments/production/s3_migration.tf`). There are a few reasons for this approach:
1. It shows with a glance of the folder that this environment has the migrator setup
2. It stops the `main.tf` becoming cluttered
3. When you are finished migrating, each of the migrator's resources and components can be removed from your platform by simply deleting this file. See [the section on uninstallation](#uninstalling-the-migrator-and-all-its-resources) for details.

### Providing input variables from your app

Configuration for the GPaaS-S3-migrator module is minimal. However it will require two outputs from your main app's installation. You will need to add these to the `outputs.tf` of your app's top-level module. This will likely be in a location such as `compositions/APPNAME_full/outputs.tf`

The two outputs you need to surface are:
- The ID (full name) of the target bucket for the migrated S3 objects (this will be populate the `target_bucket_id` variable in the migrator)
- JSON describing an IAM policy which allows writing of objects to this bucket (this will be populate the `target_bucket_write_objects_policy_document_json` variable in the migrator)

If you're using the `resource-groups/private-s3-bucket` module to provide the buckets for your actual app, you can simply surface these by adding something similar to the following to your `compositions/APPNAME_full/outputs.tf` file:

```hcl
output "documents_bucket_id" {
  description = "Full name of the bucket which is to contain the uploaded documents"
  value       = module.documents_bucket.bucket_id
}

output "documents_bucket_write_objects_policy_document_json" {
  description = "JSON describing an IAM policy to allow writing of objects to the documents bucket"
  value       = module.documents_bucket.write_objects_policy_document_json
}
```

### Enabling Lambda deployment

The migrator uses Lambda functions and so to deploy this you will need to provide the ID of an S3 bucket which can be used to distribute Lambdas. This is used to provide the `lambda_dist_bucket_id` variable.

If you are not already using Lambdas in your app then you can easily provide this bucket with the following terraform to your top-level environment folder (perhaps in a file such as `environments/production/lambda_bucket.tf`):
```hcl
resource "aws_s3_bucket" "lambda_dist" {
  bucket_prefix = "lambda-dist-assets"
  force_destroy = var.environment_is_ephemeral
}
```

### Deployment

Once you've set up the module and properties as described above, your `environments/production/s3_migration.tf` file should look something like this:
```hcl
module "migrate_documents" {
  source = "../../core/modules/gpaas-s3-migrator"

  lambda_dist_bucket_id                            = aws_s3_bucket.lambda_dist.id
  migrator_name                                    = "documents"
  resource_name_prefixes                           = var.resource_name_prefixes
  target_bucket_id                                 = module.APPNAME_full.documents_bucket_id
  target_bucket_write_objects_policy_document_json = module.APPNAME_full.documents_bucket_write_objects_policy_document_json
}
```
Now running `terraform apply` will set up the migrator in your app. Then you are good to go with the rest of the instructions in this file.

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
   $ cf create-service-key my-app-s3-service s3_key_name -c '{"allow_external_access": true}'
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

> Note that the SSM parameter is configured such that even when you re-apply Terraform during the lifecycle of this project, the new values you paste in the above steps will never be overwritten by Terraform. Therefore this is a one-time-only setup step.

## Running the Migration

The migrator comes with a script to initiate, monitor and report the results of the migration. It requires no configuration.

[The script itself](../../scripts/gpaas-s3-migrator/run_migration.py) contains the instructions for its operation. You should consult these before proceeding.

Note that the script only starts the migration process and then monitors the worklist. The migrations will continue independently of the script. So even if you cancel the script, the migrations thus far initiated will continue.

If you do stop the script for any reason, simply restarting it will allow you to pick up on the progress monitoring without interfering with the migration itself.

### IAM Permissions

To run this script a user requires the following IAM permissions:
- tag:GetResources for all resources (this is how we obviate the need for configuration)
- states:StartExecution for the "compile objects to migrate" step function
- states:DescribeExecution for any execution of that step function
- dynamodb:Query for the `CopyStatusIndex` on the "objects to migrate" Dynamo DB table

For convenience an IAM Group has been set up with the necessary minimum permissions to do this. The name of the group will be `run-MIGRATOR_NAME-migrator` where `MIGRATOR_NAME` is the value of `migrator_name` as defined in your environment's invocation of the `gpaas-s3-migrator` Terraform module.

Adding a regular no-permissions IAM user to this group will empower them to run this script (and nothing else). Note this user requires access to neither the Terraform state nor the state lock table in order to use the migrator. The IAM permissions (or Group membership) detailed above will suffice.

### Idempotency

The migrator is, by design, idempotent. If run more than once it will only perform the migration of objects in the source GPaaS-bound S3 bucket which were not present in any of its previous runs.

_(Note that it detects "newness" based only on an object's Key. If you care about idempotency in your operations of this tool then you will have to analyse the application to determine whether or not it may inadvertently reuse the same S3 Keys for different objects.)_

The migrator persists state within [a Dynamo DB table](objects_to_migrate_table.tf) and so this idempotency is present between invocations, different sessions, etc.

### Object size limit

The act of actually copying an object from the GPaaS-bound bucket to the native bucket is performed by the [migrate_batch_of_objects Lambda](lambdas/migrate_batch_of_objects/lambda_function.py).

By default S3 objects are copied via memory for speed, however if they exceed the size value within the `OBJECT_SIZE_MEMORY_COPY_THRESHOLD` constant (500MB at time of writing) then they are copied via a tmpfile (which is obviously slower than a memory copy).

If the object to be copied is larger than the `OBJECT_SIZE_ABSOLUTE_THRESHOLD` constant (5GB at time of writing) then the copy will be terminated with an error (`ObjectTooLargeError`, exit code `2`) and the object will retain the state "waiting" in the "objects to migrate" DB table and will be listed at the end of the "run_migrator" script as "not migrated".

### Terminal outputs

The script produces a progress update line every 5 seconds.

The script will end for one of two reasons:

1. The list of objects waiting to migrate goes to zero, indicating full success (exit code `0`)
2. The progress appears to stagnate (the progress stays the same for ~20 seconds) in which case the monitor script will exit with code `1` and output the name of every unmigrated object to the terminal, for investigation

## Uninstalling the Migrator and all its resources

Once the application is migrated from GPaaS it is unlikely that you will require the migrator any longer.

If you followed [the installation instructions](#using-the-migrator-in-your-project) then the removal of the migrator is simple:

1. Delete the `s3_migration.tf` file you added to your top-level environment folder
2. If you are not using Lambdas anywhere else in the app, also remove the `lambda_bucket.tf` file from the same folder
2. Re-apply the Terraform

This will remove every resource and configuration element of the migrator.

> However *BE AWARE* that if you added any users to the IAM group `run-MIGRATOR_NAME-migrator` then you will need to remove their membership of this group before you run `terraform apply`
 
If, upon running `terraform apply` you receive the error message `Error: deleting IAM Group (run-documents-migrator): DeleteConflict: Cannot delete entity, must remove users from group first` then it means you still have user(s) in that IAM group. Remove their membership, then re-apply the Terraform once more.

## Deleting the GPaaS S3 Service Key

It's good practice to delete the Service Key once you have finished with the migrator:

```bash
$ cf delete-service-key my-app-s3-service s3_key_name
```

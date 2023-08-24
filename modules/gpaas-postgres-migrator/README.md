# GPaaS PostgreSQL Migrator

## Description

Collection of resources to duplicate the contents of a GPaaS-hosted RDS Postgres instance into a natively owned RDS database.

Note that the source database is left unchanged.

## Process

The migration process is driven by [a step function](main.tf) which performs the following steps:

1. Sets a so-called "run once only" lock in a Dynamo DB table - This ensures that the migrator cannot be triggered accidentally against a database which already has been migrated into. (The results would be undesirable).
2. Dumps the data from the PostgreSQL database at GPaaS into a `.sql` file on an EFS volume. It does this by leveraging the `cf conduit` tool provided by GDS and the `pg_dump` tool.
3. Loads that `.sql` file into the empty target RDS PostgreSQL database using `psql`.

## Using the Migrator in your project

This module is designed to be reusable and temporary. To optimise on both these attributes it's advised to implement it as follows:

### Locate the module invocation separately

Invoke the gpaas-postgres-migrator module using the typical Terraform `module` construct. Several input variables will be required in order to configure the module. Each is documented clearly in [the module variables file](variables.tf) as you would expect.

It's advised to put this block into the top-level of your environment folder, as a separate file with a name such as `postgres_migration.tf` (so, for example, `environments/production/posetgres_migration.tf`). There are a few reasons for this approach:

1. It shows with a glance of the folder that this environment has the migrator setup
2. It stops the `main.tf` becoming cluttered
3. When you are finished migrating, each of the migrator's resources and components can be removed from your platform by simply deleting this file. See [the section on uninstallation](#uninstalling-the-migrator-and-all-its-resources) for details.

### Providing input variables from your app

As mentioned above, several input variables are required for the migrator to operate. Several of these will need to be surfaced in `output` statements from your primary app.

Possibly the best way to understand what's required is to look at [this reference implementation](https://github.com/Crown-Commercial-Service/ccs-conclave-document-infrastructure-aws/commit/a8880da4a6ea2c83d1d136b38381355d5a906185) from the Document Upload project. _Note: that repo is private._

### Deployment

Once you've set up the module and properties as described above, running `terraform apply` will set up the migrator in your app. Then you are good to go with the rest of the instructions in this file.

## Setting up GPaaS CloudFoundry access

The [extract ECS task](extract_task.tf) leverages the CF Conduit tool, which operates using a standard username / password combination for authenticating against GPaaS. You will therefore need to provide a suitable set of credentials to permit access to the Org, Space and RDS Service from which you are migrating the data.

Once you have the credentials, they are introduced into the migrator as follows:

1. Locate the existing (but blank) SSM Parameters which will be called `cf-username-postgres-migrator-MIGRATOR_NAME` and `cf-password-postgres-migrator-MIGRATOR_NAME` where `MIGRATOR_NAME` is the name you give to his module when invoking it from your environment Terraform.
2. Edit the parameters and paste the appropriate item into the Value box
6. Hit "Save changes"

> Note that the SSM parameters are configured such that even when you re-apply Terraform during the lifecycle of this project, the new values you paste in the above steps will never be overwritten by Terraform. Therefore this is a one-time-only setup step.

## Running the Migration

The migrator comes with a script to initiate, monitor and report the results of the migration. It requires no configuration.

[The script itself](../../scripts/gpaas_postgres_migrator/run_migration.py) contains the instructions for its operation. You should consult these before proceeding.

Note that the script only starts the migration process and then monitors the worklist. The migrations will continue independently of the script. So even if you cancel the script, the migrations thus far initiated will continue.

If you do stop the script for any reason, restarting it will produce an error as the Step Function will detect that the "run once only" lock is in place and will refuse to start a second migration. (If you legitimately need to trigger the migration process again then follow [the instructions for removing the lock](#removing-the-run-once-only-lock))

### Removing the Run Once Only lock

If for any reason the migration fails and you need to run it again, it will be necessary to locate the "run once only" lock in its Dynamo table (which will have a name which ends `PGMIGRATOR-XXXXX-LOCK`) and delete the single "LOCKED" item from the table. This is a deliberately manual step, by design. Be VERY sure that you want to run the migration more than once. If any data has actually been inserted into the target database, it's very unlikely that you want to run it again.

### IAM Permissions

To run this script a user requires the following IAM permissions:

- tag:GetResources for all resources (this is how we obviate the need for configuration)
- states:StartExecution for the "perform migration" step function
- states:DescribeExecution for any execution of that step function

For convenience an IAM policy and IAM group have been set up with the necessary minimum permissions to do this. The name of both will be `run-MIGRATOR_NAME-postgres-migrator` where `MIGRATOR_NAME` is the value of `migrator_name` as defined in your environment's invocation of the `gpaas-postgres-migrator` Terraform module.

Adding a regular no-permissions IAM user to this group - or assigning a role the permission - will empower them to run this script and perform the migration (and nothing else). Note this user requires access to neither the Terraform state nor the state lock table in order to use the migrator. The IAM permissions (or Group membership) detailed above will suffice.

### Terminal outputs

The script produces a progress update line every 5 seconds.

At the end of the script, it will report the success or failure of the migrator state machine. If for any reason the state machine was unsuccessful, you will find details of its operation within the execution record for that run. Execution records can be located easily within the state machine page, which can be found [in this list in the AWS console](https://eu-west-2.console.aws.amazon.com/states/home?region=eu-west-2#/statemachines).

## Uninstalling the Migrator and all its resources

Once the application is migrated from GPaaS it is unlikely that you will require the migrator any longer.

If you followed [the installation instructions](#using-the-migrator-in-your-project) then the removal of the migrator is simple:

1. Delete the `postgres_migration.tf` file you added to your top-level environment folder
2. Re-apply the Terraform

This will remove every resource and configuration element of the migrator.

> However *BE AWARE* that if you added any users to the IAM group `run-MIGRATOR_NAME-postgres-migrator` then you will need to remove their membership of this group before you run `terraform apply`

If, upon running `terraform apply` you receive the error message `Error: deleting IAM Group (run-documents-migrator): DeleteConflict: Cannot delete entity, must remove users from group first` then it means you still have user(s) in that IAM group. Remove their membership, then re-apply the Terraform once more.

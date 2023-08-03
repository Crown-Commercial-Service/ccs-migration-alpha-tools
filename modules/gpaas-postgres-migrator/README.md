# GPaaS PostgreSQL Migrator

## Description

Collection of resources to duplicate the contents of a GPaaS-hosted RDS Postgres instance into a natively owned RDS database.

Note that the source database is left unchanged.

## Process

The migration process is driven by [a step function](main.tf) which performs the following steps:

1. Sets a so-called "run once only" lock in a Dynamo DB table - This ensures that the migrator cannot be triggered accidentally against a database which already has been migrated into. (The results would be undesirable).
2. Dumps the data from the PostgreSQL database at GPaaS into a `.sql` file on an EFS volume. It does this by leveraging the `cf conduit` tool provided by GDS and th `pg_dump` tool.
3. Loads that `.sql` file into the target RDS PostgreSQL database using `psql`.

## Setting up

Besides the [various input variables](variables.tf) required for this module, there is also a requirement to set up CloudFoundry login credentials in SSM parameters. The parameters themselves are set up already with dummy values; the operator has to paste in appropriate real credentials. The SSM parameters are called:

* cf-username-postgres-migrator-MIGRATOR_NAME
* cf-password-postgres-migrator-MIGRATOR_NAME

where MIGRATOR_NAME is the name assigned to this module's `migrator_name` variable when invoked.

## Running the migrator

tbc


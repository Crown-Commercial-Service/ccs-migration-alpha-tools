# Postgres Migrator

## Summary

This module provides AWS resources to perform the following process:

1. Connect to GPaaS via `cf conduit` and establish a tunnel to a PostgreSQL instance
2. Dump the SQL of the connected database (using `pg_dump`) into a SQL file on an EFS volume
3. Pass the dumped SQL file into the Postgres `psql` program to load it into an empty RDS database

## Configuration

Besides the variables as detailed within [variables.tf](./variables.tf), the migration process relies on access to working credentials to access the appropriate CloudFoundry / GPaaS instance. These are specified in two AWS Systems Manager (SSM) Parameters (which you are advised to mark as Secret).

The names of those two SSM params are then passed into the process using the variable names:

* cf_password_ssm_param
* cf_username_ssm_param

Note that these SSM Parameters do not need to be in place to apply the Terraform herein; they are only required at runtime (specifically at the time when the ECS `run-task` action is initiated - they are copied in as secrets when the task is initiated)

(The process also relies on credentials for accessing the new RDS database however these are handled automatically by the Terraform).

## Operation

The migration processes are orchestrated by a step function. This can be invoked using the [supplied helper script](../../../scripts/migrate_cf_postgres_db.py).

# Scripts

Supporting script for migration:

* [migrate_cf_postgres_db.py](migrate_cf_postgres_db.py) - Migrates a PostgreSQL database from GPaaS CloudFoundry to RDS (via sql dump as per [GPaaS Migration Guidance](https://www.cloud.service.gov.uk/migration-guidance/))

For this script to function correctly, it requires that the applied Terraform output a value for each of the following:

* `deployment_agent_role_to_assume_arn` - This is the ARN of the role within the project account which is assumed by the acting user to give them deployment rights (typically a role with (near-)admin permissions)
* `migrate_postgres_sfn_arn` - This is the ARN of the step function which orchestrates the extract and load processes for PG migration; this step function is created by this "postgres_migrator" module and output from here as `migrate_postgres_sfn_arn`

These outputs are utilised by the script; they are piped in from the command line, e.g:

`terraform -chdir=infrastructure/environments/dev output -json | scripts/migrate_cf_postgres_db.py`

The extract and load tasks each run as Tasks in ECS Fargate. For this reason, the ECS Execution Role in your project will need to be assigned certain permissions also. The JSON policy documents for these required permissions are emitted from this module in its outputs. You will need to ensure that these are all assigned to the ECS Execution Role:

* `read_cf_cred_ssm_secrets_policy_document_json` - Allows retrieval of CF creds from SSM
* `read_pg_db_password_ssm_secret_policy_document_json` - Allows retrieval of RDS Postgres DB password from SSM
* `pass_task_role_policy_document_json` - Allows passage of the ECS task role for the tasks defined in this module
* `write_container_logs_policy_document_json` - Allows the container logs to be written to

Policy JSON is passed up, rather than assigning permissions to an ECS Execution Role passed in - This is because ECS Execution Roles can easily hit the policy attachment maximum, whereas policy JSON can be combined and assigned upstream at will.

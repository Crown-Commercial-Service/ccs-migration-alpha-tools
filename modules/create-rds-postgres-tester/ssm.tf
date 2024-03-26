resource "aws_ssm_parameter" "sql_script" {
  name        = "/${var.db_name}/sql_script"
  description = "SQL script to conditionally create the 'tester' user in the Postgres database"
  type        = "String"
  value       = <<EOF
DO
$do$
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolename = 'tester')
    then
    RAISE NOTICE 'Role "tester" already exists. Skipping.';
  else
    RAISE NOTICE 'Creating role "tester"...';
    CREATE ROLE tester with LOGIN;
    GRANT rds_iam TO tester;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO tester;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO tester;
  END IF;
END
$do$
EOF
}

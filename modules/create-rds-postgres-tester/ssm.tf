resource "aws_ssm_parameter" "create_rds_postgres_tester_sql" {
  name        = "${var.db_name}-create-rds-postgres-tester-sql"
  description = "SQL script to conditionally create the 'tester' user in the Postgres database"
  type        = "String"
  value       = <<EOF
DO
$do$
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'tester')
    then
    RAISE NOTICE 'Role "tester" already exists. Skipping.';
  ELSE
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

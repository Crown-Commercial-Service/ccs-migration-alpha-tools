resource "aws_ssm_parameter" "postgres_create_tester_user_sql" {
  name        = "${var.db_name}-postgres-create-tester-user-sql"
  description = "SQL script to conditionally create the 'tester' user in the Postgres database"
  type        = "String"
  value       = <<EOF
DO
$do$
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'tester')
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

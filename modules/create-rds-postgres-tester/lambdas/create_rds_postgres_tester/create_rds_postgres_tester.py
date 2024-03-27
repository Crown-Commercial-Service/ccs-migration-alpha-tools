import boto3
import os
import psycopg2


def lambda_handler(event, context):
    database_name = os.environ.get('DBNAME')

    master_username = 'postgres'
    # Retrieve the master password from AWS SSM
    ssm_client = boto3.client('ssm')
    response = ssm_client.get_parameter(Name=f'{database_name}-postgres-connection-password', WithDecryption=True)
    master_password = response['Parameter']['Value']

    # Get the RDS endpoint from the environment variable
    rds_endpoint = os.environ.get('RDSHOST')
    # Create an RDS client
    rds_client = boto3.client('rds')

    # Connect to the PostgreSQL database
    conn = psycopg2.connect(
      host=rds_endpoint,
      port=5432,
      dbname=database_name,
      user=master_username,
      password=master_password
    )

    # Create a cursor object to execute SQL queries
    cursor = conn.cursor()

    # Create a new user
    username = 'tester'
    create_user_query = """
      DO
      $$
      BEGIN
      IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE username = '{username}') THEN
        CREATE USER {username};
        GRANT rds_iam TO {username};
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO {username};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO {username};
      END IF;
      END
      $$
    """
    cursor.execute(create_user_query)

    # Commit the changes and close the connection
    conn.commit()
    conn.close()

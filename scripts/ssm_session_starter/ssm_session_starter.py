import argparse
import boto3
import os
import sys

def parse_arguments():
  parser = argparse.ArgumentParser(description="Start SSM Session Script")
  parser.add_argument("account_id", help="AWS Account ID")
  parser.add_argument("cluster_name", help="ECS Cluster Name")
  parser.add_argument("db_instance", help="RDS DB Instance Identifier")
  parser.add_argument("role_name", help="Role Name")
  parser.add_argument("rds_endpoint", help="RDS Endpoint")
  return parser.parse_args()

def get_rds_endpoint(db_instance_identifier):
  rds_client = boto3.client('rds')
  response = rds_client.describe_db_instances(DBInstanceIdentifier=db_instance_identifier)
  return response['DBInstances'][0]['Endpoint']['Address']

def get_ecs_cluster_info(cluster_name):
  ecs_client = boto3.client('ecs')
  response = ecs_client.describe_clusters(
    clusters=[cluster_name]
  )
  cluster_info = response['clusters'][0]
  return f"ecs:{cluster_name}_{cluster_info['clusterArn'].split('/')[-1]}_{cluster_info['registeredContainerInstancesCount']}"

def assume_role(account_id, role_name, session_name):
  sts_client = boto3.client('sts')
  response = sts_client.assume_role(
    RoleArn=f'arn:aws:iam::{account_id}:role/{role_name}',
    RoleSessionName=session_name
)
  return response['Credentials']

def set_aws_env_variables(Credentials):
  os.environ['AWS_ACCESS_KEY_ID'] = Credentials['AccessKeyId']
  os.environ['AWS_SECRET_ACCESS_KEY'] = Credentials['SecretAccessKey']
  os.environ['AWS_SESSION_TOKEN'] = Credentials['SessionToken']

def start_ssm_session(target, local_port, endpoint):
  parameters = {
    'portNumber': [str[remote_port]],
    'LocalPortNumber': [str[local_port]],
    'host': [f'{endpoint}']
  }

  ssm_client = boto3.client('ssm')
  response = ssm_client.start_session(
    Target=target,
    Parameters=parameters
  )
  return response

def main():
  args = parse_arguments()

  try:
    account_id = args.account_id
    cluster_name = args.cluster_name
    db_instance_identifier = args.db_instance
    local_port = 5432
    role_name = args.role_name
    remote_port = 5432
    rds_endpoint = 'rds-endpoint.region.rds.amazonaws.com'
    session_name = 'MySessionName'

    # Retrieve RDS endpoint and ECS cluster info
    rds_endpoint = get_rds_endpoint(db_instance_identifier)
    ecs_cluster_info = get_ecs_cluster_info(cluster_name)

    # Assume role
    credentials = assume_role(account_id, role_name, session_name)

    # Set AWS environment variables
    set_aws_env_variables(credentials)

    # Start SSM session
    ssm_response = start_ssm_session(ecs_cluster_info, local_port, rds_endpoint)
    print("SSM Session Started", ssm_response)

  except Exception as e:
    print("Error:", str(e))
    sys.exit(1)

if __name__ == '__main__':
  main()

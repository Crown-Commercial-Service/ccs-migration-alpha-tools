import boto3
import os
import json


def lambda_handler(event, context):

  # Check if the 'action' key in the event is to 'start' or 'stop'
  if 'action' in event:
    if event['action'] == 'start':
      return start()
    elif event['action'] == 'stop':
      return stop()
    else:
      return f"Invalid action: {event['action']}"
  else:
    return "No action specified in the event"

def start():
  ecs = boto3.client('ecs', region_name='eu-west-2')
  rds = boto3.client('rds', region_name='eu-west-2')

  resources = json.loads(os.getenv('RESOURCES'))

  for resource in resources:
    if resource['type'] == 'rds_db_instance':
      try:
        response = rds.describe_db_instances(DBInstanceIdentifier=resource['identifier'])
        db_instance = response['DBInstances'][0]
        status = db_instance['DBInstanceStatus']

        if status == 'stopped':
          print(f"RDS instance {resource['identifier']} is starting")
          response = rds.start_db_instance(DBInstanceIdentifier=resource['identifier'])
          print(response)
        else:
          print(f"RDS instance {resource['identifier']} is currently {status}")
      except Exception as e:
        return f"Error starting RDS instance: {str(e)}"
    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.describe_services(
          cluster = resource['cluster_name'],
          services = [resource['service_name']]
        )
        service = response['services'][0]
        current_count = int(service['desiredCount'])
        desired_count = int(resource['desiredCount'])

        if current_count == desired_count:
          print(f"ECS service {resource['service_name']} is already at the desired count of {current_count}.")
        else:
          update_response = ecs.update_service(
            cluster = resource['cluster_name'],
            service = resource['service_name'],
            desiredCount = desired_count
          )
          print(update_response)
      except Exception as e:
        return f"Error setting ECS service desired count: {str(e)}"

  return "Successfully started all resources"

def stop():
  ecs = boto3.client('ecs', region_name='eu-west-2')
  rds = boto3.client('rds', region_name='eu-west-2')

  resources = json.loads(os.getenv('RESOURCES'))

  for resource in resources:
    if resource['type'] == 'rds_db_instance':
      try:
        response = rds.describe_db_instances(DBInstanceIdentifier=resource['identifier'])
        db_instance = response['DBInstances'][0]
        status = db_instance['DBInstanceStatus']

        if status == 'available':
          print(f"RDS instance {resource['identifier']} is stopping.")
          stop_response = rds.stop_db_instance(DBInstanceIdentifier=resource['identifier'])
          print(stop_response)
        else:
          print(f"RDS instance {resource['identifier']} is currently {status}")
      except Exception as e:
        return f"Error stopping RDS instance: {str(e)}"

    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.describe_services(
          cluster = resource['cluster_name'],
          services = [resource['service_name']]
        )
        service = response['services'][0]
        current_count = service['desiredCount']

        if current_count == 0:
          print(f"ECS service {resource['service_name']} is already scaled to zero.")
        else:
          update_response = ecs.update_service(
            cluster = resource['cluster_name'],
            service = resource['service_name'],
            desiredCount = 0
          )
          print(update_response)
      except Exception as e:
        return f"Error scaling ECS service to zero: {str(e)}"

  return "Successfully stopped all resources"

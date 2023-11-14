import boto3
import os


def lambda_handler(event, context):

  # Check if the 'action' key in the event is to 'start' or 'stop'
  if 'action' in event:
    if event['action'] == 'start':
      return start(event.resources)
    elif event['action'] == 'stop':
      return stop(event.resources)
    else:
      return f"Invalid action: {event['action']}"
  else:
    return "No action specified in the event"

def start(resources):
  ecs = boto3.client('ecs')
  rds = boto3.client('rds')


  for resource in resources:
    if resource['type'] == 'rds_db_instance':
      try:
        response = rds.start_db_instance(DBInstanceIdentifier=resource['identifier'])
        return response
      except Exception as e:
        return f"Error starting RDS instance: {str(e)}"
    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.start_service(DBInstanceIdentifier=resource['identifier'])
        return response
      except Exception as e:
        return f"Error starting ECS service: {str(e)}"

def stop_rds_instance(instance_identifier):
  ecs = boto3.client('ecs')
  rds = boto3.client('rds')

  for resource in resources:
    if resource['type'] == 'rds_db_instance':
      try:
        response = rds.stop_db_instance(DBInstanceIdentifier=instance_identifier['identifier'])
        return response
      except Exception as e:
        return f"Error stopping RDS instance: {str(e)}"
    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.stop_service(DBInstanceIdentifier=resource['identifier'])
        return response
      except Exception as e:
        return f"Error stopping ECS service: {str(e)}"


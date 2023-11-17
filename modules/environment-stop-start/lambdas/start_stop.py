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
  f = open('resources.json')
  data = json.load(f)
  ecs = boto3.client('ecs', region_name='eu-west-2')
  rds = boto3.client('rds', region_name='eu-west-2')

  for resource in data['resources']:
    if resource['type'] == 'rds_db_instance':
      try:
        response = rds.start_db_instance(DBInstanceIdentifier=resource['identifier'])
        print(response)
      except Exception as e:
        return f"Error starting RDS instance: {str(e)}"
    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.update_service(
          cluster = resource['cluster_name'],
          service = resource['service_name'],
          desiredCount = resource['desiredCount']
        )
        print(response)
      except Exception as e:
        return f"Error starting ECS service: {str(e)}"

  return "Successfully started all resources"

def stop():
  f = open('resources.json')
  data = json.load(f)
  ecs = boto3.client('ecs', region_name='eu-west-2')
  rds = boto3.client('rds', region_name='eu-west-2')

  for resource in data['resources']:
    if resource['type'] == 'rds_db_instance':
      try:
        response = rds.stop_db_instance(DBInstanceIdentifier=resource['identifier'])
        print(response)
      except Exception as e:
        return f"Error stopping RDS instance: {str(e)}"
    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.update_service(
          cluster = resource['cluster_name'],
          service = resource['service_name'],
          desiredCount = 0
        )
        print(response)
      except Exception as e:
        return f"Error stopping ECS service: {str(e)}"

  return "Successfully stopped all resources"

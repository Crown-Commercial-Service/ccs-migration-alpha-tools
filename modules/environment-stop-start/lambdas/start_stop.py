import boto3
import os
import json


def lambda_handler(event, context):
  # Check the 'action' is 'start' or 'stop'
  action = os.getenv('ACTION')
  if action == 'start':
    return start()
  elif action == 'stop':
    return stop()
  else:
    return f"Invalid action: {action}"


def start():
  ecs = boto3.client('ecs', region_name=os.getenv('AWS_REGION'))
  rds = boto3.client('rds', region_name=os.getenv('AWS_REGION'))

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
        elif status == 'stopping':
          print(f"RDS instance {resource['identifier']} is currently stopping")
          # Need to throw exception here
          raise Exception(f"RDS instance {resource['identifier']} is currently {status}")
        # else:
        #   print(f"RDS instance {resource['identifier']} is currently {status}")
      except Exception as e:
        return f"Error starting RDS instance: {str(e)}"
    elif resource['type'] == 'ecs_service':
      try:
        response = ecs.describe_services(
          cluster = resource['clusterName'],
          services = [resource['serviceName']]
        )
        service = response['services'][0]
        currentCount = int(service['desiredCount'])
        desiredCount = int(resource['desiredCount'])

        if currentCount == desiredCount:
          print(f"ECS service {resource['serviceName']} is already at the desired count of {currentCount}.")
        else:
          update_response = ecs.update_service(
            cluster = resource['clusterName'],
            service = resource['serviceName'],
            desiredCount = desiredCount
          )
          print(update_response)
      except Exception as e:
        return f"Error setting ECS service desired count: {str(e)}"

  return "Successfully started all resources"

def stop():
  ecs = boto3.client('ecs', region_name=os.getenv('AWS_REGION'))
  rds = boto3.client('rds', region_name=os.getenv('AWS_REGION'))

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
          cluster = resource['clusterName'],
          services = [resource['serviceName']]
        )
        service = response['services'][0]
        currentCount = service['desiredCount']

        if currentCount == 0:
          print(f"ECS service {resource['serviceName']} is already scaled to zero.")
        else:
          update_response = ecs.update_service(
            cluster = resource['clusterName'],
            service = resource['serviceName'],
            desiredCount = 0
          )
          print(update_response)
      except Exception as e:
        return f"Error scaling ECS service to zero: {str(e)}"

  return "Successfully stopped all resources"

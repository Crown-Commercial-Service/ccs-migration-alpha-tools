import boto3
import os

def lambda_handler(event, context):
    region = os.environ['COPY_ORIGIN_REGION']
    backup_client = boto3.client('backup', region_name=region)
    
    # Extract the snapshot details from the completed copy
    recovery_point_arn = event['detail']['destinationRecoveryPointArn']
    source_vault_arn = event['detail']['destinationBackupVaultArn']
    source_vault_name = source_vault_arn.split(':')[-1]
    
    # Get airgapped vault parameters from environment variables
    airgap_vault_arn = os.environ['AIRGAP_VAULT_ARN']
    iam_backup_role = os.environ['BACKUP_ROLE_ARN']
    
    print(f"Starting cross-account copy for: {recovery_point_arn}")
    
    try:
        tag_response = backup_client.list_tags(ResourceArn=recovery_point_arn)
        tags = tag_response.get('Tags', {})
        retention_str = tags.get('retention_days', '7') # Default to 7 days if not specified
        retention_days = int(retention_str)
        print(f"Retention: {retention_days} days.")
        
    except Exception as e:
        print(f"Warning: Could not fetch or parse tags, defaulting to 7 days. Error: {str(e)}")
        retention_days = 7 # Safe fallback

    # Generate copy to the management account
    try:
        response = backup_client.start_copy_job(
            SourceBackupVaultName=source_vault_name,
            RecoveryPointArn=recovery_point_arn,
            DestinationBackupVaultArn=airgap_vault_arn,
            IamRoleArn=iam_backup_role,
            Lifecycle={
                'DeleteAfterDays': retention_days
            }
        )
        
        job_id = response['CopyJobId']
        print(f"Successfully started copy job: {job_id}")
        
        # RETURN A SIMPLE DICTIONARY, NOT THE FULL BOTO3 RESPONSE
        return {
            'statusCode': 200,
            'message': 'Cross-account copy started successfully',
            'CopyJobId': job_id
        }
        
    except Exception as e:
        print(f"Error: Could not complete cross-account copy: {str(e)}")
        raise e
    
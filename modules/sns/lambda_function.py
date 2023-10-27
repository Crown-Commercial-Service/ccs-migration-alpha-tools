import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):

    sns_client = boto3.client('sns')
    topic_arn = 'arn:aws:sns:eu-west-2:473251818902:testHostedZone'
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        hosted_zone_id = event['detail']['responseElements']['hostedZone']['id']
        hosted_zone_name = event['detail']['responseElements']['hostedZone']['name']
        name_servers = event['detail']['responseElements']['delegationSet']['nameServers']

        new_line = '\n'

        message = f"A new Route 53 hosted zone {hosted_zone_name} ({hosted_zone_id}) has been created with the following name servers:{new_line}{new_line}{new_line.join(name_servers)}"
        subject = "New Hosted Zone Notification"

        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject
        )
        logger.info(f"SNS publish response: {json.dumps(response)}")
        return {
            'statusCode': 200,
            'body': json.dumps('Notification sent successfully!'),
            'response': response
        }

    except KeyError as e:
        logger.error(f"key error: {str(e)} - Event structure: {json.dumps(event)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error in processing event data: {str(e)}")
        }
    except Exception as ex:
        logger.error(f"An error occurred: {str(ex)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error sending message to SNS: {str(ex)}")
        }

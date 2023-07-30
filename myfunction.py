import json
import logging
import boto3
from datetime import datetime
import os

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')
cloudwatch_logs = boto3.session.Session().client('logs')  # Use boto3.session.Session().client('logs') instead of logging.handlers.CloudWatchLogHandler

def read_items_from_dynamodb(table_name):
    table = dynamodb.Table(table_name)
    response = table.scan()
    return response['Items']

def upload_to_s3(bucket_name, file_name, data):
    response = s3.put_object(Bucket=bucket_name, Key=file_name, Body=json.dumps(data))
    return response

def lambda_handler(event, context):
    # Set up logging to CloudWatch Logs
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)  # Set log level to DEBUG
    cw_handler = logging.StreamHandler()  # Use StreamHandler for Lambda
    cw_handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    logger.addHandler(cw_handler)

    try:
        items = []

        table_name = os.environ['DYNAMODB_TABLE']
        table = dynamodb.Table(table_name)
        user_name = event['userName']
        trigger_source = event['triggerSource']
        user_attributes = event['request']['userAttributes']
        email = user_attributes.get('email', '')
        login_time = datetime.now().isoformat()
        status = 'success' if trigger_source == 'PostConfirmation_Authentication' else 'failed'
        
        # Create a CloudWatch Logs stream name using the request ID and a prefix
        log_group_name = '/aws/lambda/' + context.function_name
        log_stream_name = context.aws_request_id

        logger.info(f"Received event: {event}")
        logger.info(f"Writing user {user_name} to DynamoDB")

        table.put_item(
            Item={
                'user_id': user_name,
                'email': email,
                'login_time': login_time,
                'status': status
            }
        )

        items = read_items_from_dynamodb(table_name)
        logger.info(f"Read {len(items)} items from DynamoDB")

        bucket_name = os.environ['BUCKET_NAME']
        file_name = 'dynamodb_items.json'
        upload_to_s3(bucket_name, file_name, items)

        return event
    except Exception as e:
        # Log the exception message to CloudWatch Logs
        logger.exception(f"Error processing event: {e}")
        raise e

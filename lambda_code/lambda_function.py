import json
import boto3
import os
from kafka import KafkaProducer

# Initialize S3 client
s3_client = boto3.client('s3')

# Initialize Kafka Producer
producer = KafkaProducer(
    bootstrap_servers=os.getenv('KAFKA_BOOTSTRAP_SERVERS'),
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def lambda_handler(event, context):
    print("Received S3 event:", json.dumps(event))

    # Extract S3 bucket and object key
    s3_event = event['Records'][0]['s3']
    bucket_name = s3_event['bucket']['name']
    object_key = s3_event['object']['key']

    # Optional → read object metadata
    try:
        response = s3_client.head_object(Bucket=bucket_name, Key=object_key)
        metadata = {
            'ContentLength': response['ContentLength'],
            'ContentType': response.get('ContentType', ''),
            'LastModified': str(response['LastModified']),
            'ETag': response['ETag']
        }
    except Exception as e:
        print(f"Error reading object metadata: {e}")
        metadata = {}

    # Create message payload
    message = {
        'bucket': bucket_name,
        'key': object_key,
        'metadata': metadata
    }

    # Send message to Kafka topic
    kafka_topic = os.getenv('KAFKA_TOPIC', 'image-upload-events')
    producer.send(kafka_topic, message)
    producer.flush()

    print(f"Sent message to Kafka topic '{kafka_topic}': {message}")

    return {
        'statusCode': 200,
        'body': json.dumps('Message sent to Kafka successfully!')
    }

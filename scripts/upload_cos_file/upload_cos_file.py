import ibm_boto3
from ibm_botocore.client import Config

COS_API_KEY_ID = ''
service_instance_id = ''
auth_endpoint = 'https://iam.cloud.ibm.com/identity/token'
service_endpoint = ''
bucket_name = ''

with open('.env', 'r') as f:
    lines = f.readlines()

    for line in lines:
        if 'COS_APIKEY' in line:
            api_key = line.split('=')[1].strip()
        elif 'COS_SERVICE_INSTANCE_ID' in line:
            service_instance_id = line.split('=')[1].strip()
        elif 'COS_ENDPOINT' in line:
            service_endpoint = line.split('=')[1].strip()
        elif 'COS_BUCKET' in line:
            bucket_name = line.split('=')[1].strip()

cos = ibm_boto3.client('s3',
                        ibm_api_key_id=api_key,
                        ibm_service_instance_id=service_instance_id,
                        ibm_auth_endpoint=auth_endpoint,
                        config=Config(signature_version='oauth'),
                        endpoint_url=service_endpoint)

file_path = 'modified_client.tgz'
object_name = 'client.tgz'

with open(file_path, 'rb') as file_data:
    cos.upload_fileobj(file_data, bucket_name, object_name)

print('File uploaded successfully')


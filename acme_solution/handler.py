import logging  
from helpers import get_object,connection_db,read_file, define_insert, define_records
import boto3
# According with [https://docs.aws.amazon.com/code-library/latest/ug/lambda_example_serverless_S3_Lambda_section.html]

# set it as DEBUG 
logger = logging.getLogger()
logger.setLevel(logging.INFO)
client = boto3.client('s3')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    # TODO - the naming of the file according with CloudTrail
    key = event['Records'][0]['s3']['object']['key']
    data = get_object(client, bucket, key)
    logger.info("The response is generated -> %s", str(data))

    connection = connection_db()
    cursor = connection.cursor()
    # NOTE not the best approach - maybe an event bridge was better
    # TODO primary keys and indexes to the table in order to optimize it 
    # TODO try and error for execution
    # TODO execution as a function
    create_table = read_file('create_table.sql')
    cursor.execute(create_table)
    connection.commit()
    logger.info("The table was created")

    records = data["Records"][0]
    columns, values = define_records(records)
    query = define_insert(columns, values)
    cursor.execute(query, values)
    connection.commit()
    logger.info(
    "The values were inserted"
    )


    
    client.close()
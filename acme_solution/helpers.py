# pylint: disable=too-many-nested-blocks
import psycopg2 as pg
from psycopg2  import sql
from psycopg2.extras import Json
import logging  
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# NOTE: all the functions don't have docstrings it should be listed in TODO
def connection_db():
    try:
        # TODO - encrypt on the user and password or to save them in Parameter Storage
        connection = pg.connect(
                        dbname = "acme", 
                        user = "oanacazan",
                        password = "NewDb1234#",
                        host = "localhost",
                        port = "5432"
        )
        return connection
    except ConnectionError as error:
        logger.error(error)

def get_object(client, bucket: str, key: str):
    response = client.get_object(Bucket = bucket, Key=key)
    file_content = response['Body'].read().decode('utf-8')
    return json.loads(file_content)

def read_file(path: str):
    with open(path, 'r') as file:
        return file.read()
    
def define_records(records:dict):
    columns = []
    values  = []
    for record in records:
        if record not in ("userIdentity", "tlsDetails", "resources"):
            columns.append(record.lower())
            if record not in ("requestParameters", "responseElements", "additionalEventData"):
                values.append(records[record])
            else:
                values.append(Json(records[record]))
        else:
            decomposer = records[record]
            if not isinstance(decomposer, list):
                for element in decomposer:
                    if isinstance(element, str):
                        # IMPROVEMENT this code can be added in a function using
                        # rename_mapping = {
                        #     'userIdentity': {
                        #         'type': 'typeIdentity',
                        #         'arn': 'arnIdentity',
                        #         'accountId': 'accountIdIdentity',
                        # },
                        # 'resources': {
                        #         'type': 'typeResources',
                        #         'arn': 'arnResources',
                        #         'accountId': 'accountIdResources',
                        # },
                        # }
                        if element not in ('type','arn','accountId'):
                            columns.append(element.lower())
                        elif record == 'userIdentity' and element == 'type':
                            columns.append('typeIdentity'.lower())
                        elif record == 'userIdentity' and element == 'arn':
                            columns.append('arnIdentity'.lower())
                        elif record == 'userIdentity' and element == 'accountId':
                            columns.append('accountIdIdentity'.lower())
                    if not isinstance(decomposer[element], str):
                        values.append(Json(decomposer[element]))
                    else:
                        values.append(decomposer[element])
            else:
                for decomposer_element in decomposer:
                    for elem in decomposer_element:
                        if elem.lower() not in columns:
                            columns.append(elem.lower())
                        values.append(decomposer_element[elem])
    return columns, values

def define_insert(columns: list, values: list):
    return sql.SQL("INSERT INTO {table} ({fields}) VALUES ({placeholders})").format(
                table=sql.Identifier('cloudtraillogs'),
                fields=sql.SQL(', ').join(map(sql.Identifier, columns)),
                placeholders=sql.SQL(', ').join(sql.Placeholder() * len(values))
    )
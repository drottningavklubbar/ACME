import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)
# set it as DEBUG
import psycopg2 as pg
from psycopg2  import sql
from psycopg2.extras import Json
import json


def connection_db():
    try:
        connection = pg.connect(
            dbname="acme",
            user="oanacazan",
            password="NewDb1234#",
            host="localhost",
            port="5432",
        )
        return connection
    except ConnectionError as error:
        logger.error(error)
        print(error)


def read_json_file(path: str):
    with open(path, "r") as file:
        return json.load(file)


def read_file(path: str):
    with open(path, "r") as file:
        return file.read()


connection = connection_db()
cursor = connection.cursor()
# NOTE not the best approach - maybe an event bridge was better
# TODO primary keys and indexes to the table in order to optimize it
create_table = read_file("create_table.sql")
cursor.execute(create_table)
connection.commit()
logger.info("The table was created")
# result = cursor.fetchall()
# print(result)
file_content = read_json_file(path="iamExample.json")
records = file_content["Records"][0]
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
            # inserting a list is not working correctly needs more investigation

# the deduplication using a merge maybe or something else ?

query = sql.SQL("INSERT INTO {table} ({fields}) VALUES ({placeholders})").format(
    table=sql.Identifier('cloudtraillogs'),
    fields=sql.SQL(', ').join(map(sql.Identifier, columns)),
    placeholders=sql.SQL(', ').join(sql.Placeholder() * len(values))
)
cursor.execute(query, values)
connection.commit()
logger.info(
"The values were inserted"
)


# deduplication

# Close connection
cursor.close()
connection.close()

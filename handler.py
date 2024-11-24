import psycopg2 as pg

connection = pg.connect(
                        dbname = "oanacazan", 
                        user = "oanacazan",
                        password = "NewDb1234#",
                        host = "localhost",
                        port = "5432")
print("Connected to the database successfully!")

def lambda_handler(event, context):
    message = 'Hello {} {}!'.format(event['first_name'], event['last_name'])  
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM cars;")
    result = cursor.fetchall()
    # Close connection
    cursor.close()
    connection.close()
    return { 
        'message' : message,
        'data': result

    }
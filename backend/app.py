import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT")
)

cursor = conn.cursor()
with open("../queries/test.sql", "r") as f:
    sql = f.read()
cursor.execute(sql)


rows = cursor.fetchall()
print("TEST Query results:")
for row in rows:
    print(row)


conn.commit()
cursor.close()
conn.close()

import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

def connect():
    return psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )

def load_sql(file_path: str):
    with open(file_path, "r") as file:
        sql = file.read()
    return sql

def run_test_query():
    sql = load_sql("queries/test.sql")  # Filepath assumes backend app is run from the root directory (cs348)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql)
            rows = cursor.fetchall()
            print("TEST Query results:")
            for row in rows:
                print(row)
    finally:
        conn.close()

def has_played_for_both_teams(pid: str, tid1: str, tid2: str) -> bool:
    sql = load_sql("queries/check_played_for_both_teams.sql") # Filepath assumes backend app is run from the root directory (cs348)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (pid, tid1, pid, tid2))
            result = cursor.fetchone()
            if result is None:
                return False
            return result[0] == 1 # SQL query returns 1 if the player has played for both teams
    finally:
        conn.close()

run_test_query()
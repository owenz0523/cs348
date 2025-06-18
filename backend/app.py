import psycopg2
import os
import unicodedata
import re
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

def remove_accents(input_str: str) -> str:
    normalized = unicodedata.normalize('NFD', input_str)
    return ''.join(c for c in normalized if not unicodedata.combining(c))

def run_test_query():
    sql = load_sql("../queries/test.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
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
    sql = load_sql("../queries/check_played_for_both_teams.sql") # Filepath assumes backend app is run from the backend directory (cs348/backend)
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

def get_players_with_prefix(player_name_prefix: str):
    player_name_prefix = player_name_prefix.strip().lower() # Normalize input
    player_name_prefix = remove_accents(re.sub(r'[-\s]+', ' ', player_name_prefix)) # Remove accents and replace hyphens or multiple spaces with a single space
    sql = load_sql("../queries/get_players_by_prefix.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (player_name_prefix + '%',))
            rows = cursor.fetchall()
            return [
                {
                    "pid": row[0],
                    "pname": row[1]
                } for row in rows
            ]
    finally:
        conn.close()

def get_players_with_teams(tid1: str, tid2: str):
    sql = load_sql("../queries/get_players_by_teams.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (tid1, tid2))
            rows = cursor.fetchall()
            return [
                {
                    "pid": row[0],
                    "pname": row[1],
                } for row in rows
            ]
    finally:
        conn.close()

def get_hint_for_teams(tid1: str, tid2: str):
    sql = load_sql("../queries/get_hint_for_teams.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (tid1, tid2, tid1, tid2, tid2, tid1, tid1, tid2))
            rows = cursor.fetchall()
            return [
                {
                    "pid": row[0],
                    "pname": row[1],
                    "correct_answer": True if row[2] == 1 else False,
                } for row in rows
            ]
    finally:
        conn.close()

run_test_query()
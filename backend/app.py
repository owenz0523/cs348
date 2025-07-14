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
    sql = load_sql("../queries/tests/test.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
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

def store_match_result_info(result, p1_stats, p2_stats):
    sql = load_sql("../queries/insert_match_result.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (result, "P1", p1_stats.correct_guesses, p1_stats.incorrect_guesses, p1_stats.hints_used,
                                 "P2", p2_stats.correct_guesses, p2_stats.incorrect_guesses, p2_stats.hints_used))
            conn.commit()
    finally:
        conn.close()

def get_match_history():
    sql = load_sql("../queries/get_match_history.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql)
            rows = cursor.fetchall()
            return [
                {
                    "mid": row[0],
                    "result": row[1],
                    "p1_stats": row[3],
                    "p2_stats": row[4],
                    "played_at": row[2].isoformat() if row[2] else None,
                } for row in rows
            ]
    finally:
        conn.close()

def get_match_rows_cols():
    sql = load_sql("../queries/generate_match_rows_cols.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            result = None
            while result is None:
                cursor.execute(sql)
                result = cursor.fetchone()
            return {
                "r1": result[0],
                "r2": result[1],
                "r3": result[2],
                "c1": result[3],
                "c2": result[4],
                "c3": result[5]
            }
    finally:
        conn.close()

def get_player_statistic(pid: str):
    transaction_sql = load_sql("../queries/choose_random_statistic.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    sql = load_sql("../queries/get_player_statistic.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(transaction_sql)
            cursor.execute(sql, (pid,))
            row = cursor.fetchone()
            return {
                "pid": pid,
                "season": row[0],
                "stat_name": row[1],
                "avg_stat": float(row[2]) if row[2] else None,
            }
    finally:
        conn.close()

def activate_clear_match_history_trigger():
    sql = load_sql("../queries/clear_match_history.sql")  # Filepath assumes backend app is run from the backend directory (cs348/backend)
    conn = connect()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql)
            conn.commit()
    finally:
        conn.close()

run_test_query()
activate_clear_match_history_trigger()
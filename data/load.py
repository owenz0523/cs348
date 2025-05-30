import os
import pandas as pd
import psycopg2
from dotenv import load_dotenv

load_dotenv()
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
BASE_DIR = os.path.dirname(__file__)
SEASON = 2025 # only have one season of data for now (sample)
GAME_TYPE = "Regular" # only have regular season data for now (sample)


# DB Connection
conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT
)
cur = conn.cursor()

# Load teams
csv_path = os.path.join(BASE_DIR, 'teamsRaw.csv')
df = pd.read_csv(csv_path)
for _, row in df.iterrows():
    cur.execute(
        """
        INSERT INTO teams (tid, tname)
        VALUES (%s, %s)
        """,
        (row["Abbreviation"], row["Team"])
    )


# Load players + player team relationships
csv_path = os.path.join(BASE_DIR, 'playersRaw.csv')
df = pd.read_csv(csv_path)
for _, row in df.iterrows():
    cur.execute(
        """
        INSERT INTO players (pid, pname)
        VALUES (%s, %s)
        """,
        (row["PlayerID"], row["Player"])
    )

    # players may be traded mid season so may play for 2+ teams in season
    teams = row["Team"]
    team_ind = 0
    while team_ind < len(teams):
        cur.execute(
            """
            INSERT INTO plays_for (pid, tid, season)
            VALUES (%s, %s, %s)
            """,
            (row["PlayerID"], teams[team_ind:team_ind+3], SEASON)
        )
        team_ind += 3


# Load games
csv_path = os.path.join(BASE_DIR, 'gamesRaw.csv')
df = pd.read_csv(csv_path)
gid_index = 1
# will map game_date, tid to its unique gid to be used in box score
gid_of = dict()
for _, row in df.iterrows():
    winner = row["Home"] if row["Result"] == "W" else row["Away"]
    cur.execute(
        """
        INSERT INTO games (season, game_date, tid_home, tid_away, winner, game_type)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (SEASON, row["Date"], row["Home"], row["Away"], winner, GAME_TYPE)
    )

    gid_of[(row["Date"], row["Home"])] = gid_index
    gid_of[(row["Date"], row["Away"])] = gid_index
    gid_index +=1

# Load box scores
csv_path = os.path.join(BASE_DIR, 'boxScoreRaw.csv')
df = pd.read_csv(csv_path)
for _, row in df.iterrows():
    cur.execute(
        """
        INSERT INTO box_score (
            pid, gid, mins, pts, reb, ast, stl, blk, tov,
            fta, ft, fga, fg, fg3a, fg3, plus_minus
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        (
            row["PlayerID"],
            gid_of[(row["Date"], row["Team"])],
            row["MP"],
            row["PTS"],
            row["TRB"],
            row["AST"],
            row["STL"],
            row["BLK"],
            row["TOV"],
            row["FTA"],
            row["FT"],
            row["FGA"],
            row["FG"],
            row["3PA"],
            row["3P"],
            row["+/-"]
        )
    )

conn.commit()
cur.close()
conn.close()
print("CSV data inserted successfully! Type shiii!")
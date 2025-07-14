from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Literal
from app import has_played_for_both_teams, get_players_with_prefix, get_players_with_teams, get_hint_for_teams, store_match_result_info, get_match_history, get_match_rows_cols, get_player_statistic

app = FastAPI()

# Permit frontend CORS access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PlayerTeams(BaseModel):
    pid: str
    tid1: str
    tid2: str

@app.post("/check_played_for_both_teams")
def check_played_for_both_teams(player_and_teams: PlayerTeams):
    pid = player_and_teams.pid
    tid1 = player_and_teams.tid1
    tid2 = player_and_teams.tid2
    result = has_played_for_both_teams(pid, tid1, tid2)
    return JSONResponse(
        status_code=200,
        content={"has_played": result}
    )

@app.post("/retrieve_suggested_players")
def retrieve_suggested_players(prefix: str):
    if not prefix:
        return JSONResponse(
            status_code=400,
            content={"error": "Player name prefix cannot be empty"}
        )
    players = get_players_with_prefix(prefix)
    return JSONResponse(
        status_code=200,
        content=players
    )

class Teams(BaseModel):
    tid1: str
    tid2: str

@app.post("/retrieve_players_by_teams")
def retrieve_players_by_teams(teams: Teams):
    tid1 = teams.tid1
    tid2 = teams.tid2
    players = get_players_with_teams(tid1, tid2)
    return JSONResponse(
        status_code=200,
        content=players
    )

@app.post("/retrieve_hint_for_teams")
def retrieve_hint_for_teams(teams: Teams):
    tid1 = teams.tid1
    tid2 = teams.tid2
    hint = get_hint_for_teams(tid1, tid2)
    return JSONResponse(
        status_code=200,
        content=hint
    )

class PlayerStats(BaseModel):
    correct_guesses: int
    incorrect_guesses: int
    hints_used: int

class MatchData(BaseModel):
    result: Literal['P1 Win', 'P2 Win', 'Draw']
    p1: PlayerStats
    p2: PlayerStats

@app.post("/insert_match_result")
def insert_match_result(match_data: MatchData):
    result = match_data.result
    p1_stats = match_data.p1
    p2_stats = match_data.p2
    store_match_result_info(result, p1_stats, p2_stats)
    return JSONResponse(
        status_code=200,
        content={"message": "Match result stored successfully"}
    )

@app.get("/retrieve_match_history")
def retrieve_match_history():
    match_history = get_match_history()
    return JSONResponse(
        status_code=200,
        content=match_history
    )

@app.get("/generate_match_rows_cols")
def generate_match_rows_cols():
    match_rows_cols = get_match_rows_cols()
    return JSONResponse(
        status_code=200,
        content=match_rows_cols
    )

class Player(BaseModel):
    pid: str

@app.post("/retrieve_player_statistic")
def retrieve_player_statistic(player: Player):
    pid = player.pid
    player_statistic = get_player_statistic(pid)
    return JSONResponse(
        status_code=200,
        content=player_statistic
    )
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from backend.app import has_played_for_both_teams, get_players_with_prefix

app = FastAPI()

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
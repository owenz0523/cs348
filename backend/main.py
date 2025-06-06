from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from backend.app import has_played_for_both_teams

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
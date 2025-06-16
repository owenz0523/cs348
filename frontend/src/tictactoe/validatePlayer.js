// validatePlayer.js
import axios from "axios";

const validatePlayer = async (playerName, team1, team2) => {
    // Get players that match enough to the inputted player
    const response = await axios.post(
        `http://localhost:8000/retrieve_suggested_players?prefix=${encodeURIComponent(playerName)}`
    );
    const matchedPlayers = response.data; 
    console.log(matchedPlayers);

    // Check if any close matched players played for both teams
    for(const player of matchedPlayers){
        const pid = player.pid;
        const response = await axios.post(
            "http://localhost:8000/check_played_for_both_teams",
            {
                "pid": pid,
                "tid1": team1,
                "tid2": team2
            }
        );
        console.log(response);
        if(response.data.has_played){
            console.log(player.pname + " played for both " + team1 + " and " + team2);
            return true;
        }
    }
    return false;
};

export default validatePlayer;

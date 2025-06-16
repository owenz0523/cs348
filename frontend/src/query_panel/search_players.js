import axios from "axios";

const searchPlayers = async (team1, team2) => {
    const response = await axios.post(
        "http://localhost:8000/retrieve_players_by_teams",
        {
            "tid1": team1,
            "tid2": team2
        }
    );
    console.log(response);
    return response.data;
}

export default searchPlayers;

import axios from "axios";

const searchByPrefix = async (playerPrefix) => {
    const response = await axios.post(
        `http://localhost:8000/retrieve_suggested_players?prefix=${encodeURIComponent(playerPrefix)}`
    );
    const matchedPlayers = response.data; 
    console.log(matchedPlayers);
    return matchedPlayers;
}

export default searchByPrefix;
 
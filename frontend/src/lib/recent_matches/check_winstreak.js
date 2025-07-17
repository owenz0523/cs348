import axios from "axios";

const checkWinstreak = async () => {
    const response = await axios.get(
        "http://localhost:8000/retrieve_win_streak"
    );
    console.log(response);
    return response.data;
}

export default checkWinstreak;

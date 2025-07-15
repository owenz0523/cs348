import axios from "axios";

const getPlayerStatistic = async (pid) => {
    const response = await axios.post(
        "http://localhost:8000/retrieve_player_statistic",
        { pid }
    );
    return response.data;
};

export default getPlayerStatistic; 
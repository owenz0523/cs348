import axios from "axios";

const getHistory = async () => {
    const response = await axios.get(
        "http://localhost:8000/retrieve_match_history"
    );
    console.log(response);
    return response.data;
}

export default getHistory;

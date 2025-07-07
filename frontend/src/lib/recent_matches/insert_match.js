import axios from "axios";

const insertMatch = async (winner, p1_stats, p2_stats) => {
    let result = "Draw";
    if(winner == "X"){
        result = "P1 Win";
    } else if(winner == "O"){
        result = "P2 Win";
    }
    const response = await axios.post(
        "http://localhost:8000/insert_match_result",
        {
            "result": result,
            "p1": {
                "correct_guesses": p1_stats.correct,
                "incorrect_guesses": p1_stats.incorrect,
                "hints_used": p1_stats.hints
            },
            "p2": {
                "correct_guesses": p2_stats.correct,
                "incorrect_guesses": p2_stats.incorrect,
                "hints_used": p2_stats.hints
            }
        }
    );
    console.log(response);
    return response.data;
}

export default insertMatch;

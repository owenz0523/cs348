import React, {useState} from "react";
import searchPlayers from "../lib/post_game_query_panel/search_players";

const PostGameQueryPanel = () => {
    const [team1, setTeam1] = useState("");
    const [team2, setTeam2] = useState("");
    const [queryResults, setQueryResults] = useState([]);

    const handleClick = async (team1, team2) => {
        const queryArray = await searchPlayers(team1, team2);
        const queryPlayers = queryArray.map(p => p.pname);
        setQueryResults(queryPlayers);
        console.log(queryPlayers);
    }
    
    return (
        <div className="p-4 border-r border-gray-300 flex flex-col">
            <h2 className="text-lg font-semibold mb-2">Post-Game Search</h2>
            <input
                type="text"
                placeholder="Enter team 1"
                className="border p-2 rounded mb-2"
                value={team1}
                onChange={(e) => setTeam1(e.target.value)}
            />
            <input
                type="text"
                placeholder="Enter team 2"
                className="border p-2 rounded mb-2"
                value={team2}
                onChange={(e) => setTeam2(e.target.value)}
            />
            <button
                className="bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
                onClick={() => handleClick(team1, team2)}
            >
                Search Players
            </button>
            {queryResults.length > 0 && 
                <div className="mt-4 p-2 border rounded bg-gray-50 text-sm text-gray-700 w-full max-w-md">
                    <h3 className="font-semibold mb-2">Query Results:</h3>
                    <ul className="list-disc list-inside">
                        {queryResults.map((name, index) => (
                            <li key={index} className="list-none">{name}</li>
                        ))}
                    </ul>
                </div>
            } 
        </div>
    )
};

export default PostGameQueryPanel;

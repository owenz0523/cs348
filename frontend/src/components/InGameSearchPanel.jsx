import React, { useState, useEffect } from "react";
import searchByPrefix from "../in_game_search_panel/search_by_prefix";
import validatePlayer from "../tictactoe/validatePlayer";

const InGameSearchPanel = ({activeMove, setActiveMove, board, setBoard, turn, setTurn, setHint}) => {
  const [playerPfx, setPlayerPfx] = useState("");
  const [queryResults, setQueryResults] = useState([]);

  useEffect(() => {
    const runSearch = async () => {
      // Only search if prefix has at least 2 characters
      if (playerPfx.trim().length < 2) {
        setQueryResults([]);
        return;
      }

      const queryArray = await searchByPrefix(playerPfx);
      const queryPlayers = queryArray.map((p) => p.pname);
      setQueryResults(queryPlayers);
    };

    runSearch();
  }, [playerPfx]);

  const handleClick = async () => {
    const row = activeMove["row"];
    const col = activeMove["col"];
    const team1 = board[0][col];
    const team2 = board[row][0];

    const isValid = await validatePlayer(playerPfx, team1, team2);
    if(!isValid){
        alert(`Input player has NOT played for both ${team1} and ${team2}! Please try again.`)
        setHint([]);
        setPlayerPfx("");
        setActiveMove(null);
        return;
    }

    const updatedBoard = board.map((r, i) =>
        r.map((c, j) => (i === row && j === col ? turn : c))
    );
    setBoard(updatedBoard);
    setTurn(turn === "X" ? "O" : "X");
    setHint([]);
    setPlayerPfx("");
    setActiveMove(null);
  };

  return (
    <div className="p-4 border-r border-gray-300 flex flex-col">
      <h2 className="text-lg font-semibold mb-2">Enter a Player Name to Make a Move!</h2>
      <input
        type="text"
        placeholder="Search Players (min 2 characters)"
        className="border p-2 rounded mb-2"
        value={playerPfx}
        onChange={(e) => setPlayerPfx(e.target.value)}
      />
      <button
        className="bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
        onClick={() => {handleClick()}}
      >
        Enter
      </button>
      {queryResults.length > 0 && (
        <div className="mt-4 p-2 border rounded bg-gray-50 text-sm text-gray-700 w-full max-w-md">
          <h3 className="font-semibold mb-2">Query Results:</h3>

          <div className="h-64 overflow-y-auto pr-1">
            <ul className="list-disc list-inside">
              {queryResults.map((pname, index) => (
                <li key={index} className="list-none">{pname}</li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
};

export default InGameSearchPanel;

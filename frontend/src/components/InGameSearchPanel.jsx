import React, { useState, useEffect } from "react";
import searchByPrefix from "../lib/in_game_search_panel/search_by_prefix";
import validatePlayer from "../lib/tictactoe/validatePlayer";
import getPlayerStatistic from "../lib/tictactoe/get_player_statistic";

const InGameSearchPanel = ({playerStats, setPlayerStats, activeMove, setActiveMove, board, setBoard, turn, setTurn, setHint, playerNames, setPlayerNames, setPlayerStatsCache}) => {
  const [playerPfx, setPlayerPfx] = useState("");
  const [queryResults, setQueryResults] = useState([]);
  const [queryResultObjs, setQueryResultObjs] = useState([]); // Store full player objects

  useEffect(() => {
    const runSearch = async () => {
      // Only search if prefix has at least 2 characters
      if (playerPfx.trim().length < 2) {
        setQueryResults([]);
        setQueryResultObjs([]);
        return;
      }
      const queryArray = await searchByPrefix(playerPfx); // [{pid, pname}]
      setQueryResults(queryArray.map((p) => p.pname));
      setQueryResultObjs(queryArray);
    };
    runSearch();
  }, [playerPfx]);

  const handleClick = async () => {
    const row = activeMove["row"];
    const col = activeMove["col"];
    const team1 = board[0][col];
    const team2 = board[row][0];
    const playerObj = queryResultObjs.find(p => p.pname.toLowerCase() === playerPfx.toLowerCase());
    if (!playerObj) {
      alert("Please select a valid player from the suggestions.");
      return;
    }
    const isValid = await validatePlayer(playerPfx, team1, team2);
    if(!isValid){
        alert(`Input player has NOT played for both ${team1} and ${team2}! Turn has been switched to ${turn === "X" ? "O" : "X"}`)
        let newPlayerStats = playerStats;
        newPlayerStats[turn].incorrect += 1;
        setPlayerStats(newPlayerStats)
        setHint([]);
        setPlayerPfx("");
        setActiveMove(null);
        setTurn(turn === "X" ? "O" : "X");
        return;
    }
    setBoard(board.map((r, i) =>
      r.map((c, j) => (i === row && j === col ? turn : c))
    ));
    setPlayerNames(playerNames.map((r, i) =>
      r.map((c, j) => (i === row && j === col ? { pname: playerObj.pname, pid: playerObj.pid } : c))
    ));
    // Fetch and cache player stats
    const stats = await getPlayerStatistic(playerObj.pid);
    setPlayerStatsCache(prev => {
      const updated = prev.map(arr => arr.slice());
      updated[row][col] = stats;
      return updated;
    });
    let newPlayerStats = playerStats;
    newPlayerStats[turn].correct += 1;
    setPlayerStats(newPlayerStats)
    setTurn(turn === "X" ? "O" : "X");
    setHint([]);
    setPlayerPfx("");
    setActiveMove(null);
  };

  const handlePlayerClick = (playerName) => {
    setPlayerPfx(playerName);
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
                <li 
                  key={index} 
                  className="list-none cursor-pointer hover:bg-blue-100 px-2 py-1 rounded transition-colors"
                  onClick={() => handlePlayerClick(pname)}
                >
                  {pname}
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
};

export default InGameSearchPanel;

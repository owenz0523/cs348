import React, {useState, useEffect}  from "react";
import NavBar from "./components/NavBar";
import PostGameQueryPanel from "./components/PostGameQueryPanel";
import InGameSearchPanel from "./components/InGameSearchPanel";
import TicTacToe from "./components/TicTacToe";
import RecentMatches from "./components/RecentMatches";
import insertMatch from "./lib/recent_matches/insert_match";

const App = () => {
    const [winner, setWinner] = useState(null);
    const [playerStats, setPlayerStats] = useState(
        {
            "X": {"correct":0, "incorrect":0, "hints":0},
            "O": {"correct":0, "incorrect":0, "hints":0}
        }
    );

    const [pendingMatch, setPendingMatch] = useState(true);
    const [activeMove, setActiveMove] = useState(null);

    const [board, setBoard] = useState(
        Array.from({ length: 4 }, () => Array(4).fill(null))
    );
    const [playerNames, setPlayerNames] = useState(
        Array.from({ length: 4 }, () => Array(4).fill(null))
    );
    const [turn, setTurn] = useState("X");
    const [hint, setHint] = useState([]);

    useEffect(() => {
        if(!winner){
            return;
        }
        const asyncInsert = async () => {
            try {
                await insertMatch(winner, playerStats["X"], playerStats["O"]);
                setPendingMatch(true);
            } catch (err) {
                console.error('Failed to insert match:', err);
            }
        };
        asyncInsert();
    }, [winner]);


    return (
        <div className="min-h-screen flex flex-col">
            <NavBar />
            <div className="flex flex-1 min-w-full">
                <div className="w-1/5 border-r border-gray-300">
                    <RecentMatches pendingMatch={pendingMatch} setPendingMatch={setPendingMatch}/>
                </div>
                <div className="w-1/4 border-r border-gray-300">
                    {winner && <PostGameQueryPanel />}         
                    {activeMove && 
                    <InGameSearchPanel 
                        activeMove={activeMove} setActiveMove={setActiveMove} 
                        playerStats={playerStats} setPlayerStats={setPlayerStats}
                        board={board} setBoard={setBoard}
                        turn={turn} setTurn={setTurn} setHint={setHint}
                        playerNames={playerNames} setPlayerNames={setPlayerNames}
                    />}                
                </div>
                <div className="flex-1">
                    <TicTacToe winner={winner} setWinner={setWinner} 
                                playerStats={playerStats} setPlayerStats={setPlayerStats}
                                board={board} setBoard={setBoard}
                                hint={hint} setHint={setHint}
                                activeMove={activeMove} setActiveMove={setActiveMove}
                                turn={turn} playerNames={playerNames}
                    />
                </div>
            </div>
        </div>
    )
};

export default App;

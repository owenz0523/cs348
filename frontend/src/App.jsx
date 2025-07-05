import React, { act, useState }  from "react";
import NavBar from "./components/NavBar";
import PostGameQueryPanel from "./components/PostGameQueryPanel";
import InGameSearchPanel from "./components/InGameSearchPanel";
import TicTacToe from "./components/TicTacToe";

const App = () => {
    const [winner, setWinner] = useState(null);
    const [activeMove, setActiveMove] = useState(null);

    const [board, setBoard] = useState(
        Array.from({ length: 4 }, () => Array(4).fill(null))
    );
    const [turn, setTurn] = useState("X");
    const [hint, setHint] = useState([]);


    return (
        <div className="min-h-screen flex flex-col">
            <NavBar />
            <div className="flex flex-1">
            <div className="w-1/3 border-r border-gray-300">
                {winner && <PostGameQueryPanel />}         
                {activeMove && 
                <InGameSearchPanel 
                    activeMove={activeMove} setActiveMove={setActiveMove} 
                    board={board} setBoard={setBoard}
                    turn={turn} setTurn={setTurn} setHint={setHint}
                 />}                
            </div>
            <div className="flex-1">
                <TicTacToe winner={winner} setWinner={setWinner} 
                            board={board} setBoard={setBoard}
                            hint={hint} setHint={setHint}
                            setActiveMove={setActiveMove}
                />
            </div>
            </div>
        </div>
    )
};

export default App;

import React, { useState }  from "react";
import NavBar from "./components/NavBar";
import QueryPanel from "./components/QueryPanel";
import TicTacToe from "./components/TicTacToe";

const App = () => {
    const [winner, setWinner] = useState(null);

    return (
        <div className="min-h-screen flex flex-col">
            <NavBar />
            <div className="flex flex-1">
            <div className="w-1/3 border-r border-gray-300">
                {winner && <QueryPanel />}                
            </div>
            <div className="flex-1">
                <TicTacToe winner={winner} setWinner={setWinner} />
            </div>
            </div>
        </div>
    )
};

export default App;

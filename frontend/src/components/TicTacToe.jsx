import React, { useState, useEffect }  from "react";
import initBoard from "../lib/tictactoe/initBoard";
import getHint from "../lib/tictactoe/getHint";

const TicTacToe = (
    {winner, setWinner, playerStats, setPlayerStats, 
        board, setBoard, hint, setHint, activeMove, setActiveMove, turn, playerNames, playerStatsCache}
) => {
    // Add state to track hovered cell
    const [hoveredCell, setHoveredCell] = useState(null);

    useEffect(() => {
        const loadBoard = async () => {
            const initialBoard = await initBoard();
            setBoard(initialBoard);
        };
        loadBoard();
    }, []);
    
    // Check if board has a winner
    useEffect(() => {
        console.log(board);
        for(let i = 1; i <= 3; i++){
            if(board[i][1] && board[i][1] == board[i][2] && board[i][1] == board[i][3]){
                setWinner(board[i][1]);
                return;
            }
            if(board[1][i] && board[1][i] == board[2][i] && board[1][i] == board[3][i]){
                setWinner(board[1][i]);
                return;
            }
        }
        if(board[1][1] && board[1][1] == board[2][2] && board[1][1] == board[3][3]){
            setWinner(board[1][1]);
            return;
        }
        if(board[3][1] && board[3][1] == board[2][2] && board[3][1] == board[1][3]){
            setWinner(board[3][1]);
        }

        // Draw
        let free = 0;
        for(let i = 1; i <= 3; i++){
            for(let j = 1; j <= 3; j++){
                free += !board[i][j];
            }
        }
        if(!free){
            setWinner("Draw");
        }
    }, [board]);

    const shuffleArray = (array) => {
        for(let i = array.length - 1; i > 0; i--){
            const j = Math.floor(Math.random()*(i+1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        return array;
    }

    const handleClick = async (row, col) => {
        if(winner || row === 0 || col === 0 || board[row][col]){
            return;
        }
        setActiveMove({"row": row, "col": col});
    };

    const handleMenu = async (e, row, col) => {
        e.preventDefault();
        if (board[row][col]) {
            return;
        }
        const team1 = board[0][col];
        const team2 = board[row][0];
        const hintArray = await getHint(team1, team2);
        const shuffledHints = shuffleArray(hintArray);
        const hintPlayers = shuffledHints.map(p => p.pname);
        setHint(hintPlayers);

        let newPlayerStats = playerStats;
        newPlayerStats[turn].hints += 1;
        setPlayerStats(newPlayerStats)
    };

    return (
        <div className="p-4 flex flex-col items-center">
            <h2 className="text-lg font-semibold mb-4">NBA Tic Tac Toe</h2>
            <div className="grid grid-cols-4 gap-0">
                {board.map((row, rowIndex) =>
                    row.map((cell, colIndex) => (
                        <div
                            key={`${rowIndex}-${colIndex}`}
                            className={`w-20 h-20 border border-gray-400 flex items-center justify-center text-l font-bold cursor-pointer select-none relative group
                                ${rowIndex > 0 && colIndex > 0 ? "hover:bg-gray-100" : ""}
                                ${activeMove && rowIndex === activeMove.row && colIndex === activeMove.col ? "bg-blue-200 hover:bg-blue-100" : ""}
                            `}
                            onClick={() => handleClick(rowIndex, colIndex)}
                            onContextMenu={(e) => handleMenu(e, rowIndex, colIndex)}
                            onMouseEnter={() => setHoveredCell({ row: rowIndex, col: colIndex })}
                            onMouseLeave={() => setHoveredCell(null)}
                            >
                            {cell}
                        </div>
                    ))
                )}
            </div>

            {hoveredCell &&
                hoveredCell.row > 0 && hoveredCell.col > 0 &&
                playerNames[hoveredCell.row] && playerNames[hoveredCell.row][hoveredCell.col] && playerNames[hoveredCell.row][hoveredCell.col].pname && (
                    <div className="mt-4 p-2 border rounded bg-gray-50 text-sm text-gray-700 w-full max-w-md">
                        <h3 className="font-semibold mb-2">Random Player Stat of the Day!</h3>
                        <div className="font-medium mb-1">{playerNames[hoveredCell.row][hoveredCell.col].pname}</div>
                        {playerStatsCache && playerStatsCache[hoveredCell.row] && playerStatsCache[hoveredCell.row][hoveredCell.col] && (
                            <table className="w-full text-left">
                                <tbody>
                                    <tr className="border-t">
                                        <td className="pr-2 py-1 font-medium">Season:</td>
                                        <td className="py-1">{playerStatsCache[hoveredCell.row][hoveredCell.col].season}</td>
                                    </tr>
                                    <tr className="border-t">
                                        <td className="pr-2 py-1 font-medium">Stat:</td>
                                        <td className="py-1">{playerStatsCache[hoveredCell.row][hoveredCell.col].stat_name.toUpperCase()}</td>
                                    </tr>
                                    <tr className="border-t">
                                        <td className="pr-2 py-1 font-medium">Value:</td>
                                        <td className="py-1">{playerStatsCache[hoveredCell.row][hoveredCell.col].avg_stat}</td>
                                    </tr>
                                </tbody>
                            </table>
                        )}
                    </div>
                )
            }

            {hint.length > 0 && !winner &&
                <div className="mt-4 p-2 border rounded bg-gray-50 text-sm text-gray-700 w-full max-w-md">
                    <h3 className="font-semibold mb-2">Hint Players:</h3>
                    <ul className="list-disc list-inside">
                        {hint.map((name, index) => (
                            <li key={index} className="list-none">{name}</li>
                        ))}
                    </ul>
                </div>
            }

            {winner && (
                <div className="mt-4 p-4 border rounded bg-gray-50 text-sm text-gray-700 w-full max-w-md">
                    <h3 className="font-semibold mb-2">
                        {winner === "Draw" ? "Draw!" : "Winner!"}
                    </h3>
                    {winner !== "Draw" && <p>{`Player ${winner}`}</p>}

                    <button
                        onClick={() => window.location.reload()}
                        className="mt-4 px-4 py-2 bg-blue-500 text-white font-medium rounded hover:bg-blue-600 transition"
                        >
                        Play Again
                    </button>
                </div>
            )}
        </div>
    );
    
};

export default TicTacToe;

import React, { useState, useEffect }  from "react";
import initBoard from "../tictactoe/initBoard";
import getHint from "../tictactoe/getHint";

const TicTacToe = ({winner, setWinner, board, setBoard, hint, setHint, setActiveMove}) => {

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
    }, [board]);

    const handleClick = async (row, col) => {
        if(winner || row === 0 || col === 0 || board[row][col]){
            return;
        }
        setActiveMove({"row": row, "col": col});
    };

    const handleMenu = async (e, row, col) => {
        e.preventDefault();
        const team1 = board[0][col];
        const team2 = board[row][0];
        const hintArray = await getHint(team1, team2);
        const hintPlayers = hintArray.map(p => p.pname);
        setHint(hintPlayers);
    };

    return (
        <div className="p-4 flex flex-col items-center">
            <h2 className="text-lg font-semibold mb-4">NBA Tic Tac Toe</h2>
            <div className="grid grid-cols-4 gap-0">
                {board.map((row, rowIndex) =>
                    row.map((cell, colIndex) => (
                        <div
                            key={`${rowIndex}-${colIndex}`}
                            className={`w-20 h-20 border border-gray-400 flex items-center justify-center text-l font-bold cursor-pointer select-none ${
                                rowIndex > 0 && colIndex > 0 ? "hover:bg-gray-100" : ""
                            }`}
                            onClick={() => handleClick(rowIndex, colIndex)}
                            onContextMenu={(e) => handleMenu(e, rowIndex, colIndex)}
                        >
                            {cell}
                        </div>
                    ))
                )}
            </div>

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
                <div className="mt-4 p-2 border rounded bg-gray-50 text-sm text-gray-700 w-full max-w-md">
                    <h3 className="font-semibold mb-2">Winner!</h3>
                    {`Player ${winner}`}
                </div>
            )}
        </div>
    );
    
};

export default TicTacToe;

import React from "react";

const Instructions = () => {    
    return (
        <div className="p-4 border-r border-gray-300 flex flex-col">
            <h2 className="text-lg font-semibold mb-2">How to play NBA tic tac toe:</h2>
            <ul className="list-disc list-inside">
                <li key={1}>
                    NBA tic tac toe is a spinoff of{" "}
                    <a
                        href="https://playfootball.games/footy-tic-tac-toe/"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-500 hover:underline"
                    >
                        Tiki Taka Toe
                    </a>
                    , the football tic tac toe game
                </li>
                <li key={2}>A 3x3 grid is lined with random NBA teams along the rows and columns</li>
                <li key={3}>Each move X or O on a square may only be played by first entering
                    a player who has played for both the row and column teams within the last 10 years
                </li>
                <li key={4}>If you incorrectly enter a player who has not played for both teams, your turn
                    is skipped.
                </li>

                <li key={5}>Players can request hints by right clicking any square, which will prompt four 
                    players to be displayed as hints, of which only one has actually played for both teams
                </li>

                <li key={6}>The first player to connect three squares in a row, column, or diagonal wins. Have fun playing!
                </li>
            </ul>
            <br></br>
            <h2 className="text-lg font-semibold mb-2">Post Game:</h2>
            <ul className="list-disc list-inside">
                <li key={3}>Hovering over any played square will generate a random fun fact about that
                    NBA player's stats
                </li>
                <li key={4}>After a game ends, you can query more about players who have played for
                    any two NBA teams in the past 10 years
                </li>
            </ul>
        </div>
    )
};

export default Instructions;

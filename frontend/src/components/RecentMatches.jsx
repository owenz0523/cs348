import React, { useEffect, useState } from 'react';
import getHistory from '../lib/recent_matches/get_history';

const RecentMatches = ({pendingMatch, setPendingMatch}) => {
  const [matches, setMatches] = useState([]);

  useEffect(() => {
    if(!pendingMatch){
        return;
    }
    const fetchHistory = async () => {
      try {
        const data = await getHistory();
        console.log(data)
        setMatches(data);
        setPendingMatch(false);
      } catch (error) {
        console.error("Failed to fetch match history:", error);
      }
    };
    fetchHistory();
  }, [pendingMatch]);

  return (
    <div className="bg-white p-6 w-full max-w-md mx-auto">
        <h2 className="text-2xl font-bold mb-4 text-gray-800">Recent Matches</h2>
        {matches.length === 0 ? (
        <p className="text-gray-500 text-sm">No matches found.</p>
        ) : (
        <ul className="divide-y divide-gray-200">
            {[...matches].reverse().map((match, index) => {
            const isDraw = match.result.toLowerCase().includes("draw");
            const isP1Win = match.result.toLowerCase().includes("p1");
            const isP2Win = match.result.toLowerCase().includes("p2");

            const p1Color = isDraw
                ? "text-yellow-500"
                : isP1Win
                ? "text-green-600"
                : "text-red-600";

            const p2Color = isDraw
                ? "text-yellow-500"
                : isP2Win
                ? "text-green-600"
                : "text-red-600";

            return (
                <li key={index} className="py-3">
                <p className="text-sm text-gray-500 mb-1">
                    {new Date(match.played_at).toLocaleString()}
                </p>

                <div className="text-sm text-gray-600 space-y-1">
                    <p className={`font-semibold ${p1Color}`}>Player X</p>
                    Hints: {match.p1_stats.hints_used}, Correct: {match.p1_stats.correct_guesses}, Incorrect: {match.p1_stats.incorrect_guesses}
                    <p className={`font-semibold ${p2Color}`}>Player O</p>
                    Hints: {match.p2_stats.hints_used}, Correct: {match.p2_stats.correct_guesses}, Incorrect: {match.p2_stats.incorrect_guesses}
                </div>
                </li>
            );
            })}
        </ul>
        )}
    </div>
    );


};

export default RecentMatches;

import React, { useEffect, useState } from 'react';
import getHistory from '../lib/recent_matches/get_history';
import checkWinstreak from '../lib/recent_matches/check_winstreak';

const RecentMatches = ({pendingMatch, setPendingMatch}) => {
  const [matches, setMatches] = useState([]);
  const [winstreak, setWinstreak] = useState(null);
  const playerMap = {
    "P1 Win": 'X',
    "P2 Win": 'O'
  };

  useEffect(() => {
    // rerender match history and winstreak if there is a new match that was inserted
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
    const fetchWinstreak = async () => {
      try {
        const data = await checkWinstreak();
        console.log(data)
        setWinstreak(data);
      } catch (error) {
        console.error("Failed to fetch winstreak history:", error);
      }
    };
    fetchHistory();
    fetchWinstreak();
  }, [pendingMatch]);

  return (
    <div className="bg-white p-6 w-full max-w-md mx-auto h-full overflow-y-auto">
        <h2 className="text-2xl font-bold mb-4 text-gray-800">Recent Matches</h2>
        {matches.length === 0 ? (
        <p className="text-gray-500 text-sm">No matches found.</p>
        ) : (
        <div>
          {/* win streak */}
          {winstreak && (winstreak.message ? (
            <></>
            // <p className="text-gray-600 text-sm mb-2">{winstreak.message}</p>
          ) : (
            <p className="text-transparent bg-clip-text bg-gradient-to-r from-orange-500 via-red-500 to-red-700 animate-pulse text-sm mb-2">
              Player {playerMap[winstreak.player_result]} is on a {winstreak.streak_count} game win streak!
            </p>
          ))}
          
          {/* match list */}
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
        </div>
        )}
    </div>
    );


};

export default RecentMatches;

-- Retrieve match history from the database and format player 1 and player 2 stats as JSON objects.
WITH json_stats AS ( -- Group player 1 and player 2 stats into JSON objects
    SELECT
        mid,
        player_role,
        json_build_object( -- Build JSON from match_player_stats
            'correct_guesses', correct_guesses,
            'incorrect_guesses', incorrect_guesses,
            'hints_used', hints_used
        ) AS stats_json
    FROM match_player_stats
)
SELECT
    mh.*,
    p1.stats_json AS p1_stats,
    p2.stats_json AS p2_stats
FROM match_history mh
LEFT JOIN json_stats p1 ON p1.mid = mh.mid AND p1.player_role = 'P1' -- Get player 1 stats as JSON
LEFT JOIN json_stats p2 ON p2.mid = mh.mid AND p2.player_role = 'P2' -- Get player 2 stats as JSON
ORDER BY mh.played_at;
-- Trigger that checks for a 3+ win streak in match history and updates the current_win_streak table
DROP TRIGGER IF EXISTS check_match_win_streak ON match_history;

CREATE OR REPLACE FUNCTION check_win_streak_notify()
RETURNS TRIGGER AS $$
DECLARE
    streak_count INTEGER;
    player_result TEXT;
BEGIN
    WITH latest_result AS (
        SELECT result
        FROM match_history
        ORDER BY played_at DESC
        LIMIT 1
    ),
    candidate_matches AS (
        SELECT mh1.*
        FROM match_history mh1
        JOIN latest_result lr ON mh1.result = lr.result
        LEFT JOIN match_history mh2 -- Merge mh2 with mh1 on conditions that mh2's matches have a later timestamp than mh1's and a different result.
            ON mh2.played_at > mh1.played_at
            AND mh2.result != mh1.result
        WHERE mh2.result IS NULL -- Since it is a left join, mh1 results that have no later matches with a different result will have null in mh2.result. This will give us our win streak matches.
    )
    SELECT result, COUNT(*) AS streak
    INTO player_result, streak_count
    FROM candidate_matches
    GROUP BY result;

    -- Always clear the table first
    DELETE FROM current_win_streak;

    -- If it's a 3+ win streak and not a draw, insert the row
    IF streak_count >= 3 AND player_result != 'Draw' THEN
        INSERT INTO current_win_streak (player_result, streak_count)
        VALUES (player_result, streak_count);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on match_history table
CREATE TRIGGER check_match_win_streak
AFTER INSERT ON match_history
FOR EACH STATEMENT
EXECUTE FUNCTION check_win_streak_notify();
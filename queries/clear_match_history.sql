-- Before storing a new match result, clear match history if the last match was played more than 1 hour ago
DROP TRIGGER IF EXISTS clear_match_history ON match_history;

CREATE OR REPLACE FUNCTION remove_old_matches()
RETURNS TRIGGER AS $$
DECLARE
    last_played TIMESTAMP; -- Will store the latest timestamp in match_history
BEGIN
    SELECT MAX(played_at) INTO last_played FROM match_history; -- Get max timestamp

    IF last_played < CURRENT_TIMESTAMP - INTERVAL '1 hour' THEN -- If the latest match is older than 1 hour
        DELETE FROM match_history; -- Clear the match_history table
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clear_match_history
BEFORE INSERT ON match_history
FOR EACH STATEMENT -- Delete should only occur once
EXECUTE FUNCTION remove_old_matches();
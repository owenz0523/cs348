-- Given info for one match, insert match result and player stats into their respective tables
BEGIN; -- Start of transaction

-- Insert match result and get the generated match ID
WITH inserted_match AS (
    INSERT INTO match_history (result)
    VALUES (%s) -- 'P1 Win', 'P2 Win', or 'Draw'
    RETURNING mid
)

-- Insert both player stats using the returned match ID
INSERT INTO match_player_stats (mid, player_role, correct_guesses, incorrect_guesses, hints_used)
SELECT
    mid, %s, %s, %s, %s -- e.g. 'P1', 5, 2, 1
FROM inserted_match
UNION ALL
SELECT
    mid, %s, %s, %s, %s -- e.g. 'P2', 4, 2, 0
FROM inserted_match;

-- Commit transaction
COMMIT;
-- Given a player ID (pid) and two team IDs (tid1, tid2), check if the player has played for both teams historically.
SELECT 1
WHERE EXISTS (
    SELECT 1
    FROM plays_for
    WHERE pid = %s AND tid = %s
) AND EXISTS (
    SELECT 1
    FROM plays_for
    WHERE pid = %s AND tid = %s
)
LIMIT 1;
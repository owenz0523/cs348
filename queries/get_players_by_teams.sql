-- Given two team IDs (tid1, tid2), get all players who have played for both teams historically.
SELECT DISTINCT p.pid AS pid, p.pname AS pname
FROM plays_for pf
INNER JOIN players p ON p.pid = pf.pid
WHERE EXISTS (
    SELECT 1
    FROM plays_for pf1
    WHERE pf1.pid = pf.pid AND pf1.tid = %s -- tid1
) AND EXISTS (
    SELECT 1
    FROM plays_for pf2
    WHERE pf2.pid = pf.pid AND pf2.tid = %s -- tid2
);
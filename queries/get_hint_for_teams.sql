-- Given two team IDs (tid1, tid2), retrieve one player who has played for both teams historically, and three players who have played for only one of the teams.
-- If there are less than three players who have played for only one of the teams, make up the difference with players who have played for none of those teams.
WITH players_both_teams AS (
    SELECT pid, pname, 1 AS table_order
    FROM (
        SELECT DISTINCT p.pid, p.pname
        FROM plays_for pf
        INNER JOIN players p ON p.pid = pf.pid
        WHERE pf.tid = %s -- tid1
        AND EXISTS (
            SELECT 1
            FROM plays_for pf1
            WHERE pf1.pid = pf.pid AND pf1.tid = %s -- tid2
        )
    ) AS subquery
    ORDER BY random()
    LIMIT 1 -- Get one player who has played for both teams
),
players_one_team AS (
    SELECT pid, pname, 2 AS table_order
    FROM (
        SELECT DISTINCT p.pid, p.pname
        FROM plays_for pf
        INNER JOIN players p ON p.pid = pf.pid
        WHERE (pf.tid = %s -- tid1
        AND NOT EXISTS (
            SELECT 1
            FROM plays_for pf1
            WHERE pf1.pid = pf.pid AND pf1.tid = %s -- tid2
        ))
        OR (pf.tid = %s -- tid2
        AND NOT EXISTS (
            SELECT 1
            FROM plays_for pf1
            WHERE pf1.pid = pf.pid AND pf1.tid = %s -- tid1
        )) 
    ) AS subquery
    ORDER BY random()
    LIMIT 3 -- Get up to three players who have played for only one of the teams
),
players_none_teams AS (
    SELECT pid, pname, 3 AS table_order
    FROM (
        SELECT DISTINCT p.pid, p.pname
        FROM players p
        WHERE NOT EXISTS (
            SELECT 1
            FROM plays_for pf
            WHERE pf.pid = p.pid AND pf.tid IN (%s, %s) -- tid1, tid2 (Exclude players who have played for either team)
        )
    ) AS subquery
    ORDER BY random()
    LIMIT 3 -- Get up to three players who have played for none of the teams
),
combined_players AS (
    SELECT pid, pname, table_order
    FROM players_both_teams
    UNION ALL
    SELECT pid, pname, table_order
    FROM players_one_team
    UNION ALL
    SELECT pid, pname, table_order
    FROM players_none_teams
)
SELECT pid, pname, table_order
FROM combined_players
ORDER BY table_order
LIMIT 4;
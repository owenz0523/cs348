-- sample SQL queries on local database

-- check if tables exist and have data
SELECT 'Players table count:' AS info, COUNT(*) AS count FROM players;
SELECT 'Teams table count:' AS info, COUNT(*) AS count FROM teams;
SELECT 'Plays_for table count:' AS info, COUNT(*) AS count FROM plays_for;
SELECT 'Games table count:' AS info, COUNT(*) AS count FROM games;
SELECT 'Box_score table count:' AS info, COUNT(*) AS count FROM box_score;

-- testing teams table
SELECT 'Available teams for testing:' AS test_description;
SELECT tid, tname FROM teams LIMIT 5;

-- testing games table
SELECT 'Testing game statistics' AS test_description;
SELECT 
    g.gid,
    g.season,
    g.game_date,
    ht.tname AS home_team,
    at.tname AS away_team,
    g.winner,
    g.game_type
FROM games g
LEFT JOIN teams ht ON g.tid_home = ht.tid
LEFT JOIN teams at ON g.tid_away = at.tid
ORDER BY g.game_date DESC
LIMIT 5;

-- test box scores table
SELECT 'Testing box score statistics' AS test_description;
SELECT 
    p.pname,
    bs.mins,
    bs.pts,
    bs.reb,
    bs.ast,
    bs.stl,
    bs.blk,
    bs.tov,
    bs.plus_minus
FROM box_score bs
JOIN players p ON bs.pid = p.pid
ORDER BY bs.pts DESC
LIMIT 10;

-- testing plays for table
SELECT 'Testing plays for table' AS test_description;
SELECT pid, tid, season FROM plays_for LIMIT 5;


-- testing name prefix search
SELECT 'Testing player search by prefix (LeBron)' AS test_description;
SELECT pid, pname FROM players WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT pid, pname, regexp_split_to_array(lower(replace(pname, '-', ' ')), '\s+') AS names
        FROM players
    ) split_names,
    LATERAL (
        SELECT array_to_string(names[name_index:array_length(names, 1)], ' ') AS term
        FROM generate_subscripts(split_names.names, 1) AS name_index
    ) names_search_terms
    WHERE split_names.pid = players.pid
    AND term LIKE 'lebron%'
);

-- testing get players by teams
SELECT 'Testing players by teams' AS test_description;
WITH team_pair AS (
    SELECT tid FROM teams LIMIT 2
),
team1 AS (SELECT tid FROM team_pair LIMIT 1),
team2 AS (SELECT tid FROM team_pair OFFSET 1)
SELECT DISTINCT p.pid AS pid, p.pname AS pname
FROM plays_for pf
CROSS JOIN team1 t1
CROSS JOIN team2 t2
INNER JOIN players p ON p.pid = pf.pid
WHERE pf.tid = t1.tid
AND EXISTS (
    SELECT 1
    FROM plays_for pf1
    WHERE pf1.pid = pf.pid AND pf1.tid = t2.tid
);

-- testing check if player played for both teams
SELECT 'Testing check if player played for both teams' AS test_description;
WITH sample_player AS (
    SELECT pid, pname FROM players LIMIT 1
),
sample_teams AS (
    SELECT tid FROM teams LIMIT 2
),
team1 AS (SELECT tid FROM sample_teams LIMIT 1),
team2 AS (SELECT tid FROM sample_teams OFFSET 1)
SELECT 
    p.pid,
    p.pname,
    t1.tid AS tid1,
    t2.tid AS tid2,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM plays_for pf1 
            WHERE pf1.pid = p.pid AND pf1.tid = t1.tid
        ) AND EXISTS (
            SELECT 1 FROM plays_for pf2 
            WHERE pf2.pid = p.pid AND pf2.tid = t2.tid
        ) THEN 'Yes'
        ELSE 'No'
    END AS played_for_both
FROM sample_player p, team1 t1, team2 t2;

-- testing hint generation
SELECT 'Testing hint generation' AS test_description;
WITH team_pair AS (
    SELECT tid FROM teams LIMIT 2
),
team1 AS (SELECT tid FROM team_pair LIMIT 1),
team2 AS (SELECT tid FROM team_pair OFFSET 1),

players_both_teams AS (
    SELECT pid, pname, 1 AS table_order
    FROM (
        SELECT DISTINCT p.pid, p.pname
        FROM plays_for pf
        INNER JOIN players p ON p.pid = pf.pid, team1 t1, team2 t2
        WHERE pf.tid = t1.tid
        AND EXISTS (
            SELECT 1
            FROM plays_for pf1
            WHERE pf1.pid = pf.pid AND pf1.tid = t2.tid
        )
    ) AS played_for_both_teams
    ORDER BY random()
    LIMIT 1
),

players_one_team AS (
    SELECT pid, pname, 2 AS table_order
    FROM (
        SELECT DISTINCT p.pid, p.pname
        FROM plays_for pf
        INNER JOIN players p ON p.pid = pf.pid, team1 t1, team2 t2
        WHERE (pf.tid = t1.tid
        AND NOT EXISTS (
            SELECT 1
            FROM plays_for pf1
            WHERE pf1.pid = pf.pid AND pf1.tid = t2.tid
        ))
        OR (pf.tid = t2.tid
        AND NOT EXISTS (
            SELECT 1
            FROM plays_for pf1
            WHERE pf1.pid = pf.pid AND pf1.tid = t1.tid
        ))
    ) as played_for_one_team
    ORDER BY random()
    LIMIT 3
),

players_none_teams AS (
    SELECT pid, pname, 3 AS table_order
    FROM (
        SELECT DISTINCT p.pid, p.pname
        FROM players p, team1 t1, team2 t2
        WHERE NOT EXISTS (
            SELECT 1
            FROM plays_for pf
            WHERE pf.pid = p.pid AND pf.tid IN (t1.tid, t2.tid)
        )
    ) as played_for_none_teams
    ORDER BY random()
    LIMIT 3
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
SELECT 
    pid, 
    pname, 
    CASE 
        WHEN table_order = 1 THEN 'Both Teams'
        WHEN table_order = 2 THEN 'One Team'
        WHEN table_order = 3 THEN 'Neither Team'
    END AS hint_category,
    table_order
FROM combined_players
ORDER BY table_order
LIMIT 4;

-- testing generate match rows and columns
SELECT 'Testing generate match rows and columns' AS test_description;
WITH valid_pairs AS (
    SELECT DISTINCT
        LEAST(p1.tid, p2.tid) AS t1,
        GREATEST(p1.tid, p2.tid) AS t2
    FROM plays_for p1
    JOIN plays_for p2 ON p1.pid = p2.pid AND p1.tid <> p2.tid
),
adjacency AS (
    SELECT t1 AS team, t2 AS neighbor FROM valid_pairs
    UNION ALL
    SELECT t2 AS team, t1 AS neighbor FROM valid_pairs
),
sampled_rows AS (
    SELECT team FROM (
        SELECT DISTINCT team
        FROM adjacency
    ) AS subquery
    ORDER BY random()
    LIMIT 5
),
sampled_columns AS (
    SELECT team FROM (
        SELECT DISTINCT team
        FROM adjacency
        WHERE team NOT IN (SELECT team FROM sampled_rows)
    ) AS subquery
    ORDER BY random()
    LIMIT 10
),
row_teams AS (
    SELECT r1.team AS r1, r2.team AS r2, r3.team AS r3
    FROM sampled_rows r1
    JOIN sampled_rows r2 ON r1.team < r2.team
    JOIN sampled_rows r3 ON r2.team < r3.team
),
column_teams AS (
    SELECT c1.team AS c1, c2.team AS c2, c3.team AS c3
    FROM sampled_columns c1
    JOIN sampled_columns c2 ON c1.team < c2.team
    JOIN sampled_columns c3 ON c2.team < c3.team
)
SELECT rt.r1, rt.r2, rt.r3, ct.c1, ct.c2, ct.c3
FROM row_teams rt
CROSS JOIN column_teams ct
WHERE
    (LEAST(rt.r1, ct.c1), GREATEST(rt.r1, ct.c1)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r1, ct.c2), GREATEST(rt.r1, ct.c2)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r1, ct.c3), GREATEST(rt.r1, ct.c3)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r2, ct.c1), GREATEST(rt.r2, ct.c1)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r2, ct.c2), GREATEST(rt.r2, ct.c2)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r2, ct.c3), GREATEST(rt.r2, ct.c3)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r3, ct.c1), GREATEST(rt.r3, ct.c1)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r3, ct.c2), GREATEST(rt.r3, ct.c2)) IN (SELECT t1, t2 FROM valid_pairs)
    AND (LEAST(rt.r3, ct.c3), GREATEST(rt.r3, ct.c3)) IN (SELECT t1, t2 FROM valid_pairs)
LIMIT 1;


-- testing match history sequence (insert, get, clear trigger)
SELECT 'Testing match history sequence' AS test_description;

DELETE FROM match_player_stats;
DELETE FROM match_history;

DROP TRIGGER IF EXISTS clear_match_history ON match_history;

CREATE OR REPLACE FUNCTION remove_old_matches()
RETURNS TRIGGER AS $$
DECLARE
    last_played TIMESTAMP;
BEGIN
    SELECT MAX(played_at) INTO last_played FROM match_history;

    IF last_played < CURRENT_TIMESTAMP - INTERVAL '1 hour' THEN
        DELETE FROM match_history;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clear_match_history
BEFORE INSERT ON match_history
FOR EACH STATEMENT
EXECUTE FUNCTION remove_old_matches();

INSERT INTO match_history (result, played_at) VALUES ('Draw', CURRENT_TIMESTAMP - INTERVAL '2 hours');
WITH draw_match AS (
    SELECT mid FROM match_history WHERE result = 'Draw' ORDER BY mid DESC LIMIT 1
)
INSERT INTO match_player_stats (mid, player_role, correct_guesses, incorrect_guesses, hints_used)
SELECT mid, 'P1', 1, 1, 0 FROM draw_match
UNION ALL
SELECT mid, 'P2', 1, 1, 0 FROM draw_match;

BEGIN;
WITH inserted_match AS (
    INSERT INTO match_history (result)
    VALUES ('P1 Win')
    RETURNING mid
)
INSERT INTO match_player_stats (mid, player_role, correct_guesses, incorrect_guesses, hints_used)
SELECT
    mid, 'P1', 5, 2, 1
FROM inserted_match
UNION ALL
SELECT
    mid, 'P2', 4, 2, 0
FROM inserted_match;
COMMIT;

WITH json_stats AS (
    SELECT
        mid,
        player_role,
        json_build_object(
            'correct_guesses', correct_guesses,
            'incorrect_guesses', incorrect_guesses,
            'hints_used', hints_used
        ) AS stats_json
    FROM match_player_stats
)
SELECT
    mh.mid,
    mh.result,
    mh.played_at,
    p1.stats_json AS p1_stats,
    p2.stats_json AS p2_stats
FROM match_history mh
LEFT JOIN json_stats p1 ON p1.mid = mh.mid AND p1.player_role = 'P1'
LEFT JOIN json_stats p2 ON p2.mid = mh.mid AND p2.player_role = 'P2'
ORDER BY mh.played_at;
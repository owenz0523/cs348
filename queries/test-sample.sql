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
-- sample SQL queries on local database

-- check if tables exist and have data
SELECT 'Players table count:' AS info, COUNT(*) AS count FROM players;
SELECT 'Teams table count:' AS info, COUNT(*) AS count FROM teams;
SELECT 'Plays_for table count:' AS info, COUNT(*) AS count FROM plays_for;
SELECT 'Games table count:' AS info, COUNT(*) AS count FROM games;
SELECT 'Box_score table count:' AS info, COUNT(*) AS count FROM box_score;

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

-- testing players who played for both teams check
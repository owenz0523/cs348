-- Generate a valid set of 3 rows and 3 columns for the tic-tac-toe table, ensuring that all row-column pairs have at least one player who has played for both teams.
WITH valid_pairs AS ( -- Used for checking for validity of row-column pairs
    SELECT DISTINCT
        LEAST(p1.tid, p2.tid) AS t1,
        GREATEST(p1.tid, p2.tid) AS t2
    FROM plays_for p1
    JOIN plays_for p2 ON p1.pid = p2.pid AND p1.tid <> p2.tid -- Ensure there is at least one player who has played for both teams
),
adjacency AS ( -- Same as valid_pairs but includes the reverse pairs, which is useful for random selection
    SELECT t1 AS team, t2 AS neighbor FROM valid_pairs
    UNION ALL
    SELECT t2 AS team, t1 AS neighbor FROM valid_pairs
),
sampled_rows AS ( -- Randomly sample 5 distinct row teams
    SELECT team FROM (
        SELECT DISTINCT team
        FROM adjacency
    )
    ORDER BY random()
    LIMIT 5
),
sampled_columns AS ( -- Randomly sample 10 distinct column teams, excluding those already sampled as rows
    SELECT team FROM (
        SELECT DISTINCT team
        FROM adjacency
        WHERE team NOT IN (SELECT team FROM sampled_rows)
    )
    ORDER BY random()
    LIMIT 10
),
row_teams AS ( -- Generate row triples from sampled rows
    SELECT r1.team AS r1, r2.team AS r2, r3.team AS r3
    FROM sampled_rows r1
    JOIN sampled_rows r2 ON r1.team < r2.team
    JOIN sampled_rows r3 ON r2.team < r3.team
),
column_teams AS ( -- Generate column triples from sampled columns
    SELECT c1.team AS c1, c2.team AS c2, c3.team AS c3
    FROM sampled_columns c1
    JOIN sampled_columns c2 ON c1.team < c2.team
    JOIN sampled_columns c3 ON c2.team < c3.team
)
SELECT rt.r1, rt.r2, rt.r3, ct.c1, ct.c2, ct.c3 -- Join row triples and column triples and validate using valid_pairs
FROM row_teams rt
CROSS JOIN column_teams ct
WHERE -- Check all 9 pairs exist in valid_pairs (using LEAST/GREATEST to match pair ordering)
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
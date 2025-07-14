-- Given a player ID (pid), retrieve their best season in a randomly selected statistic.
-- The newly selected statistic excludes the most recent statistic that this query has selected.
BEGIN;
 
DELETE FROM random_stat; -- Clear the randomly selected stat from last query

WITH ordered_last AS ( -- Get the most recent stat
    SELECT stat
    FROM last_displayed_stats
    ORDER BY last_displayed DESC -- Sort by the row timestamp
    LIMIT 1
)
INSERT INTO random_stat -- Store the randomly selected stat
SELECT *
FROM ( -- Turnovers are better to be lower, so we order them ascending, rest are descending
    VALUES ('pts', 'desc'), ('reb', 'desc'), ('ast', 'desc'), ('stl', 'desc'), ('blk', 'desc'), ('tov', 'asc'), ('ft', 'desc'), ('fg', 'desc'), ('fg3', 'desc')
) AS stat_directions(stat_name, sort_direction)
WHERE stat_name NOT IN (SELECT stat FROM ordered_last) -- Can't select the same stat as last time
ORDER BY random()
LIMIT 1;

-- Delete the existing row for randomly selected stat (if any)
DELETE FROM last_displayed_stats
WHERE stat IN (SELECT stat_name FROM random_stat);

-- Insert new row for that stat with current timestamp
INSERT INTO last_displayed_stats (stat)
SELECT stat_name FROM random_stat;

COMMIT;

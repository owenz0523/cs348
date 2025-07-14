-- Get the player's best season in the chosen stat
WITH player_season_stats AS (
    SELECT
        g.season,
        rs.stat_name,
        rs.sort_direction,
        ROUND(AVG( -- Get average of chosen stat for that season
            CASE rs.stat_name
                WHEN 'pts' THEN b.pts
                WHEN 'reb' THEN b.reb
                WHEN 'ast' THEN b.ast
                WHEN 'stl' THEN b.stl
                WHEN 'blk' THEN b.blk
                WHEN 'tov' THEN b.tov
                WHEN 'ft' THEN b.ft
                WHEN 'fg' THEN b.fg
                WHEN 'fg3' THEN b.fg3
            END
        )::NUMERIC, 2) AS avg_stat
    FROM box_score b
    INNER JOIN games g ON b.gid = g.gid
    CROSS JOIN random_stat rs -- Chosen stat
    WHERE b.pid = %s -- Player we are querying
    GROUP BY g.season, rs.stat_name, rs.sort_direction -- Group by season
)
SELECT season, stat_name, avg_stat
FROM player_season_stats
ORDER BY
    CASE WHEN sort_direction = 'desc' THEN avg_stat END DESC, -- Evaluates to null if sort_direction is 'asc'
    CASE WHEN sort_direction = 'asc' THEN avg_stat END ASC
LIMIT 1;
-- Delete
DROP DATABASE nba_stats;
-- Init
CREATE DATABASE nba_stats;
\c nba_stats
\i queries/init/schema.sql   
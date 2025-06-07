-- Delete
DROP DATABASE nba_stats;
-- Init
CREATE DATABASE nba_stats;
\c nba_stats
CREATE EXTENSION IF NOT EXISTS unaccent;
\i queries/init/schema.sql   
CREATE TABLE players (
    pid TEXT PRIMARY KEY,
    pname TEXT
);

CREATE TABLE teams (
    tid TEXT PRIMARY KEY,
    tname TEXT
);

CREATE TABLE plays_for (
    pid TEXT,
    tid TEXT,
    season INT,
    PRIMARY KEY (pid, tid, season),
    FOREIGN KEY (pid) REFERENCES players(pid) ON DELETE CASCADE,
    FOREIGN KEY (tid) REFERENCES teams(tid) ON DELETE CASCADE
);


CREATE TABLE games (
    gid SERIAL PRIMARY KEY,
    season INT, 
    game_date DATE,
    tid_home TEXT,
    tid_away TEXT,
    winner TEXT,
    game_type TEXT
);

CREATE TABLE box_score (
    pid TEXT,
    gid INT, 
    mins INT,
    pts INT,
    reb INT,
    ast INT,
    stl INT,
    blk INT,
    tov INT,
    fta INT,
    ft INT,
    fga INT,
    fg INT,
    fg3a INT,
    fg3 INT,
    plus_minus FLOAT,
    PRIMARY KEY (pid, gid),
    FOREIGN KEY (pid) REFERENCES players(pid) ON DELETE CASCADE,
    FOREIGN KEY (gid) REFERENCES games(gid) ON DELETE CASCADE
);
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
    game_type TEXT,
    FOREIGN KEY (tid_home) REFERENCES teams(tid) ON DELETE CASCADE,
    FOREIGN KEY (tid_away) REFERENCES teams(tid) ON DELETE CASCADE,
    FOREIGN KEY (winner) REFERENCES teams(tid) ON DELETE CASCADE,
    CHECK (tid_home != tid_away AND (winner = tid_home OR winner = tid_away))
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

CREATE TABLE match_history (
    mid SERIAL PRIMARY KEY,
    result TEXT CHECK (result IN ('P1 Win', 'P2 Win', 'Draw')),
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE match_player_stats (
    mid INT REFERENCES match_history(mid) ON DELETE CASCADE,
    player_role TEXT CHECK (player_role IN ('P1', 'P2')),
    correct_guesses INT,
    incorrect_guesses INT,
    hints_used INT,
    PRIMARY KEY (mid, player_role)
);
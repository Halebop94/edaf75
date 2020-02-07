CREATE TABLE THEATRE (
    name TEXT,
    capacity INTEGER,
    PRIMARY KEY (name)
);

CREATE TABLE SCREENINGS (
    start_time INTEGER,
    theatre TEXT,
    movie TEXT,
    FOREIGN KEY (theatre) REFERENCES THEATRE(name),
    FOREIGN KEY (movie) REFERENCES MOVIES(imdb_key),
    PRIMARY KEY (start_time)
)

CREATE TABLE MOVIES (
    title TEXT,
    p_year TEXT,
    imdb_key TEXT,
    runtime TEXT
    PRIMARY KEY (imdb_key)
)


CREATE TABLE TICKETS (
    uuid TEXT DEFAULT (LOWER(HEX(RANDOMBLOB(16)))),
    screening INTEGER,
    FOREIGN KEY (screening) REFERENCES SCREENINGS(start_time),
    PRIMARY KEY (uuid)
)

CREATE TABLE CUSTOMERS (
    username TEXT,
    full_name TEXT,
    password TEXT,
    PRIMARY KEY (username)
)
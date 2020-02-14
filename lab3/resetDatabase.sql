-- Delete the tables if they exist.
-- Disable foreign key checks, so the tables can
-- be dropped in arbitrary order.
PRAGMA foreign_keys=OFF;

DROP TABLE IF EXISTS THEATRES;
DROP TABLE IF EXISTS SCREENINGS;
DROP TABLE IF EXISTS MOVIES;
DROP TABLE IF EXISTS TICKETS;
DROP TABLE IF EXISTS CUSTOMERS;

PRAGMA foreign_keys=ON;

--Create tables
CREATE TABLE THEATRES (
    theatre_name TEXT,
    capacity INTEGER,
    PRIMARY KEY (theatre_name)
);

CREATE TABLE SCREENINGS (
    uuid TEXT DEFAULT (LOWER(HEX(RANDOMBLOB(16)))),
    showing_date DATE,
    start_time TIME,
    theatre_name TEXT,
    imdb_key TEXT,
    max_seats INTEGER,
    FOREIGN KEY (theatre_name) REFERENCES THEATRES(theatre_name),
    FOREIGN KEY (imdb_key) REFERENCES MOVIES(imdb_key),
    PRIMARY KEY (uuid)
);

CREATE TABLE MOVIES (
    imdb_key TEXT,
    title TEXT,
    p_year DATE,
    runtime TEXT,
    PRIMARY KEY (imdb_key)
);

CREATE TABLE TICKETS (
    uuid TEXT DEFAULT (LOWER(HEX(RANDOMBLOB(16)))),
    screening TEXT,
    username TEXT,
    FOREIGN KEY (screening) REFERENCES SCREENINGS(uuid),
    FOREIGN KEY (username) REFERENCES CUSTOMERS(username),
    PRIMARY KEY (uuid)
);

CREATE TABLE CUSTOMERS (
    username TEXT,
    full_name TEXT,
    password TEXT,
    PRIMARY KEY (username)
);

-- Insert data into tables.

INTO THEATRES(name, capacity)
VALUES  ("Kino", 10),
        ("Södran", 16),
        ("Skandia", 100);

INSERT
INTO MOVIES(imdb_key, title, p_year, runtime)
VALUES  ("tt5580390", "The Shape of Water", '2017', "1h 43min"),
        ("tt4975722", "Moonlight", '2016', "1h 39min"),
        ("tt1895587", "Spotlight", '2015', "2h 32min"),
        ("tt2562232", "Birdman", '2014', "2h 18min")
;

INSERT
INTO CUSTOMERS(username, full_name, password)
VALUES  ("alice", "Alice", "dobido"),
        ("bob", "Bob", "whatsinaname");

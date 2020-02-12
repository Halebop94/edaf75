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
    FOREIGN KEY (username) REFERENCES CUSTOMERS (username),
    PRIMARY KEY (uuid)
);

CREATE TABLE CUSTOMERS (
    username TEXT,
    full_name TEXT,
    password TEXT,
    PRIMARY KEY (username)
);

-- Insert data into tables.

INSERT 
INTO THEATRES(theatre_name, capacity)
VALUES  ("Filmstaden Lund", 120),
        ("Filmstaden Malmö", 200),
        ("Filmstaden Hötorget", 1000);

INSERT 
INTO MOVIES(imdb_key, title, p_year, runtime)
VALUES  ("tt4520988", "Frozen 2", '2019', "1h 43min"),
        ("tt0105236", "Reservoir Dogs", '1992', "1h 39min"),
        ("tt2527336", "Star Wars: Episode VIII - The Last Jedi", '2017', "2h 32min"),
        ("tt0373889", "Harry Potter and the Order of the Phoenix", '2007', "2h 18min"),
        ("tt0167260", "The Lord of the Rings: The Return of the King", '2003', "3h 21min")
;
INSERT 
INTO SCREENINGS(uuid, showing_date, start_time, theatre_name, imdb_key, max_seats)
VALUES  ("3e532c11625236c837738609f09cb76e", '2020-03-01', '19:00', "Filmstaden Lund", "tt4520988", 40),
        ("556e29358e83c1e0d0605741aba2b613", '2020-03-01', '19:00', "Filmstaden Malmö", "tt0105236", 100),
        ("f9c35f6db48b446dc3caf6d80e941479", '2020-03-01', '01:00', "Filmstaden Malmö", "tt2527336", 100),
        ("74bcbb492ba1b129ae28c5b0d2263c97", '2020-03-01', '10:00', "Filmstaden Hötorget", "tt0373889", 100),
        ("df20a592ffb474ff6493a7d1319e8972", '2020-03-01', '19:00', "Filmstaden Hötorget", "tt2527336", 300),
        ("e27d9de6f564b3aa55b82cc947555c9b", '2020-03-03', '23:00', "Filmstaden Hötorget", "tt0167260", 200)
;

INSERT 
INTO CUSTOMERS(username, full_name, password)
VALUES  ("halebop94", "Hanna Höjbert", "123456"),
        ("frednordell", "Fred Nordell", "123456")
;

INSERT 
INTO TICKETS(screening, username)
VALUES  ("e27d9de6f564b3aa55b82cc947555c9b", "halebop94"),
        ("e27d9de6f564b3aa55b82cc947555c9b", "frednordell"),
        ("df20a592ffb474ff6493a7d1319e8972", "halebop94")
;
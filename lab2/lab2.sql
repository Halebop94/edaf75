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
    name TEXT,
    capacity INTEGER,
    PRIMARY KEY (name)
);

CREATE TABLE SCREENINGS (
    uuid TEXT DEFAULT (LOWER(HEX(RANDOMBLOB(16)))),
    showing_date DATE,
    start_time TIME,
    theatre TEXT,
    movie TEXT,
    max_seats INTEGER,
    FOREIGN KEY (theatre) REFERENCES THEATRES(name),
    FOREIGN KEY (movie) REFERENCES MOVIES(imdb_key),
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
INTO THEATRES(name, capacity)
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
INTO SCREENINGS(showing_date, start_time, theatre, movie, max_seats)
VALUES  ('2020-03-01', '19:00', "Filmstaden Lund", "tt4520988", 40),
        ('2020-03-01', '19:00', "Filmstaden Malmö", "tt0105236", 100),
        ('2020-03-01', '01:00', "Filmstaden Malmö", "tt2527336", 100),
        ('2020-03-01', '10:00', "Filmstaden Hötorget", "tt0373889", 100),
        ('2020-03-01', '19:00', "Filmstaden Hötorget", "tt2527336", 300),
        ('2020-03-03', '23:00', "Filmstaden Hötorget", "tt0167260", 200)
;

INSERT 
INTO CUSTOMERS(username, full_name, password)
VALUES  ("halebop94", "Hanna Höjbert", "123456"),
        ("frednordell", "Fred Nordell", "123456")
;

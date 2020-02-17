from fastapi import FastAPI
import sqlite3
import json
from starlette.responses import Response

app = FastAPI()
conn = sqlite3.connect("movies.sqlite", check_same_thread = False)

@app.get("/ping")
def ping():
    return Response(content = 'pong', status_code = 200)

@app.post("/reset")
def reset_database():
    c = conn.cursor()
    c.execute("PRAGMA foreign_keys=OFF")
    c.execute("DROP TABLE IF EXISTS THEATRES")
    c.execute("DROP TABLE IF EXISTS SCREENINGS")
    c.execute("DROP TABLE IF EXISTS MOVIES")
    c.execute("DROP TABLE IF EXISTS TICKETS")
    c.execute("DROP TABLE IF EXISTS CUSTOMERS")
    c.execute("PRAGMA foreign_keys=ON")

    c.execute("""
        CREATE TABLE THEATRES (
            theatre_name TEXT,
            capacity INTEGER,
            PRIMARY KEY (theatre_name)
        );

        """)
    c.execute("""
        CREATE TABLE SCREENINGS (
            screeningId TEXT DEFAULT (LOWER(HEX(RANDOMBLOB(16)))),
            showing_date DATE,
            start_time TIME,
            theatre_name TEXT,
            imdb_key TEXT,
            FOREIGN KEY (theatre_name) REFERENCES THEATRES(theatre_name),
            FOREIGN KEY (imdb_key) REFERENCES MOVIES(imdb_key),
            PRIMARY KEY (screeningId)
        );

        """)
    c.execute("""
        CREATE TABLE MOVIES (
            imdb_key TEXT,
            title TEXT,
            p_year DATE,
            runtime TEXT,
            PRIMARY KEY (imdb_key)
        );

        """)
    c.execute("""
        CREATE TABLE TICKETS (
            ticketID TEXT DEFAULT (LOWER(HEX(RANDOMBLOB(16)))),
            screeningId TEXT,
            username TEXT,
            FOREIGN KEY (screeningId) REFERENCES SCREENINGS(screeningId),
            FOREIGN KEY (username) REFERENCES CUSTOMERS(username),
            PRIMARY KEY (ticketId)
        );


        """)
    c.execute("""
        CREATE TABLE CUSTOMERS (
            username TEXT,
            full_name TEXT,
            password TEXT,
            PRIMARY KEY (username)
        );

        """)
    theatres = [("Kino", 10),
            ("Södran", 16),
            ("Skandia", 100)]
    c.executemany("""
        INSERT
        INTO THEATRES(theatre_name, capacity)
        VALUES (?, ?) ;
        """,
        theatres)
    movies = [("tt5580390", "The Shape of Water", '2017', "1h 43min"),
            ("tt4975722", "Moonlight", '2016', "1h 39min"),
            ("tt1895587", "Spotlight", '2015', "2h 32min"),
            ("tt2562232", "Birdman", '2014', "2h 18min")]
    c.executemany("""
        INSERT
        INTO MOVIES(imdb_key, title, p_year, runtime)
        VALUES  (?, ?, ?, ?)
        ;
        """, movies)
    customers = [("alice", "Alice", "dobido"),
            ("bob", "Bob", "whatsinaname")]
    c.executemany("""
        INSERT
        INTO CUSTOMERS(username, full_name, password)
        VALUES  (?, ?, ?);
        """, customers)
    return Response(content = 'OK', status_code = 200)

@app.get("/movies")
def get_movies(title: str = '', year: str = ''):
    c = conn.cursor()
    c.execute( """
        SELECT imdb_key, title, p_year
        FROM movies
        WHERE title LIKE ? AND p_year LIKE ?
    """, ['%'+title+'%', '%'+year+'%'])
    s = [{"imdb_key": imdb_key, "title": title, "year": p_year}
        for (imdb_key, title, p_year) in c ]
    return Response(content = json.dumps({"data": s}, indent = 4), status_code = 200)

@app.get("/movies/{imdb_key}")
def get_movie_with_imdb_key(imdb_key: str = ''):
    c = conn.cursor()
    c.execute( """
        SELECT imdb_key, title, p_year
        FROM movies
        WHERE imdb_key = ?
    """, [imdb_key])
    s = [{"imdb_key": imdb_key, "title": title, "year": p_year}
        for (imdb_key, title, p_year) in c ]
    return Response(content = json.dumps({"data": s}, indent = 4), status_code = 200)

@app.post("/performances")
def add_performances(imdb: str = '', theater: str = '', date: str = '', time: str = ''):
    c = conn.cursor()
    try :
        c.execute("""
            INSERT
            INTO SCREENINGS(showing_date, start_time, theatre_name, imdb_key)
            VALUES  (?,	?,	?,	?);
        """, [date, time, theater, imdb])
        conn.commit()
    except sqlite3.Error:
        return Response(content = "No such movie or theater", status_code = 500)
    c.execute("""
        SELECT imdb_key
        FROM screenings
        WHERE rowid = last_insert_rowid()
    """)
    id = c.fetchone()[0]
    return Response(content = "/performances/"+id, status_code = 200)

@app.get("/performances")
def get_performances():
    c = conn.cursor()
    c.execute( """
        WITH ticket_count AS (
            SELECT screeningId, count(ticketId) AS bought_tickets
            FROM screenings
            LEFT OUTER JOIN tickets
            USING (screeningId)
            GROUP BY screeningId
        )
        SELECT screeningId, showing_date, start_time, theatre_name, title, p_year, capacity - bought_tickets AS remaining_seats
        FROM screenings
        JOIN movies
        USING (imdb_key)
        JOIN ticket_count
        USING (screeningId)
        JOIN theatres
        USING (theatre_name)
        """)
    s = [{"performanceId": screeningId, "date": showing_date, "startTime": start_time, "theater": theatre_name, "title": title, "year": p_year, "remainingSeats": remaining_seats}
        for (screeningId, showing_date, start_time, theatre_name, title, p_year, remaining_seats) in c ]
    return Response(content = json.dumps({"data": s}, indent = 4), status_code = 200)

@app.post("/tickets")
def buy_tickets(performance: str, user: str, pwd: str):
    try:
        c = conn.cursor()
        c.execute("""
            SELECT screeningId, capacity - count(ticketId) AS remaining_seats
            FROM screenings
            LEFT OUTER JOIN tickets
            USING (screeningId)
            JOIN theatres
            USING (theatre_name)
            WHERE screeningId = ?
        """, [performance])
        remaining_seats = c.fetchone()[1]
        if(remaining_seats == 0):
            return Response(content = "No tickets left", status_code = 200)
        conn.commit()
        c.execute("""
            INSERT
            INTO TICKETS(screeningId, username)
            VALUES (?, ?)

        """, [performance, user])
        conn.commit()
        c.execute("""
            SELECT ticketId
            FROM tickets
            WHERE rowid = last_insert_rowid()
        """)
        id = c.fetchone()[0]
        return Response(content = "/tickets/"+id, status_code = 200)
    except sqlite3.Error:
        return Response(content = "Error", status_code = 404)

@app.get("/customers/{username}/tickets")
def see_tickets(username: str):
    c = conn.cursor()
    c.execute( """
        WITH ticket_count AS (
            SELECT screeningId, count(ticketId) AS bought_tickets
            FROM screenings
            LEFT OUTER JOIN tickets
            USING (screeningId)
            WHERE username = ?
            GROUP BY screeningId
        )
        SELECT screeningId, showing_date, start_time, theatre_name, title, p_year, bought_tickets
        FROM screenings
        JOIN movies
        USING (imdb_key)
        JOIN ticket_count
        USING (screeningId)
        JOIN theatres
        USING (theatre_name)
        """, [username])
    s = [{"date": showing_date, "startTime": start_time, "theater": theatre_name, "title": title, "year": p_year, "nbrOfTickets": bought_tickets}
        for (screeningId, showing_date, start_time, theatre_name, title, p_year, bought_tickets) in c ]
    return Response(content = json.dumps({"data": s}, indent = 4), status_code = 200)

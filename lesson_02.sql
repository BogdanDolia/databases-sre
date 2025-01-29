/*
Lesson #2. Advanced SELECT syntax, sorting, filtering, JOIN

Lesson objectives:
1. Learn to filter data more flexibly (operators BETWEEN, LIKE, IN).
2. Sort query results (ORDER BY).
3. Understand the main types of JOIN (INNER JOIN, LEFT JOIN, RIGHT JOIN).

JOIN: Basics
JOINs are used to combine data from multiple tables. Types:
- INNER JOIN: returns only records that have matches in both tables.
- LEFT JOIN: returns all records from the left table + matching records from the right (if no match, columns from the right table will be NULL).
- RIGHT JOIN: similar to the previous one, but reversed (all from the right + matching from the left).
 */
-- Create genres table
CREATE TABLE
    genres (
        genre_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL
    );

-- Insert genres
INSERT INTO
    genres (name)
VALUES
    ('Action'),
    ('Comedy'),
    ('Drama'),
    ('Thriller'),
    ('Horror'),
    ('Fantasy'),
    ('Science Fiction'),
    ('Romance'),
    ('Adventure'),
    ('Animation');

CREATE TABLE
    movies (
        movie_id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        year SMALLINT,
        availability BOOLEAN
    );

-- Insert more realistic movie data
INSERT INTO
    movies (name, year, availability)
VALUES
    ('Inception', 2010, TRUE),
    ('The Matrix', 1999, TRUE),
    ('The Godfather', 1972, TRUE),
    ('Pulp Fiction', 1994, TRUE),
    ('The Shawshank Redemption', 1994, TRUE),
    ('Fight Club', 1999, FALSE),
    ('Forrest Gump', 1994, TRUE),
    ('The Dark Knight', 2008, TRUE),
    ('Avengers: Endgame', 2019, FALSE),
    ('Titanic', 1997, TRUE),
    ('Interstellar', 2014, TRUE),
    ('The Lion King', 1994, TRUE),
    ('Jurassic Park', 1993, TRUE),
    ('Star Wars: A New Hope', 1977, TRUE),
    ('Back to the Future', 1985, TRUE);

ALTER TABLE movies
ADD COLUMN copy_available INTEGER;

UPDATE movies
SET
    copy_available = CASE
        WHEN name = 'Fight Club' THEN 0
        WHEN name = 'Avengers: Endgame' THEN 0
        WHEN name = 'Interstellar' THEN 1
        WHEN name = 'Star Wars: A New Hope' THEN 2
        WHEN name = 'Back to the Future' THEN 5
        WHEN name = 'The Matrix' THEN 7
        WHEN name = 'Forrest Gump' THEN 9
        WHEN name = 'Jurassic Park' THEN 8
        WHEN name = 'Inception' THEN 3
        WHEN name = 'The Dark Knight' THEN NULL
        ELSE 10 -- Default value for unspecified movies
    END;

-- Create movie_genres join table
CREATE TABLE
    movie_genres (
        movie_id INT REFERENCES movies (movie_id) ON DELETE CASCADE,
        genre_id INT REFERENCES genres (genre_id),
        PRIMARY KEY (movie_id, genre_id)
    );

-- Assign genres to the movies
INSERT INTO
    movie_genres (movie_id, genre_id)
VALUES
    (1, 7), -- Inception -> Science Fiction
    (2, 7), -- The Matrix -> Science Fiction
    (3, 3), -- The Godfather -> Drama
    (4, 3), -- Pulp Fiction -> Drama
    (5, 3), -- The Shawshank Redemption -> Drama
    (6, 3), -- Fight Club -> Drama
    (7, 3), -- Forrest Gump -> Drama
    (8, 1), -- The Dark Knight -> Action
    (9, 1), -- Avengers: Endgame -> Action
    (10, 8), -- Titanic -> Romance
    (11, 7), -- Interstellar -> Science Fiction
    (12, 10), -- The Lion King -> Animation
    (13, 1), -- Jurassic Park -> Action
    (14, 1), -- Star Wars: A New Hope -> Action
    (15, 7);

-- Back to the Future -> Science Fiction
SELECT
    name,
    year
FROM
    movies
ORDER BY
    year DESC;

-- delete duplicates
SELECT DISTINCT
    year
FROM
    movies;

SELECT
    *
FROM
    movies
WHERE
    year BETWEEN 1900 AND 2000;

SELECT
    *
FROM
    movies
WHERE
    name LIKE '%film%';

-- include "film"
SELECT
    *
FROM
    movies
WHERE
    year IN (1999, 2011);

SELECT
    *
FROM
    movies
ORDER BY
    year
LIMIT
    2 -- 2 lines
OFFSET
    1;

-- skip 1 line
-- List all movies with their genres
SELECT
    m.name AS movie_name,
    g.name AS genre_name
FROM
    movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id;

-- List genres with the number of movies in each genre
SELECT
    g.name AS genre_name,
    COUNT(mg.movie_id) AS movie_count
FROM
    genres g
    LEFT JOIN movie_genres mg ON g.genre_id = mg.genre_id
GROUP BY
    g.name
ORDER BY
    movie_count DESC;

-- Using BETWEEN
SELECT
    m.name AS movie_name,
    m.year AS release_year,
    g.name AS genre_name
FROM
    movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id
WHERE
    m.year BETWEEN 1990 AND 2000;

-- Using LIKE
SELECT
    m.name AS movie_name,
    m.year AS release_year
FROM
    movies m
WHERE
    m.name LIKE 'The%';

-- Using IN
SELECT
    m.name AS movie_name,
    g.name AS genre_name
FROM
    movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id
WHERE
    g.name IN ('Drama', 'Science Fiction');

-- Combining Filters
SELECT
    m.name AS movie_name,
    m.year AS release_year,
    g.name AS genre_name
FROM
    movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id
WHERE
    m.year >= 1990
    AND m.year <= 2000
    AND m.name LIKE 'The%'
    AND g.name IN ('Drama', 'Science Fiction');
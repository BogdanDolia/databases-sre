/*
Learn to use subqueries in different parts of SQL queries:
In WHERE for filtering using IN or EXISTS
In the list of selected columns
In the FROM section as virtual (temporary) tables
Master the CASE construct to implement conditional logic directly within the query
Get acquainted with the COALESCE function for handling NULL values
The COALESCE function returns the first non-null argument from the list. This is useful for replacing NULL with a default value.

Select movies whose release year is greater than the average release year of all movies.
 */
SELECT
    name,
    year
FROM
    movies
WHERE
    year > (
        SELECT
            AVG(year)
        FROM
            movies
    );

-- For each movie, output its name and the number of genres it belongs to.
SELECT
    m.name,
    (
        SELECT
            COUNT(*)
        FROM
            movie_genres mg
        WHERE
            mg.movie_id = m.movie_id
    ) AS genre_count
FROM
    movies m;

-- Count the number of copies for each movie (if, for example, copies are stored in a separate field) 
-- and select the movies where the number of copies is greater than the average for all movies.
SELECT
    t.movie_id,
    t.total_copies
FROM
    (
        SELECT
            movie_id,
            SUM(copy_available) AS total_copies
        FROM
            movies
        GROUP BY
            movie_id
    ) t
WHERE
    t.total_copies > (
        SELECT
            AVG(total_copies)
        FROM
            (
                SELECT
                    movie_id,
                    SUM(copy_available) AS total_copies
                FROM
                    movies
                GROUP BY
                    movie_id
            ) tt
    );

-- Determine a conditional availability rating for each movie based on the number of copies.
SELECT
    name,
    copy_available,
    CASE
        WHEN copy_available >= 10 THEN 'Excellent'
        WHEN copy_available >= 5
        AND copy_available <= 9 THEN 'Good'
        ELSE 'Low'
    END AS availability_rating
FROM
    movies;

-- Conditional categories can be created. For example, if you need to classify movie release years by decades.
SELECT
    name,
    year,
    CASE
        WHEN year < 1980 THEN 'Before 1980'
        WHEN year >= 1980
        AND year <= 1989 THEN '80s'
        WHEN year >= 1990
        AND year <= 1999 THEN '90s'
        WHEN year >= 2000
        AND year <= 2009 THEN '2000s'
        ELSE '2010 and later'
    END AS decade_group
FROM
    movies;

-- If the movies table unexpectedly contains NULL in the copy_available column, you can replace it with 0:
SELECT
    name,
    COALESCE(copy_available, 0) AS available_copies
FROM
    movies;

-- Write a query that outputs movie titles where the number of copies 
-- (copy_available) is greater than the average number of copies for all movies.
SELECT
    t.name,
    t.total_copies
FROM
    (
        SELECT
            name,
            SUM(copy_available) AS total_copies
        FROM
            movies
        GROUP BY
            name
    ) t
WHERE
    t.total_copies > (
        SELECT
            AVG(total_copies)
        FROM
            (
                SELECT
                    name,
                    SUM(copy_available) AS total_copies
                FROM
                    movies
                GROUP BY
                    name
            ) tt
    );

-- COALESCE
SELECT
    name,
    COALESCE(copy_available, 0) AS copy_available,
    CASE
        WHEN COALESCE(copy_available, 0) >= 10 THEN 'Excellent'
        WHEN COALESCE(copy_available, 0) >= 5
        AND COALESCE(copy_available, 0) <= 9 THEN 'Good'
        ELSE 'Low'
    END AS availability_rating
FROM
    movies;
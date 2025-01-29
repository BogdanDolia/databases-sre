/*
noinspection SqlNoDataSourceInspectionForFile

Learn to use aggregate functions (COUNT, SUM, AVG, MIN, MAX) in queries.
Understand the application of GROUP BY and HAVING operators.

Aggregate Functions
COUNT() – counts the number of rows.
SUM() – sums the values of a column.
AVG() – calculates the average value.
MIN() / MAX() – finds the minimum and maximum values of a column.

Filtering groups – HAVING
WHERE filters individual rows, whereas HAVING filters already “grouped” data.

Creating the employees table
 */
CREATE TABLE
    employees (
        employee_id SERIAL PRIMARY KEY,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        department VARCHAR(50),
        salary NUMERIC(10, 2),
        status VARCHAR(20)
    );

-- Populating the table with test data
INSERT INTO
    employees (first_name, last_name, department, salary, status)
VALUES
    (
        'Alice',
        'Smith',
        'Engineering',
        75000.00,
        'ACTIVE'
    ),
    ('Bob', 'Johnson', 'Finance', 65000.00, 'ACTIVE'),
    (
        'Charlie',
        'Williams',
        'Engineering',
        80000.00,
        'INACTIVE'
    ),
    ('Diana', 'Brown', 'Marketing', 55000.00, 'ACTIVE'),
    ('Edward', 'Jones', 'HR', 50000.00, 'ACTIVE'),
    (
        'Fiona',
        'Garcia',
        'Engineering',
        95000.00,
        'ACTIVE'
    ),
    (
        'George',
        'Martinez',
        'Finance',
        68000.00,
        'INACTIVE'
    ),
    (
        'Helen',
        'Miller',
        'Marketing',
        60000.00,
        'ACTIVE'
    ),
    ('Ian', 'Davis', 'HR', 52000.00, 'ACTIVE'),
    (
        'Julia',
        'Rodriguez',
        'Engineering',
        72000.00,
        'INACTIVE'
    );

-- Employees
SELECT
    AVG(salary) AS avg_salary
FROM
    employees;

SELECT
    department,
    AVG(salary) AS avg_salary
FROM
    employees
GROUP BY
    department;

SELECT
    department,
    AVG(salary) AS avg_salary
FROM
    employees
GROUP BY
    department
HAVING
    AVG(salary) > 50000;

SELECT
    department,
    AVG(salary) AS avg_salary
FROM
    employees
WHERE
    status = 'ACTIVE'
GROUP BY
    department
HAVING
    AVG(salary) > 60000;

-- Movies
SELECT
    *
FROM
    movies;

SELECT
    m.name AS movie_name,
    g.name AS genre_name
FROM
    movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id
WHERE
    m.availability = 'true'
GROUP BY
    m.name,
    g.name
HAVING
    g.name = 'Drama';

SELECT
    SUM(copy_available) AS sum_copy_available
FROM
    movies;

SELECT
    m.name AS movie_name,
    g.name AS genre_name,
    m.copy_available AS copy_available
FROM
    movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id
WHERE
    m.availability = 'true'
GROUP BY
    m.name,
    g.name,
    m.copy_available
HAVING
    m.copy_available > 5
ORDER BY
    m.copy_available ASC;
-- noinspection SqlNoDataSourceInspectionForFile

-- Каждая таблица имеет ключевые столбцы:
--  Первичный ключ (Primary Key, PK): уникально идентифицирует строку.
--  Внешний ключ (Foreign Key, FK): ссылается на первичный ключ в другой таблице.
--
-- Основные команды языка SQL:
--  SELECT – выбор данных из таблиц.
--  FROM – указание таблицы (или нескольких, если делаем JOIN).
--  WHERE – фильтрация строк.

CREATE TABLE employees (
                           employee_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(100),
                           last_name VARCHAR(100),
                           salary NUMERIC(10, 2)
);

INSERT INTO employees (first_name, last_name, salary)
VALUES
    ('Alice', 'Smith', 45000),
    ('Bob', 'Jones', 55000),
    ('Charlie', 'Brown', 60000);

SELECT *
FROM employees;

SELECT first_name, salary
FROM employees;

SELECT *
FROM employees
WHERE salary > 50000;


--
-- Homework
--

CREATE TABLE movies (
                           movie_id SERIAL PRIMARY KEY,
                           name VARCHAR(100),
                           year SMALLINT,
                           availability BOOLEAN
);

INSERT INTO movies (name, year, availability)
VALUES
    ('film1', 1906, TRUE),
    ('film2', 2011, FALSE),
    ('film3', 1987, TRUE),
    ('film4', 1999, TRUE),
    ('film5', 2025, TRUE);

INSERT INTO movies (name, year, availability)
VALUES
    ('film1', 1906, TRUE);

SELECT *
FROM movies;

SELECT name, availability
FROM movies;

SELECT *
FROM movies
WHERE availability is TRUE;
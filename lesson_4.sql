-- Научиться использовать подзапросы в различных частях SQL-запросов:
--  В WHERE для фильтрации с использованием IN или EXISTS
--  В списке выбираемых столбцов
--  В секции FROM как виртуальные (временные) таблицы
--  Освоить конструкцию CASE для реализации условной логики прямо внутри запроса
--  Познакомиться с функцией COALESCE для обработки NULL значений
-- Функция COALESCE возвращает первый ненулевой аргумент из списка. Это удобно для замены NULL на стандартное значение.
--
-- выбрать фильмы, год выпуска которых больше, чем средний год выпуска всех фильмов.
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

-- для каждого фильма вывести имя и количество жанров, к которым он принадлежит.
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

-- посчитать количество копий для каждого фильма (если, например, копии хранятся в отдельном поле) 
-- и выбрать те фильмы, у которых количество копий больше среднего по всем фильмам.
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

-- Для каждого фильма определить условный рейтинг доступности по количеству копий
SELECT
    name,
    copy_available,
    CASE
        WHEN copy_available >= 10 THEN 'Отличный'
        WHEN copy_available >= 5
        AND copy_available <= 9 THEN 'Хороший'
        ELSE 'Низкий'
    END AS availability_rating
FROM
    movies;

-- Можно создавать условные категории. Например, если нужно классифицировать года выпуска фильмов по десятилетиям
SELECT
    name,
    year,
    CASE
        WHEN year < 1980 THEN 'До 1980'
        WHEN year >= 1980
        AND year <= 1989 THEN '80-е'
        WHEN year >= 1990
        AND year <= 1999 THEN '90-е'
        WHEN year >= 2000
        AND year <= 2009 THEN '2000-е'
        ELSE '2010 и позже'
    END AS decade_group
FROM
    movies;

-- Если в таблице movies вдруг окажется NULL в колонке copy_available, можно заменить его на 0:
SELECT
    name,
    COALESCE(copy_available, 0) AS available_copies
FROM
    movies;

-- Напишите запрос, который выводит названия фильмов, у которых количество копий 
-- (copy_available) больше среднего количества копий по всем фильмам.
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
        WHEN COALESCE(copy_available, 0) >= 10 THEN 'Отличный'
        WHEN COALESCE(copy_available, 0) >= 5
        AND COALESCE(copy_available, 0) <= 9 THEN 'Хороший'
        ELSE 'Низкий'
    END AS availability_rating
FROM
    movies;
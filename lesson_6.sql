-- День 6. Индексы и оптимизация запросов
--
--
-- 1. Индексы в базах данных
--
-- Индекс — это структура данных, которая улучшает скорость операций поиска и 
-- выборки данных в таблицах базы данных. Однако создание индексов увеличивает 
-- время операций вставки, обновления и удаления, а также занимает дополнительное 
-- пространство на диске. Поэтому важно грамотно подбирать индексы, балансируя 
-- между скоростью выборок и затратами на поддержание индексов.
--
--
-- Основные виды индексов:
--
--
-- 	1.	B-tree индексы (по умолчанию):
-- 	•	Наиболее распространённый тип индексов.
-- 	•	Эффективны для равенства и диапазонных запросов.
-- 	•	Применяются по умолчанию для большинства типов данных.
CREATE INDEX idx_books_title ON Books (title);

-- 2.	Уникальные индексы:
-- •	Обеспечивают уникальность значений в индексированном столбце.
-- •	Автоматически создаются при определении столбца как UNIQUE.
CREATE UNIQUE INDEX idx_users_email ON Users (email);

-- 3.	Составные индексы:
-- •	Индексируются несколько столбцов одновременно.
-- •	Полезны для запросов, фильтрующих по нескольким столбцам.
CREATE INDEX idx_orders_user_status ON Orders (user_id, status);

-- 4.	Покрывающие индексы:
-- •	Индекс включает все столбцы, используемые в запросе.
-- •	Позволяет выполнять запросы полностью из индекса без обращения к таблице.
CREATE INDEX idx_order_items_order_book ON Order_Items (order_id, book_id, quantity);

-- 5.	GIN и GiST индексы:
-- •	Используются для сложных типов данных, таких как массивы, JSONB, географические данные.
-- •	Предоставляют расширенные возможности поиска.
CREATE INDEX idx_books_categories ON Book_Categories USING GIN (category_id);

-- Рекомендации по созданию индексов:
-- 	•	Создавайте индексы на столбцах, часто используемых в условиях WHERE, JOIN, ORDER BY и GROUP BY.
-- 	•	Избегайте избыточного количества индексов — каждый индекс добавляет нагрузку при модификации данных.
-- 	•	Используйте составные индексы, если запросы фильтруют по нескольким столбцам одновременно.
--
--
-- 2. Анализ планов выполнения запросов с помощью EXPLAIN
--
--
-- Команда EXPLAIN позволяет увидеть, как PostgreSQL планирует выполнить ваш запрос. 
-- Это полезно для выявления узких мест и понимания, как оптимизировать запросы.
EXPLAIN
SELECT
    *
FROM
    Books
WHERE
    title = 'Inception';

-- Результат:
-- Seq Scan on Books  (cost=0.00..12.50 rows=1 width=...)
--   Filter: (title = 'Inception'::varchar)
--
-- •	Seq Scan — последовательное сканирование таблицы, что может быть медленным для больших таблиц.
-- •	cost=0.00..12.50 — оценка стоимости выполнения запроса.
-- •	rows=1 — предполагаемое количество строк, которые вернёт запрос.
--
--
-- Улучшение плана выполнения с помощью индексов:
CREATE INDEX idx_books_title ON Books (title);

EXPLAIN
SELECT
    *
FROM
    Books
WHERE
    title = 'Inception';

-- Index Scan using idx_books_title on Books  (cost=0.29..8.31 rows=1 width=...)
--   Index Cond: (title = 'Inception'::varchar)
-- Пример сложного запроса:
SELECT
    o.order_id,
    u.username,
    b.title,
    oi.quantity
FROM
    Orders o
    JOIN Users u ON o.user_id = u.user_id
    JOIN Order_Items oi ON o.order_id = oi.order_id
    JOIN Books b ON oi.book_id = b.book_id
WHERE
    u.username = 'john_doe'
    AND b.title LIKE 'Harry Potter%';

-- Вариант как создать индекс для этого запроса:
CREATE INDEX idx_users_username ON Users (username);

CREATE INDEX idx_books_title ON Books (title);

CREATE INDEX idx_orders_user_id ON Orders (user_id);

CREATE INDEX idx_order_items_order_id ON Order_Items (order_id);

CREATE INDEX idx_order_items_book_id ON Order_Items (book_id);

--
--
-- 3. Оптимизация запросов
--
--
-- 	1.	Избегать SELECT *:
-- 	•	Запрашивайте только необходимые столбцы, чтобы уменьшить объём передаваемых данных.
SELECT
    title,
    price
FROM
    Books
WHERE
    title LIKE 'Harry Potter%';

-- 2.	Использовать покрывающие индексы:
-- •	Индексы, включающие все столбцы, используемые в запросе, позволяют выполнять запросы только из индекса.
CREATE INDEX idx_books_title_price ON Books (title, price);

SELECT
    title,
    price
FROM
    Books
WHERE
    title LIKE 'Harry Potter%';

-- 3.	Избегать функций на индексированных столбцах:
-- •	Использование функций на индексированных столбцах может предотвратить использование индекса.
-- Плохо:
WHERE
    LOWER(title) = 'inception'
    -- Хорошо:
WHERE
    title = 'Inception'
    -- 4.	Использовать LIMIT для больших выборок:
    -- •	Если нужно получить только часть результатов, используйте LIMIT для сокращения объёма обрабатываемых данных.
SELECT
    title
FROM
    Books
ORDER BY
    publication_date DESC
LIMIT
    10;

-- Домашнее задание:
EXPLAIN
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

CREATE INDEX idx_movies_name_year ON movies (name, year);

CREATE INDEX idx_movies_year ON movies (year);

EXPLAIN ANALYZE
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

--
--
Итоговые рекомендации
-- •	Создавай индексы на те столбцы, которые часто используются в условиях WHERE, JOIN, ORDER BY и GROUP BY.
-- •	Используй EXPLAIN ANALYZE для получения реальных данных о выполнении запроса.
-- •	Обновляй статистику таблиц с помощью ANALYZE, чтобы оптимизатор запросов имел актуальную информацию.
-- •	Избегай избыточного количества индексов, так как они замедляют операции INSERT, UPDATE и DELETE.
-- •	Тестируй свои индексы на реальных данных или больших объёмах данных, чтобы оценить их влияние на производительность.
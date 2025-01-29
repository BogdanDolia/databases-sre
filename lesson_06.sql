-- Day 6. Indexes and Query Optimization
--
--
-- 1. Indexes in Databases
--
-- An index is a data structure that improves the speed of search and 
-- data retrieval operations in database tables. However, creating indexes increases 
-- the time required for insert, update, and delete operations, as well as consuming additional 
-- disk space. Therefore, it is important to carefully choose indexes, balancing 
-- between query speed and index maintenance costs.
--
--
-- Main types of indexes:
--
--
-- 	1.	B-tree indexes (default):
-- 	•	The most common type of index.
-- 	•	Effective for equality and range queries.
-- 	•	Applied by default for most data types.
CREATE INDEX idx_books_title ON Books (title);

-- 2.	Unique indexes:
-- •	Ensure uniqueness of values in the indexed column.
-- •	Automatically created when a column is defined as UNIQUE.
CREATE UNIQUE INDEX idx_users_email ON Users (email);

-- 3.	Composite indexes:
-- •	Multiple columns are indexed at the same time.
-- •	Useful for queries filtering by multiple columns.
CREATE INDEX idx_orders_user_status ON Orders (user_id, status);

-- 4.	Covering indexes:
-- •	An index includes all the columns used in a query.
-- •	Allows queries to be executed entirely from the index without accessing the table.
CREATE INDEX idx_order_items_order_book ON Order_Items (order_id, book_id, quantity);

-- 5.	GIN and GiST indexes:
-- •	Used for complex data types, such as arrays, JSONB, and geographic data.
-- •	Provide advanced search capabilities.
CREATE INDEX idx_books_categories ON Book_Categories USING GIN (category_id);

-- Recommendations for creating indexes:
-- 	•	Create indexes on columns frequently used in WHERE, JOIN, ORDER BY, and GROUP BY clauses.
-- 	•	Avoid excessive indexing—each index adds overhead to data modification operations.
-- 	•	Use composite indexes if queries filter by multiple columns at once.
--
--
-- 2. Query Execution Plan Analysis with EXPLAIN
--
--
-- The EXPLAIN command allows you to see how PostgreSQL plans to execute your query. 
-- This is useful for identifying bottlenecks and understanding how to optimize queries.
EXPLAIN
SELECT
    *
FROM
    Books
WHERE
    title = 'Inception';

-- Result:
-- Seq Scan on Books  (cost=0.00..12.50 rows=1 width=...)
--   Filter: (title = 'Inception'::varchar)
--
-- •	Seq Scan — sequential table scan, which can be slow for large tables.
-- •	cost=0.00..12.50 — estimated execution cost.
-- •	rows=1 — estimated number of rows returned by the query.
--
--
-- Improving execution plan using indexes:
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
-- Example of a complex query:
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

-- How to create an index for this query:
CREATE INDEX idx_users_username ON Users (username);

CREATE INDEX idx_books_title ON Books (title);

CREATE INDEX idx_orders_user_id ON Orders (user_id);

CREATE INDEX idx_order_items_order_id ON Order_Items (order_id);

CREATE INDEX idx_order_items_book_id ON Order_Items (book_id);

--
--
-- 3. Query Optimization
--
--
-- 	1.	Avoid SELECT *:
-- 	•	Request only the necessary columns to reduce the amount of transferred data.
SELECT
    title,
    price
FROM
    Books
WHERE
    title LIKE 'Harry Potter%';

-- 2.	Use covering indexes:
-- •	Indexes that include all columns used in a query allow queries to be executed entirely from the index.
CREATE INDEX idx_books_title_price ON Books (title, price);

SELECT
    title,
    price
FROM
    Books
WHERE
    title LIKE 'Harry Potter%';

-- 3.	Avoid functions on indexed columns:
-- •	Using functions on indexed columns can prevent index usage.
-- Bad:
WHERE
    LOWER(title) = 'inception'
    -- Good:
WHERE
    title = 'Inception'
    -- 4.	Use LIMIT for large result sets:
    -- •	If you need only part of the results, use LIMIT to reduce the amount of processed data.
SELECT
    title
FROM
    Books
ORDER BY
    publication_date DESC
LIMIT
    10;

-- Homework:
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
Final Recommendations
-- •	Create indexes on columns frequently used in WHERE, JOIN, ORDER BY, and GROUP BY clauses.
-- •	Use EXPLAIN ANALYZE to obtain actual execution data.
-- •	Update table statistics using ANALYZE so the query optimizer has up-to-date information.
-- •	Avoid excessive indexing, as it slows down INSERT, UPDATE, and DELETE operations.
-- •	Test your indexes on real or large datasets to evaluate their impact on performance.
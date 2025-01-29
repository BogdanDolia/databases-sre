/* 

Day 7. Stored Procedures, Functions, and Triggers

Lesson Objectives
1. Get acquainted with stored procedures and functions in relational 
DBMS (using PostgreSQL as an example):
• Understand their differences.
• Learn how to create and use them.
2. Learn about triggers:
• Types of triggers (BEFORE, AFTER, INSTEAD OF).
• Main events (INSERT, UPDATE, DELETE).
• Real-world use cases for triggers.
3. Write a simple stored procedure for data processing and implement 
a trigger for data control or automatic updates.

1. Stored Procedures and Functions in PostgreSQL
Stored procedures and functions allow executing a set of SQL commands on the server side. 
This can speed up operations since the logic is executed "closer" to the data rather than in the application.
1.1 Differences Between Procedures and Functions
• A function in PostgreSQL:
• Can return a value (scalar or table-based).
• Cannot manage transactions directly (COMMIT/ROLLBACK cannot be used inside a function).
• Typically used for data transformation, aggregation, generating computed fields, etc.
• A procedure in PostgreSQL (since version 11):
• Does not have to return anything and can perform actions "without returning."
• Can manage transactions (CALL my_procedure() can be used, and COMMIT/ROLLBACK can be executed 
within the procedure).
• Used for more complex logic where transaction management or sequential steps are 
required beyond just returning a result.


 */
-- FUNCTION
CREATE
OR REPLACE FUNCTION hello_world () RETURNS text AS $$ 
BEGIN
    RETURN 'Hello, world!';
END;
$$ LANGUAGE plpgsql;

SELECT
    hello_world ();

CREATE
OR REPLACE FUNCTION calculate_discount (price numeric, discount_percent numeric) RETURNS numeric AS $$
DECLARE
    discounted_price numeric;
BEGIN
    discounted_price := price - (price * discount_percent / 100);
    RETURN discounted_price;
END;
$$ LANGUAGE plpgsql;

SELECT
    calculate_discount (100, 15);

-- Result: 85
CREATE
OR REPLACE FUNCTION get_expensive_books (min_price numeric) RETURNS TABLE (book_id int, title text, price numeric) AS $$
BEGIN
    RETURN QUERY
        SELECT b.book_id, b.title, b.price
        FROM books b
        WHERE b.price >= min_price;
END;
$$ LANGUAGE plpgsql;

SELECT
    *
FROM
    get_expensive_books (50);

-- PROCEDURE
CREATE
OR REPLACE PROCEDURE apply_discount_to_books (discount_percent numeric) LANGUAGE plpgsql AS $$
BEGIN
    -- Example: updating the price for all books.
    UPDATE books
    SET price = price - (price * discount_percent / 100);
    
    RAISE NOTICE 'Discount of %%% applied to all books', discount_percent;
END;
$$;

CALL apply_discount_to_books (10);

/*
4. Triggers
A trigger is a database object that "fires" when a certain event 
(INSERT, UPDATE, DELETE, TRUNCATE) occurs in the specified table and can perform actions before or after this event.

Main types of triggers in PostgreSQL:
1. BEFORE — fires before the operation is executed.
2. AFTER — fires after the operation is executed.
3. INSTEAD OF — used for views.

Example: Audit trigger
Suppose we have a table `books`, and we want to keep a log of price changes in the `books_price_log` table.
 */
CREATE TABLE
    books_price_log (
        log_id SERIAL PRIMARY KEY,
        book_id INT NOT NULL,
        old_price DECIMAL(10, 2),
        new_price DECIMAL(10, 2),
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

CREATE
OR REPLACE FUNCTION log_price_change () RETURNS TRIGGER AS $$
BEGIN
    -- Функция будет вызываться перед обновлением данных
    IF NEW.price <> OLD.price THEN
        INSERT INTO books_price_log(book_id, old_price, new_price)
        VALUES (OLD.book_id, OLD.price, NEW.price);
    END IF;
    RETURN NEW;  -- важно вернуть NEW, чтобы продолжить операцию UPDATE
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER books_price_log_trigger
AFTER
UPDATE OF price ON books FOR EACH ROW
EXECUTE PROCEDURE log_price_change ();

/*
• AFTER UPDATE OF price — the trigger fires after the `price` column is updated.
• FOR EACH ROW — the trigger executes for each affected row.

4. Result:
When `books.price` is updated, a record is automatically inserted into the `books_price_log` table, 
logging the old and new price along with the time of change.

Additional Tips:
• When debugging functions and procedures in PostgreSQL, it is useful to use `RAISE NOTICE 'Message';` 
inside the body to see intermediate results or the current state of variables.
• Always specify `RETURN NEW;` (for INSERT/UPDATE) or `RETURN OLD;` (for DELETE) 
when writing a row-level trigger to prevent the operation from being interrupted.
• A trigger can also be `BEFORE` if you need to modify data before it is written to the table. 
For example, setting `updated_at = NOW()` or adjusting input data.

### Homework:
1. Create a function that returns the number of movies in a given genre.
2. Create a stored procedure that deletes all movies released before a specified year.
3. Create a trigger that automatically sets the creation date of a movie when it is added.

1. Create a function that returns the number of movies in a given genre.
 */
CREATE
OR REPLACE FUNCTION get_movie_count_by_genre (genre_name text) RETURNS integer AS $$
DECLARE
    movie_count integer;
BEGIN
    SELECT COUNT(*)
    INTO movie_count
    FROM movie_genres mg
    JOIN genres g ON mg.genre_id = g.genre_id
    JOIN movies m ON mg.movie_id = m.movie_id
    WHERE g.name = genre_name;

    RETURN movie_count;
END;
$$ LANGUAGE plpgsql;

SELECT
    get_movie_count_by_genre ('Action');

-- 2.	Create a stored procedure that deletes all movies released before a specified year.
CREATE
OR REPLACE PROCEDURE delete_movies_before (in_year INT) LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM movies
    WHERE year < in_year;
END;
$$;

CALL delete_movies_before (2000);

-- 3. Create a trigger that automatically sets the creation date of a movie when it is added.
ALTER TABLE movies
ADD COLUMN creation_date DATE;

CREATE
OR REPLACE FUNCTION set_creation_date () RETURNS TRIGGER AS $$
BEGIN
    NEW.creation_date := CURRENT_DATE;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_creation_date BEFORE INSERT ON movies FOR EACH ROW
EXECUTE FUNCTION set_creation_date ();

INSERT INTO
    movies (name, year, availability)
VALUES
    ('Dark Knight', 2008, TRUE);
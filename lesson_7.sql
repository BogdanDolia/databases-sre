-- День 7. Хранимые процедуры, функции и триггеры
--
-- Цели занятия
-- 	1.	Познакомиться с хранимыми процедурами и функциями в реляционных СУБД (на примере PostgreSQL):
-- 	•	Понять, чем они отличаются.
-- 	•	Научиться их создавать и использовать.
-- 	2.	Узнать о триггерах (triggers):
-- 	•	Типы триггеров (BEFORE, AFTER, INSTEAD OF).
-- 	•	Основные события (INSERT, UPDATE, DELETE).
-- 	•	Реальные сценарии применения триггеров.
-- 	3.	Написать простую хранимую процедуру для обработки данных и реализовать триггер для контроля 
-- или автоматического обновления данных.
--
-- 1. Хранимые процедуры и функции в PostgreSQL
-- Хранимые процедуры (Stored Procedures) и функции (Functions) позволяют выполнять набор SQL-команд 
-- на стороне сервера. Это может ускорять работу, поскольку логика выполняется «ближе» к данным, а не в приложении.
-- 1.1 Отличия процедур и функций
-- 	•	Функция в PostgreSQL:
-- 	•	Может возвращать какое-то значение (скалярное или табличное).
-- 	•	Не может управлять транзакциями напрямую (нельзя использовать COMMIT/ROLLBACK внутри функции).
-- 	•	Обычно используется для преобразования данных, агрегации, генерации вычисляемых полей и т.д.
-- 	•	Процедура в PostgreSQL (с 11-й версии):
-- 	•	Не обязана что-то возвращать, может выполнять любые действия «без возврата».
-- 	•	Может управлять транзакциями (можно вызвать CALL my_procedure() и внутри процедуры делать COMMIT/ROLLBACK).
-- 	•	Используется для более сложной логики, где требуется управление транзакциями или последовательные шаги, 
--     не связанные только с возвратом результата.
--
--
-- FUNCTION
CREATE OR REPLACE FUNCTION hello_world()
RETURNS text AS $$ 
BEGIN
    RETURN 'Hello, world!';
END;
$$ LANGUAGE plpgsql;
SELECT hello_world();

CREATE OR REPLACE FUNCTION calculate_discount(price numeric, discount_percent numeric)
RETURNS numeric AS $$
DECLARE
    discounted_price numeric;
BEGIN
    discounted_price := price - (price * discount_percent / 100);
    RETURN discounted_price;
END;
$$ LANGUAGE plpgsql;
SELECT calculate_discount(100, 15);  -- Результат: 85

CREATE OR REPLACE FUNCTION get_expensive_books(min_price numeric)
RETURNS TABLE(book_id int, title text, price numeric) AS $$
BEGIN
    RETURN QUERY
        SELECT b.book_id, b.title, b.price
        FROM books b
        WHERE b.price >= min_price;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_expensive_books(50);
--
--
-- PROCEDURE
CREATE OR REPLACE PROCEDURE apply_discount_to_books(discount_percent numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Пример: обновляем цену у всех книг
    UPDATE books
    SET price = price - (price * discount_percent / 100);
    
    RAISE NOTICE 'Discount of %%% applied to all books', discount_percent;
END;
$$;
CALL apply_discount_to_books(10);

--
--
-- 4. Триггеры

-- Триггер — это объект базы данных, который «срабатывает» при наступлении определённого события 
-- (INSERT, UPDATE, DELETE, TRUNCATE) в указанной таблице и может выполнять действия до или после этого события.
-- Основные типы триггеров в PostgreSQL
-- 	1.	BEFORE — срабатывает перед выполнением операции.
-- 	2.	AFTER — срабатывает после выполнения операции.
-- 	3.	INSTEAD OF — используется для представлений (view).
--
--
-- Пример: Триггер для аудита
-- Допустим, у нас есть таблица books, и мы хотим вести журнал изменений цены в таблице books_price_log.
CREATE TABLE books_price_log (
    log_id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_price_change()
RETURNS TRIGGER AS $$
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
AFTER UPDATE OF price ON books
FOR EACH ROW
EXECUTE PROCEDURE log_price_change();

-- 	•	AFTER UPDATE OF price — триггер срабатывает после изменения столбца price.
-- 	•	FOR EACH ROW — триггер исполняется для каждой затронутой строки.

-- 	4.	Результат:
-- При обновлении books.price, в таблицу books_price_log автоматически вставится запись, 
-- фиксирующая старую и новую цену и время изменения.
--
-- Дополнительные советы
-- 	•	При отладке функций и процедур в PostgreSQL удобно использовать RAISE NOTICE 'Message'; 
--     внутри тела, чтобы видеть промежуточные результаты или текущее состояние переменных.
-- 	•	Обязательно указывай RETURN NEW; (для INSERT/UPDATE) или RETURN OLD; (для DELETE), 
--     если триггер пишется на уровне строк (row-level), чтобы операция не прерывалась.
-- 	•	Триггер можно делать и BEFORE, если нужно изменить данные до записи в таблицу. 
--     Например, установить поле updated_at = NOW() или скорректировать входные данные.
--
--
-- Домашнее задание
--  1. Создать функцию, которая будет возвращать количество фильмов в заданном жанре.
-- 	2. Создать хранимую процедуру, которая будет удалять все фильмы, выпущенные до заданного года.
-- 	3. Создать триггер, который будет автоматически устанавливать дату создания фильма при его добавлении.
--

-- 1. Создать функцию, которая будет возвращать количество фильмов в заданном жанре.
CREATE OR REPLACE FUNCTION get_movie_count_by_genre(genre_name text)
RETURNS integer AS
$$
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
SELECT get_movie_count_by_genre('Action');

-- 2. Создать хранимую процедуру, которая будет удалять все фильмы, выпущенные до заданного года.
CREATE OR REPLACE PROCEDURE delete_movies_before(in_year INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM movies
    WHERE year < in_year;
END;
$$;
CALL delete_movies_before(2000);

-- 3. Создать триггер, который будет автоматически устанавливать дату создания фильма при его добавлении.
ALTER TABLE movies ADD COLUMN creation_date DATE;

CREATE OR REPLACE FUNCTION set_creation_date()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.creation_date := CURRENT_DATE;
    RETURN NEW; 
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_creation_date
BEFORE INSERT ON movies
FOR EACH ROW
EXECUTE FUNCTION set_creation_date();

INSERT INTO movies (name, year, availability)
VALUES
    ('Dark Knight', 2008, TRUE);
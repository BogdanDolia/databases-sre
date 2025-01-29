## 1. Типы данных

При проектировании базы данных важно выбрать правильные типы данных для каждого столбца. Вот основные категории:

- **Числовые типы**:
  - `INTEGER`, `SMALLINT`, `BIGINT` для целых чисел.
  - `DECIMAL`, `NUMERIC`, `FLOAT` для чисел с плавающей точкой.

  *Пример*: для хранения количества копий или зарплаты часто используют `NUMERIC(10,2)`.

- **Строковые типы**:
  - `VARCHAR(n)`, `CHAR(n)` – переменной и фиксированной длины соответственно.
  - `TEXT` – для больших объёмов текста.

- **Дата и время**:
  - `DATE`, `TIME`, `TIMESTAMP` для хранения даты и/или времени.

- **Другие типы данных**:
  - `BOOLEAN` для хранения логических значений (`true/false`).
  - `JSON/JSONB` (в PostgreSQL) – для хранения данных в формате JSON.
  - Специализированные типы (например, географические данные).

> **Замечание**: Выбор типа данных влияет на точность хранения, скорость выполнения запросов и использование памяти.

---

## 2. Нормальные формы

Нормализация – это процесс организации данных для уменьшения избыточности и предотвращения аномалий обновления. Рассмотрим основные нормальные формы:

### 2.1 Первая нормальная форма (1NF)

- **Определение**: Все столбцы таблицы должны содержать атомарные (неделимые) значения; не должно быть повторяющихся групп.
- **Пример**: Если таблица «Заказы» хранит список товаров в одном поле, это нарушает 1NF. Лучше разделить данные, чтобы каждый товар был в отдельной строке или создать дополнительную таблицу «Заказы_товаров».

### 2.2 Вторая нормальная форма (2NF)

- **Требования**: Таблица находится в 1NF и все неключевые атрибуты полностью зависят от первичного ключа (то есть отсутствует частичная зависимость от части составного ключа).
- **Пример**: Если таблица имеет составной ключ (например, `(order_id, product_id)`), все остальные столбцы должны зависеть от обоих полей целиком, а не от одного из них.

### 2.3 Третья нормальная форма (3NF)

- **Требования**: Таблица находится во 2NF, и никакой неключевой столбец не зависит транзитивно (через другой неключевой столбец) от первичного ключа.
- **Пример**: Если в таблице «Сотрудники» хранится информация о департаменте, и в этом же ряду повторяется название менеджера департамента (что может быть получено из отдельной таблицы «Департаменты»), — это транзитивная зависимость. Для устранения избыточности данные о департаментах лучше хранить в отдельной таблице.

> **Общее правило**:  
> Нормализация помогает снизить избыточность, улучшает целостность данных, но чрезмерная нормализация может привести к избыточным соединениям (`JOIN`’ам). В проектах часто используют баланс между нормализацией и денормализацией в зависимости от требований к производительности.

---

## 3. Проектирование таблиц

При проектировании базы данных необходимо:

1. **Определить предметную область**:
   - Какие данные будут храниться, какие объекты являются ключевыми.
   - *Например*, для кинотеатра: фильмы, жанры, сеансы, билеты и т.д.

2. **Определить сущности и связи**:
   - Определить сущности (таблицы) и отношения между ними (один-ко-многим, многие-ко-многим).
   - *Пример*: «Фильмы» (`movies`) и «Жанры» (`genres`) связаны отношением многие-ко-многим. Для этого создаётся промежуточная таблица (`movie_genres`).

3. **Определить первичные и внешние ключи**:
   - Каждая таблица должна иметь первичный ключ (уникальный идентификатор).
   - Внешние ключи используются для установления связей между таблицами.

4. **Учитывать нормализацию**:
   - Применить принципы нормальных форм для предотвращения избыточности.

5. **Дополнительные соображения**:
   - Какие индексы нужны для ускорения поиска?
   - Как будут проводиться обновления данных, какие ограничения (`constraints`) установить (например, уникальность, `NOT NULL`, `CHECK`)?

**Пример проектирования небольшой схемы для кинотеатра**:

1. **Таблица `movies`**:
   - `movie_id (SERIAL PRIMARY KEY)`
   - `name (VARCHAR)`
   - `year (SMALLINT)`
   - `availability (BOOLEAN)`
   - `copy_available (INTEGER)`

2. **Таблица `genres`**:
   - `genre_id (SERIAL PRIMARY KEY)`
   - `name (VARCHAR)`

3. **Таблица `movie_genres`**: (для связи многие-ко-многим)
   - `movie_genre_id (SERIAL PRIMARY KEY)`
   - `movie_id (INTEGER, FOREIGN KEY ссылается на movies(movie_id))`
   - `genre_id (INTEGER, FOREIGN KEY ссылается на genres(genre_id))`

Эта схема соответствует нормальным формам (1NF, 2NF, 3NF) за счёт разделения данных на связанные таблицы.

---

## Пример

### 1. Проектирование схемы БД

**Предметная область**: Онлайн-магазин книг

**Основные сущности (таблицы) и связи между ними**:
1. **Книги (Books)**
   - Хранит информацию о книгах, доступных в магазине.
2. **Авторы (Authors)**
   - Хранит информацию об авторах книг.
3. **Категории (Categories)**
   - Хранит различные категории или жанры книг.
4. **Пользователи (Users)**
   - Хранит информацию о клиентах магазина.
5. **Заказы (Orders)**
   - Хранит информацию о заказах, сделанных пользователями.
6. **Заказанные книги (Order_Items)**
   - Хранит информацию о конкретных книгах в каждом заказе.

**Связи между сущностями**:
- **Книги** и **Авторы**: Многие-ко-многим (одна книга может иметь нескольких авторов, и один автор может написать несколько книг). Для реализации связи создается промежуточная таблица `Book_Authors`.
- **Книги** и **Категории**: Многие-ко-многим (одна книга может принадлежать к нескольким категориям, и одна категория может включать несколько книг). Для реализации связи создается промежуточная таблица `Book_Categories`.
- **Пользователи** и **Заказы**: Один-ко-многим (один пользователь может сделать несколько заказов).
- **Заказы** и **Заказанные книги**: Один-ко-многим (один заказ может содержать несколько книг).

---

### 2. Определение ключей и типов данных

**Таблицы и их структуры**:

1. **Authors (Авторы)**
   - `author_id SERIAL PRIMARY KEY`: Уникальный идентификатор автора.
   - `first_name VARCHAR(50) NOT NULL`: Имя автора.
   - `last_name VARCHAR(50) NOT NULL`: Фамилия автора.
   - `bio TEXT`: Биография автора (опционально).

2. **Categories (Категории)**
   - `category_id SERIAL PRIMARY KEY`: Уникальный идентификатор категории.
   - `name VARCHAR(100) NOT NULL UNIQUE`: Название категории.

3. **Books (Книги)**
   - `book_id SERIAL PRIMARY KEY`: Уникальный идентификатор книги.
   - `title VARCHAR(255) NOT NULL`: Название книги.
   - `description TEXT`: Описание книги.
   - `price DECIMAL(10,2) NOT NULL`: Цена книги.
   - `publication_date DATE`: Дата публикации.
   - `stock_quantity INTEGER NOT NULL`: Количество доступных копий.

4. **Book_Authors (Авторы_Книг)**
   - `book_id INTEGER NOT NULL`: Внешний ключ на `Books(book_id)`.
   - `author_id INTEGER NOT NULL`: Внешний ключ на `Authors(author_id)`.
   - `PRIMARY KEY (book_id, author_id)`: Составной первичный ключ.

5. **Book_Categories (Книги_Категорий)**
   - `book_id INTEGER NOT NULL`: Внешний ключ на `Books(book_id)`.
   - `category_id INTEGER NOT NULL`: Внешний ключ на `Categories(category_id)`.
   - `PRIMARY KEY (book_id, category_id)`: Составной первичный ключ.

6. **Users (Пользователи)**
   - `user_id SERIAL PRIMARY KEY`: Уникальный идентификатор пользователя.
   - `username VARCHAR(50) NOT NULL UNIQUE`: Имя пользователя.
   - `password_hash VARCHAR(255) NOT NULL`: Хэш пароля.
   - `email VARCHAR(100) NOT NULL UNIQUE`: Электронная почта.
   - `first_name VARCHAR(50)`: Имя.
   - `last_name VARCHAR(50)`: Фамилия.
   - `created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`: Дата и время регистрации.

7. **Orders (Заказы)**
   - `order_id SERIAL PRIMARY KEY`: Уникальный идентификатор заказа.
   - `user_id INTEGER NOT NULL`: Внешний ключ на `Users(user_id)`.
   - `order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP`: Дата и время заказа.
   - `status VARCHAR(50) NOT NULL`: Статус заказа (например, “В обработке”, “Доставлен”).

8. **Order_Items (Заказанные_Книги)**
   - `order_item_id SERIAL PRIMARY KEY`: Уникальный идентификатор записи.
   - `order_id INTEGER NOT NULL`: Внешний ключ на `Orders(order_id)`.
   - `book_id INTEGER NOT NULL`: Внешний ключ на `Books(book_id)`.
   - `quantity INTEGER NOT NULL`: Количество экземпляров книги в заказе.
   - `unit_price DECIMAL(10,2) NOT NULL`: Цена за единицу на момент заказа.

**Зависимости через внешние ключи**:
- `Book_Authors`: `book_id` ссылается на `Books(book_id)`, `author_id` ссылается на `Authors(author_id)`.
- `Book_Categories`: `book_id` ссылается на `Books(book_id)`, `category_id` ссылается на `Categories(category_id)`.
- `Orders`: `user_id` ссылается на `Users(user_id)`.
- `Order_Items`: `order_id` ссылается на `Orders(order_id)`, `book_id` ссылается на `Books(book_id)`.

---

### 3. Нормализация

#### Первая нормальная форма (1NF)

**Требования**:
- Все столбцы содержат атомарные (неделимые) значения.
- Отсутствуют повторяющиеся группы или массивы данных.

**Применение**:
- Каждая таблица имеет уникальный первичный ключ.
- Нет столбцов с множественными значениями (например, список авторов для книги разделён в отдельной таблице `Book_Authors`).

#### Вторая нормальная форма (2NF)

**Требования**:
- Таблица находится в 1NF.
- Все неключевые атрибуты полностью зависят от первичного ключа.

**Применение**:
- В таблицах `Book_Authors` и `Book_Categories` используются составные первичные ключи (`(book_id, author_id)` и `(book_id, category_id)` соответственно), и все неключевые столбцы зависят от всего составного ключа.
- В таблицах с одиночными первичными ключами (например, `Books`, `Authors`) все неключевые атрибуты зависят от первичного ключа.

#### Третья нормальная форма (3NF)

**Требования**:
- Таблица находится во 2NF.
- Нет транзитивных зависимостей (неключевой столбец не зависит от другого неключевого столбца).

**Применение**:
- В таблице `Users` все атрибуты зависят непосредственно от `user_id`, нет транзитивных зависимостей.
- В таблице `Orders` все атрибуты зависят непосредственно от `order_id`.
- Таблицы `Book_Authors` и `Book_Categories` не содержат неключевых столбцов, кроме составного ключа.

> **Почему разделение таблиц важно**:
> - Устраняет избыточность данных.
> - Обеспечивает целостность данных через внешние ключи.
> - Облегчает обновление данных без риска несогласованности.

---

### Пример SQL-кода

```sql
-- Таблица Authors (Авторы)
CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    bio TEXT
);

-- Таблица Categories (Категории)
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица Books (Книги)
CREATE TABLE Books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    publication_date DATE,
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

-- Таблица Book_Authors (Авторы_Книг) - связь многие-ко-многим
CREATE TABLE Book_Authors (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Таблица Book_Categories (Книги_Категорий) - связь многие-ко-многим
CREATE TABLE Book_Categories (
    book_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

-- Таблица Users (Пользователи)
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица Orders (Заказы)
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Таблица Order_Items (Заказанные_Книги)
CREATE TABLE Order_Items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);
```

```bash
Users
│
│ 1
│
│ M
Orders
│
│ 1
│
│ M
Order_Items ── M ── Books ── M ── Authors
               │
               │
               └── M ── Categories
```
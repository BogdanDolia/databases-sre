## 1. Data Types

When designing a database, it is important to choose the right data types for each column. Here are the main categories:

- **Numeric types**:
  - `INTEGER`, `SMALLINT`, `BIGINT` for whole numbers.
  - `DECIMAL`, `NUMERIC`, `FLOAT` for floating-point numbers.

  *Example*: `NUMERIC(10,2)` is often used to store quantities or salaries.

- **String types**:
  - `VARCHAR(n)`, `CHAR(n)` – variable and fixed length, respectively.
  - `TEXT` – for large amounts of text.

- **Date and time**:
  - `DATE`, `TIME`, `TIMESTAMP` for storing date and/or time.

- **Other data types**:
  - `BOOLEAN` for storing logical values (`true/false`).
  - `JSON/JSONB` (in PostgreSQL) – for storing JSON-formatted data.
  - Specialized types (e.g., geographic data).

> **Note**: The choice of data type affects storage accuracy, query execution speed, and memory usage.

---

## 2. Normal Forms

Normalization is the process of organizing data to reduce redundancy and prevent update anomalies. Let’s examine the main normal forms:

### 2.1 First Normal Form (1NF)

- **Definition**: All table columns must contain atomic (indivisible) values; there should be no repeating groups.
- **Example**: If the "Orders" table stores a list of items in a single field, it violates 1NF. It is better to split the data so that each item is in a separate row or create an additional "Order_Items" table.

### 2.2 Second Normal Form (2NF)

- **Requirements**: The table is in 1NF, and all non-key attributes fully depend on the primary key (i.e., no partial dependency on part of a composite key).
- **Example**: If a table has a composite key (e.g., `(order_id, product_id)`), all other columns must depend on both fields entirely, not just one of them.

### 2.3 Third Normal Form (3NF)

- **Requirements**: The table is in 2NF, and no non-key column depends transitively (through another non-key column) on the primary key.
- **Example**: If the "Employees" table stores department information and also repeats the department manager's name (which can be obtained from a separate "Departments" table), this is a transitive dependency. To eliminate redundancy, department data should be stored in a separate table.

> **General rule**:  
> Normalization helps reduce redundancy and improves data integrity, but excessive normalization can lead to excessive joins (`JOIN`s). In projects, a balance between normalization and denormalization is often used depending on performance requirements.

---

## 3. Table Design

When designing a database, you need to:

1. **Define the subject area**:
   - What data will be stored? What are the key objects?
   - *Example*: For a cinema, key entities include movies, genres, screenings, tickets, etc.

2. **Define entities and relationships**:
   - Identify entities (tables) and their relationships (one-to-many, many-to-many).
   - *Example*: "Movies" (`movies`) and "Genres" (`genres`) have a many-to-many relationship. A junction table (`movie_genres`) is created to manage this relationship.

3. **Define primary and foreign keys**:
   - Each table should have a primary key (unique identifier).
   - Foreign keys establish relationships between tables.

4. **Consider normalization**:
   - Apply normalization principles to prevent redundancy.

5. **Additional considerations**:
   - What indexes are needed to speed up searches?
   - How will data updates be handled? What constraints (`constraints`) should be enforced (e.g., uniqueness, `NOT NULL`, `CHECK`)?

**Example of designing a small database schema for a cinema**:

1. **Table `movies`**:
   - `movie_id (SERIAL PRIMARY KEY)`
   - `name (VARCHAR)`
   - `year (SMALLINT)`
   - `availability (BOOLEAN)`
   - `copy_available (INTEGER)`

2. **Table `genres`**:
   - `genre_id (SERIAL PRIMARY KEY)`
   - `name (VARCHAR)`

3. **Table `movie_genres`**: (to manage the many-to-many relationship)
   - `movie_genre_id (SERIAL PRIMARY KEY)`
   - `movie_id (INTEGER, FOREIGN KEY referencing movies(movie_id))`
   - `genre_id (INTEGER, FOREIGN KEY referencing genres(genre_id))`

This schema complies with normal forms (1NF, 2NF, 3NF) by splitting data into related tables.

---

## Example

### 1. Database Schema Design

**Subject area**: Online bookstore

**Main entities (tables) and their relationships**:
1. **Books (Books)**
   - Stores information about books available in the store.
2. **Authors (Authors)**
   - Stores information about book authors.
3. **Categories (Categories)**
   - Stores different categories or genres of books.
4. **Users (Users)**
   - Stores customer information.
5. **Orders (Orders)**
   - Stores information about user orders.
6. **Ordered books (Order_Items)**
   - Stores details about specific books in each order.

**Relationships between entities**:
- **Books** and **Authors**: Many-to-many (one book can have multiple authors, and one author can write multiple books). This relationship is implemented through the `Book_Authors` junction table.
- **Books** and **Categories**: Many-to-many (one book can belong to multiple categories, and one category can contain multiple books). This relationship is implemented through the `Book_Categories` junction table.
- **Users** and **Orders**: One-to-many (one user can place multiple orders).
- **Orders** and **Ordered Books**: One-to-many (one order can contain multiple books).

---

### 2. Defining Keys and Data Types

**Tables and their structures**:

1. **Authors**
   - `author_id SERIAL PRIMARY KEY`: Unique identifier for the author.
   - `first_name VARCHAR(50) NOT NULL`: Author’s first name.
   - `last_name VARCHAR(50) NOT NULL`: Author’s last name.
   - `bio TEXT`: Author’s biography (optional).

2. **Categories**
   - `category_id SERIAL PRIMARY KEY`: Unique category identifier.
   - `name VARCHAR(100) NOT NULL UNIQUE`: Category name.

3. **Books**
   - `book_id SERIAL PRIMARY KEY`: Unique book identifier.
   - `title VARCHAR(255) NOT NULL`: Book title.
   - `description TEXT`: Book description.
   - `price DECIMAL(10,2) NOT NULL`: Book price.
   - `publication_date DATE`: Publication date.
   - `stock_quantity INTEGER NOT NULL`: Available copies.

4. **Book_Authors**
   - `book_id INTEGER NOT NULL`: Foreign key referencing `Books(book_id)`.
   - `author_id INTEGER NOT NULL`: Foreign key referencing `Authors(author_id)`.
   - `PRIMARY KEY (book_id, author_id)`: Composite primary key.

5. **Book_Categories**
   - `book_id INTEGER NOT NULL`: Foreign key referencing `Books(book_id)`.
   - `category_id INTEGER NOT NULL`: Foreign key referencing `Categories(category_id)`.
   - `PRIMARY KEY (book_id, category_id)`: Composite primary key.

6. **Users**
   - `user_id SERIAL PRIMARY KEY`: Unique user identifier.
   - `username VARCHAR(50) NOT NULL UNIQUE`: Username.
   - `password_hash VARCHAR(255) NOT NULL`: Password hash.
   - `email VARCHAR(100) NOT NULL UNIQUE`: Email.
   - `first_name VARCHAR(50)`: First name.
   - `last_name VARCHAR(50)`: Last name.
   - `created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`: Registration date and time.

7. **Orders**
   - `order_id SERIAL PRIMARY KEY`: Unique order identifier.
   - `user_id INTEGER NOT NULL`: Foreign key referencing `Users(user_id)`.
   - `order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP`: Order date and time.
   - `status VARCHAR(50) NOT NULL`: Order status (e.g., “Processing,” “Delivered”).

8. **Order_Items**
   - `order_item_id SERIAL PRIMARY KEY`: Unique record identifier.
   - `order_id INTEGER NOT NULL`: Foreign key referencing `Orders(order_id)`.
   - `book_id INTEGER NOT NULL`: Foreign key referencing `Books(book_id)`.
   - `quantity INTEGER NOT NULL`: Number of book copies in the order.
   - `unit_price DECIMAL(10,2) NOT NULL`: Unit price at the time of order.

---

### 3. Normalization

### First Normal Form (1NF)

**Requirements**:
- All columns contain atomic (indivisible) values.
- No repeating groups or array data.

**Application**:
- Each table has a unique primary key.
- There are no columns with multiple values (for example, a list of authors for a book is stored in a separate `Book_Authors` table).

### Second Normal Form (2NF)

**Requirements**:
- The table is in 1NF.
- All non-key attributes fully depend on the primary key.

**Application**:
- The `Book_Authors` and `Book_Categories` tables use composite primary keys (`(book_id, author_id)` and `(book_id, category_id)`, respectively), and all non-key columns depend on the entire composite key.
- In tables with single primary keys (e.g., `Books`, `Authors`), all non-key attributes depend on the primary key.

### Third Normal Form (3NF)

**Requirements**:
- The table is in 2NF.
- No transitive dependencies (a non-key column does not depend on another non-key column).

**Application**:
- In the `Users` table, all attributes depend directly on `user_id`, with no transitive dependencies.
- In the `Orders` table, all attributes depend directly on `order_id`.
- The `Book_Authors` and `Book_Categories` tables do not contain non-key columns apart from the composite key.

### Why Table Separation is Important:

- Eliminates data redundancy.
- Ensures data integrity through foreign keys.
- Facilitates data updates without the risk of inconsistencies.

### Example SQL Code

```sql
CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    bio TEXT
);

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
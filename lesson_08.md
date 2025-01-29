## Day 8. Transactions and Concurrency Control

### Session Goals
1. Understand the concept of transactions and the ACID principle:
   - What atomicity, consistency, isolation, and durability mean.
   - Why transactions are needed and how they help maintain data integrity.
2. Study database isolation levels:
   - READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE.
   - How they differ and their impact on data concurrency.
3. Learn about locking (locks) and deadlocks:
   - Types of locks (row-level, table-level).
   - How to avoid and resolve deadlock situations.
4. Practical exercises:
   - Experiments with isolation levels and locks.
   - Demonstration of how different isolation levels affect query results and parallel database operations.

---

## 1. Transactions and ACID

A transaction is a logical unit of work with data that either completes fully or is rolled back entirely if something goes wrong.

### ACID
1. **Atomicity**
   - All operations within a transaction are treated as a single unit.
   - If any operation fails, all changes are rolled back to the state before the transaction started.
2. **Consistency**
   - A transaction must take the database from one consistent state to another.
   - In case of failure, the database remains in its original consistent state (thanks to rollback).
3. **Isolation**
   - Two parallel transactions should not unpredictably affect each other.
   - Each transaction sees the data as if it operates alone (to some extent).
4. **Durability**
   - If a transaction is committed, its results are not lost even in the event of a failure.
   - In PostgreSQL, this is ensured through WAL (Write-Ahead Logging) and other mechanisms.

**Example transaction usage (PostgreSQL):**
```sql
BEGIN;  -- Start transaction

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 2;

COMMIT;  -- Commit changes
```
If an error occurs during the fund transfer, we execute `ROLLBACK`, and all changes within this transaction are undone.

---

## 2. Isolation Levels

Databases allow configuring the isolation level, defining which "dirty" and "phantom" data a transaction can see.

1. **READ UNCOMMITTED**
   - The least strict level, allowing reading uncommitted (dirty) data.
   - Not supported in pure form in PostgreSQL—effectively equivalent to READ COMMITTED.
2. **READ COMMITTED** (default in PostgreSQL)
   - Each command inside a transaction sees only changes committed before its execution.
   - If another transaction commits between two commands, the second command will see new data.
3. **REPEATABLE READ**
   - A transaction "sees" data as it was at the start of the transaction, even if other transactions modify it.
   - Prevents phantom reads in PostgreSQL since version 9.1.
4. **SERIALIZABLE**
   - The strictest level. Transactions execute as if they were running sequentially.
   - "Serialization failures" may occur if the DB detects an isolation violation and rolls back the transaction.

**Example of manually setting isolation level:**
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN;
-- ... operations ...
COMMIT;
```

---

## 3. Locks and Deadlocks

### 3.1 Locking Mechanism

To maintain data consistency, databases use locks. Main types of locks in PostgreSQL:

- **Row-level locks**
  - When executing `UPDATE/DELETE`, a row is locked so that other transactions cannot modify it.
  - However, reading is not blocked.
- **Table-level locks**
  - PostgreSQL enforces various lock modes (`ACCESS SHARE`, `ROW EXCLUSIVE`, etc.).
  - For example, `ALTER TABLE` requires an exclusive lock on the entire table, preventing concurrent reads/writes.

### 3.2 Deadlocks

**Deadlock** occurs when two or more transactions wait on each other without releasing resources:
1. Transaction A locks row X and attempts to update row Y.
2. Transaction B locks row Y and attempts to update row X.

Both transactions wait for each other, leading to a "deadlock" situation.

**Example:**
```sql
-- Transaction A
BEGIN;
UPDATE table1 SET ... WHERE id = 10;  -- Locks row id=10
UPDATE table1 SET ... WHERE id = 20;  -- Attempts to lock row id=20

-- Transaction B
BEGIN;
UPDATE table1 SET ... WHERE id = 20;  -- Locks row id=20
UPDATE table1 SET ... WHERE id = 10;  -- Attempts to lock row id=10
```

PostgreSQL detects deadlocks and rolls back one of the transactions with an error:
```text
ERROR: deadlock detected
```

### How to Avoid Deadlocks?
- Always acquire locks in the same order (e.g., first `id=10`, then `id=20`).
- Minimize the time transactions hold locks—avoid long-running transactions.
- Separate read/write operations: first execute necessary `SELECT` statements in `READ COMMITTED`, then perform short `UPDATE` transactions.

---

## Experiment: Isolation Levels

### Goal
Understand how different isolation levels (`READ COMMITTED` and `REPEATABLE READ`) affect visibility of changes in parallel transactions.

### Steps
1. Open two PostgreSQL sessions/windows.

#### Session A (READ COMMITTED):
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM accounts;
```

#### Session B (REPEATABLE READ):
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM accounts;
```

2. Execute an update in session A:
```sql
UPDATE accounts
SET balance = balance + 100
WHERE owner_name = 'Alice';
```

3. Run `SELECT` in both sessions and compare results.

4. Commit in session A:
```sql
COMMIT;
```

5. Run `SELECT` in session B: the data might not change until a new transaction starts.

**Conclusion:**
- `READ COMMITTED` sees the latest committed changes.
- `REPEATABLE READ` keeps a snapshot of data from the transaction's start.

---

## Experiment: Locking

### Goal
Observe how PostgreSQL locks rows.

### Steps

#### Session 1:
```sql
BEGIN;
UPDATE accounts
SET balance = balance + 300
WHERE owner_name = 'Bob';
```

#### Session 2 (will wait for unlock):
```sql
BEGIN;
UPDATE accounts
SET balance = balance + 200
WHERE owner_name = 'Bob';
```

Session 2 will hang until session 1 commits:
```sql
COMMIT;
```

**Conclusion:** PostgreSQL prevents simultaneous modifications of a row.

---

## Experiment: Deadlock Demonstration

### Goal
Create a deadlock.

### Steps

#### Session A:
```sql
BEGIN;
UPDATE accounts
SET balance = balance + 10
WHERE owner_name = 'Eve';
```

#### Session B:
```sql
BEGIN;
UPDATE accounts
SET balance = balance + 20
WHERE owner_name = 'Frank';
```

#### Session A:
```sql
UPDATE accounts
SET balance = balance + 10
WHERE owner_name = 'Frank';
```

#### Session B:
```sql
UPDATE accounts
SET balance = balance + 20
WHERE owner_name = 'Eve';
```

PostgreSQL will detect a deadlock and rollback one transaction with an error:
```text
ERROR: deadlock detected
```

**Conclusion:** Deadlocks occur when transactions lock resources in different orders.

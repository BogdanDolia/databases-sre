# Day 9. Security and Access Control

## Session Goals

1. **Familiarize with basic authentication mechanisms and user/role management**:
   - Creating users and roles in PostgreSQL.
   - Differences between a user and a role.
   - Authentication methods (md5, scram-sha-256, trust, etc.).

2. **Study GRANT and REVOKE commands**:
   - How to grant and revoke permissions on objects (tables, schemas, functions, sequences, etc.).
   - Inheritance of permissions through role groups.

3. **Understand encryption basics**:
   - Encryption of communication channels (SSL/TLS).
   - Data encryption at the file system or application level.
   - Basic approaches to protecting confidential data.

4. **Learn how to test query execution and permissions**:
   - How to test different users' access to tables and other objects.
   - Logs and event audit checks.

---

## 1. Users and Roles in PostgreSQL

### 1.1 Roles

In PostgreSQL, both users and groups are called **roles**. The only difference is that a role may have login capability (`LOGIN`) or not.

- **CREATE ROLE** — creates a role (can be a "group" or "user").
- **CREATE USER** — a simplified syntax for a role with the `LOGIN` option.

### 1.2 Role Creation Examples

```sql
-- Create a simple user:
CREATE USER alice WITH PASSWORD 'alicepass';

-- Create a developer role without login capability (a group):
CREATE ROLE dev_team;

-- Add user alice to the dev_team role:
GRANT dev_team TO alice;

-- Create user bob with database creation privileges (CREATEDB)
CREATE USER bob WITH PASSWORD 'bobpass' CREATEDB;
```

### 1.3 Authentication Parameters

The `pg_hba.conf` configuration file specifies connection rules (`host`, `local`), databases, roles, and authentication methods (`md5`, `scram-sha-256`, `trust`, `peer`, etc.).

Example `pg_hba.conf` entry:

```
host    all             all             0.0.0.0/0       md5
```

This means that for all users (`all`), for all databases (`all`), from any IP address (`0.0.0.0/0`), the password authentication method `md5` is used.

## 2. Access Control (GRANT, REVOKE)

### 2.1 GRANT Command

Grants permissions on objects (tables, schemas, functions) to specific roles.

```sql
GRANT SELECT, INSERT ON TABLE books TO alice;
```

- Grants `SELECT` and `INSERT` permissions on the `books` table to user `alice`.

Other variations:
- `GRANT UPDATE, DELETE` — allows modifying/deleting rows.
- `GRANT ALL PRIVILEGES` — grants all permissions.

### 2.2 REVOKE Command

Revokes previously granted permissions.

```sql
REVOKE INSERT ON TABLE books FROM alice;
```

- Now `alice` can no longer insert rows into the `books` table.

### 2.3 Permission Inheritance

If a user is part of a role (group) that has permissions, the user inherits those permissions.

```sql
-- Grant permissions to a group:
GRANT SELECT ON TABLE books TO dev_team;
```

- All users in `dev_team` can now read from the `books` table.

## 3. Encryption (Basic Approaches)

### 3.1 Connection Encryption (SSL/TLS)

- PostgreSQL supports SSL connections to encrypt data transmission.
- This requires a certificate on the server and corresponding settings in `postgresql.conf` and `pg_hba.conf`:

```ini
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

And in `pg_hba.conf`:

```
hostssl all all 0.0.0.0/0 scram-sha-256
```

### 3.2 Data Encryption at Disk Level

- PostgreSQL does not have built-in full database encryption.
- Typically, OS-level solutions (`LUKS`, `BitLocker`, etc.) or plugins/extensions (`pgcrypto`) are used.
- `pgcrypto` allows encrypting specific fields in tables.

```sql
-- Example using pgcrypto to encrypt a column:
INSERT INTO users (username, secret_data)
VALUES (
  'Bob',
  pgp_sym_encrypt('Some secret info', 'my_secret_key')
);
```

## 4. Query Execution Testing and Logging

### 4.1 PostgreSQL Logs

- Log files (e.g., `postgresql-<date>.log`) contain information about connections, errors, executed commands (depending on settings).
- Logging settings example:

```ini
log_statement = 'all'
log_connections = on
log_disconnections = on
```

Then restart or use `pg_ctl reload`.

### 4.2 Permission Testing

- Log in as different users (`alice`, `bob`) and attempt commands (`SELECT`, `INSERT`, `UPDATE`, `CREATE TABLE`).
- If you receive an error like `ERROR: permission denied for relation books`, the role lacks necessary permissions.

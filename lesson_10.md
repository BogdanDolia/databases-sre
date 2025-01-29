# Day 10. Advanced Scenarios for SRE

## Session Goals

1. **Understand the key approaches to backup and recovery**:
   - Different types of backups (physical, logical).
   - Point-In-Time Recovery (PITR).
   - Tools and commands (pg_dump, pg_restore, pg_basebackup).

2. **Familiarize with basic monitoring mechanisms**:
   - Database metrics: number of connections, latency, CPU/RAM usage, I/O.
   - Built-in PostgreSQL views (pg_stat_activity, pg_stat_database, pg_stat_bgwriter, etc.).
   - External monitoring tools.

3. **Study performance optimization approaches**:
   - Use of caching.
   - Horizontal scaling and sharding (general concept).
   - The role of SRE in analyzing and optimizing high-load systems.

4. **Prepare for an SRE interview**:
   - Example questions and tasks that may appear in interviews.
   - A comprehensive assignment integrating topics from previous days.

---

## 1. Backup and Recovery

### 1.1 Types of Backups

1. **Physical Backup**  
   - Directly saving PostgreSQL data files (copying the /data directory).  
   - Suitable for large databases where fast recovery in the same environment is essential.  
   - Convenient tools: `pg_basebackup` or third-party solutions.

2. **Logical Backup**  
   - `pg_dump` / `pg_dumpall`, which generate SQL scripts or data archives.  
   - Useful for migrations or restoring specific tables/schemas.

### 1.2 Point-in-time Recovery (PITR)

- Allows recovery not only to the last backup but also to a specific point in time (e.g., before an error).  
- Requires setting up **WAL (Write-Ahead Log) archiving**.  
- Process: restore a physical backup + apply WAL segments up to the desired point.

#### PITR Key Steps

1. Enable archiving in `postgresql.conf`:
```conf
wal_level = replica
archive_mode = on
archive_command = 'cp %p /path/to/archive/%f'
```

2. Take a base backup (e.g., using pg_basebackup).
3. During recovery:
   - Stop the server,
   - Copy the backup files,
   - Specify `restore_command` and `recovery_target_time` in `recovery.conf` (or `postgresql.conf` in modern versions).
   - Start the server: PostgreSQL will apply WAL segments until the specified moment is reached.

## 2. Monitoring

### 2.1 Built-in PostgreSQL Views

1. **pg_stat_activity**  
   - Contains information about all active sessions (processes).
   - Useful for checking active queries, identifying long-running transactions.

2. **pg_stat_database**  
   - General database statistics (number of queries, read/write operations, connection count).

3. **pg_stat_bgwriter**  
   - Information about background buffer writer processes.

4. **pg_locks**  
   - Current locks; can be used to identify blockers and potential deadlocks.

### 2.2 External Monitoring Tools

- `pgAdmin`, `pganalyze`, `Prometheus + Grafana`: collecting and visualizing database metrics (connections, latencies, table sizes, indexing, etc.).
- `Zabbix`, `Datadog`, `New Relic`, and other services that integrate with PostgreSQL.

## 3. Performance Optimization

### 3.1 Caching

- `Shared buffers` (PostgreSQL parameter) determines how much memory is allocated for data caching.
- External caching (`Redis`, `Memcached`) is sometimes used when very fast responses are required without accessing the database.

### 3.2 Sharding and Scaling

- **Horizontal scaling**: splitting data across multiple servers (shards).
- PostgreSQL can implement distributed tables (`FDW`, `pg_shard`, `Citus`) for high loads.
- **SRE's Role**: ensuring high availability, disaster recovery (geo-replication), monitoring load balancing.

## 4. Interview/Practice: Sample Tasks and Questions

### 4.1 Common Questions

1. How do you set up and verify PostgreSQL replication?
2. How do you implement Point-in-time recovery?
3. What isolation levels exist in PostgreSQL, and how do they impact concurrency?
4. How do you create indexes and analyze query plans (`EXPLAIN`)?
5. What are transactions, block reads, and `deadlocks`?
6. How would you set up PostgreSQL monitoring, and what key metrics are important?

### 4.2 Sample Practical Tasks

1. Perform a backup using `pg_dump`, then delete a table and restore it from the backup.
2. Set up PITR: enable WAL archiving, simulate "data deletion," and roll back to a point before deletion.
3. Configure monitoring: collect metrics on active connections, slow queries, and locks.
4. Analyze a "heavy" query using `EXPLAIN ANALYZE`, suggest indexes and/or query modifications for optimization.

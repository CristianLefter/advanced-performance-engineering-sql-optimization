# Lab 05 – Query Refactoring: Less Data, Less Work

## Goal
We refactor a query so it does **less work**:
- return fewer columns (narrower rows)
- filter earlier (reduce row flow)
- avoid unnecessary DISTINCT / ORDER BY work

We’ll run “before/after” on **Postgres** and **SQL Server**, capture plans + runtime/IO, and write down what changed.

## What we measure (evidence)
### Postgres
- `EXPLAIN (ANALYZE, BUFFERS)` for **before** and **after**
- Look for:
  - fewer rows flowing through nodes
  - lower buffer reads
  - sorts removed or reduced
  - joins fed by smaller inputs

### SQL Server
- Actual execution plan (include it in screenshots or exported `.sqlplan`)
- `SET STATISTICS IO, TIME ON`
- Look for:
  - fewer logical reads
  - reduced CPU / elapsed time
  - sorts removed or reduced
  - join strategy improvements (often a side-effect)

## Setup
This lab uses **lab-only tables** created by the scripts (no dependency on other labs).

- Postgres scripts:
  - `scripts/postgres/50_sort_spill.sql` (baseline heavy work)
  - `scripts/postgres/51_sort_fix.sql`  (refactored: less data, less work)

- SQL Server scripts:
  - `scripts/sqlserver/50_sort_spill.sql` (baseline heavy work)
  - `scripts/sqlserver/51_sort_fix.sql`  (refactored: less data, less work)

## Run – Postgres
### 1) Baseline (“before”)
Run:

```bash
psql -h postgres -U postgres -d perf_lab -f scripts/postgres/50_sort_spill.sql
```

Capture:
- the `EXPLAIN (ANALYZE, BUFFERS)` output

### 2) Refactor (“after”)
Run:

```bash
psql -h postgres -U postgres -d perf_lab -f scripts/postgres/51_sort_fix.sql
```

Capture:
- the `EXPLAIN (ANALYZE, BUFFERS)` output

### Notes to write down
- Did the plan avoid an explicit Sort?
- Did the query return fewer columns?
- Were buffers and total time reduced?

## Run – SQL Server
### 1) Baseline (“before”)
Run:

```bash
sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/50_sort_spill.sql
```

Capture:
- `STATISTICS IO/TIME`
- actual plan (ideally)

### 2) Refactor (“after”)
Run:

```bash
sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/51_sort_fix.sql
```

Capture:
- `STATISTICS IO/TIME`
- actual plan (ideally)

### Notes to write down
- Did the index support the `ORDER BY`?
- Did reads and elapsed time drop?
- Any spill/sort warnings disappear?

## What we learned
**Query refactoring** is performance work even before indexes:
- returning fewer columns reduces memory, network, and sometimes spills
- filtering earlier reduces join input sizes and sort sizes
- supporting indexes can remove sorts entirely

## Cleanup (optional)
Lab tables are isolated:
- Postgres: `public.lab05_sort_demo`
- SQL Server: `dbo.Lab05SortDemo`

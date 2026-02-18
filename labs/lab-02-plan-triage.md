# Lab 02 – Plan triage: find the signal fast (SQL Server + Postgres)

## Goal
In 5 minutes, decide:
1) where most of the work happens
2) what the first fix should be (query rewrite, index, stats, or “stop and measure more”)

## What we capture (Before)
### PostgreSQL
- `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` output
- note: top nodes + time + buffers

### SQL Server
- Actual plan (in VS Code MSSQL extension)
- `SET STATISTICS IO, TIME ON` output

## Triage checklist (both engines)
### 1) Start at the top: elapsed time + where it accumulates
- Which node(s) dominate **actual time**?
- Is the time CPU-bound or I/O-bound?

### 2) Look for the classic red flags
- Big **scans** (Seq Scan / Table Scan / Clustered Index Scan)
- Large **sorts** (Sort operator, high memory / spills)
- **Nested loops** with large outer input
- **Hash join** with spills / high memory
- Repeated **key lookups** / row-by-row probes
- “Rows Removed by Filter” is huge (filter applied late)
- Estimates wildly off vs actual (cardinality issue)

### 3) Decide the first intervention
- Can we **filter earlier** / make predicate SARGable?
- Is this missing a **supporting index** (ESR: equality, sort/range, return columns)?
- Do we have a **stats/selectivity** problem?
- Are we sorting because of ORDER BY we can avoid or support with index?

## Your task
1) Re-run the baseline query from Lab 01 in both engines.
2) Fill in: top 3 red flags + your “first fix” hypothesis.
3) Implement only ONE change and re-measure.

(Next labs will formalize each fix category.)

## Suggested “one change” for this lab (Query rewrite)
Use the SARGable version of the baseline query:

- PostgreSQL: `scripts/postgres/20_sargable_fix.sql`
- SQL Server: `scripts/sqlserver/20_sargable_fix.sql`

Capture a new Evidence Pack change folder:
`evidence-pack/lab-02/sargable-fix/before` and `after`


> Note: without a supporting index, a SARGable rewrite may not change the access path; and an index can be slower if it introduces physical reads (cold cache).

# Lab 04 – Strategic Indexing (ESR + Covering)

## Goal
Design an index that supports a specific query shape and verify the effect in the plan + metrics.

We’ll use the **ESR** mental model:

- **E**quality predicates first
- **S**ort / range next
- **R**eturn columns (covering) last (engine-dependent)

## The query we tune
Same business question as Lab 01/02:

- recent completed orders
- only VIP / Business customers
- ordered by newest first
- joined to order_items

## Before (capture)
### PostgreSQL
- `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)`
- Identify: is `orders` a Seq Scan? Is there a Sort?

### SQL Server
- Actual plan (VS Code MSSQL extension)
- `SET STATISTICS IO, TIME ON`

Store evidence in:
- `evidence-pack/lab-04/index-esr/before`

## Index design
### PostgreSQL
Use `scripts/postgres/30_index_esr_covering.sql`

What it targets:
- `status` (equality)
- `order_date` (range + supports ordering)
- include/cover: enough columns to reduce heap access (practically, Postgres still may hit heap unless index-only scan is possible)

### SQL Server
Use `scripts/sqlserver/30_index_esr_covering.sql`

What it targets:
- key: `(status, order_date)` (plus customer_id if needed based on your predicate/join)
- INCLUDE: columns needed to avoid key lookups

## Apply the change + re-measure
1) Create the index (script above).
2) Rerun the tuned query (SARGable form).
3) Capture new plan + metrics.

Store evidence in:
- `evidence-pack/lab-04/index-esr/after`

## What to look for
### Plan shape improvements
- `orders` access: Scan → Index/Bitmap/Seek
- Sort removed or reduced
- Fewer reads / buffers
- Reduced CPU/elapsed time (but note cold-cache effects)

### When an index is NOT faster
- Table is small / fully cached
- Predicate is not selective
- Bitmap + heap adds overhead
- Extra writes / maintenance cost outweighs read benefit

## Your output
In your notes:
- the ESR index you chose (key + includes)
- the plan delta (1–3 bullets)
- the metric delta (reads + elapsed)
- trade-offs (write overhead, memory, plan stability)

## Postgres note: index may be ignored (and that can be OK)
PostgreSQL may still choose a Seq Scan even when an ESR index exists, especially when:
- a large fraction of the table qualifies (low selectivity)
- data is warm in cache
- the planner estimates sequential access is cheaper

Use `SET enable_seqscan = off` **only as a diagnostic** to see whether an index-path plan exists and how it would behave.

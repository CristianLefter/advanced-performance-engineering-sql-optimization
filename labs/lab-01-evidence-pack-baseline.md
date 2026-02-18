# Lab 01 – Creating the “Evidence Pack” (Baseline)

## Goal
Before we optimize anything, we standardize what we capture.

We will run the same “slow-ish” query in:
- SQL Server (actual plan + STATISTICS IO/TIME)
- PostgreSQL (EXPLAIN ANALYZE + BUFFERS)

…and save outputs into an **Evidence Pack** folder.

## 1) Create your Evidence Pack folder
Create:

`evidence-pack/lab-01/baseline/`

with:
- `before/`
- `after/`
- `notes.md` (copy from `evidence-pack/template/notes.md`)

For this lab, we only fill **Before**.

## 2) Baseline query (same intent in both engines)
Find recent orders for a frequent customer segment and include line totals.

### SQL Server
Open `scripts/sqlserver/10_baseline_query.sql`

- Use `evidence-pack/collect-sqlserver.sql` wrapper (STATISTICS IO/TIME)
- Include **Actual Execution Plan**
- Save:
  - plan file into `before/`
  - the Messages output (IO/TIME) into `before/metrics.txt`

### PostgreSQL
Open `scripts/postgres/10_baseline_query.sql`

Run:
- `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` version
- Save output into `before/plan.txt`

## 3) What to record in notes.md
- “Red flags” you see
- estimated vs actual row mismatches
- where the work happens (scan? join? sort? lookup?)

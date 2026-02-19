# Lab 07 – Capstone: End-to-End Optimization Challenge

## Goal
We apply the full workflow end-to-end:
1) reproduce a performance complaint
2) capture baseline evidence (plans + IO/time)
3) form hypotheses (what is the bottleneck and why)
4) apply one change at a time (query, index, stats, configuration)
5) verify improvement and record the results
6) add a regression guardrail so performance stays stable

This is intentionally practical: we focus on repeatable steps and evidence.

## Scenario
A reporting query "works sometimes, but randomly becomes slow" and the team wants:
- clear evidence of the bottleneck
- a minimal, safe fix
- a short write-up they can paste into a ticket

We will run the same scenario on:
- Postgres
- SQL Server

## Capstone rules
- Change one thing at a time.
- Always capture a before/after plan and IO/time.
- Prefer low-risk changes first (query shape, returned columns, indexes).
- Note tradeoffs (write amplification, maintenance, plan stability).

## What we capture (evidence pack)
### Postgres
- EXPLAIN (ANALYZE, BUFFERS) for baseline and after each fix
- Any notes about spills, row estimates vs actual, and buffer reads

### SQL Server
- SET STATISTICS IO, TIME ON output for baseline and after each fix
- Actual execution plan for baseline and final (and intermediate if helpful)

## Tasks

### Task 1 — Establish a baseline
Run the baseline scripts:

Postgres:
- scripts/postgres/70_capstone_baseline.sql

SQL Server:
- scripts/sqlserver/70_capstone_baseline.sql

Record:
- runtime
- logical reads / buffers
- the most expensive plan operators (the "red flags")

### Task 2 — Identify the bottleneck
Write 3 bullet points:
- what operation dominates (scan, sort, join, key lookup, spill)
- why it happens (missing index, too many rows, non-SARGable predicate, bad join order, stats)
- what evidence proves it (plan node + reads/time)

### Task 3 — Apply one safe fix (query refactor)
Run the refactor scripts:

Postgres:
- scripts/postgres/71_capstone_refactor.sql

SQL Server:
- scripts/sqlserver/71_capstone_refactor.sql

Record before/after deltas.

### Task 4 — Apply one physical fix (index)
Run the indexing scripts:

Postgres:
- scripts/postgres/72_capstone_index.sql

SQL Server:
- scripts/sqlserver/72_capstone_index.sql

Record:
- plan shape changes
- IO/time changes
- any tradeoffs (extra index maintenance)

### Task 5 — Stability / regression guardrail
Pick one guardrail:
- SQL Server: Query Store plan forcing (if enabled) or documented mitigation choice
- Postgres: baseline metrics + (if available) pg_stat_statements snapshot

Write a short "regression checklist" that someone can rerun after changes.

## What we learned
In 5 to 10 lines, summarize:
- the top 2 causes of the slowdown
- the fix that gave the biggest impact
- why the final solution is safe
- what guardrail we added

## Cleanup (optional)
Capstone tables are isolated:
- Postgres: public.lab07_capstone_orders, public.lab07_capstone_lines
- SQL Server: dbo.Lab07CapstoneOrders, dbo.Lab07CapstoneLines

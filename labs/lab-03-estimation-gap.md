# Lab 03 – Estimation gap: when the optimizer guesses wrong

## Goal
Learn to spot and explain “estimate vs actual” mismatches and connect them to:
- stale / missing statistics
- skewed data distributions
- correlated predicates
- parameter sensitivity

## What you capture
### PostgreSQL
- `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` including “rows” and “Rows Removed by Filter”
- optional: `EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)` for structured diffing

### SQL Server
- Actual plan + “Estimated Number of Rows” vs “Actual Number of Rows”
- `SET STATISTICS IO, TIME ON`

## Quick triage checklist
- Is the mismatch 10x+ on a key operator?
- Does it happen early (scan/join input) or late (after sort/aggregate)?
- Are predicates correlated (e.g., segment + date)?
- Are stats current? (Postgres: ANALYZE; SQL Server: auto stats / update stats)

## Exercise A (gentle)
1) Run the baseline query.
2) Identify one operator with the largest estimate gap.
3) Write a hypothesis: what might the optimizer be missing?

## Exercise B (make it worse on purpose)
We will introduce skew and then measure:
- insert many “VIP” customers with recent orders
- re-run query without updating stats
- compare plan estimates before vs after stats refresh

(Next lab will teach targeted fixes: stats refresh, extended stats, filtered indexes, and query rewrites.)
> Note: after refreshing stats, runtime improvement may be small; the primary learning signal is estimate vs actual changes and whether plan choices become more appropriate.

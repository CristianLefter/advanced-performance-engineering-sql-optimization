/*
Evidence Pack helper – PostgreSQL

Goal: standardize what we capture before/after.
- EXPLAIN (ANALYZE, BUFFERS) as text or JSON
- planning time, execution time
- shared buffer hits/reads

How to use:
1) Run your query wrapped in EXPLAIN.
2) Save output to your Evidence Pack folder.
*/

-- Text format (easy to read)
-- EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
-- SELECT ...;

-- JSON format (easy to diff / parse)
-- EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT JSON)
-- SELECT ...;

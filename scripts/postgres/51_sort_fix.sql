-- Lab 05 (Postgres) - refactor: supporting index + narrower projection
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/51_sort_fix.sql

\set ON_ERROR_STOP on
\timing on

-- Add index aligned to ORDER BY
CREATE INDEX IF NOT EXISTS ix_lab05_sort_payload_created
ON public.lab05_sort_demo (payload, created_at);

ANALYZE public.lab05_sort_demo;

-- Keep work_mem low to highlight index benefit (less sorting)
SET work_mem = '1MB';

EXPLAIN (ANALYZE, BUFFERS)
SELECT payload, created_at
FROM public.lab05_sort_demo
ORDER BY payload, created_at
LIMIT 50000;

-- Evidence notes:
-- - Compare plan shape, buffers, and total time vs baseline.
-- - Often the explicit Sort is reduced/removed and fewer columns flow through.

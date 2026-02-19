-- Lab 05 (Postgres) - baseline: heavy ORDER BY that can spill
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/50_sort_spill.sql

\set ON_ERROR_STOP on
\timing on

DROP TABLE IF EXISTS public.lab05_sort_demo;
CREATE TABLE public.lab05_sort_demo
(
    id         bigserial PRIMARY KEY,
    group_id   int NOT NULL,
    payload    text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Enough rows to make sorting non-trivial
INSERT INTO public.lab05_sort_demo (group_id, payload)
SELECT (random()*1000)::int,
       repeat(md5(gs::text), 5)
FROM generate_series(1, 300000) AS gs;

ANALYZE public.lab05_sort_demo;

-- Force low memory to increase chance of spill
SET work_mem = '1MB';

EXPLAIN (ANALYZE, BUFFERS)
SELECT group_id, payload, created_at
FROM public.lab05_sort_demo
ORDER BY payload, created_at
LIMIT 50000;

-- Evidence notes:
-- - Look for: Sort Method: external merge  (and Disk: ...), plus BUFFERS.

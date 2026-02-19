-- Lab 06 (Postgres) - generic vs custom plan with prepared statements + skew
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/60_generic_vs_custom.sql

\set ON_ERROR_STOP on
\timing on

DROP TABLE IF EXISTS public.lab06_skew;
CREATE TABLE public.lab06_skew
(
    id bigserial PRIMARY KEY,
    tenant_id int NOT NULL,
    payload text NOT NULL DEFAULT repeat('x', 200)
);

-- Skew: tenant_id=1 is huge, others are tiny
INSERT INTO public.lab06_skew (tenant_id)
SELECT CASE WHEN gs <= 450000 THEN 1 ELSE (gs % 5000) + 2 END
FROM generate_series(1, 500000) gs;

CREATE INDEX ON public.lab06_skew (tenant_id);
ANALYZE public.lab06_skew;

-- Prepared statement: show behavior for two values
SET plan_cache_mode = auto;

PREPARE q(int) AS
SELECT count(*) FROM public.lab06_skew WHERE tenant_id = $1;

EXPLAIN (ANALYZE, BUFFERS) EXECUTE q(4242);
EXPLAIN (ANALYZE, BUFFERS) EXECUTE q(1);

-- Force generic plan to discuss tradeoffs
SET plan_cache_mode = force_generic_plan;
EXPLAIN (ANALYZE, BUFFERS) EXECUTE q(4242);
EXPLAIN (ANALYZE, BUFFERS) EXECUTE q(1);

DEALLOCATE q;

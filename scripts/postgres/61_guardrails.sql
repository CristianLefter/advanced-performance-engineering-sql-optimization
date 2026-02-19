-- Lab 06 (Postgres) - practical guardrails / observability basics
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/61_guardrails.sql

\set ON_ERROR_STOP on

-- These are "what can we use here?" checks.
-- Not all environments have extensions enabled.

SELECT version();

-- pg_stat_statements is a common baseline for regression detection.
-- If not installed, this will fail (that's ok: note it in the lab).
SELECT extname, extversion
FROM pg_extension
ORDER BY extname;

-- If pg_stat_statements exists, show top queries by total time (may be empty in labs).
-- This block is safe: it only runs if the view exists.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'pg_stat_statements'
  ) THEN
    RAISE NOTICE 'public.pg_stat_statements exists (unexpected layout).';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'pg_catalog' AND c.relname = 'pg_stat_statements'
  ) THEN
    RAISE NOTICE 'pg_catalog.pg_stat_statements exists.';
  END IF;
END $$;

-- Explain the idea (in notes):
-- - Keep a small baseline query set + metrics (time, buffers) in version control.
-- - Re-run after changes (schema/stats/app) and compare.

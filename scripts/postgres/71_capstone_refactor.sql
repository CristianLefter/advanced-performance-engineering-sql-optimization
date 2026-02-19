-- Lab 07 (Postgres) - Capstone refactor (less data, filter earlier)
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/71_capstone_refactor.sql

\set ON_ERROR_STOP on
\timing on

SET work_mem = '1MB';

EXPLAIN (ANALYZE, BUFFERS)
WITH recent_paid AS
(
  SELECT order_id, customer_id, created_at
  FROM public.lab07_capstone_orders
  WHERE status = 'PAID'
    AND created_at >= now() - interval '90 days'
),
filtered_lines AS
(
  SELECT order_id, sku, qty, price
  FROM public.lab07_capstone_lines
  WHERE price > 50
)
SELECT rp.customer_id, rp.created_at,
       fl.sku, fl.qty, fl.price
FROM recent_paid rp
JOIN filtered_lines fl ON fl.order_id = rp.order_id
ORDER BY rp.customer_id, rp.created_at
LIMIT 20000;

-- Notes:
-- - We reduced selected columns and reduced row width.
-- - We push filters into CTEs to cut row flow before the join.

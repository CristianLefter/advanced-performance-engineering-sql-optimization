-- Lab 07 (Postgres) - Capstone indexing improvement
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/72_capstone_index.sql

\set ON_ERROR_STOP on
\timing on

-- Support the orders predicate (status + created_at) and join key order_id is already PK.
CREATE INDEX IF NOT EXISTS ix_lab07_orders_status_created
ON public.lab07_capstone_orders (status, created_at) INCLUDE (customer_id);

-- Support filtering lines by price and then joining by order_id
CREATE INDEX IF NOT EXISTS ix_lab07_lines_price_order
ON public.lab07_capstone_lines (price, order_id) INCLUDE (sku, qty);

ANALYZE public.lab07_capstone_orders;
ANALYZE public.lab07_capstone_lines;

SET work_mem = '1MB';

-- Re-run the refactored query to show plan/IO improvements after indexes
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

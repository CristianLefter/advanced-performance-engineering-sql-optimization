-- Lab 03 - Create data skew (PostgreSQL)
-- Goal: add many VIP customers with many recent orders, WITHOUT running ANALYZE yet.

BEGIN;

-- 1) Add new VIP customers (IDs above current max to avoid collisions)
INSERT INTO customers (customer_id, customer_name, customer_segment, created_at)
SELECT
  200000 + gs AS customer_id,
  'Skew VIP ' || gs AS customer_name,
  'VIP' AS customer_segment,
  now() - (random() * interval '365 days') AS created_at
FROM generate_series(1, 5000) AS gs;

-- 2) Add recent orders for these VIP customers
-- Create 10 orders per new VIP customer (50k orders)
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
SELECT
  900000 + row_number() OVER () AS order_id,
  200000 + ((gs-1) / 10) + 1 AS customer_id,
  current_date - ((random() * 7)::int) AS order_date,         -- last 7 days
  'Completed' AS status,
  (100 + random() * 5000)::numeric(12,2) AS total_amount
FROM generate_series(1, 50000) AS gs;

-- 3) Add order items (5 per new order = 250k items)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price)
SELECT
  9000000 + row_number() OVER () AS order_item_id,
  900000 + ((gs-1) / 5) + 1 AS order_id,
  1 + (random() * 999)::int AS product_id,
  1 + (random() * 4)::int AS quantity,
  (10 + random() * 500)::numeric(12,2) AS unit_price
FROM generate_series(1, 250000) AS gs;

-- Recompute line_total (generated column in SQL Server, stored in Postgres table)
UPDATE order_items
SET line_total = quantity * unit_price
WHERE order_item_id >= 9000000;

COMMIT;

-- IMPORTANT: do NOT run ANALYZE here (Lab 03 wants stale stats first).

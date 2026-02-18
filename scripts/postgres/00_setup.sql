/*
PostgreSQL setup (perf_lab)

Creates schema + seeds data for Option A (Orders).
Designed for Codespaces. Safe to re-run (drops/recreates tables).
*/

BEGIN;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers
(
  customer_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_name    TEXT NOT NULL,
  customer_segment TEXT NOT NULL,
  created_at       TIMESTAMP NOT NULL
);

CREATE TABLE products
(
  product_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_name  TEXT NOT NULL,
  category      TEXT NOT NULL,
  base_price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders
(
  order_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  INT NOT NULL REFERENCES customers(customer_id),
  order_date   DATE NOT NULL,
  status       TEXT NOT NULL,
  total_amount NUMERIC(12,2)
);

CREATE TABLE order_items
(
  order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id      BIGINT NOT NULL REFERENCES orders(order_id),
  product_id    INT NOT NULL REFERENCES products(product_id),
  quantity      INT NOT NULL,
  unit_price    NUMERIC(10,2) NOT NULL,
  line_total    NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

-- Intentionally minimal indexes at start
CREATE INDEX ix_orders_customer_id ON orders(customer_id);
CREATE INDEX ix_order_items_order_id ON order_items(order_id);

-- Customers: 20,000
INSERT INTO customers(customer_name, customer_segment, created_at)
SELECT
  'Customer ' || gs,
  CASE
    WHEN gs % 20 = 0 THEN 'VIP'
    WHEN gs % 5  = 0 THEN 'Business'
    ELSE 'Retail'
  END,
  now() - (gs % 365) * interval '1 day'
FROM generate_series(1, 20000) AS gs;

-- Products: 1,000
INSERT INTO products(product_name, category, base_price)
SELECT
  'Product ' || gs || ' ' || CASE WHEN gs % 10 = 0 THEN 'Pro' ELSE 'Standard' END,
  CASE
    WHEN gs % 8 = 0 THEN 'Hardware'
    WHEN gs % 8 = 1 THEN 'Software'
    WHEN gs % 8 = 2 THEN 'Accessories'
    WHEN gs % 8 = 3 THEN 'Services'
    ELSE 'Other'
  END,
  ((gs % 500) * 1.0 + 9.99)::numeric(10,2)
FROM generate_series(1, 1000) AS gs;

-- Orders: 50,000 (skewed)
INSERT INTO orders(customer_id, order_date, status, total_amount)
SELECT
  CASE
    WHEN gs % 10 = 0 THEN (SELECT customer_id FROM customers WHERE customer_segment='VIP' ORDER BY random() LIMIT 1)
    ELSE (1 + (random() * 19999))::int
  END,
  (current_date - (gs % 180))::date,
  CASE
    WHEN gs % 20 = 0 THEN 'Cancelled'
    WHEN gs % 7  = 0 THEN 'Pending'
    ELSE 'Completed'
  END,
  NULL
FROM generate_series(1, 50000) AS gs;

-- Order items: 250,000 (avg 5 per order)
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
SELECT
  ((gs - 1) / 5) + 1,
  (1 + (random() * 999))::int,
  (gs % 4) + 1,
  (((gs % 500) * 1.0 + 9.99))::numeric(10,2)
FROM generate_series(1, 250000) AS gs;

-- Compute order totals
UPDATE orders o
SET total_amount = t.total_amount
FROM (
  SELECT order_id, SUM(line_total) AS total_amount
  FROM order_items
  GROUP BY order_id
) t
WHERE o.order_id = t.order_id;

COMMIT;

ANALYZE;

-- Setup complete.

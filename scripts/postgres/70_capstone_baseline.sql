-- Lab 07 (Postgres) - Capstone baseline
-- Run: psql -h postgres -U postgres -d perf_lab -f scripts/postgres/70_capstone_baseline.sql

\set ON_ERROR_STOP on
\timing on

DROP TABLE IF EXISTS public.lab07_capstone_lines;
DROP TABLE IF EXISTS public.lab07_capstone_orders;

CREATE TABLE public.lab07_capstone_orders
(
    order_id    bigserial PRIMARY KEY,
    customer_id int NOT NULL,
    status      text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.lab07_capstone_lines
(
    order_id bigint NOT NULL,
    line_no  int NOT NULL,
    sku      text NOT NULL,
    qty      int NOT NULL,
    price    numeric(10,2) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY(order_id, line_no)
);

-- 200k orders
INSERT INTO public.lab07_capstone_orders (customer_id, status, created_at)
SELECT (random()*20000)::int,
       CASE WHEN gs % 10 = 0 THEN 'CANCELLED' ELSE 'PAID' END,
       now() - ((gs % 365) || ' days')::interval
FROM generate_series(1, 200000) gs;

-- 10 lines per order => ~2M lines
INSERT INTO public.lab07_capstone_lines(order_id, line_no, sku, qty, price, created_at)
SELECT o.order_id,
       gs AS line_no,
       md5((o.order_id::text || '-' || gs::text)),
       (random()*5)::int + 1,
       (random()*100)::numeric(10,2),
       o.created_at
FROM public.lab07_capstone_orders o
JOIN LATERAL generate_series(1, 10) gs ON true;

ANALYZE public.lab07_capstone_orders;
ANALYZE public.lab07_capstone_lines;

-- Baseline: wide projection + filter late + ORDER BY (likely heavy)
SET work_mem = '1MB';

EXPLAIN (ANALYZE, BUFFERS)
SELECT o.customer_id, o.created_at, o.status,
       l.sku, l.qty, l.price, l.created_at
FROM public.lab07_capstone_orders o
JOIN public.lab07_capstone_lines l ON l.order_id = o.order_id
WHERE o.status = 'PAID'
  AND o.created_at >= now() - interval '90 days'
  AND l.price > 50
ORDER BY o.customer_id, o.created_at
LIMIT 20000;

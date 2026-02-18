/*
Baseline query – intentionally not ideal.

Patterns we will improve later:
- non-SARGable date predicate (function on column)
- SELECT *
- potentially large join + late filtering
*/

-- Text output:
-- EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT *
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE (current_date - o.order_date) <= 30
  AND c.customer_segment IN ('VIP', 'Business')
  AND o.status = 'Completed'
ORDER BY o.order_date DESC;

-- JSON output (optional):
-- EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT JSON)
-- <same query>

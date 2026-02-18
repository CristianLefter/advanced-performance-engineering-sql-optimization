/*
Make predicate SARGable and reduce payload.
*/

-- EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
  o.order_id, o.order_date, o.status, o.total_amount,
  c.customer_id, c.customer_segment,
  oi.product_id, oi.quantity, oi.unit_price, oi.line_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_date >= (current_date - 30)
  AND c.customer_segment IN ('VIP', 'Business')
  AND o.status = 'Completed'
ORDER BY o.order_date DESC;

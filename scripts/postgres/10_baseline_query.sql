SELECT
    o.order_id,
    o.order_date,
    c.customer_name
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date >= DATE '2023-01-01';
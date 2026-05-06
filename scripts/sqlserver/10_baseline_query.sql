USE perf_lab;
GO

SELECT
    o.order_id,
    o.order_date,
    c.customer_name
FROM dbo.orders o
JOIN dbo.customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-01-01';
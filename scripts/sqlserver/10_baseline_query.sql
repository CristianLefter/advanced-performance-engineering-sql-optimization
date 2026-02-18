\
USE perf_lab;
GO

/*
Baseline query – intentionally not ideal.

Patterns we will improve later:
- non-SARGable date predicate
- SELECT *
- potentially large join + late filtering
*/

DECLARE @daysBack INT = 30;

SELECT *
FROM dbo.orders o
JOIN dbo.order_items oi ON oi.order_id = o.order_id
JOIN dbo.customers c ON c.customer_id = o.customer_id
WHERE DATEDIFF(DAY, o.order_date, CAST(GETDATE() AS date)) <= @daysBack
  AND c.customer_segment IN (N'VIP', N'Business')
  AND o.status = N'Completed'
ORDER BY o.order_date DESC;

\
USE perf_lab;
GO

/*
Make predicate SARGable and reduce payload.
*/

DECLARE @daysBack INT = 30;
DECLARE @fromDate DATE = DATEADD(DAY, -@daysBack, CAST(GETDATE() AS date));

SELECT
  o.order_id, o.order_date, o.status, o.total_amount,
  c.customer_id, c.customer_segment,
  oi.product_id, oi.quantity, oi.unit_price, oi.line_total
FROM dbo.orders o
JOIN dbo.customers c ON c.customer_id = o.customer_id
JOIN dbo.order_items oi ON oi.order_id = o.order_id
WHERE o.order_date >= @fromDate
  AND c.customer_segment IN (N'VIP', N'Business')
  AND o.status = N'Completed'
ORDER BY o.order_date DESC;

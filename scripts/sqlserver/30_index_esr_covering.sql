\
USE perf_lab;
GO

/*
Strategic index (ESR-friendly):
Equality: status
Sort/Range: order_date
Also includes customer_id and total_amount to avoid lookups for common patterns.
*/

CREATE INDEX IX_orders_status_orderdate
ON dbo.orders(status, order_date)
INCLUDE (customer_id, total_amount);
GO

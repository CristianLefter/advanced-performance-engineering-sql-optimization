USE perf_lab;
GO

/*
Strategic index (ESR-friendly):
Equality: status
Sort/Range: order_date
Include: customer_id, total_amount, order_id (supports join to order_items without extra lookups)
*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_orders_status_orderdate'
      AND object_id = OBJECT_ID('dbo.orders')
)
BEGIN
    CREATE INDEX IX_orders_status_orderdate
    ON dbo.orders(status, order_date)
    INCLUDE (customer_id, total_amount, order_id);
END
GO

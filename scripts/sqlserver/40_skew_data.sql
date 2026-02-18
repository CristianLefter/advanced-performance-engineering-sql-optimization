-- Lab 03 - Create data skew (SQL Server)
-- Goal: add many VIP customers with many recent orders, WITHOUT updating stats yet.

USE perf_lab;
GO

SET NOCOUNT ON;

-- 1) Add new VIP customers
;WITH n AS (
    SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.customers (customer_id, customer_name, customer_segment, created_at)
SELECT
    200000 + n.n,
    CONCAT('Skew VIP ', n.n),
    N'VIP',
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, SYSUTCDATETIME())
FROM n;

-- 2) Add recent orders (10 per new VIP customer = 50k orders)
;WITH n AS (
    SELECT TOP (50000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.orders (order_id, customer_id, order_date, status, total_amount)
SELECT
    900000 + n.n,
    200000 + ((n.n - 1) / 10) + 1,
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 7), CAST(GETDATE() AS date)), -- last 7 days
    N'Completed',
    CAST(100 + (ABS(CHECKSUM(NEWID())) % 500000) / 100.0 AS decimal(12,2))
FROM n;

-- 3) Add order items (5 per new order = 250k items)
;WITH n AS (
    SELECT TOP (250000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.order_items (order_item_id, order_id, product_id, quantity, unit_price)
SELECT
    9000000 + n.n,
    900000 + ((n.n - 1) / 5) + 1,
    1 + (ABS(CHECKSUM(NEWID())) % 999),
    1 + (ABS(CHECKSUM(NEWID())) % 4),
    CAST(10 + (ABS(CHECKSUM(NEWID())) % 50000) / 100.0 AS decimal(12,2))
FROM n;

-- IMPORTANT: do NOT run UPDATE STATISTICS here (Lab 03 wants stale stats first).
PRINT 'Skew data inserted. Do NOT update stats yet.';
GO

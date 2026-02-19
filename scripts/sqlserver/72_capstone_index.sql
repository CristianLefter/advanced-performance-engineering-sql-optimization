-- Lab 07 (SQL Server) - Capstone indexing improvement
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/72_capstone_index.sql

SET NOCOUNT ON;

-- Support orders filtering and ordering
CREATE INDEX IX_Lab07Orders_Status_CreatedAt
ON dbo.Lab07CapstoneOrders (Status, CreatedAt)
INCLUDE (CustomerId, OrderId);

-- Support lines filter + join
CREATE INDEX IX_Lab07Lines_Price_OrderId
ON dbo.Lab07CapstoneLines (Price, OrderId)
INCLUDE (Sku, Qty);

SET STATISTICS IO, TIME ON;

-- Re-run refactored query after indexes
;WITH RecentPaid AS
(
    SELECT OrderId, CustomerId, CreatedAt
    FROM dbo.Lab07CapstoneOrders
    WHERE Status = 'PAID'
      AND CreatedAt >= DATEADD(day, -90, SYSUTCDATETIME())
),
FilteredLines AS
(
    SELECT OrderId, Sku, Qty, Price
    FROM dbo.Lab07CapstoneLines
    WHERE Price > 50
)
SELECT TOP (20000)
       rp.CustomerId, rp.CreatedAt,
       fl.Sku, fl.Qty, fl.Price
FROM RecentPaid rp
JOIN FilteredLines fl ON fl.OrderId = rp.OrderId
ORDER BY rp.CustomerId, rp.CreatedAt
OPTION (MAXDOP 1);

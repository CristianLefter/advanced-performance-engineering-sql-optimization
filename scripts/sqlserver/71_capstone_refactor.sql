-- Lab 07 (SQL Server) - Capstone refactor (less data, filter earlier)
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/71_capstone_refactor.sql

SET NOCOUNT ON;
SET STATISTICS IO, TIME ON;

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

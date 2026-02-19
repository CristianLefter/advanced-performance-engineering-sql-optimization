-- Lab 07 (SQL Server) - Capstone baseline
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/70_capstone_baseline.sql

SET NOCOUNT ON;

IF OBJECT_ID('dbo.Lab07CapstoneLines','U') IS NOT NULL DROP TABLE dbo.Lab07CapstoneLines;
IF OBJECT_ID('dbo.Lab07CapstoneOrders','U') IS NOT NULL DROP TABLE dbo.Lab07CapstoneOrders;

CREATE TABLE dbo.Lab07CapstoneOrders
(
    OrderId     bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerId  int NOT NULL,
    Status      varchar(20) NOT NULL,
    CreatedAt   datetime2 NOT NULL
);

CREATE TABLE dbo.Lab07CapstoneLines
(
    OrderId    bigint NOT NULL,
    LineNo     int NOT NULL,
    Sku        varchar(64) NOT NULL,
    Qty        int NOT NULL,
    Price      decimal(10,2) NOT NULL,
    CreatedAt  datetime2 NOT NULL,
    CONSTRAINT PK_Lab07CapstoneLines PRIMARY KEY (OrderId, LineNo)
);

;WITH n AS
(
    SELECT TOP (200000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT dbo.Lab07CapstoneOrders (CustomerId, Status, CreatedAt)
SELECT ABS(CHECKSUM(NEWID())) % 20000,
       CASE WHEN rn % 10 = 0 THEN 'CANCELLED' ELSE 'PAID' END,
       DATEADD(day, -(rn % 365), SYSUTCDATETIME())
FROM n;

;WITH lines AS
(
    SELECT o.OrderId, v.LineNo, o.CreatedAt
    FROM dbo.Lab07CapstoneOrders o
    CROSS APPLY (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) v(LineNo)
)
INSERT dbo.Lab07CapstoneLines (OrderId, LineNo, Sku, Qty, Price, CreatedAt)
SELECT OrderId, LineNo,
       CONVERT(varchar(64), NEWID()),
       ABS(CHECKSUM(NEWID())) % 5 + 1,
       (ABS(CHECKSUM(NEWID())) % 10000) / 100.0,
       CreatedAt
FROM lines;

SET STATISTICS IO, TIME ON;

-- Baseline: wide projection + filter late + ORDER BY
SELECT TOP (20000)
       o.CustomerId, o.CreatedAt, o.Status,
       l.Sku, l.Qty, l.Price, l.CreatedAt
FROM dbo.Lab07CapstoneOrders o
JOIN dbo.Lab07CapstoneLines l ON l.OrderId = o.OrderId
WHERE o.Status = 'PAID'
  AND o.CreatedAt >= DATEADD(day, -90, SYSUTCDATETIME())
  AND l.Price > 50
ORDER BY o.CustomerId, o.CreatedAt
OPTION (MAXDOP 1);

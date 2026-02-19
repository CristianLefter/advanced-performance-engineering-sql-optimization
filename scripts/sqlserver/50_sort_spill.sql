-- Lab 05 (SQL Server) - baseline: heavy ORDER BY (sort / memory pressure)
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/50_sort_spill.sql

SET NOCOUNT ON;

IF OBJECT_ID('dbo.Lab05SortDemo','U') IS NOT NULL DROP TABLE dbo.Lab05SortDemo;
CREATE TABLE dbo.Lab05SortDemo
(
    Id        bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    GroupId   int NOT NULL,
    Payload   varchar(200) NOT NULL,
    CreatedAt datetime2 NOT NULL DEFAULT sysdatetime()
);

;WITH n AS
(
    SELECT TOP (300000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT dbo.Lab05SortDemo (GroupId, Payload)
SELECT ABS(CHECKSUM(NEWID())) % 1000,
       REPLICATE(CONVERT(varchar(32), CHECKSUM(NEWID())), 5)
FROM n;

SET STATISTICS IO, TIME ON;

SELECT TOP (50000) GroupId, Payload, CreatedAt
FROM dbo.Lab05SortDemo
ORDER BY Payload, CreatedAt
OPTION (MAXDOP 1);

-- Evidence notes:
-- - Save actual execution plan if possible; check Sort operator and warnings (spill-to-tempdb).

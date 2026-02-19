-- Lab 05 (SQL Server) - refactor: support ORDER BY with index + narrower projection
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/51_sort_fix.sql

SET NOCOUNT ON;

CREATE INDEX IX_Lab05Sort_Payload_CreatedAt
ON dbo.Lab05SortDemo (Payload, CreatedAt);

SET STATISTICS IO, TIME ON;

SELECT TOP (50000) Payload, CreatedAt
FROM dbo.Lab05SortDemo
ORDER BY Payload, CreatedAt
OPTION (MAXDOP 1);

-- Evidence notes:
-- - Compare logical reads and elapsed time vs baseline.
-- - Plan often reduces/removes explicit sort work.

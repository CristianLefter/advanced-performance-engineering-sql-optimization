-- Lab 06 (SQL Server) - parameter sensitivity / sniffing demo using skewed data
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/60_parameter_sensitivity.sql

SET NOCOUNT ON;

IF OBJECT_ID('dbo.Lab06Skew','U') IS NOT NULL DROP TABLE dbo.Lab06Skew;
CREATE TABLE dbo.Lab06Skew
(
    Id       bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId int NOT NULL,
    Payload  char(200) NOT NULL DEFAULT REPLICATE('X', 200)
);

-- Skew: TenantId=1 is huge, others are tiny
;WITH n AS
(
    SELECT TOP (500000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT dbo.Lab06Skew (TenantId)
SELECT CASE WHEN rn <= 450000 THEN 1 ELSE (rn % 5000) + 2 END
FROM n;

CREATE INDEX IX_Lab06Skew_TenantId ON dbo.Lab06Skew (TenantId);

DECLARE @TenantId int;

SET STATISTICS IO, TIME ON;

-- Compile for a "small" tenant first
SET @TenantId = 4242;
SELECT COUNT(*) AS Cnt
FROM dbo.Lab06Skew
WHERE TenantId = @TenantId;

-- Reuse the same cached plan for the "huge" tenant
SET @TenantId = 1;
SELECT COUNT(*) AS Cnt
FROM dbo.Lab06Skew
WHERE TenantId = @TenantId;

-- Evidence:
-- - Compare IO/TIME and the plan shape between the two executions.

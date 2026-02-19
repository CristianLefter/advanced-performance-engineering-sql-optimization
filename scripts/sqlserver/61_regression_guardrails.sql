-- Lab 06 (SQL Server) - mitigation options + (optional) Query Store guardrail
-- Run: sqlcmd -C -S mssql -U sa -P "YourStrong!Passw0rd" -d perf_lab -i scripts/sqlserver/61_regression_guardrails.sql

SET NOCOUNT ON;
SET STATISTICS IO, TIME ON;

DECLARE @TenantId int;

-- Option A: RECOMPILE (per-exec optimization; good for "rare but expensive")
SET @TenantId = 4242;
SELECT COUNT(*) AS Cnt
FROM dbo.Lab06Skew
WHERE TenantId = @TenantId
OPTION (RECOMPILE);

SET @TenantId = 1;
SELECT COUNT(*) AS Cnt
FROM dbo.Lab06Skew
WHERE TenantId = @TenantId
OPTION (RECOMPILE);

-- Option B: OPTIMIZE FOR (when you have a "typical" value you want the plan for)
SET @TenantId = 1;
SELECT COUNT(*) AS Cnt
FROM dbo.Lab06Skew
WHERE TenantId = @TenantId
OPTION (OPTIMIZE FOR (@TenantId = 4242));

-- Optional guardrail concept (Query Store):
-- In real systems, Query Store can capture regressions and allow plan forcing.
-- Enabling/configuring Query Store is environment-specific; discuss and/or demo if available.

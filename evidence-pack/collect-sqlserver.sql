/*
Evidence Pack helper – SQL Server

Goal: standardize what we capture before/after.
- Actual execution plan (SSMS/VS Code can save it)
- CPU/elapsed
- logical reads

How to use:
1) Enable "Include Actual Execution Plan" in your SQL client (VS Code MSSQL extension supports it).
2) Run this script in the same session.
*/

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Optional: isolate cache effects for labs (use with care in shared environments)
-- DBCC FREEPROCCACHE;
-- DBCC DROPCLEANBUFFERS;

-- Put your test query below this line
-- ------------------------------------------------------------
-- SELECT ...;
-- ------------------------------------------------------------

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

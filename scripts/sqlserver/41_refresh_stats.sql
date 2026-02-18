-- Lab 03 - Refresh statistics (SQL Server)
USE perf_lab;
GO

-- Keep it explicit and simple for learners
UPDATE STATISTICS dbo.customers WITH FULLSCAN;
UPDATE STATISTICS dbo.orders WITH FULLSCAN;
UPDATE STATISTICS dbo.order_items WITH FULLSCAN;
GO

/*
SQL Server setup (perf_lab)

Creates schema + seeds data for Option A (Orders).
Designed for Codespaces. Safe to re-run (drops/recreates database).
*/

USE master;
GO

IF DB_ID('perf_lab') IS NOT NULL
BEGIN
  ALTER DATABASE perf_lab SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE perf_lab;
END
GO

CREATE DATABASE perf_lab;
GO

ALTER DATABASE perf_lab SET RECOVERY SIMPLE;
GO

USE perf_lab;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

-- ---------- Schema ----------
CREATE TABLE dbo.customers
(
  customer_id  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_customers PRIMARY KEY,
  customer_name NVARCHAR(200) NOT NULL,
  customer_segment NVARCHAR(50) NOT NULL,
  created_at   DATETIME2(0) NOT NULL
);

CREATE TABLE dbo.products
(
  product_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_products PRIMARY KEY,
  product_name NVARCHAR(200) NOT NULL,
  category NVARCHAR(50) NOT NULL,
  base_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.orders
(
  order_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_orders PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  status NVARCHAR(20) NOT NULL,
  total_amount DECIMAL(12,2) NULL,
  CONSTRAINT FK_orders_customers FOREIGN KEY(customer_id) REFERENCES dbo.customers(customer_id)
);

CREATE TABLE dbo.order_items
(
  order_item_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_order_items PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  line_total AS (quantity * unit_price) PERSISTED,
  CONSTRAINT FK_order_items_orders FOREIGN KEY(order_id) REFERENCES dbo.orders(order_id),
  CONSTRAINT FK_order_items_products FOREIGN KEY(product_id) REFERENCES dbo.products(product_id)
);

-- Intentionally minimal indexes at start (labs will add better ones)
CREATE INDEX IX_orders_customer_id ON dbo.orders(customer_id);
CREATE INDEX IX_order_items_order_id ON dbo.order_items(order_id);

-- ---------- Seed data ----------
SET NOCOUNT ON;

-- Customers: 20,000
;WITH n AS
(
  SELECT TOP (20000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT dbo.customers(customer_name, customer_segment, created_at)
SELECT
  CONCAT(N'Customer ', rn),
  CASE
    WHEN rn % 20 = 0 THEN N'VIP'
    WHEN rn % 5  = 0 THEN N'Business'
    ELSE N'Retail'
  END,
  DATEADD(DAY, -1 * (rn % 365), SYSUTCDATETIME())
FROM n;

-- Products: 1,000
;WITH n AS
(
  SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects
)
INSERT dbo.products(product_name, category, base_price)
SELECT
  CONCAT(N'Product ', rn, N' ', CASE WHEN rn % 10 = 0 THEN N'Pro' ELSE N'Standard' END),
  CASE WHEN rn % 8 = 0 THEN N'Hardware'
       WHEN rn % 8 = 1 THEN N'Software'
       WHEN rn % 8 = 2 THEN N'Accessories'
       WHEN rn % 8 = 3 THEN N'Services'
       ELSE N'Other' END,
  CAST( (rn % 500) * 1.0 + 9.99 AS DECIMAL(10,2))
FROM n;

-- Orders: 50,000 (skewed: VIP customers get more orders)
;WITH n AS
(
  SELECT TOP (50000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
cust AS
(
  SELECT customer_id, customer_segment
  FROM dbo.customers
)
INSERT dbo.orders(customer_id, order_date, status, total_amount)
SELECT
  CASE
    WHEN rn % 10 = 0
      THEN (SELECT TOP 1 customer_id FROM cust WHERE customer_segment = N'VIP' ORDER BY NEWID())
    ELSE (ABS(CHECKSUM(NEWID())) % 20000) + 1
  END,
  DATEADD(DAY, -1 * (rn % 180), CAST(GETDATE() AS date)), -- last ~6 months heavier
  CASE WHEN rn % 20 = 0 THEN N'Cancelled'
       WHEN rn % 7  = 0 THEN N'Pending'
       ELSE N'Completed' END,
  NULL
FROM n;

-- Order items: 250,000 (avg 5 per order)
;WITH n AS
(
  SELECT TOP (250000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT dbo.order_items(order_id, product_id, quantity, unit_price)
SELECT
  ((rn - 1) / 5) + 1,                           -- spread across orders
  (ABS(CHECKSUM(NEWID())) % 1000) + 1,
  (rn % 4) + 1,
  CAST( ((rn % 500) * 1.0 + 9.99) AS DECIMAL(10,2))
FROM n;

-- Compute order totals (simple aggregation)
;WITH totals AS
(
  SELECT order_id, SUM(line_total) AS total_amount
  FROM dbo.order_items
  GROUP BY order_id
)
UPDATE o
SET o.total_amount = t.total_amount
FROM dbo.orders o
JOIN totals t ON t.order_id = o.order_id;

PRINT 'SQL Server setup complete.';
GO

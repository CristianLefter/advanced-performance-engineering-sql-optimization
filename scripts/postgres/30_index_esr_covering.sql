/*
Strategic index (ESR-friendly-ish):
Equality: status
Range/Sort: order_date
Include customer_id + total_amount.

In Postgres we can include columns to support index-only scans.
*/

CREATE INDEX IF NOT EXISTS ix_orders_status_orderdate
ON orders(status, order_date)
INCLUDE (customer_id, total_amount);

ANALYZE orders;

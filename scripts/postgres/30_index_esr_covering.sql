/*
Strategic index (ESR-ish):
Equality: status
Range/Sort: order_date
Include: customer_id, total_amount, order_id (supports join to order_items without extra heap lookups in some cases)
*/

CREATE INDEX IF NOT EXISTS ix_orders_status_orderdate
ON orders(status, order_date)
INCLUDE (customer_id, total_amount, order_id);

ANALYZE orders;

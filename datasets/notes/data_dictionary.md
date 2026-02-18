# Data Dictionary (Option A: Orders)

Tables (both engines, same logical model):

- `customers` – customer master
- `products` – product catalog
- `orders` – order header (date, status, customer)
- `order_items` – order lines (product, quantity, unit_price)

Built-in characteristics (intentionally):
- **Skew**: a small % of customers generate a large % of orders.
- **Hot range**: recent dates appear more often to make range predicates common.
- **Text search bait**: product name prefix filtering for SARGability labs.

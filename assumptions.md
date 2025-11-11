Assumptions & Clarifications – StockFlow Backend Case Study

This document contains all assumptions I made while completing the backend engineering case study.
The original problem statement intentionally left some requirements ambiguous, so the following assumptions ensure consistent and logical implementation.

📌 General Assumptions

Each company has its own product catalog.

A product belongs to only one company.

SKU uniqueness is enforced globally, not just per company.

All APIs are authenticated in real-world systems,
but authentication is skipped here since the case study focuses only on backend logic.

Database engine assumed to be MySQL, unless otherwise specified.

📌 Assumptions for Part 1 (Product Creation API – Python)
1. SKU must be globally unique

If a SKU already exists, API returns a 400 error.

2. Price will be a decimal

Stored using MySQL DECIMAL(10,2)

Python side uses Decimal

3. Product is NOT tied to a warehouse directly

Products can exist in multiple warehouses

Only the inventory table links warehouse → product → quantity

4. initial_quantity and warehouse_id are optional

If not provided, product is created with no inventory entry.

5. API uses one single database transaction

Prevents partial writes

Avoids inconsistent product-without-inventory case

6. Error handling returns JSON errors, not HTML responses

📌 Assumptions for Part 2 (Database Schema – MySQL)
1. Companies are multi-tenant

Each company has:

multiple warehouses

independent products

shared suppliers (optionally)

2. Products may have multiple suppliers

Used for reorder recommendations.

3. Bundle products contain other products

Bundle has its own SKU and price

Bundles do not maintain separate inventory

Inventory is based on its components
(1 bundle of X reduces stock of its components)

4. Inventory changes must be logged

inventory_movements table stores:

product

warehouse

quantity change

timestamp

reason

5. Soft deletes are NOT implemented

Deleted rows are permanently removed.

6. Warehouses belong strictly to one company
7. All foreign key constraints use ON DELETE CASCADE

This ensures clean data removal.

📌 Assumptions for Part 3 (Low Stock Alerts API – Node.js)
1. “Recent sales activity” = sales within last 30 days

If no sales in last 30 days → no alert even if stock is low.

2. Low-stock threshold is defined per product

Stored in products.threshold

3. Average daily sales calculated as:
avgDailySales = totalSalesLast30Days / 30

4. days_until_stockout formula:
days = Math.round(current_stock / avgDailySales)

5. Supplier selection logic

If a product has multiple suppliers, first supplier is chosen

Output includes: id, name, contact_email

6. Inventory checked across all warehouses of that company

Alert generated per warehouse, not per product

A product may appear multiple times (different warehouses)

7. Missing data handling

If the product has low stock but no supplier → supplier: null

If product has low stock but no recent sales → skipped

8. Database queries use SQL JOINs 

📌 Edge-Case Assumptions

Division by zero avoided
If avg_daily_sales = 0 → product is skipped.

Case-insensitive SKU comparison assumed.

Timezone used = database server timezone.

Inventory quantity cannot be negative.
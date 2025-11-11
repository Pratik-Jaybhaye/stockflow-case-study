# stockflow-case-study Backend Engineering Case Study (Inventory Management System)
This repository contains my complete solution for the Backend Engineering Intern – Inventory Management System Case Study.
The project includes code review, debugging, database design, and API development across Python (Flask) and Node.js (Express).

🧩 Part 1 – Code Review & Debugging (Python) 
✔ What I did

Reviewed the existing Flask endpoint for product creation
Identified technical issues & business logic flaws
Explained production impact of each issue
Provided a corrected, optimized, secure implementation

🔍 Key Fixes

Added input validation
Ensured SKU uniqueness
Price stored as Decimal
Transaction kept atomic (single commit)
Removed invalid warehouse reference from Product model
Added error handling & proper HTTP status codes

🗄️ Part 2 – Database Schema (MySQL)
✔ What I did

Designed relational schema supporting:

Companies with multiple warehouses

Products stored in multiple warehouses

Inventory logging (movements)

Suppliers linked to products

Bundle products containing other products 

Highlights

Many-to-many tables (product_suppliers, bundle_components)

DECIMAL used for monetary values

Composite unique constraints for inventory

Proper foreign keys & indexing 

🚨 Part 3 – Low Stock Alert API (Node.js)
✔ What I did

Implemented REST endpoint using Express.js

Fetched low-stock items across all warehouses

Filtered only products with recent sales activity

Included supplier information

Calculated avg daily sales + days until stockout
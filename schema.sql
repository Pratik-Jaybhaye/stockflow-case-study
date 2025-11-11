CREATE TABLE companies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
    -- (additional fields like address, etc.)
);

CREATE TABLE warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    contact_email VARCHAR(255)
    -- (additional fields as needed)
);

-- Company-supplier many-to-many (if suppliers can serve multiple companies)
CREATE TABLE company_suppliers (
    company_id INT NOT NULL,
    supplier_id INT NOT NULL,
    PRIMARY KEY (company_id, supplier_id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- surrogate key:contentReference[oaicite:16]{index=16}
    company_id INT NOT NULL,           -- which company owns this product
    sku VARCHAR(100) NOT NULL UNIQUE,  -- global unique SKU
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,      -- monetary value:contentReference[oaicite:17]{index=17}
    is_bundle BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Supplier-product many-to-many: which supplier(s) supply each product
CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Inventory table: current stock per product per warehouse
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE (product_id, warehouse_id)  -- one row per product-warehouse pair
);

-- Inventory movements (audit/log of stock changes)
CREATE TABLE inventory_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    change_qty INT NOT NULL,
    reason VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

-- Bundle components (many-to-many, self-referential)
CREATE TABLE bundle_components (
    bundle_id INT NOT NULL,    -- a product that is a bundle
    component_id INT NOT NULL, -- a product contained in the bundle
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (bundle_id, component_id),
    FOREIGN KEY (bundle_id) REFERENCES products(id),
    FOREIGN KEY (component_id) REFERENCES products(id)
);

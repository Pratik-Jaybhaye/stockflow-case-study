// GET /api/companies/:company_id/alerts/low-stock
app.get('/api/companies/:company_id/alerts/low-stock', async (req, res) => {
  try {
    // 1. Parse and validate company ID from URL
    const companyId = parseInt(req.params.company_id, 10);
    if (isNaN(companyId)) {
      return res.status(400).json({ error: 'Invalid company ID' });
    }

    // 2. Query total sales per product in the last 30 days
    //    (Assumes a function NOW() and INTERVAL syntax; adjust for MySQL as needed.)
    const salesResult = await db.query(
      `SELECT product_id, SUM(quantity) AS total_sold
       FROM sales
       WHERE sold_at >= NOW() - INTERVAL '30 days'
       GROUP BY product_id`
    );
    // Convert sales results to a lookup map: product_id -> total_sold
    const salesMap = {};
    for (const row of salesResult.rows) {
      salesMap[row.product_id] = parseFloat(row.total_sold);
    }

    // 3. Query inventory for this company where quantity < threshold
    //    Join products and warehouses to get names. 
    //    Similar to: SELECT ... FROM Products p JOIN Inventory i ON p.id = i.product_id WHERE i.quantity < p.threshold
    const inventoryResult = await db.query(
      `SELECT i.product_id, p.name AS product_name, p.sku, p.threshold,
              i.warehouse_id, w.name AS warehouse_name, i.quantity AS current_stock
       FROM inventory i
       JOIN products p ON i.product_id = p.id
       JOIN warehouses w ON i.warehouse_id = w.id
       WHERE p.company_id = $1
         AND i.quantity < p.threshold`,
      [companyId]
    );

    const alerts = [];
    // 4. Loop through each low-stock inventory record
    for (const row of inventoryResult.rows) {
      const productId = row.product_id;
      const totalSold = salesMap[productId] || 0;
      // Skip products with no sales in last 30 days (no recent activity)
      if (totalSold <= 0) {
        continue;
      }

      // 5. Compute average daily sales and days until stockout
      const avgDailySales = totalSold / 30.0;
      const daysUntilStockout = Math.round(row.current_stock / avgDailySales);

      // 6. Fetch supplier(s) for this product
      const supplierResult = await db.query(
        `SELECT s.id, s.name, s.contact_email
         FROM suppliers s
         JOIN product_suppliers ps ON s.id = ps.supplier_id
         WHERE ps.product_id = $1`,
        [productId]
      );
      // If multiple suppliers exist, we take the first one (could also return all if needed)
      const supplierRow = supplierResult.rows[0] || null;

      // 7. Build the alert object for this product/warehouse
      alerts.push({
        product_id: productId,
        product_name: row.product_name,
        sku: row.sku,
        warehouse_id: row.warehouse_id,
        warehouse_name: row.warehouse_name,
        current_stock: parseInt(row.current_stock, 10),
        threshold: parseInt(row.threshold, 10),
        days_until_stockout: daysUntilStockout,
        supplier: supplierRow
          ? {
              id: supplierRow.id,
              name: supplierRow.name,
              contact_email: supplierRow.contact_email
            }
          : null  // No supplier found case
      });
    }

    // 8. Return the alerts array and total count in JSON format
    return res.json({ alerts, total_alerts: alerts.length });
    
  } catch (error) {
    // Error handling: log and return 500 status
    console.error('Error fetching low-stock alerts:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});
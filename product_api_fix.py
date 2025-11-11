from flask import request, jsonify
from decimal import Decimal, InvalidOperation

@app.route('/api/products', methods=['POST'])
def create_product():
    try:
        data = request.get_json(force=True)
    except Exception:
        # Invalid JSON
        return jsonify(error="Invalid JSON payload"), 400

    # Validate required fields
    name = data.get('name')
    sku  = data.get('sku')
    if not name or not sku:
        return jsonify(error="Both 'name' and 'sku' are required"), 400

    # Optional fields with defaults
    price_val = data.get('price')
    initial_qty = data.get('initial_quantity', 0)
    warehouse_id = data.get('warehouse_id')

    # Convert and validate price if provided
    price = None
    if price_val is not None:
        try:
            price = Decimal(str(price_val))
        except (InvalidOperation, ValueError):
            return jsonify(error="Invalid price format"), 400

    # Enforce SKU uniqueness (application-level check)
    existing = Product.query.filter_by(sku=sku).first()
    if existing:
        return jsonify(error="SKU already exists"), 400

    # Create the Product (without tying to a warehouse)
    product = Product(
        name=name,
        sku=sku,
        price=price  # assume model uses Decimal/NUMERIC
    )
    db.session.add(product)
    db.session.flush()  # push to DB to get product.id without final commit:contentReference[oaicite:10]{index=10}

    # If initial warehouse and quantity given, create inventory record
    if warehouse_id is not None:
        # Validate warehouse_id (e.g., ensure it exists) - omitted for brevity
        inventory = Inventory(
            product_id=product.id,
            warehouse_id=warehouse_id,
            quantity=initial_qty or 0
        )
        db.session.add(inventory)

    # Commit once for atomicity
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify(error="Database error: " + str(e)), 500

    # Return success with created status
    return jsonify(message="Product created", product_id=product.id), 201

CREATE DATABASE datacraftinglab_db;

CREATE TABLE flourmills_sales (
    sales_id INTEGER PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INTEGER,
    quantity_sold INTEGER,
    unit_price NUMERIC(10, 2),
    discount_rate INTEGER,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INTEGER,
    production_date DATE,
    total_amount NUMERIC(10, 2)
);
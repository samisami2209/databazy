--2
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    quantity * unit_price AS revenue,
    SUM(quantity * unit_price) OVER (
        PARTITION BY
            customer_id
        ORDER BY invoice_date RANGE BETWEEN INTERVAL '14 days' PRECEDING
            AND CURRENT ROW
    ) AS revenue_last_14_days
FROM retail_sales
WHERE
    customer_id IS NOT NULL
ORDER BY customer_id, invoice_date;

--3
SELECT
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(
        AVG(quantity) OVER (
            PARTITION BY
                stock_code,
                country
            ORDER BY invoice_date RANGE BETWEEN INTERVAL '7 days' PRECEDING
                AND CURRENT ROW
        ),
        2
    ) AS avg_quantity_7_days
FROM retail_sales
WHERE
    quantity > 1
ORDER BY
    stock_code,
    country,
    invoice_date;

--4
WITH
    unique_orders AS (
        SELECT DISTINCT
            customer_id,
            invoice_no,
            invoice_date::date AS invoice_date
        FROM retail_sales
        WHERE
            customer_id IS NOT NULL
    ),
    with_next AS (
        SELECT
            customer_id,
            invoice_no,
            invoice_date,
            LEAD(invoice_date) OVER (
                PARTITION BY
                    customer_id
                ORDER BY invoice_date
            ) AS next_invoice_date
        FROM unique_orders
    )
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    next_invoice_date - invoice_date AS days_to_next_invoice
FROM with_next
WHERE
    next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

--5
SELECT
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    unit_price AS current_price,
    unit_price - previous_price AS price_difference
FROM (
        SELECT
            stock_code, invoice_no, invoice_date, unit_price, LAG(unit_price) OVER (
                PARTITION BY
                    stock_code
                ORDER BY invoice_date
            ) AS previous_price
        FROM retail_sales
    ) t
WHERE
    previous_price IS NOT NULL
    AND unit_price <> previous_price
ORDER BY invoice_date ASC;

--6
SELECT
    customer_id,
    total_amount,
    NTILE(4) OVER (
        ORDER BY total_amount DESC
    ) AS sales_quartile
FROM (
        SELECT customer_id, SUM(quantity * unit_price) AS total_amount
        FROM retail_sales
        WHERE
            customer_id IS NOT NULL
        GROUP BY
            customer_id
    ) c
ORDER BY total_amount DESC;

--7
SELECT
    country,
    month,
    total_amount,
    NTILE(4) OVER (
        PARTITION BY
            country
        ORDER BY total_amount DESC
    ) AS sales_quartile
FROM (
        SELECT
            country, DATE_TRUNC('month', invoice_date)::date AS month, SUM(quantity * unit_price) AS total_amount
        FROM retail_sales
        GROUP BY
            country, DATE_TRUNC('month', invoice_date)
    ) m
ORDER BY country, month;

--8
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
FROM (
        SELECT
            customer_id, invoice_no, invoice_date, stock_code, description, quantity, unit_price, ROW_NUMBER() OVER (
                PARTITION BY
                    customer_id
                ORDER BY invoice_date ASC
            ) AS rn
        FROM retail_sales
        WHERE
            customer_id IS NOT NULL
    ) t
WHERE
    rn = 1
ORDER BY customer_id ASC;

--9
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    amount,
    row_num
FROM (
        SELECT
            invoice_no, stock_code, description, quantity, unit_price, quantity * unit_price AS amount, ROW_NUMBER() OVER (
                PARTITION BY
                    invoice_no
                ORDER BY quantity * unit_price DESC
            ) AS row_num
        FROM retail_sales
    ) t
WHERE
    row_num <= 3
ORDER BY invoice_no, row_num;

--10
WITH
    monthly AS (
        SELECT
            country,
            DATE_TRUNC('month', invoice_date)::date AS month,
            customer_id,
            SUM(quantity * unit_price) AS total_amount
        FROM retail_sales
        WHERE
            customer_id IS NOT NULL
        GROUP BY
            country,
            DATE_TRUNC('month', invoice_date),
            customer_id
    ),
    ranked AS (
        SELECT
            country,
            month,
            customer_id,
            total_amount,
            DENSE_RANK() OVER (
                PARTITION BY
                    country,
                    month
                ORDER BY total_amount DESC
            ) AS sales_rank
        FROM monthly
    )
SELECT
    country,
    month,
    customer_id,
    total_amount,
    sales_rank
FROM ranked
WHERE
    sales_rank <= 5
ORDER BY
    country,
    month,
    sales_rank,
    customer_id;

--11
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
FROM (
        SELECT
            invoice_no, stock_code, description, quantity, unit_price, DENSE_RANK() OVER (
                PARTITION BY
                    invoice_no
                ORDER BY unit_price DESC
            ) AS price_rank
        FROM retail_sales
    ) t
WHERE
    price_rank <= 5
ORDER BY
    invoice_no,
    price_rank,
    stock_code;
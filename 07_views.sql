CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(ORDERDATE, '%Y-%m') AS sales_month,
    COUNT(DISTINCT ORDERNUMBER)     AS num_orders,
    ROUND(SUM(SALES), 2)            AS total_revenue,
    ROUND(AVG(SALES), 2)            AS avg_sale_value
FROM sales_data_sample
GROUP BY sales_month;

CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    CUSTOMERNAME,
    COUNTRY,
    COUNT(DISTINCT ORDERNUMBER)     AS num_orders,
    ROUND(SUM(SALES), 2)            AS total_revenue,
    ROUND(AVG(SALES), 2)            AS avg_order_line_value,
    MIN(ORDERDATE)                  AS first_order_date,
    MAX(ORDERDATE)                  AS last_order_date,
    CASE
        WHEN SUM(SALES) >= 100000 THEN 'Platinum'
        WHEN SUM(SALES) >= 50000  THEN 'Gold'
        WHEN SUM(SALES) >= 20000  THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment
FROM sales_data_sample
GROUP BY CUSTOMERNAME, COUNTRY;

CREATE OR REPLACE VIEW vw_productline_performance AS
SELECT
    PRODUCTLINE,
    COUNT(*)                        AS num_order_lines,
    ROUND(SUM(SALES), 2)            AS total_revenue,
    ROUND(AVG(SALES), 2)            AS avg_sale_value,
    ROUND(AVG(MSRP), 2)             AS avg_msrp,
    ROUND(SUM(SALES) * 100.0 / (SELECT SUM(SALES) FROM sales_data_sample), 2) AS pct_of_total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE;

CREATE OR REPLACE VIEW vw_country_territory_summary AS
SELECT
    COUNTRY,
    TERRITORY,
    COUNT(DISTINCT ORDERNUMBER)     AS num_orders,
    COUNT(DISTINCT CUSTOMERNAME)    AS num_customers,
    ROUND(SUM(SALES), 2)            AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY, TERRITORY;

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    ORDERNUMBER,
    CUSTOMERNAME,
    COUNTRY,
    ORDERDATE,
    STATUS,
    DEALSIZE,
    COUNT(*)                        AS num_line_items,
    ROUND(SUM(SALES), 2)            AS order_total
FROM sales_data_sample
GROUP BY ORDERNUMBER, CUSTOMERNAME, COUNTRY, ORDERDATE, STATUS, DEALSIZE;

SHOW FULL TABLES IN sales_analysis WHERE TABLE_TYPE = 'VIEW';

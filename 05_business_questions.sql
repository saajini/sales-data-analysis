SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS sales_month, ROUND(SUM(SALES), 2) AS total_sales
FROM sales_data_sample
GROUP BY sales_month
ORDER BY sales_month;

SELECT YEAR_ID, ROUND(SUM(SALES), 2) AS total_sales
FROM sales_data_sample
GROUP BY YEAR_ID
ORDER BY YEAR_ID;

SELECT COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY total_revenue DESC;

SELECT CITY, COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY CITY, COUNTRY
ORDER BY total_revenue DESC
LIMIT 15;

SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY total_revenue DESC
LIMIT 10;

SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY total_revenue ASC
LIMIT 10;

SELECT PRODUCTCODE, PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTCODE, PRODUCTLINE
ORDER BY total_revenue DESC
LIMIT 10;

SELECT PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC
LIMIT 1;

SELECT PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_revenue ASC
LIMIT 1;

SELECT DEALSIZE, COUNT(*) AS num_orders, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY DEALSIZE
ORDER BY total_revenue DESC;

SELECT ROUND(SUM(SALES) / COUNT(DISTINCT ORDERNUMBER), 2) AS avg_order_value
FROM sales_data_sample;

SELECT COUNTRY, ROUND(AVG(SALES), 2) AS avg_sale_value
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY avg_sale_value DESC
LIMIT 10;

SELECT PRODUCTCODE, PRODUCTLINE, COUNT(*) AS times_ordered
FROM sales_data_sample
GROUP BY PRODUCTCODE, PRODUCTLINE
ORDER BY times_ordered DESC
LIMIT 10;

SELECT QTR_ID, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY QTR_ID
ORDER BY QTR_ID;

SELECT MONTH_ID, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY MONTH_ID
ORDER BY MONTH_ID;

SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS order_frequency
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY order_frequency DESC
LIMIT 15;

SELECT STATUS, COUNT(*) AS num_orders, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY STATUS
ORDER BY num_orders DESC;

SELECT TERRITORY, ROUND(SUM(SALES), 2) AS total_revenue, COUNT(DISTINCT ORDERNUMBER) AS num_orders
FROM sales_data_sample
GROUP BY TERRITORY
ORDER BY total_revenue DESC;

SELECT
    CASE
        WHEN SALES < 1000 THEN '0-999'
        WHEN SALES < 2000 THEN '1000-1999'
        WHEN SALES < 4000 THEN '2000-3999'
        WHEN SALES < 6000 THEN '4000-5999'
        ELSE '6000+'
    END AS sales_bucket,
    COUNT(*) AS num_orders
FROM sales_data_sample
GROUP BY sales_bucket
ORDER BY MIN(SALES);

SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS total_revenue,
    ROUND(SUM(SALES) * 100.0 / (SELECT SUM(SALES) FROM sales_data_sample), 2) AS pct_of_total
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY pct_of_total DESC;

SELECT ORDERNUMBER, CUSTOMERNAME, ROUND(SUM(SALES), 2) AS order_total
FROM sales_data_sample
GROUP BY ORDERNUMBER, CUSTOMERNAME
ORDER BY order_total DESC
LIMIT 10;

SELECT ORDERNUMBER, CUSTOMERNAME, ROUND(SUM(SALES), 2) AS order_total
FROM sales_data_sample
GROUP BY ORDERNUMBER, CUSTOMERNAME
ORDER BY order_total ASC
LIMIT 10;

SELECT
    CUSTOMERNAME,
    total_revenue,
    CASE
        WHEN total_revenue >= 100000 THEN 'Platinum'
        WHEN total_revenue >= 50000  THEN 'Gold'
        WHEN total_revenue >= 20000  THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment
FROM (
    SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS total_revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) t
ORDER BY total_revenue DESC;

SELECT COUNTRY, PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY, PRODUCTLINE
ORDER BY COUNTRY, total_revenue DESC;

SELECT
    PRODUCTCODE,
    PRODUCTLINE,
    MSRP,
    ROUND(AVG(SALES), 2) AS avg_actual_sale,
    ROUND(AVG(SALES) / MSRP, 2) AS sale_to_msrp_ratio
FROM sales_data_sample
GROUP BY PRODUCTCODE, PRODUCTLINE, MSRP
ORDER BY sale_to_msrp_ratio DESC
LIMIT 10;

WITH yearly AS (
    SELECT YEAR_ID, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY YEAR_ID
)
SELECT
    YEAR_ID,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY YEAR_ID))
        / LAG(total_revenue) OVER (ORDER BY YEAR_ID) * 100, 2
    ) AS yoy_growth_pct
FROM yearly
ORDER BY YEAR_ID;

WITH last_order AS (
    SELECT CUSTOMERNAME, MAX(ORDERDATE) AS last_order_date
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
)
SELECT CUSTOMERNAME, last_order_date
FROM last_order
WHERE last_order_date < (SELECT DATE_SUB(MAX(ORDERDATE), INTERVAL 6 MONTH) FROM sales_data_sample)
ORDER BY last_order_date;

WITH customer_revenue AS (
    SELECT CUSTOMERNAME, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
),
ranked AS (
    SELECT CUSTOMERNAME, total_revenue,
           NTILE(5) OVER (ORDER BY total_revenue DESC) AS quintile
    FROM customer_revenue
)
SELECT
    ROUND(SUM(CASE WHEN quintile = 1 THEN total_revenue ELSE 0 END) * 100.0 / SUM(total_revenue), 2)
    AS pct_revenue_from_top_20_pct_customers
FROM ranked;

SELECT
    COUNT(DISTINCT ORDERNUMBER)    AS total_orders,
    COUNT(DISTINCT CUSTOMERNAME)   AS total_customers,
    COUNT(DISTINCT COUNTRY)        AS countries_served,
    COUNT(DISTINCT PRODUCTLINE)    AS product_lines,
    ROUND(SUM(SALES), 2)           AS total_revenue,
    ROUND(SUM(SALES) / COUNT(DISTINCT ORDERNUMBER), 2) AS avg_order_value,
    MIN(ORDERDATE)                 AS first_order_date,
    MAX(ORDERDATE)                 AS last_order_date
FROM sales_data_sample;

SELECT 'Top Country' AS metric, COUNTRY AS value, ROUND(SUM(SALES),2) AS revenue
FROM sales_data_sample GROUP BY COUNTRY ORDER BY revenue DESC LIMIT 1
UNION ALL
SELECT 'Top Product Line', PRODUCTLINE, ROUND(SUM(SALES),2)
FROM sales_data_sample GROUP BY PRODUCTLINE ORDER BY 3 DESC LIMIT 1
UNION ALL
SELECT 'Top Customer', CUSTOMERNAME, ROUND(SUM(SALES),2)
FROM sales_data_sample GROUP BY CUSTOMERNAME ORDER BY 3 DESC LIMIT 1
UNION ALL
SELECT 'Top Deal Size', DEALSIZE, ROUND(SUM(SALES),2)
FROM sales_data_sample GROUP BY DEALSIZE ORDER BY 3 DESC LIMIT 1
UNION ALL
SELECT 'Top Territory', TERRITORY, ROUND(SUM(SALES),2)
FROM sales_data_sample GROUP BY TERRITORY ORDER BY 3 DESC LIMIT 1;

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
    AS pct_revenue_top_20pct_customers
FROM ranked;

SELECT QTR_ID, ROUND(SUM(SALES), 2) AS total_revenue,
       ROUND(SUM(SALES) * 100.0 / (SELECT SUM(SALES) FROM sales_data_sample), 2) AS pct_of_total
FROM sales_data_sample
GROUP BY QTR_ID
ORDER BY QTR_ID;

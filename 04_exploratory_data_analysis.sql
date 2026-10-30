SELECT * FROM sales_data_sample LIMIT 10;

SELECT DISTINCT PRODUCTLINE FROM sales_data_sample ORDER BY PRODUCTLINE;

SELECT ORDERNUMBER, CUSTOMERNAME, COUNTRY, SALES
FROM sales_data_sample
WHERE COUNTRY = 'FRANCE';

SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
WHERE SALES > 5000
ORDER BY SALES DESC;

SELECT ORDERNUMBER, ORDERDATE, SALES
FROM sales_data_sample
WHERE ORDERDATE BETWEEN '2004-01-01' AND '2004-03-31'
ORDER BY ORDERDATE;

SELECT DISTINCT CUSTOMERNAME
FROM sales_data_sample
WHERE CUSTOMERNAME LIKE '%Toys%';

SELECT ORDERNUMBER, COUNTRY, SALES
FROM sales_data_sample
WHERE COUNTRY IN ('USA', 'FRANCE', 'AUSTRALIA');

SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
ORDER BY SALES DESC
LIMIT 10;

SELECT ROUND(SUM(SALES), 2) AS total_revenue FROM sales_data_sample;

SELECT ROUND(AVG(SALES), 2) AS avg_sale_value FROM sales_data_sample;

SELECT MIN(SALES) AS min_sale, MAX(SALES) AS max_sale FROM sales_data_sample;

SELECT COUNT(*) AS total_line_items FROM sales_data_sample;

SELECT COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY total_revenue DESC;

SELECT PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC;

SELECT COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY
HAVING SUM(SALES) > 500000
ORDER BY total_revenue DESC;

SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS num_orders
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY num_orders DESC;

SELECT
    ORDERNUMBER,
    SALES,
    CASE
        WHEN SALES >= 5000 THEN 'High Value'
        WHEN SALES >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS revenue_tier
FROM sales_data_sample;

SELECT
    CASE
        WHEN SALES >= 5000 THEN 'High Value'
        WHEN SALES >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS revenue_tier,
    COUNT(*) AS num_orders
FROM sales_data_sample
GROUP BY revenue_tier;

SELECT CUSTOMERNAME, COALESCE(STATE, 'Not Provided') AS state_clean
FROM sales_data_sample
LIMIT 20;

SELECT ORDERNUMBER, ORDERDATE, YEAR(ORDERDATE) AS order_year, MONTH(ORDERDATE) AS order_month
FROM sales_data_sample;

SELECT
    DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month,
    ROUND(SUM(SALES), 2) AS monthly_revenue
FROM sales_data_sample
GROUP BY order_month
ORDER BY order_month;

SELECT ORDERNUMBER, ORDERDATE, DATEDIFF(CURDATE(), ORDERDATE) AS days_since_order
FROM sales_data_sample
ORDER BY ORDERDATE DESC;

SELECT ORDERNUMBER, ORDERDATE, DAYNAME(ORDERDATE) AS order_weekday
FROM sales_data_sample;

SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
WHERE SALES > (SELECT AVG(SALES) FROM sales_data_sample);

SELECT CUSTOMERNAME, total_revenue
FROM (
    SELECT CUSTOMERNAME, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) AS customer_totals
ORDER BY total_revenue DESC
LIMIT 1;

SELECT DISTINCT CUSTOMERNAME
FROM sales_data_sample
WHERE CUSTOMERNAME NOT IN (
    SELECT DISTINCT CUSTOMERNAME
    FROM sales_data_sample
    WHERE PRODUCTLINE = 'Classic Cars'
);

WITH country_revenue AS (
    SELECT COUNTRY, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY COUNTRY
)
SELECT COUNTRY, ROUND(total_revenue, 2) AS total_revenue
FROM country_revenue
ORDER BY total_revenue DESC;

WITH customer_dates AS (
    SELECT CUSTOMERNAME, MIN(ORDERDATE) AS first_order_date, MAX(ORDERDATE) AS last_order_date
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
)
SELECT CUSTOMERNAME, first_order_date, last_order_date,
       DATEDIFF(last_order_date, first_order_date) AS customer_lifespan_days
FROM customer_dates
ORDER BY customer_lifespan_days DESC;

WITH productline_revenue AS (
    SELECT PRODUCTLINE, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY PRODUCTLINE
)
SELECT PRODUCTLINE, ROUND(total_revenue, 2) AS total_revenue
FROM productline_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM productline_revenue)
ORDER BY total_revenue DESC;

DROP TABLE IF EXISTS customer_lookup;
CREATE TABLE customer_lookup AS
SELECT DISTINCT CUSTOMERNAME, COUNTRY, TERRITORY
FROM sales_data_sample;

SELECT s.ORDERNUMBER, s.SALES, c.CUSTOMERNAME, c.COUNTRY, c.TERRITORY
FROM sales_data_sample s
INNER JOIN customer_lookup c
    ON s.CUSTOMERNAME = c.CUSTOMERNAME
LIMIT 20;

SELECT c.CUSTOMERNAME, s.ORDERNUMBER, s.SALES
FROM customer_lookup c
LEFT JOIN sales_data_sample s
    ON c.CUSTOMERNAME = s.CUSTOMERNAME
LIMIT 20;

SELECT c.CUSTOMERNAME AS lookup_name, s.ORDERNUMBER, s.CUSTOMERNAME, s.SALES
FROM customer_lookup c
RIGHT JOIN sales_data_sample s
    ON c.CUSTOMERNAME = s.CUSTOMERNAME
LIMIT 20;

SELECT DISTINCT p.PRODUCTLINE, d.DEALSIZE
FROM (SELECT DISTINCT PRODUCTLINE FROM sales_data_sample) p
CROSS JOIN (SELECT DISTINCT DEALSIZE FROM sales_data_sample) d
ORDER BY p.PRODUCTLINE, d.DEALSIZE;

SELECT DISTINCT
    a.CUSTOMERNAME AS customer_a,
    b.CUSTOMERNAME AS customer_b,
    a.COUNTRY
FROM sales_data_sample a
INNER JOIN sales_data_sample b
    ON a.COUNTRY = b.COUNTRY
   AND a.CUSTOMERNAME <> b.CUSTOMERNAME
WHERE a.COUNTRY = 'USA'
LIMIT 20;

SELECT CUSTOMERNAME FROM (
    SELECT CUSTOMERNAME, SUM(SALES) AS rev FROM sales_data_sample GROUP BY CUSTOMERNAME ORDER BY rev DESC LIMIT 5
) top_by_revenue
UNION
SELECT CUSTOMERNAME FROM (
    SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS orders FROM sales_data_sample GROUP BY CUSTOMERNAME ORDER BY orders DESC LIMIT 5
) top_by_orders;

SELECT CUSTOMERNAME FROM (
    SELECT CUSTOMERNAME, SUM(SALES) AS rev FROM sales_data_sample GROUP BY CUSTOMERNAME ORDER BY rev DESC LIMIT 5
) top_by_revenue
UNION ALL
SELECT CUSTOMERNAME FROM (
    SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS orders FROM sales_data_sample GROUP BY CUSTOMERNAME ORDER BY orders DESC LIMIT 5
) top_by_orders;

SELECT
    COUNTRY,
    CUSTOMERNAME,
    SALES,
    ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY SALES DESC) AS row_num
FROM sales_data_sample;

SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(SALES) DESC) AS revenue_rank
FROM sales_data_sample
GROUP BY PRODUCTLINE;

SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY SUM(SALES) DESC) AS revenue_dense_rank
FROM sales_data_sample
GROUP BY PRODUCTLINE;

SELECT
    CUSTOMERNAME,
    total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
FROM (
    SELECT CUSTOMERNAME, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) t;

SELECT
    order_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month), 2) AS revenue_change
FROM (
    SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month, SUM(SALES) AS monthly_revenue
    FROM sales_data_sample
    GROUP BY order_month
) monthly;

SELECT
    order_month,
    monthly_revenue,
    LEAD(monthly_revenue) OVER (ORDER BY order_month) AS next_month_revenue
FROM (
    SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month, SUM(SALES) AS monthly_revenue
    FROM sales_data_sample
    GROUP BY order_month
) monthly;

DROP TEMPORARY TABLE IF EXISTS temp_yearly_revenue;
CREATE TEMPORARY TABLE temp_yearly_revenue AS
SELECT YEAR_ID, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY YEAR_ID;

SELECT * FROM temp_yearly_revenue ORDER BY YEAR_ID;

SELECT
    YEAR_ID,
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS pct_of_total_revenue
FROM temp_yearly_revenue
ORDER BY YEAR_ID;

CREATE OR REPLACE VIEW vw_productline_dealsize_summary AS
SELECT
    PRODUCTLINE,
    DEALSIZE,
    COUNT(*) AS num_orders,
    ROUND(SUM(SALES), 2) AS total_revenue,
    ROUND(AVG(SALES), 2) AS avg_sale
FROM sales_data_sample
GROUP BY PRODUCTLINE, DEALSIZE;

SELECT * FROM vw_productline_dealsize_summary ORDER BY total_revenue DESC;

SELECT * FROM vw_productline_dealsize_summary
WHERE DEALSIZE = 'Large'
ORDER BY total_revenue DESC;


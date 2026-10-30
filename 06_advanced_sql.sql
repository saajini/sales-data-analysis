WITH RECURSIVE calendar_months AS (
    SELECT DATE_FORMAT(MIN(ORDERDATE), '%Y-%m-01') AS month_start
    FROM sales_data_sample

    UNION ALL

    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM calendar_months
    WHERE month_start < (SELECT DATE_FORMAT(MAX(ORDERDATE), '%Y-%m-01') FROM sales_data_sample)
)
SELECT
    DATE_FORMAT(cm.month_start, '%Y-%m') AS calendar_month,
    COALESCE(ROUND(SUM(s.SALES), 2), 0) AS total_revenue
FROM calendar_months cm
LEFT JOIN sales_data_sample s
    ON DATE_FORMAT(s.ORDERDATE, '%Y-%m') = DATE_FORMAT(cm.month_start, '%Y-%m')
GROUP BY calendar_month
ORDER BY calendar_month;

WITH RECURSIVE tier_bounds AS (
    SELECT 0 AS lower_bound
    UNION ALL
    SELECT lower_bound + 1000
    FROM tier_bounds
    WHERE lower_bound < 10000
)
SELECT
    tb.lower_bound,
    tb.lower_bound + 999 AS upper_bound,
    COUNT(s.SALES) AS num_orders
FROM tier_bounds tb
LEFT JOIN sales_data_sample s
    ON s.SALES >= tb.lower_bound AND s.SALES <= tb.lower_bound + 999
GROUP BY tb.lower_bound
ORDER BY tb.lower_bound;

SELECT
    order_month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_revenue
FROM (
    SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month, SUM(SALES) AS monthly_revenue
    FROM sales_data_sample
    GROUP BY order_month
) monthly
ORDER BY order_month;

SELECT
    order_month,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        ORDER BY order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3month
FROM (
    SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month, SUM(SALES) AS monthly_revenue
    FROM sales_data_sample
    GROUP BY order_month
) monthly
ORDER BY order_month;

SELECT *
FROM (
    SELECT
        COUNTRY,
        CUSTOMERNAME,
        SUM(SALES) AS total_revenue,
        RANK() OVER (PARTITION BY COUNTRY ORDER BY SUM(SALES) DESC) AS rank_in_country
    FROM sales_data_sample
    GROUP BY COUNTRY, CUSTOMERNAME
) ranked
WHERE rank_in_country <= 3
ORDER BY COUNTRY, rank_in_country;

SELECT
    TERRITORY,
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS revenue,
    ROUND(SUM(SALES) * 100.0 / SUM(SUM(SALES)) OVER (PARTITION BY TERRITORY), 2) AS pct_of_territory_revenue
FROM sales_data_sample
GROUP BY TERRITORY, PRODUCTLINE
ORDER BY TERRITORY, pct_of_territory_revenue DESC;

WITH first_order AS (
    SELECT CUSTOMERNAME, MIN(YEAR(ORDERDATE)) AS cohort_year
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
)
SELECT
    fo.cohort_year,
    YEAR(s.ORDERDATE) AS activity_year,
    ROUND(SUM(s.SALES), 2) AS revenue
FROM sales_data_sample s
INNER JOIN first_order fo
    ON s.CUSTOMERNAME = fo.CUSTOMERNAME
GROUP BY fo.cohort_year, activity_year
ORDER BY fo.cohort_year, activity_year;

SELECT COUNTRY, PRODUCTLINE, total_revenue
FROM (
    SELECT COUNTRY, PRODUCTLINE, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY COUNTRY, PRODUCTLINE
) outer_q
WHERE total_revenue = (
    SELECT MAX(total_revenue)
    FROM (
        SELECT COUNTRY, PRODUCTLINE, SUM(SALES) AS total_revenue
        FROM sales_data_sample
        GROUP BY COUNTRY, PRODUCTLINE
    ) inner_q
    WHERE inner_q.COUNTRY = outer_q.COUNTRY
)
ORDER BY COUNTRY;

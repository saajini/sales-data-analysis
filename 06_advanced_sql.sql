-- ============================================================================
-- File        : 06_advanced_sql.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Advanced SQL concepts - recursive CTEs, advanced window
--                function patterns, and multi-level analytical queries.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- 1. RECURSIVE CTE: Generate a full calendar month series
-- ----------------------------------------------------------------------------
-- Purpose: Build a continuous month-by-month calendar spanning the full date
--          range of the dataset. Useful for reports that must show months
--          with zero sales (which a simple GROUP BY would silently skip).
-- Logic  : A recursive CTE starts at the earliest ORDERDATE month and adds
--          one month at a time until it passes the latest ORDERDATE month.
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

-- ----------------------------------------------------------------------------
-- 2. RECURSIVE CTE: Generate a numbers sequence (used to build revenue tiers)
-- ----------------------------------------------------------------------------
-- Purpose: Demonstrate a classic recursive CTE pattern - a number generator -
--          then use it to build custom $1,000 revenue bands dynamically.
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

-- ----------------------------------------------------------------------------
-- 3. WINDOW FUNCTION: Running (cumulative) total of revenue by month
-- ----------------------------------------------------------------------------
-- Purpose: Show cumulative revenue growth across the timeline - a common
--          executive dashboard visual.
-- Logic  : SUM() OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING) computes a
--          running total.
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

-- ----------------------------------------------------------------------------
-- 4. WINDOW FUNCTION: 3-month moving average of revenue
-- ----------------------------------------------------------------------------
-- Purpose: Smooth out month-to-month volatility to reveal the underlying
--          trend line.
-- Logic  : AVG() OVER (ORDER BY ... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
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

-- ----------------------------------------------------------------------------
-- 5. WINDOW FUNCTION: Each customer's rank within their own country
-- ----------------------------------------------------------------------------
-- Purpose: Identify the top customer(s) inside each country rather than
--          globally - useful for regional account management.
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

-- ----------------------------------------------------------------------------
-- 6. WINDOW FUNCTION: Percentage of each product line's contribution within
--    its own territory
-- ----------------------------------------------------------------------------
-- Purpose: Understand relative product mix per territory rather than globally.
SELECT
    TERRITORY,
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS revenue,
    ROUND(SUM(SALES) * 100.0 / SUM(SUM(SALES)) OVER (PARTITION BY TERRITORY), 2) AS pct_of_territory_revenue
FROM sales_data_sample
GROUP BY TERRITORY, PRODUCTLINE
ORDER BY TERRITORY, pct_of_territory_revenue DESC;

-- ----------------------------------------------------------------------------
-- 7. MULTI-LEVEL ANALYSIS: Customer cohort analysis by first-order year
-- ----------------------------------------------------------------------------
-- Purpose: Group customers into "cohorts" based on the year of their first
--          order, then track total revenue generated by each cohort in each
--          subsequent year - a common SaaS/retail retention analysis pattern.
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

-- ----------------------------------------------------------------------------
-- 8. MULTI-LEVEL ANALYSIS: Top product per country using a correlated
--    subquery
-- ----------------------------------------------------------------------------
-- Purpose: For each country, find its single best-selling product line.
-- Logic  : A correlated subquery re-evaluates for every row of the outer
--          query, comparing each country/productline total against the
--          max total for that same country.
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

-- ============================================================================
-- End of 06_advanced_sql.sql
-- ============================================================================

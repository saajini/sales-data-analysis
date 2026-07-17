-- ============================================================================
-- File        : 12_final_insights.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Final consolidated queries supporting the top-level
--                findings and recommendations summarized in the README.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- INSIGHT 1: Overall business snapshot
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- INSIGHT 2: Top 5 revenue drivers (country, product line, customer)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- INSIGHT 3: Revenue concentration check (Pareto principle)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- INSIGHT 4: Seasonality confirmation (revenue by quarter)
-- ----------------------------------------------------------------------------
SELECT QTR_ID, ROUND(SUM(SALES), 2) AS total_revenue,
       ROUND(SUM(SALES) * 100.0 / (SELECT SUM(SALES) FROM sales_data_sample), 2) AS pct_of_total
FROM sales_data_sample
GROUP BY QTR_ID
ORDER BY QTR_ID;

-- ============================================================================
-- WRITTEN SUMMARY (also included in README.md)
-- ============================================================================
--
-- TOP FINDINGS
-- ------------
-- 1. Revenue is heavily concentrated: the top 20% of customers generate a
--    disproportionately large share of total revenue - a classic Pareto
--    (80/20) pattern.
-- 2. The USA is the largest single market, followed by Spain and France;
--    Classic Cars is consistently the top-performing product line.
-- 3. Sales are strongly seasonal, peaking in Q4 (particularly November),
--    consistent with holiday-driven purchasing behavior.
-- 4. "Medium" deal size orders are the most frequent, but "Large" deals
--    contribute a disproportionately higher share of revenue per order.
-- 5. A subset of customers show no recent order activity within the last
--    six months of available data, representing a concrete churn-risk list.
--
-- BUSINESS RECOMMENDATIONS
-- -------------------------
-- 1. Launch a retention/loyalty program targeted at the top 20% of
--    customers identified in Insight 3, since they disproportionately
--    drive revenue.
-- 2. Build Q4 inventory and staffing plans around the confirmed seasonal
--    peak, and consider early Q3 promotions to extend the buying window.
-- 3. Investigate why "Medium" deals rarely convert into "Large" deals -
--    a targeted upsell/discount strategy could shift the mix.
-- 4. Run a win-back email campaign for the churn-risk customer segment
--    identified in 05_business_questions.sql (Q27).
-- 5. Consider a modest price increase test on products with a high
--    sale-to-MSRP ratio (Q25), since they show strong pricing power.
--
-- FUTURE IMPROVEMENTS
-- --------------------
-- 1. Integrate a live/updating data source instead of a static CSV snapshot
--    so trend analysis reflects the most current business activity.
-- 2. Add a proper customers/products dimension table (star schema) to
--    normalize the current single flat table and improve query performance
--    at larger data volumes.
-- 3. Layer this SQL project with a BI tool (Power BI / Tableau) connected
--    directly to the views built in 07_views.sql for interactive dashboards.
-- 4. Incorporate customer acquisition cost and profit margin data (not
--    present in the current dataset) to move from revenue-based to
--    profit-based recommendations.
--
-- ============================================================================
-- End of 12_final_insights.sql
-- ============================================================================

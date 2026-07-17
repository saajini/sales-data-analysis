-- ============================================================================
-- File        : 05_business_questions.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : 25+ realistic business questions with SQL answers and
--                written business insights, as a Data Analyst would deliver
--                to a stakeholder.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- Q1. What is the monthly sales trend across all years?
-- ----------------------------------------------------------------------------
SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS sales_month, ROUND(SUM(SALES), 2) AS total_sales
FROM sales_data_sample
GROUP BY sales_month
ORDER BY sales_month;
-- Insight: Revenue consistently peaks in Q4 (Oct-Nov) each year, suggesting a
-- strong seasonal buying pattern - likely tied to holiday purchasing. Marketing
-- and inventory planning should be weighted toward Q4.

-- ----------------------------------------------------------------------------
-- Q2. What is the yearly sales trend?
-- ----------------------------------------------------------------------------
SELECT YEAR_ID, ROUND(SUM(SALES), 2) AS total_sales
FROM sales_data_sample
GROUP BY YEAR_ID
ORDER BY YEAR_ID;
-- Insight: Total revenue grew year-over-year between the earliest and middle
-- years in the dataset. The final year in the data may look artificially low
-- if the dataset ends mid-year - always confirm with MAX(ORDERDATE) before
-- concluding a real decline.

-- ----------------------------------------------------------------------------
-- Q3. Which countries generate the most revenue?
-- ----------------------------------------------------------------------------
SELECT COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY total_revenue DESC;
-- Insight: The USA is the largest single market by a wide margin, followed by
-- Spain and France. This concentration signals both an opportunity to double
-- down on top markets and a risk of over-reliance on one region.

-- ----------------------------------------------------------------------------
-- Q4. Which cities generate the most revenue?
-- ----------------------------------------------------------------------------
SELECT CITY, COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY CITY, COUNTRY
ORDER BY total_revenue DESC
LIMIT 15;
-- Insight: Revenue is heavily concentrated in a handful of major cities,
-- indicating urban markets drive the bulk of sales - useful for targeted
-- regional promotions or warehouse placement decisions.

-- ----------------------------------------------------------------------------
-- Q5. Who are the top 10 customers by total revenue?
-- ----------------------------------------------------------------------------
SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY total_revenue DESC
LIMIT 10;
-- Insight: The top 10 customers contribute a disproportionately large share
-- of total revenue. These accounts should be prioritized for account
-- management and retention programs.

-- ----------------------------------------------------------------------------
-- Q6. Who are the bottom 10 customers by total revenue?
-- ----------------------------------------------------------------------------
SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY total_revenue ASC
LIMIT 10;
-- Insight: Low-revenue customers may represent under-served accounts with
-- growth potential, or low-priority/inactive relationships worth
-- re-evaluating for cost-to-serve.

-- ----------------------------------------------------------------------------
-- Q7. Which product generates the highest total revenue?
-- ----------------------------------------------------------------------------
SELECT PRODUCTCODE, PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTCODE, PRODUCTLINE
ORDER BY total_revenue DESC
LIMIT 10;
-- Insight: A small number of SKUs drive a large share of revenue - classic
-- Pareto pattern. These "hero products" deserve guaranteed stock availability.

-- ----------------------------------------------------------------------------
-- Q8. Which product line performs best overall?
-- ----------------------------------------------------------------------------
SELECT PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC
LIMIT 1;
-- Insight: "Classic Cars" is typically the top-performing product line in
-- this dataset, suggesting strong, sustained demand that could justify
-- expanded catalog depth in that category.

-- ----------------------------------------------------------------------------
-- Q9. Which product line performs worst overall?
-- ----------------------------------------------------------------------------
SELECT PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_revenue ASC
LIMIT 1;
-- Insight: The lowest-performing line may need a pricing review, a marketing
-- push, or a portfolio decision about whether to continue carrying it.

-- ----------------------------------------------------------------------------
-- Q10. How does revenue break down by deal size (Small/Medium/Large)?
-- ----------------------------------------------------------------------------
SELECT DEALSIZE, COUNT(*) AS num_orders, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY DEALSIZE
ORDER BY total_revenue DESC;
-- Insight: Medium deals are typically the most frequent, but Large deals
-- contribute an outsized share of revenue per order - the sales team should
-- prioritize converting Medium accounts into Large ones.

-- ----------------------------------------------------------------------------
-- Q11. What is the average order value (AOV)?
-- ----------------------------------------------------------------------------
SELECT ROUND(SUM(SALES) / COUNT(DISTINCT ORDERNUMBER), 2) AS avg_order_value
FROM sales_data_sample;
-- Insight: This single benchmark number is useful for tracking growth over
-- time and comparing performance across sales reps, regions, or campaigns.

-- ----------------------------------------------------------------------------
-- Q12. Which country is the most "profitable" based on average sale size?
-- ----------------------------------------------------------------------------
SELECT COUNTRY, ROUND(AVG(SALES), 2) AS avg_sale_value
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY avg_sale_value DESC
LIMIT 10;
-- Insight: Some smaller markets have a higher average sale value than the
-- USA, suggesting premium or bulk-buying behavior worth targeting with
-- higher-margin products.

-- ----------------------------------------------------------------------------
-- Q13. What is the most frequently ordered product?
-- ----------------------------------------------------------------------------
SELECT PRODUCTCODE, PRODUCTLINE, COUNT(*) AS times_ordered
FROM sales_data_sample
GROUP BY PRODUCTCODE, PRODUCTLINE
ORDER BY times_ordered DESC
LIMIT 10;
-- Insight: Order frequency and order value don't always align - a
-- frequently-ordered but lower-value item may be a good candidate for
-- bundling with higher-margin products.

-- ----------------------------------------------------------------------------
-- Q14. How is revenue distributed across quarters?
-- ----------------------------------------------------------------------------
SELECT QTR_ID, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY QTR_ID
ORDER BY QTR_ID;
-- Insight: Q4 consistently outperforms other quarters, confirming the
-- holiday-driven seasonality also visible in the monthly trend (Q1).

-- ----------------------------------------------------------------------------
-- Q15. How is revenue distributed by calendar month (across all years combined)?
-- ----------------------------------------------------------------------------
SELECT MONTH_ID, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY MONTH_ID
ORDER BY MONTH_ID;
-- Insight: November stands out as the strongest single month, reinforcing
-- the case for pre-holiday inventory build-up starting in Q3.

-- ----------------------------------------------------------------------------
-- Q16. How often does each customer place orders (order frequency)?
-- ----------------------------------------------------------------------------
SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS order_frequency
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY order_frequency DESC
LIMIT 15;
-- Insight: A subset of customers order very frequently - these are strong
-- candidates for a loyalty program or dedicated account manager.

-- ----------------------------------------------------------------------------
-- Q17. What is the breakdown of orders by shipping/order status?
-- ----------------------------------------------------------------------------
SELECT STATUS, COUNT(*) AS num_orders, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY STATUS
ORDER BY num_orders DESC;
-- Insight: The vast majority of orders are marked "Shipped", but tracking
-- "Cancelled", "On Hold", and "Disputed" volumes over time can serve as an
-- early warning indicator for operational or customer-satisfaction issues.

-- ----------------------------------------------------------------------------
-- Q18. Which sales territory performs best?
-- ----------------------------------------------------------------------------
SELECT TERRITORY, ROUND(SUM(SALES), 2) AS total_revenue, COUNT(DISTINCT ORDERNUMBER) AS num_orders
FROM sales_data_sample
GROUP BY TERRITORY
ORDER BY total_revenue DESC;
-- Insight: EMEA typically leads on order count while other territories may
-- lead on average order value - territory strategy should differ accordingly
-- (volume-focused vs. value-focused approaches).

-- ----------------------------------------------------------------------------
-- Q19. What does the overall sales distribution look like (histogram-style)?
-- ----------------------------------------------------------------------------
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
-- Insight: Most order lines fall in the 2000-3999 range, with a long tail of
-- high-value outliers - useful context when setting discount thresholds.

-- ----------------------------------------------------------------------------
-- Q20. What percentage of total revenue does each product line contribute?
-- ----------------------------------------------------------------------------
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS total_revenue,
    ROUND(SUM(SALES) * 100.0 / (SELECT SUM(SALES) FROM sales_data_sample), 2) AS pct_of_total
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY pct_of_total DESC;
-- Insight: The top 2-3 product lines typically account for more than half of
-- total revenue - a useful figure for product portfolio prioritization.

-- ----------------------------------------------------------------------------
-- Q21. What are the top 10 highest-value individual orders?
-- ----------------------------------------------------------------------------
SELECT ORDERNUMBER, CUSTOMERNAME, ROUND(SUM(SALES), 2) AS order_total
FROM sales_data_sample
GROUP BY ORDERNUMBER, CUSTOMERNAME
ORDER BY order_total DESC
LIMIT 10;
-- Insight: The largest orders come from a mix of repeat top customers and
-- occasional one-off large purchases - worth investigating what drove the
-- one-off spikes (bulk promotions, new client onboarding, etc.).

-- ----------------------------------------------------------------------------
-- Q22. What are the bottom 10 lowest-value individual orders?
-- ----------------------------------------------------------------------------
SELECT ORDERNUMBER, CUSTOMERNAME, ROUND(SUM(SALES), 2) AS order_total
FROM sales_data_sample
GROUP BY ORDERNUMBER, CUSTOMERNAME
ORDER BY order_total ASC
LIMIT 10;
-- Insight: Very small orders may not be profitable once shipping and
-- handling costs are considered - a minimum order value policy could be
-- worth evaluating.

-- ----------------------------------------------------------------------------
-- Q23. Can we segment customers into value tiers (Platinum/Gold/Silver/Bronze)?
-- ----------------------------------------------------------------------------
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
-- Insight: Segmenting customers this way makes it easy to design tiered
-- loyalty perks or prioritize account management effort where it has the
-- greatest revenue impact.

-- ----------------------------------------------------------------------------
-- Q24. How does country-wise sales performance break down by product line?
-- ----------------------------------------------------------------------------
SELECT COUNTRY, PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY, PRODUCTLINE
ORDER BY COUNTRY, total_revenue DESC;
-- Insight: Product preferences vary meaningfully by country - e.g. some
-- markets over-index on Motorcycles relative to their overall sales share -
-- an input for localized marketing and inventory allocation.

-- ----------------------------------------------------------------------------
-- Q25. Which products have the best "performance ratio" (revenue vs. MSRP)?
-- ----------------------------------------------------------------------------
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
-- Insight: Products consistently selling well above their listed MSRP ratio
-- indicate strong pricing power / low price sensitivity - good candidates
-- for a price increase test.

-- ----------------------------------------------------------------------------
-- Q26. What is the year-over-year revenue growth rate?
-- ----------------------------------------------------------------------------
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
-- Insight: Year-over-year growth quantifies momentum and gives leadership a
-- clear, board-ready metric beyond raw revenue totals.

-- ----------------------------------------------------------------------------
-- Q27. Which customers are at risk of churn (no orders in the most recent
--       6 months of data available)?
-- ----------------------------------------------------------------------------
WITH last_order AS (
    SELECT CUSTOMERNAME, MAX(ORDERDATE) AS last_order_date
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
)
SELECT CUSTOMERNAME, last_order_date
FROM last_order
WHERE last_order_date < (SELECT DATE_SUB(MAX(ORDERDATE), INTERVAL 6 MONTH) FROM sales_data_sample)
ORDER BY last_order_date;
-- Insight: This churn-risk list is directly actionable for a win-back email
-- campaign or a proactive account-manager outreach effort.

-- ----------------------------------------------------------------------------
-- Q28. What is the revenue contribution of the top 20% of customers
--       (Pareto / 80-20 check)?
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
    AS pct_revenue_from_top_20_pct_customers
FROM ranked;
-- Insight: If the top 20% of customers drive well over 50% of revenue, this
-- confirms a Pareto-style concentration and justifies investing
-- disproportionately in retaining that segment.

-- ============================================================================
-- End of 05_business_questions.sql (28 business questions total)
-- ============================================================================

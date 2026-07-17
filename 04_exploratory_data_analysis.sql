-- ============================================================================
-- File        : 04_exploratory_data_analysis.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Exploratory Data Analysis (EDA) - 40+ queries covering
--                core SQL fundamentals through intermediate SQL concepts.
-- Note         : Every query includes Purpose / Logic / Expected Output.
-- ============================================================================

USE sales_analysis;

-- ============================================================================
-- SECTION A: BASIC SELECT / FILTERING / SORTING (Queries 1-8)
-- ============================================================================

-- Query 1
-- Purpose : Preview the raw dataset.
-- Logic   : Simple SELECT with LIMIT.
-- Output  : First 10 rows of all columns.
SELECT * FROM sales_data_sample LIMIT 10;

-- Query 2
-- Purpose : List distinct product lines sold.
-- Logic   : DISTINCT removes duplicate PRODUCTLINE values.
-- Output  : 7 unique product lines (e.g. Classic Cars, Motorcycles, ...).
SELECT DISTINCT PRODUCTLINE FROM sales_data_sample ORDER BY PRODUCTLINE;

-- Query 3
-- Purpose : Find all orders shipped to France.
-- Logic   : WHERE filters rows on an exact match.
-- Output  : All order rows where COUNTRY = 'FRANCE'.
SELECT ORDERNUMBER, CUSTOMERNAME, COUNTRY, SALES
FROM sales_data_sample
WHERE COUNTRY = 'FRANCE';

-- Query 4
-- Purpose : Find high-value order lines.
-- Logic   : WHERE with a comparison operator.
-- Output  : Rows where SALES exceeds 5000.
SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
WHERE SALES > 5000
ORDER BY SALES DESC;

-- Query 5
-- Purpose : Find orders placed within a specific date range.
-- Logic   : BETWEEN is inclusive of both boundary dates.
-- Output  : Orders placed during Q1 2004.
SELECT ORDERNUMBER, ORDERDATE, SALES
FROM sales_data_sample
WHERE ORDERDATE BETWEEN '2004-01-01' AND '2004-03-31'
ORDER BY ORDERDATE;

-- Query 6
-- Purpose : Find customers whose company name contains "Toys".
-- Logic   : LIKE with wildcard % for partial text matching.
-- Output  : All CUSTOMERNAME values containing the substring "Toys".
SELECT DISTINCT CUSTOMERNAME
FROM sales_data_sample
WHERE CUSTOMERNAME LIKE '%Toys%';

-- Query 7
-- Purpose : Find orders from a specific set of countries.
-- Logic   : IN checks membership against a list of values.
-- Output  : Rows where COUNTRY is USA, France, or Australia.
SELECT ORDERNUMBER, COUNTRY, SALES
FROM sales_data_sample
WHERE COUNTRY IN ('USA', 'FRANCE', 'AUSTRALIA');

-- Query 8
-- Purpose : Top 10 highest-value order lines.
-- Logic   : ORDER BY DESC + LIMIT.
-- Output  : 10 rows sorted by SALES descending.
SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
ORDER BY SALES DESC
LIMIT 10;

-- ============================================================================
-- SECTION B: AGGREGATE FUNCTIONS / GROUP BY / HAVING (Queries 9-16)
-- ============================================================================

-- Query 9
-- Purpose : Calculate total revenue across the whole dataset.
-- Logic   : SUM aggregate function.
-- Output  : Single value - total sales.
SELECT ROUND(SUM(SALES), 2) AS total_revenue FROM sales_data_sample;

-- Query 10
-- Purpose : Calculate average order line value.
-- Logic   : AVG aggregate function.
-- Output  : Single value - average SALES per line item.
SELECT ROUND(AVG(SALES), 2) AS avg_sale_value FROM sales_data_sample;

-- Query 11
-- Purpose : Find the minimum and maximum sale amount.
-- Logic   : MIN and MAX in one query.
-- Output  : Two columns showing the smallest and largest sale.
SELECT MIN(SALES) AS min_sale, MAX(SALES) AS max_sale FROM sales_data_sample;

-- Query 12
-- Purpose : Count total number of order line items.
-- Logic   : COUNT(*) counts all rows.
-- Output  : Single value - total row count.
SELECT COUNT(*) AS total_line_items FROM sales_data_sample;

-- Query 13
-- Purpose : Revenue grouped by country.
-- Logic   : GROUP BY aggregates SALES per COUNTRY.
-- Output  : One row per country with total revenue, sorted highest first.
SELECT COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY
ORDER BY total_revenue DESC;

-- Query 14
-- Purpose : Revenue grouped by product line.
-- Logic   : GROUP BY on PRODUCTLINE.
-- Output  : One row per product line with total revenue.
SELECT PRODUCTLINE, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC;

-- Query 15
-- Purpose : Find countries generating more than $500,000 in total revenue.
-- Logic   : HAVING filters aggregated groups (unlike WHERE, which filters
--           rows before aggregation).
-- Output  : Countries whose SUM(SALES) exceeds 500000.
SELECT COUNTRY, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY COUNTRY
HAVING SUM(SALES) > 500000
ORDER BY total_revenue DESC;

-- Query 16
-- Purpose : Count number of distinct orders per customer.
-- Logic   : COUNT(DISTINCT ...) inside a GROUP BY.
-- Output  : One row per customer with their number of unique orders.
SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS num_orders
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY num_orders DESC;

-- ============================================================================
-- SECTION C: CASE, COALESCE, DATE FUNCTIONS (Queries 17-23)
-- ============================================================================

-- Query 17
-- Purpose : Classify each order line into a revenue tier.
-- Logic   : CASE WHEN creates a derived categorical column.
-- Output  : ORDERNUMBER, SALES, and a new revenue_tier column.
SELECT
    ORDERNUMBER,
    SALES,
    CASE
        WHEN SALES >= 5000 THEN 'High Value'
        WHEN SALES >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS revenue_tier
FROM sales_data_sample;

-- Query 18
-- Purpose : Count how many orders fall into each revenue tier.
-- Logic   : CASE inside GROUP BY (grouping by the derived expression).
-- Output  : Three rows - High/Medium/Low Value with counts.
SELECT
    CASE
        WHEN SALES >= 5000 THEN 'High Value'
        WHEN SALES >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS revenue_tier,
    COUNT(*) AS num_orders
FROM sales_data_sample
GROUP BY revenue_tier;

-- Query 19
-- Purpose : Display a fallback value when STATE is missing.
-- Logic   : COALESCE returns the first non-NULL argument.
-- Output  : STATE column with 'Not Provided' shown instead of NULL.
SELECT CUSTOMERNAME, COALESCE(STATE, 'Not Provided') AS state_clean
FROM sales_data_sample
LIMIT 20;

-- Query 20
-- Purpose : Extract the year and month from ORDERDATE.
-- Logic   : YEAR() and MONTH() date functions.
-- Output  : ORDERNUMBER with separate year and month columns.
SELECT ORDERNUMBER, ORDERDATE, YEAR(ORDERDATE) AS order_year, MONTH(ORDERDATE) AS order_month
FROM sales_data_sample;

-- Query 21
-- Purpose : Calculate monthly total revenue.
-- Logic   : DATE_FORMAT groups dates into a 'YYYY-MM' bucket.
-- Output  : One row per calendar month with total revenue.
SELECT
    DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month,
    ROUND(SUM(SALES), 2) AS monthly_revenue
FROM sales_data_sample
GROUP BY order_month
ORDER BY order_month;

-- Query 22
-- Purpose : Find how many days have passed since each order was placed.
-- Logic   : DATEDIFF compares ORDERDATE against today's date.
-- Output  : ORDERNUMBER, ORDERDATE, and days_since_order.
SELECT ORDERNUMBER, ORDERDATE, DATEDIFF(CURDATE(), ORDERDATE) AS days_since_order
FROM sales_data_sample
ORDER BY ORDERDATE DESC;

-- Query 23
-- Purpose : Identify the day of week each order was placed.
-- Logic   : DAYNAME() extracts the weekday name from a DATE.
-- Output  : ORDERNUMBER, ORDERDATE, and the weekday name.
SELECT ORDERNUMBER, ORDERDATE, DAYNAME(ORDERDATE) AS order_weekday
FROM sales_data_sample;

-- ============================================================================
-- SECTION D: SUBQUERIES & CTEs (Queries 24-29)
-- ============================================================================

-- Query 24
-- Purpose : Find orders with a sale value above the overall average.
-- Logic   : Scalar subquery inside WHERE.
-- Output  : Rows where SALES > the average of all SALES.
SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
WHERE SALES > (SELECT AVG(SALES) FROM sales_data_sample);

-- Query 25
-- Purpose : Find the single highest-spending customer.
-- Logic   : Subquery in FROM clause aggregates first, outer query sorts.
-- Output  : One row - top customer by total revenue.
SELECT CUSTOMERNAME, total_revenue
FROM (
    SELECT CUSTOMERNAME, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) AS customer_totals
ORDER BY total_revenue DESC
LIMIT 1;

-- Query 26
-- Purpose : Find customers who have never ordered the 'Classic Cars' line.
-- Logic   : NOT IN with a subquery returning a list of customer names.
-- Output  : Customers absent from the Classic Cars buyer list.
SELECT DISTINCT CUSTOMERNAME
FROM sales_data_sample
WHERE CUSTOMERNAME NOT IN (
    SELECT DISTINCT CUSTOMERNAME
    FROM sales_data_sample
    WHERE PRODUCTLINE = 'Classic Cars'
);

-- Query 27
-- Purpose : Rank countries by total revenue using a CTE for readability.
-- Logic   : WITH clause defines a named temporary result set.
-- Output  : Countries ranked by revenue, most recent CTE syntax.
WITH country_revenue AS (
    SELECT COUNTRY, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY COUNTRY
)
SELECT COUNTRY, ROUND(total_revenue, 2) AS total_revenue
FROM country_revenue
ORDER BY total_revenue DESC;

-- Query 28
-- Purpose : Find each customer's first and most recent order date.
-- Logic   : CTE aggregates MIN/MAX dates per customer, then joins back for detail.
-- Output  : CUSTOMERNAME, first_order_date, last_order_date.
WITH customer_dates AS (
    SELECT CUSTOMERNAME, MIN(ORDERDATE) AS first_order_date, MAX(ORDERDATE) AS last_order_date
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
)
SELECT CUSTOMERNAME, first_order_date, last_order_date,
       DATEDIFF(last_order_date, first_order_date) AS customer_lifespan_days
FROM customer_dates
ORDER BY customer_lifespan_days DESC;

-- Query 29
-- Purpose : Identify product lines that outperform the overall average
--           product line revenue.
-- Logic   : CTE for per-productline revenue, filtered against a second
--           scalar subquery for the overall average.
-- Output  : Product lines above the average product-line revenue.
WITH productline_revenue AS (
    SELECT PRODUCTLINE, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY PRODUCTLINE
)
SELECT PRODUCTLINE, ROUND(total_revenue, 2) AS total_revenue
FROM productline_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM productline_revenue)
ORDER BY total_revenue DESC;

-- ============================================================================
-- SECTION E: JOINS (Queries 30-35)
-- ============================================================================
-- Note: The raw dataset is a single flat table. To demonstrate JOIN syntax
-- meaningfully, we build small reference/lookup tables from the data itself.

-- Setup: create a lightweight customer lookup table for JOIN demonstrations.
DROP TABLE IF EXISTS customer_lookup;
CREATE TABLE customer_lookup AS
SELECT DISTINCT CUSTOMERNAME, COUNTRY, TERRITORY
FROM sales_data_sample;

-- Query 30
-- Purpose : Combine order details with the customer lookup table.
-- Logic   : INNER JOIN returns only matching rows in both tables.
-- Output  : Order-level rows enriched with customer country/territory.
SELECT s.ORDERNUMBER, s.SALES, c.CUSTOMERNAME, c.COUNTRY, c.TERRITORY
FROM sales_data_sample s
INNER JOIN customer_lookup c
    ON s.CUSTOMERNAME = c.CUSTOMERNAME
LIMIT 20;

-- Query 31
-- Purpose : Show every customer in the lookup table, even those without
--           matching order rows (demonstrates LEFT JOIN behavior).
-- Logic   : LEFT JOIN keeps all rows from the left table (customer_lookup).
-- Output  : All customers, with NULL order data if no match exists.
SELECT c.CUSTOMERNAME, s.ORDERNUMBER, s.SALES
FROM customer_lookup c
LEFT JOIN sales_data_sample s
    ON c.CUSTOMERNAME = s.CUSTOMERNAME
LIMIT 20;

-- Query 32
-- Purpose : Show every order row, even if the lookup table were missing
--           a matching customer (demonstrates RIGHT JOIN behavior).
-- Logic   : RIGHT JOIN keeps all rows from the right table (sales_data_sample).
-- Output  : All order rows, matched to lookup data where possible.
SELECT c.CUSTOMERNAME AS lookup_name, s.ORDERNUMBER, s.CUSTOMERNAME, s.SALES
FROM customer_lookup c
RIGHT JOIN sales_data_sample s
    ON c.CUSTOMERNAME = s.CUSTOMERNAME
LIMIT 20;

-- Query 33
-- Purpose : Generate every possible combination of product line and deal size.
-- Logic   : CROSS JOIN produces the Cartesian product of two result sets.
-- Output  : (number of product lines) x (number of deal sizes) rows.
SELECT DISTINCT p.PRODUCTLINE, d.DEALSIZE
FROM (SELECT DISTINCT PRODUCTLINE FROM sales_data_sample) p
CROSS JOIN (SELECT DISTINCT DEALSIZE FROM sales_data_sample) d
ORDER BY p.PRODUCTLINE, d.DEALSIZE;

-- Query 34
-- Purpose : Compare each customer's orders against other orders from the
--           same country (self join).
-- Logic   : SELF JOIN joins sales_data_sample to itself on COUNTRY, excluding
--           identical rows and identical customers.
-- Output  : Pairs of different customers who share the same country.
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

-- Query 35
-- Purpose : Combine two separate result sets (top customers by revenue and
--           top customers by order count) into one list, deduplicated.
-- Logic   : UNION removes duplicates; UNION ALL keeps every row.
-- Output  : Distinct list vs. full list, demonstrating the difference.
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

-- ============================================================================
-- SECTION F: WINDOW & RANKING FUNCTIONS (Queries 36-41)
-- ============================================================================

-- Query 36
-- Purpose : Assign a unique sequential number to orders within each country,
--           sorted by revenue.
-- Logic   : ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)
-- Output  : Every row gets a unique rank per country, no ties.
SELECT
    COUNTRY,
    CUSTOMERNAME,
    SALES,
    ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY SALES DESC) AS row_num
FROM sales_data_sample;

-- Query 37
-- Purpose : Rank product lines by total revenue, allowing tied ranks.
-- Logic   : RANK() OVER (...) skips ranks after a tie (1,2,2,4).
-- Output  : PRODUCTLINE, total_revenue, and its RANK.
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(SALES) DESC) AS revenue_rank
FROM sales_data_sample
GROUP BY PRODUCTLINE;

-- Query 38
-- Purpose : Rank product lines using DENSE_RANK for comparison against RANK.
-- Logic   : DENSE_RANK() does not skip numbers after ties (1,2,2,3).
-- Output  : Same as Query 37 but with DENSE_RANK behavior.
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES), 2) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY SUM(SALES) DESC) AS revenue_dense_rank
FROM sales_data_sample
GROUP BY PRODUCTLINE;

-- Query 39
-- Purpose : Split all customers into 4 equal-sized revenue quartiles.
-- Logic   : NTILE(4) divides the ordered result set into 4 buckets.
-- Output  : CUSTOMERNAME, total_revenue, and a quartile number (1-4).
SELECT
    CUSTOMERNAME,
    total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
FROM (
    SELECT CUSTOMERNAME, SUM(SALES) AS total_revenue
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) t;

-- Query 40
-- Purpose : Compare each month's revenue to the previous month's revenue.
-- Logic   : LAG() looks back one row within the ordered window.
-- Output  : order_month, monthly_revenue, previous_month_revenue.
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

-- Query 41
-- Purpose : Compare each month's revenue to the following month's revenue.
-- Logic   : LEAD() looks ahead one row within the ordered window.
-- Output  : order_month, monthly_revenue, next_month_revenue.
SELECT
    order_month,
    monthly_revenue,
    LEAD(monthly_revenue) OVER (ORDER BY order_month) AS next_month_revenue
FROM (
    SELECT DATE_FORMAT(ORDERDATE, '%Y-%m') AS order_month, SUM(SALES) AS monthly_revenue
    FROM sales_data_sample
    GROUP BY order_month
) monthly;

-- ============================================================================
-- SECTION G: TEMPORARY TABLES & VIEWS (Queries 42-45)
-- ============================================================================

-- Query 42
-- Purpose : Build a reusable temporary table of yearly revenue for use in
--           subsequent queries within the same session.
-- Logic   : TEMPORARY TABLE exists only for the current connection/session.
-- Output  : A temp table `temp_yearly_revenue` you can SELECT from below.
DROP TEMPORARY TABLE IF EXISTS temp_yearly_revenue;
CREATE TEMPORARY TABLE temp_yearly_revenue AS
SELECT YEAR_ID, ROUND(SUM(SALES), 2) AS total_revenue
FROM sales_data_sample
GROUP BY YEAR_ID;

SELECT * FROM temp_yearly_revenue ORDER BY YEAR_ID;

-- Query 43
-- Purpose : Use the temporary table to calculate each year's percentage
--           share of overall revenue.
-- Logic   : Cross join the temp table against its own SUM total.
-- Output  : YEAR_ID, total_revenue, pct_of_total_revenue.
SELECT
    YEAR_ID,
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS pct_of_total_revenue
FROM temp_yearly_revenue
ORDER BY YEAR_ID;

-- Query 44
-- Purpose : Create a persistent VIEW summarizing revenue by product line
--           and deal size, for easy reuse across reporting tools.
-- Logic   : CREATE VIEW stores the query definition, not the data itself.
-- Output  : A queryable view `vw_productline_dealsize_summary`.
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

-- Query 45
-- Purpose : Demonstrate querying a view with an additional filter, exactly
--           like querying any normal table.
-- Logic   : Views can be filtered/sorted just like base tables.
-- Output  : Only 'Large' deal size rows from the view above.
SELECT * FROM vw_productline_dealsize_summary
WHERE DEALSIZE = 'Large'
ORDER BY total_revenue DESC;

-- ============================================================================
-- End of 04_exploratory_data_analysis.sql  (45 queries total)
-- ============================================================================

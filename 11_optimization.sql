-- ============================================================================
-- File        : 11_optimization.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Before/after query optimization examples with EXPLAIN
--                output and written justification for each improvement.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- OPTIMIZATION EXAMPLE 1: Filtering on COUNTRY
-- ----------------------------------------------------------------------------

-- BEFORE (no index / function wraps the column, defeats index usage)
EXPLAIN
SELECT *
FROM sales_data_sample
WHERE UPPER(COUNTRY) = 'USA';
-- Problem: Wrapping the column in UPPER() prevents MySQL from using
-- idx_country, forcing a full table scan (type = ALL in EXPLAIN output).

-- AFTER (index-friendly - data was already standardized to uppercase in
-- 03_data_cleaning.sql, so the function call is unnecessary)
EXPLAIN
SELECT *
FROM sales_data_sample
WHERE COUNTRY = 'USA';
-- Result: EXPLAIN shows type = ref and key = idx_country - MySQL uses the
-- index directly instead of scanning every row.

-- ----------------------------------------------------------------------------
-- OPTIMIZATION EXAMPLE 2: Date range filtering
-- ----------------------------------------------------------------------------

-- BEFORE (function applied to the column blocks index usage)
EXPLAIN
SELECT *
FROM sales_data_sample
WHERE YEAR(ORDERDATE) = 2004;
-- Problem: YEAR(ORDERDATE) must be computed for every row before it can be
-- compared, so idx_orderdate cannot be used - full table scan results.

-- AFTER (rewritten as a sargable range condition)
EXPLAIN
SELECT *
FROM sales_data_sample
WHERE ORDERDATE >= '2004-01-01' AND ORDERDATE < '2005-01-01';
-- Result: MySQL can use idx_orderdate directly with a range scan
-- (type = range, key = idx_orderdate), which is dramatically faster on
-- large tables.

-- ----------------------------------------------------------------------------
-- OPTIMIZATION EXAMPLE 3: Correlated subquery vs. JOIN
-- ----------------------------------------------------------------------------

-- BEFORE (correlated subquery re-executes for every outer row)
EXPLAIN
SELECT CUSTOMERNAME
FROM sales_data_sample s1
WHERE SALES = (
    SELECT MAX(SALES)
    FROM sales_data_sample s2
    WHERE s2.CUSTOMERNAME = s1.CUSTOMERNAME
);
-- Problem: The subquery runs once per row of the outer query, which does
-- not scale well as the table grows.

-- AFTER (rewritten using a derived table + JOIN, computed once)
EXPLAIN
SELECT s.CUSTOMERNAME, s.SALES
FROM sales_data_sample s
INNER JOIN (
    SELECT CUSTOMERNAME, MAX(SALES) AS max_sale
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) top_sale
    ON s.CUSTOMERNAME = top_sale.CUSTOMERNAME
   AND s.SALES = top_sale.max_sale;
-- Result: The aggregation runs exactly once, then is joined back - far more
-- efficient than a correlated subquery evaluated per row.

-- ----------------------------------------------------------------------------
-- OPTIMIZATION EXAMPLE 4: SELECT * vs. selecting only needed columns
-- ----------------------------------------------------------------------------

-- BEFORE
EXPLAIN
SELECT *
FROM sales_data_sample
WHERE PRODUCTLINE = 'Classic Cars';
-- Problem: Retrieves every column (25+ fields), including large text
-- fields like ADDRESSLINE1/2 that the report doesn't actually need,
-- increasing I/O and network transfer cost.

-- AFTER
EXPLAIN
SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
WHERE PRODUCTLINE = 'Classic Cars';
-- Result: Smaller result set, less I/O, and (with the right composite
-- index) can sometimes be satisfied entirely from the index itself
-- (a "covering index"), avoiding a lookup into the full row.

-- ----------------------------------------------------------------------------
-- OPTIMIZATION EXAMPLE 5: Composite index for a two-column filter
-- ----------------------------------------------------------------------------

-- BEFORE (only single-column indexes available)
EXPLAIN
SELECT ORDERNUMBER, SALES
FROM sales_data_sample
WHERE COUNTRY = 'USA' AND PRODUCTLINE = 'Classic Cars';
-- Problem: MySQL can use at most one single-column index efficiently here,
-- then must filter the remaining condition row-by-row.

-- AFTER (composite index created in 08_indexes.sql)
-- idx_country_productline ON sales_data_sample (COUNTRY, PRODUCTLINE)
EXPLAIN
SELECT ORDERNUMBER, SALES
FROM sales_data_sample
WHERE COUNTRY = 'USA' AND PRODUCTLINE = 'Classic Cars';
-- Result: With idx_country_productline in place, MySQL can satisfy both
-- filter conditions directly from a single index lookup (key =
-- idx_country_productline), significantly narrowing the scanned rows
-- before touching the base table.

-- ----------------------------------------------------------------------------
-- SUMMARY OF OPTIMIZATION PRINCIPLES APPLIED
-- ----------------------------------------------------------------------------
-- 1. Avoid wrapping indexed columns in functions inside WHERE clauses
--    (keep conditions "sargable").
-- 2. Prefer range conditions (>=, <) over YEAR()/MONTH() extraction when
--    filtering dates.
-- 3. Replace correlated subqueries with JOINs to derived tables wherever
--    the subquery result doesn't actually depend on per-row context.
-- 4. Select only the columns actually needed by the report/application.
-- 5. Add composite indexes that match the exact column combination used
--    together in WHERE/JOIN/GROUP BY clauses, in the correct column order.

-- ============================================================================
-- End of 11_optimization.sql
-- ============================================================================

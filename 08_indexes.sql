-- ============================================================================
-- File        : 08_indexes.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Index strategy - what was indexed, why, and how to verify
--                index usage with EXPLAIN.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- 1. VIEW EXISTING INDEXES
-- ----------------------------------------------------------------------------
SHOW INDEX FROM sales_data_sample;

-- ----------------------------------------------------------------------------
-- 2. INDEX STRATEGY / JUSTIFICATION
-- ----------------------------------------------------------------------------
-- idx_customername  -> Speeds up GROUP BY / WHERE / JOIN on CUSTOMERNAME,
--                       used constantly across business questions (top
--                       customers, customer segmentation, churn analysis).
--
-- idx_country        -> Speeds up filtering and grouping by COUNTRY, used in
--                       nearly every regional revenue breakdown query.
--
-- idx_productline    -> Speeds up product line aggregations (Q8, Q9, Q20,
--                       vw_productline_performance).
--
-- idx_orderdate      -> Speeds up date-range filters and DATE_FORMAT-based
--                       monthly/quarterly/yearly grouping queries.
--
-- idx_dealsize        -> Speeds up deal-size segmentation (Q10) and the
--                       vw_productline_dealsize_summary view.
--
-- idx_status          -> Speeds up STATUS-based filtering (Q17) used for
--                       operational/fulfillment monitoring.
--
-- (These indexes were already created in 01_create_database.sql. This file
--  documents the reasoning and adds a couple of composite indexes that
--  target the most expensive multi-column queries.)

-- ----------------------------------------------------------------------------
-- 3. ADDITIONAL COMPOSITE INDEXES FOR MULTI-COLUMN QUERIES
-- ----------------------------------------------------------------------------
-- Purpose: Business question 24 (country-wise sales by product line) and the
--          vw_country_territory_summary view both group on COUNTRY together
--          with a second column. A composite index avoids two separate
--          single-column index lookups.

CREATE INDEX idx_country_productline ON sales_data_sample (COUNTRY, PRODUCTLINE);
CREATE INDEX idx_customer_orderdate  ON sales_data_sample (CUSTOMERNAME, ORDERDATE);

-- ----------------------------------------------------------------------------
-- 4. VERIFY INDEX USAGE WITH EXPLAIN
-- ----------------------------------------------------------------------------
-- Purpose: Confirm MySQL's query planner is actually choosing to use the
--          indexes we created, rather than falling back to a full table scan.

EXPLAIN
SELECT COUNTRY, SUM(SALES)
FROM sales_data_sample
WHERE COUNTRY = 'USA'
GROUP BY COUNTRY;

EXPLAIN
SELECT *
FROM sales_data_sample
WHERE ORDERDATE BETWEEN '2004-01-01' AND '2004-12-31';

EXPLAIN
SELECT CUSTOMERNAME, ORDERDATE
FROM sales_data_sample
WHERE CUSTOMERNAME = 'Land of Toys Inc.'
ORDER BY ORDERDATE;

-- ----------------------------------------------------------------------------
-- 5. WHEN NOT TO INDEX
-- ----------------------------------------------------------------------------
-- Columns like ADDRESSLINE1, ADDRESSLINE2, PHONE, and CONTACTFIRSTNAME are
-- rarely used in WHERE/GROUP BY/JOIN clauses in this project, so they are
-- intentionally NOT indexed. Over-indexing slows down INSERT/UPDATE/DELETE
-- operations and wastes storage without a corresponding read-speed benefit.

-- ============================================================================
-- End of 08_indexes.sql
-- ============================================================================

-- ============================================================================
-- File        : 03_data_cleaning.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Data quality checks and cleaning routines for sales_data_sample.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- 1. CHECK FOR EXACT DUPLICATE ROWS
-- ----------------------------------------------------------------------------
-- Purpose: Identify rows that are fully identical across all business
--          columns (ignoring the surrogate row_id).
-- Logic  : Group by every business column and flag groups with COUNT > 1.
-- Expected Output: Ideally 0 rows - this dataset is generally clean, but we
--                  check anyway as a best practice.
SELECT
    ORDERNUMBER, ORDERLINENUMBER, CUSTOMERNAME, PRODUCTCODE, SALES,
    COUNT(*) AS duplicate_count
FROM sales_data_sample
GROUP BY ORDERNUMBER, ORDERLINENUMBER, CUSTOMERNAME, PRODUCTCODE, SALES
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 2. CHECK FOR DUPLICATE (ORDERNUMBER, ORDERLINENUMBER) COMBINATIONS
-- ----------------------------------------------------------------------------
-- Purpose: Each order line should be unique. This confirms the composite
--          UNIQUE constraint created in 01_create_database.sql holds true.
-- Expected Output: 0 rows if data is clean.
SELECT ORDERNUMBER, ORDERLINENUMBER, COUNT(*) AS occurrences
FROM sales_data_sample
GROUP BY ORDERNUMBER, ORDERLINENUMBER
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 3. REMOVE EXACT DUPLICATE ROWS (IF ANY ARE FOUND)
-- ----------------------------------------------------------------------------
-- Purpose: Safely remove duplicate rows while keeping the lowest row_id.
-- Logic  : Self-join the table to itself on the business key and delete
--          the row with the higher row_id when a match exists.
DELETE t1 FROM sales_data_sample t1
INNER JOIN sales_data_sample t2
    ON t1.ORDERNUMBER = t2.ORDERNUMBER
   AND t1.ORDERLINENUMBER = t2.ORDERLINENUMBER
   AND t1.row_id > t2.row_id;

-- ----------------------------------------------------------------------------
-- 4. CHECK NULL VALUES ACROSS ALL COLUMNS
-- ----------------------------------------------------------------------------
-- Purpose: Get a full picture of missing data, column by column.
-- Expected Output: ADDRESSLINE2, STATE, POSTALCODE, TERRITORY typically show
--                  the highest NULL counts (this is normal - not every
--                  customer record has a secondary address line, a state,
--                  or falls inside a defined sales territory).
SELECT
    SUM(CASE WHEN ORDERNUMBER      IS NULL THEN 1 ELSE 0 END) AS null_ordernumber,
    SUM(CASE WHEN CUSTOMERNAME     IS NULL THEN 1 ELSE 0 END) AS null_customername,
    SUM(CASE WHEN SALES            IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN ORDERDATE        IS NULL THEN 1 ELSE 0 END) AS null_orderdate,
    SUM(CASE WHEN STATUS           IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN PRODUCTLINE      IS NULL THEN 1 ELSE 0 END) AS null_productline,
    SUM(CASE WHEN STATE            IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN POSTALCODE       IS NULL THEN 1 ELSE 0 END) AS null_postalcode,
    SUM(CASE WHEN TERRITORY        IS NULL THEN 1 ELSE 0 END) AS null_territory,
    SUM(CASE WHEN ADDRESSLINE2     IS NULL THEN 1 ELSE 0 END) AS null_addressline2,
    SUM(CASE WHEN DEALSIZE         IS NULL THEN 1 ELSE 0 END) AS null_dealsize
FROM sales_data_sample;

-- ----------------------------------------------------------------------------
-- 5. HANDLE NULL VALUES
-- ----------------------------------------------------------------------------
-- Purpose: Replace NULLs with sensible defaults so downstream aggregations
--          and joins don't silently drop rows.
-- Logic  : Use UPDATE + COALESCE-style replacement for categorical text
--          columns. Numeric/date columns are left as NULL (better to be
--          explicit about "unknown" than fabricate a number).

UPDATE sales_data_sample
SET TERRITORY = 'UNSPECIFIED'
WHERE TERRITORY IS NULL;

UPDATE sales_data_sample
SET STATE = 'N/A'
WHERE STATE IS NULL;

UPDATE sales_data_sample
SET POSTALCODE = 'N/A'
WHERE POSTALCODE IS NULL;

UPDATE sales_data_sample
SET ADDRESSLINE2 = 'N/A'
WHERE ADDRESSLINE2 IS NULL;

-- Example of COALESCE used at query time instead of permanently altering data
-- (useful when you want to preserve the raw NULL but display a default):
SELECT
    ORDERNUMBER,
    COALESCE(STATE, 'N/A') AS state_display
FROM sales_data_sample
LIMIT 20;

-- ----------------------------------------------------------------------------
-- 6. TRIM WHITESPACE FROM TEXT COLUMNS
-- ----------------------------------------------------------------------------
-- Purpose: Remove leading/trailing spaces that can break GROUP BY and JOIN
--          matching (e.g. "France " vs "France").
UPDATE sales_data_sample
SET CUSTOMERNAME    = TRIM(CUSTOMERNAME),
    CITY             = TRIM(CITY),
    COUNTRY          = TRIM(COUNTRY),
    PRODUCTLINE      = TRIM(PRODUCTLINE),
    CONTACTFIRSTNAME = TRIM(CONTACTFIRSTNAME),
    CONTACTLASTNAME  = TRIM(CONTACTLASTNAME),
    DEALSIZE         = TRIM(DEALSIZE),
    STATUS           = TRIM(STATUS);

-- ----------------------------------------------------------------------------
-- 7. STANDARDIZE TEXT CASE (UPPER / LOWER)
-- ----------------------------------------------------------------------------
-- Purpose: Standardize free-text fields so that "usa", "USA", "Usa" are
--          treated identically when grouping/filtering.
-- Logic  : COUNTRY and TERRITORY are standardized to uppercase for
--          consistent reporting; CUSTOMERNAME is kept in its original case
--          for display purposes but a helper query shows both approaches.

UPDATE sales_data_sample
SET COUNTRY = UPPER(TRIM(COUNTRY));

UPDATE sales_data_sample
SET TERRITORY = UPPER(TRIM(TERRITORY));

-- Example: Query-time case standardization without altering stored data
SELECT DISTINCT
    UPPER(PRODUCTLINE) AS productline_upper,
    LOWER(PRODUCTLINE) AS productline_lower
FROM sales_data_sample;

-- ----------------------------------------------------------------------------
-- 8. FIND AND FIX INCONSISTENT VALUES IN CATEGORICAL COLUMNS
-- ----------------------------------------------------------------------------
-- Purpose: Inspect distinct values in key categorical fields to spot typos,
--          casing differences, or unexpected categories.
SELECT DISTINCT STATUS     FROM sales_data_sample ORDER BY STATUS;
SELECT DISTINCT DEALSIZE   FROM sales_data_sample ORDER BY DEALSIZE;
SELECT DISTINCT TERRITORY  FROM sales_data_sample ORDER BY TERRITORY;
SELECT DISTINCT COUNTRY    FROM sales_data_sample ORDER BY COUNTRY;

-- Example fix: standardize a known inconsistent value
-- (Illustrative pattern - adjust based on what STEP 8's inspection reveals)
UPDATE sales_data_sample
SET COUNTRY = 'UK'
WHERE COUNTRY IN ('UNITED KINGDOM', 'U.K.', 'ENGLAND');

-- ----------------------------------------------------------------------------
-- 9. VALIDATE / CONVERT DATE VALUES
-- ----------------------------------------------------------------------------
-- Purpose: Confirm all ORDERDATE values are valid, real calendar dates and
--          fall within a sensible business range.
-- Logic  : A NULL result after STR_TO_DATE conversion in the import step
--          indicates an unparseable date string in the source CSV.
SELECT *
FROM sales_data_sample
WHERE ORDERDATE IS NULL
   OR ORDERDATE > CURDATE()
   OR YEAR(ORDERDATE) < 2000;

-- ----------------------------------------------------------------------------
-- 10. CHECK FOR INVALID / IMPOSSIBLE NUMERIC RECORDS
-- ----------------------------------------------------------------------------
-- Purpose: Flag rows with business-rule violations, e.g. negative sales,
--          zero quantity, or price that doesn't reasonably reconcile with
--          quantity * price ≈ sales.
SELECT *
FROM sales_data_sample
WHERE SALES <= 0
   OR QUANTITYORDERED <= 0
   OR PRICEEACH <= 0;

-- Reconciliation check: SALES should roughly equal QUANTITYORDERED * PRICEEACH
SELECT
    ORDERNUMBER,
    ORDERLINENUMBER,
    QUANTITYORDERED,
    PRICEEACH,
    SALES,
    ROUND(QUANTITYORDERED * PRICEEACH, 2) AS calculated_sales,
    ROUND(SALES - (QUANTITYORDERED * PRICEEACH), 2) AS variance
FROM sales_data_sample
HAVING ABS(variance) > 1
ORDER BY ABS(variance) DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- 11. CHECK FOR ORPHAN / INCOMPLETE CUSTOMER RECORDS
-- ----------------------------------------------------------------------------
-- Purpose: Find rows missing critical customer identification data.
SELECT *
FROM sales_data_sample
WHERE CUSTOMERNAME IS NULL
   OR CUSTOMERNAME = '';

-- ----------------------------------------------------------------------------
-- 12. FINAL DATA QUALITY SUMMARY
-- ----------------------------------------------------------------------------
-- Purpose: One consolidated query giving a health-check snapshot of the
--          cleaned table, useful to paste into documentation/README.
SELECT
    COUNT(*)                              AS total_rows,
    COUNT(DISTINCT ORDERNUMBER)           AS distinct_orders,
    COUNT(DISTINCT CUSTOMERNAME)          AS distinct_customers,
    COUNT(DISTINCT COUNTRY)               AS distinct_countries,
    COUNT(DISTINCT PRODUCTLINE)           AS distinct_productlines,
    MIN(ORDERDATE)                        AS earliest_order,
    MAX(ORDERDATE)                        AS latest_order,
    ROUND(SUM(SALES), 2)                  AS total_sales
FROM sales_data_sample;

-- ============================================================================
-- End of 03_data_cleaning.sql
-- ============================================================================


SELECT COUNT(*) FROM sales_data_sample;
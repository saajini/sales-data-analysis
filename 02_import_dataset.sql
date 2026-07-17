-- ============================================================================
-- File        : 02_import_dataset.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Import the raw CSV (sales_data_sample.csv) into the
--                sales_data table created in 01_create_database.sql.
-- ============================================================================
--
-- The original Kaggle CSV file is encoded in Latin-1 (ISO-8859-1), not UTF-8.
-- Two import methods are documented below. Use whichever is convenient.
--
-- ----------------------------------------------------------------------------
-- METHOD 1: MySQL Workbench "Table Data Import Wizard" (Recommended for
--           beginners / GUI users - no SQL required for the import itself)
-- ----------------------------------------------------------------------------
--
--  1. Download "sales_data_sample.csv" from:
--     https://www.kaggle.com/datasets/kyanyoga/sample-sales-data
--     and place it inside the /dataset folder of this project.
--
--  2. Open MySQL Workbench and connect to your local MySQL server.
--
--  3. In the left-hand "Navigator" panel, expand Schemas -> sales_analysis.
--
--  4. Right-click on "Tables" -> "Table Data Import Wizard".
--
--  5. Browse to dataset/sales_data_sample.csv and click Next.
--
--  6. Choose "Use existing table" and select `sales_data`.
--     (If you prefer the wizard to auto-create the table instead, you may
--      create a new table here, but the manual DDL in 01_create_database.sql
--      gives you far more control over data types, keys, and indexes.)
--
--  7. Map each CSV column to the matching table column
--     (the wizard usually auto-matches columns by name).
--     NOTE: Do NOT map the CSV columns to `row_id` - leave it unmapped since
--     it is an AUTO_INCREMENT surrogate key.
--
--  8. Choose encoding "latin1" if you see garbled characters (common issue
--     with this dataset because of special characters in address fields).
--
--  9. Click Next -> Next -> Finish to run the import.
--
-- 10. Verify the row count once the import completes:
--       SELECT COUNT(*) FROM sales_data;
--     Expected result: 2,823 rows.
--
-- ----------------------------------------------------------------------------
-- METHOD 2: LOAD DATA INFILE (Recommended for automation / repeatable runs)
-- ----------------------------------------------------------------------------
--
-- Prerequisite: `secure_file_priv` must allow reading from the folder that
-- holds the CSV, OR you can use LOAD DATA LOCAL INFILE from the client side.
-- Check the allowed directory with:
--       SHOW VARIABLES LIKE 'secure_file_priv';

USE sales_analysis;

-- Empty the table first if you are re-running the import.
TRUNCATE TABLE sales_data;

-- Option A: Server-side LOAD DATA INFILE
-- (CSV file must be placed inside the server's secure_file_priv directory)
LOAD DATA INFILE '/var/lib/mysql-files/sales_data_sample.csv'
INTO TABLE sales_data
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, @ORDERDATE,
 STATUS, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, MSRP, PRODUCTCODE,
 CUSTOMERNAME, PHONE, ADDRESSLINE1, ADDRESSLINE2, CITY, STATE, POSTALCODE,
 COUNTRY, TERRITORY, CONTACTLASTNAME, CONTACTFIRSTNAME, DEALSIZE)
SET ORDERDATE = STR_TO_DATE(@ORDERDATE, '%m/%d/%Y %H:%i');

-- Option B: Client-side LOAD DATA LOCAL INFILE
-- (Run from the machine where the CSV file is stored; requires the client
--  and server to both have local_infile enabled)
--
-- LOAD DATA LOCAL INFILE 'dataset/sales_data_sample.csv'
-- INTO TABLE sales_data
-- CHARACTER SET latin1
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
-- IGNORE 1 ROWS
-- (ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, @ORDERDATE,
--  STATUS, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, MSRP, PRODUCTCODE,
--  CUSTOMERNAME, PHONE, ADDRESSLINE1, ADDRESSLINE2, CITY, STATE, POSTALCODE,
--  COUNTRY, TERRITORY, CONTACTLASTNAME, CONTACTFIRSTNAME, DEALSIZE)
-- SET ORDERDATE = STR_TO_DATE(@ORDERDATE, '%m/%d/%Y %H:%i');

-- ----------------------------------------------------------------------------
-- STEP: Verify the import
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows_imported FROM sales_data;
SELECT * FROM sales_data LIMIT 10;

-- ============================================================================
-- End of 02_import_dataset.sql
-- ============================================================================

-- ============================================================================
-- File        : 01_create_database.sql
-- Project      : Sales Analysis SQL Project
-- Dataset      : Sample Sales Data (Kaggle - kyanyoga/sample-sales-data)
-- Purpose      : Create the database and the core sales_data table with
--                appropriate data types, primary key, and constraints.
-- Environment  : MySQL 8.0+ (MySQL Workbench)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STEP 1: Create the database
-- ----------------------------------------------------------------------------
-- We drop the database first only if you want a clean rebuild.
-- Comment out the DROP line if you don't want to lose existing data.

DROP DATABASE IF EXISTS sales_analysis;

CREATE DATABASE sales_analysis
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- STEP 2: Create the main sales_data table
-- ----------------------------------------------------------------------------
-- The table structure mirrors the actual columns found in the Kaggle
-- "Sample Sales Data" CSV file (sales_data_sample.csv).
-- The dataset contains one row per order line item (25 columns, ~2,823 rows).
--
-- A surrogate primary key (row_id) is added because the raw dataset does not
-- provide a single-column unique identifier on its own
-- (ORDERNUMBER + ORDERLINENUMBER together form a natural composite key).

CREATE TABLE sales_data (
    row_id              INT AUTO_INCREMENT PRIMARY KEY,   -- surrogate key
    ORDERNUMBER         INT             NOT NULL,
    QUANTITYORDERED     INT             NOT NULL,
    PRICEEACH           DECIMAL(10,2)   NOT NULL,
    ORDERLINENUMBER     INT             NOT NULL,
    SALES               DECIMAL(12,2)   NOT NULL,
    ORDERDATE           DATE            NULL,
    STATUS              VARCHAR(20)     NULL,
    QTR_ID               INT            NULL,
    MONTH_ID             INT            NULL,
    YEAR_ID               INT           NULL,
    PRODUCTLINE         VARCHAR(50)     NULL,
    MSRP                 INT            NULL,
    PRODUCTCODE         VARCHAR(20)     NULL,
    CUSTOMERNAME        VARCHAR(100)    NULL,
    PHONE               VARCHAR(30)     NULL,
    ADDRESSLINE1        VARCHAR(100)    NULL,
    ADDRESSLINE2        VARCHAR(100)    NULL,
    CITY                VARCHAR(50)     NULL,
    STATE                VARCHAR(50)    NULL,
    POSTALCODE           VARCHAR(20)    NULL,
    COUNTRY              VARCHAR(50)    NULL,
    TERRITORY           VARCHAR(20)     NULL,
    CONTACTLASTNAME     VARCHAR(50)     NULL,
    CONTACTFIRSTNAME    VARCHAR(50)     NULL,
    DEALSIZE            VARCHAR(10)     NULL,

    -- ------------------------------------------------------------------
    -- Composite unique constraint: an order line item should be unique
    -- for a given order number + line number combination.
    -- ------------------------------------------------------------------
    CONSTRAINT uq_order_line UNIQUE (ORDERNUMBER, ORDERLINENUMBER)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- STEP 3: Create supporting indexes for common query patterns
-- ----------------------------------------------------------------------------
-- These indexes speed up filtering/joining/grouping on the columns most
-- frequently used throughout the business questions and EDA queries.
-- (Full list and justification is repeated/expanded in 08_indexes.sql)

CREATE INDEX idx_customername   ON sales_data (CUSTOMERNAME);
CREATE INDEX idx_country        ON sales_data (COUNTRY);
CREATE INDEX idx_productline    ON sales_data (PRODUCTLINE);
CREATE INDEX idx_orderdate      ON sales_data (ORDERDATE);
CREATE INDEX idx_dealsize       ON sales_data (DEALSIZE);
CREATE INDEX idx_status         ON sales_data (STATUS);

-- ----------------------------------------------------------------------------
-- STEP 4: Verify table creation
-- ----------------------------------------------------------------------------
DESCRIBE sales_data;
SHOW INDEX FROM sales_data;

-- ============================================================================
-- End of 01_create_database.sql
-- ============================================================================

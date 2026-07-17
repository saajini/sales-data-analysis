-- ============================================================================
-- File        : 10_transactions.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Demonstrate transaction control (COMMIT/ROLLBACK) and data
--                integrity handling using InnoDB.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- 1. CONFIRM STORAGE ENGINE SUPPORTS TRANSACTIONS
-- ----------------------------------------------------------------------------
-- Purpose: Transactions require InnoDB (not MyISAM). sales_data_sample was created
--          with ENGINE = InnoDB in 01_create_database.sql.
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sales_analysis' AND TABLE_NAME = 'sales_data_sample';

-- ----------------------------------------------------------------------------
-- 2. BASIC TRANSACTION: Archive an order, then remove it, atomically
-- ----------------------------------------------------------------------------
-- Purpose: Move a cancelled order into an archive table and delete it from
--          the live table as a single atomic unit - either both actions
--          succeed, or neither does.

DROP TABLE IF EXISTS sales_data_sample_archive;
CREATE TABLE sales_data_sample_archive LIKE sales_data_sample;

START TRANSACTION;

    INSERT INTO sales_data_sample_archive
    SELECT * FROM sales_data_sample
    WHERE STATUS = 'Cancelled';

    DELETE FROM sales_data_sample
    WHERE STATUS = 'Cancelled';

-- If everything above succeeded without error, make it permanent:
COMMIT;

-- If something went wrong instead, you would run ROLLBACK; here to undo
-- both statements above and leave the database exactly as it was.
-- ROLLBACK;

-- Verify:
SELECT COUNT(*) AS archived_rows FROM sales_data_sample_archive;
SELECT COUNT(*) AS remaining_cancelled_rows FROM sales_data_sample WHERE STATUS = 'Cancelled';

-- ----------------------------------------------------------------------------
-- 3. TRANSACTION WITH ROLLBACK ON ERROR (SAVEPOINT DEMONSTRATION)
-- ----------------------------------------------------------------------------
-- Purpose: Demonstrate SAVEPOINT usage - useful when a multi-step process
--          needs to roll back only part of its work rather than everything.

START TRANSACTION;

    UPDATE sales_data_sample
    SET DEALSIZE = 'Large'
    WHERE SALES > 7000;

    SAVEPOINT after_dealsize_update;

    -- Suppose this second update turns out to be incorrect...
    UPDATE sales_data_sample
    SET STATUS = 'Shipped'
    WHERE STATUS IS NULL;

    -- ...we can roll back JUST this second update while keeping the first:
    ROLLBACK TO SAVEPOINT after_dealsize_update;

COMMIT;

-- ----------------------------------------------------------------------------
-- 4. TRANSACTION ISOLATION DEMONSTRATION (READ COMMITTED behavior notes)
-- ----------------------------------------------------------------------------
-- Purpose: Document how MySQL's default isolation level (REPEATABLE READ)
--          affects concurrent readers/writers on this table.
SELECT @@transaction_isolation;

-- Example of explicitly setting isolation level for a session that needs to
-- read the very latest committed data (useful for real-time dashboards):
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ----------------------------------------------------------------------------
-- 5. RESTORE ARCHIVED DATA (undo the archive step for portfolio re-runs)
-- ----------------------------------------------------------------------------
-- Purpose: Allows this script to be re-run repeatedly during development
--          without permanently losing the "Cancelled" rows.
START TRANSACTION;

    INSERT INTO sales_data_sample
    SELECT * FROM sales_data_sample_archive;

    TRUNCATE TABLE sales_data_sample_archive;

COMMIT;

SELECT COUNT(*) AS total_rows_after_restore FROM sales_data_sample;

-- ============================================================================
-- End of 10_transactions.sql
-- ============================================================================

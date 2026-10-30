SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sales_analysis' AND TABLE_NAME = 'sales_data_sample';

DROP TABLE IF EXISTS sales_data_sample_archive;
CREATE TABLE sales_data_sample_archive LIKE sales_data_sample;

START TRANSACTION;

    INSERT INTO sales_data_sample_archive
    SELECT * FROM sales_data_sample
    WHERE STATUS = 'Cancelled';

    DELETE FROM sales_data_sample
    WHERE STATUS = 'Cancelled';

COMMIT;

SELECT COUNT(*) AS archived_rows FROM sales_data_sample_archive;
SELECT COUNT(*) AS remaining_cancelled_rows FROM sales_data_sample WHERE STATUS = 'Cancelled';

START TRANSACTION;

    UPDATE sales_data_sample
    SET DEALSIZE = 'Large'
    WHERE SALES > 7000;

    SAVEPOINT after_dealsize_update;

    UPDATE sales_data_sample
    SET STATUS = 'Shipped'
    WHERE STATUS IS NULL;

    ROLLBACK TO SAVEPOINT after_dealsize_update;

COMMIT;

SELECT @@transaction_isolation;

START TRANSACTION;

    INSERT INTO sales_data_sample
    SELECT * FROM sales_data_sample_archive;

    TRUNCATE TABLE sales_data_sample_archive;

COMMIT;

SELECT COUNT(*) AS total_rows_after_restore FROM sales_data_sample;

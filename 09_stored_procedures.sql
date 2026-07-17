-- ============================================================================
-- File        : 09_stored_procedures.sql
-- Project      : Sales Analysis SQL Project
-- Purpose      : Stored procedures and stored functions that encapsulate
--                reusable business logic.
-- ============================================================================

USE sales_analysis;

-- ----------------------------------------------------------------------------
-- STORED PROCEDURE 1: sp_get_revenue_by_country
-- ----------------------------------------------------------------------------
-- Purpose: Return total revenue and order count for a single country,
--          passed in as a parameter. Demonstrates a simple input-parameter
--          procedure.
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_revenue_by_country $$

CREATE PROCEDURE sp_get_revenue_by_country(IN p_country VARCHAR(50))
BEGIN
    SELECT
        COUNTRY,
        COUNT(DISTINCT ORDERNUMBER) AS num_orders,
        ROUND(SUM(SALES), 2) AS total_revenue,
        ROUND(AVG(SALES), 2) AS avg_sale_value
    FROM sales_data
    WHERE COUNTRY = UPPER(p_country)
    GROUP BY COUNTRY;
END $$

DELIMITER ;

-- Usage example:
-- CALL sp_get_revenue_by_country('USA');

-- ----------------------------------------------------------------------------
-- STORED PROCEDURE 2: sp_top_n_customers
-- ----------------------------------------------------------------------------
-- Purpose: Return the top N customers by total revenue, where N is
--          configurable at call time. Demonstrates a dynamic LIMIT pattern
--          using a prepared statement (MySQL does not allow variables
--          directly inside LIMIT).
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_top_n_customers $$

CREATE PROCEDURE sp_top_n_customers(IN p_top_n INT)
BEGIN
    SET @sql = CONCAT(
        'SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS total_revenue
         FROM sales_data
         GROUP BY CUSTOMERNAME
         ORDER BY total_revenue DESC
         LIMIT ', p_top_n
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- Usage example:
-- CALL sp_top_n_customers(5);

-- ----------------------------------------------------------------------------
-- STORED PROCEDURE 3: sp_monthly_revenue_report
-- ----------------------------------------------------------------------------
-- Purpose: Return a full monthly revenue report between two dates, with an
--          OUT parameter that returns the grand total for the period.
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_monthly_revenue_report $$

CREATE PROCEDURE sp_monthly_revenue_report(
    IN  p_start_date DATE,
    IN  p_end_date   DATE,
    OUT p_grand_total DECIMAL(14,2)
)
BEGIN
    SELECT
        DATE_FORMAT(ORDERDATE, '%Y-%m') AS sales_month,
        ROUND(SUM(SALES), 2) AS monthly_revenue
    FROM sales_data
    WHERE ORDERDATE BETWEEN p_start_date AND p_end_date
    GROUP BY sales_month
    ORDER BY sales_month;

    SELECT ROUND(SUM(SALES), 2) INTO p_grand_total
    FROM sales_data
    WHERE ORDERDATE BETWEEN p_start_date AND p_end_date;
END $$

DELIMITER ;

-- Usage example:
-- CALL sp_monthly_revenue_report('2004-01-01', '2004-12-31', @total);
-- SELECT @total AS grand_total_2004;

-- ----------------------------------------------------------------------------
-- STORED FUNCTION 1: fn_customer_segment
-- ----------------------------------------------------------------------------
-- Purpose: Given a total revenue amount, return its customer segment label.
--          Demonstrates a reusable scalar function that can be called
--          inline inside any SELECT statement.
DELIMITER $$

DROP FUNCTION IF EXISTS fn_customer_segment $$

CREATE FUNCTION fn_customer_segment(p_total_revenue DECIMAL(12,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE v_segment VARCHAR(10);

    IF p_total_revenue >= 100000 THEN
        SET v_segment = 'Platinum';
    ELSEIF p_total_revenue >= 50000 THEN
        SET v_segment = 'Gold';
    ELSEIF p_total_revenue >= 20000 THEN
        SET v_segment = 'Silver';
    ELSE
        SET v_segment = 'Bronze';
    END IF;

    RETURN v_segment;
END $$

DELIMITER ;

-- Usage example:
-- SELECT CUSTOMERNAME, SUM(SALES) AS total_revenue,
--        fn_customer_segment(SUM(SALES)) AS segment
-- FROM sales_data
-- GROUP BY CUSTOMERNAME;

-- ----------------------------------------------------------------------------
-- STORED FUNCTION 2: fn_days_since_last_order
-- ----------------------------------------------------------------------------
-- Purpose: Given a customer name, return the number of days since their
--          most recent order relative to the latest order date in the
--          entire dataset (a proxy for "today" since this is historical
--          data).
DELIMITER $$

DROP FUNCTION IF EXISTS fn_days_since_last_order $$

CREATE FUNCTION fn_days_since_last_order(p_customername VARCHAR(100))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_days INT;

    SELECT DATEDIFF(
        (SELECT MAX(ORDERDATE) FROM sales_data),
        (SELECT MAX(ORDERDATE) FROM sales_data WHERE CUSTOMERNAME = p_customername)
    ) INTO v_days;

    RETURN v_days;
END $$

DELIMITER ;

-- Usage example:
-- SELECT fn_days_since_last_order('Land of Toys Inc.') AS days_inactive;

-- ============================================================================
-- End of 09_stored_procedures.sql
-- ============================================================================

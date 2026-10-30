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

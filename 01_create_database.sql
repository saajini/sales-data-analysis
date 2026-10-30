CREATE DATABASE sales_analysis
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sales_analysis;

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

    CONSTRAINT uq_order_line UNIQUE (ORDERNUMBER, ORDERLINENUMBER)
) ENGINE = InnoDB;

CREATE INDEX idx_customername   ON sales_data (CUSTOMERNAME);
CREATE INDEX idx_country        ON sales_data (COUNTRY);
CREATE INDEX idx_productline    ON sales_data (PRODUCTLINE);
CREATE INDEX idx_orderdate      ON sales_data (ORDERDATE);
CREATE INDEX idx_dealsize       ON sales_data (DEALSIZE);
CREATE INDEX idx_status         ON sales_data (STATUS);

DESCRIBE sales_data;
SHOW INDEX FROM sales_data;



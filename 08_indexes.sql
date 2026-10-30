SHOW INDEX FROM sales_data_sample;

CREATE INDEX idx_country_productline ON sales_data_sample (COUNTRY, PRODUCTLINE);
CREATE INDEX idx_customer_orderdate  ON sales_data_sample (CUSTOMERNAME, ORDERDATE);

SELECT COUNTRY, SUM(SALES)
FROM sales_data_sample
WHERE COUNTRY = 'USA'
GROUP BY COUNTRY;

SELECT *
FROM sales_data_sample
WHERE ORDERDATE BETWEEN '2004-01-01' AND '2004-12-31';

SELECT CUSTOMERNAME, ORDERDATE
FROM sales_data_sample
WHERE CUSTOMERNAME = 'Land of Toys Inc.'
ORDER BY ORDERDATE;

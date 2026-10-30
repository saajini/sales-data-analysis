SELECT *
FROM sales_data_sample
WHERE UPPER(COUNTRY) = 'USA';

SELECT *
FROM sales_data_sample
WHERE COUNTRY = 'USA';

SELECT *
FROM sales_data_sample
WHERE YEAR(ORDERDATE) = 2004;

SELECT *
FROM sales_data_sample
WHERE ORDERDATE >= '2004-01-01' AND ORDERDATE < '2005-01-01';

SELECT CUSTOMERNAME
FROM sales_data_sample s1
WHERE SALES = (
    SELECT MAX(SALES)
    FROM sales_data_sample s2
    WHERE s2.CUSTOMERNAME = s1.CUSTOMERNAME
);

SELECT s.CUSTOMERNAME, s.SALES
FROM sales_data_sample s
INNER JOIN (
    SELECT CUSTOMERNAME, MAX(SALES) AS max_sale
    FROM sales_data_sample
    GROUP BY CUSTOMERNAME
) top_sale
    ON s.CUSTOMERNAME = top_sale.CUSTOMERNAME
   AND s.SALES = top_sale.max_sale;

SELECT *
FROM sales_data_sample
WHERE PRODUCTLINE = 'Classic Cars';

SELECT ORDERNUMBER, CUSTOMERNAME, SALES
FROM sales_data_sample
WHERE PRODUCTLINE = 'Classic Cars';

SELECT ORDERNUMBER, SALES
FROM sales_data_sample
WHERE COUNTRY = 'USA' AND PRODUCTLINE = 'Classic Cars';

SELECT ORDERNUMBER, SALES
FROM sales_data_sample
WHERE COUNTRY = 'USA' AND PRODUCTLINE = 'Classic Cars';

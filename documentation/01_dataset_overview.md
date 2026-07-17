# Dataset Overview

## Business Background

This dataset represents historical order-level transactions for a company
that sells scale-model vehicles and collectibles (classic cars, motorcycles,
planes, ships, trains, trucks/buses, and vintage cars) to retailers across
multiple countries. Each row is a single **order line item** — one product,
on one order, for one customer.

This kind of dataset is commonly used to simulate a B2B wholesale distributor
selling to independent retail shops around the world, making it a realistic
sandbox for practicing retail/sales analytics.

## Dataset Source

- **Name:** Sample Sales Data
- **Source:** Kaggle — [kyanyoga/sample-sales-data](https://www.kaggle.com/datasets/kyanyoga/sample-sales-data)
- **File:** `sales_data_sample.csv`
- **Size:** 2,823 rows × 25 columns

## Column Descriptions

| Column | Type | Description |
|---|---|---|
| `ORDERNUMBER` | Integer | Unique identifier for a customer order (multiple line items can share one order number). |
| `QUANTITYORDERED` | Integer | Number of units ordered for this line item. |
| `PRICEEACH` | Decimal | Unit price for the product on this line item. |
| `ORDERLINENUMBER` | Integer | Sequence number of this line item within its order. |
| `SALES` | Decimal | Total revenue for this line item (roughly `QUANTITYORDERED * PRICEEACH`). |
| `ORDERDATE` | Date | Date the order was placed. |
| `STATUS` | Text | Order fulfillment status (e.g. Shipped, Cancelled, On Hold, Disputed, In Process, Resolved). |
| `QTR_ID` | Integer | Calendar quarter (1–4) the order falls in. |
| `MONTH_ID` | Integer | Calendar month (1–12) the order falls in. |
| `YEAR_ID` | Integer | Calendar year the order falls in. |
| `PRODUCTLINE` | Text | Product category (e.g. Classic Cars, Motorcycles, Planes, Ships, Trains, Trucks and Buses, Vintage Cars). |
| `MSRP` | Integer | Manufacturer's Suggested Retail Price for the product. |
| `PRODUCTCODE` | Text | Unique product SKU/code. |
| `CUSTOMERNAME` | Text | Name of the purchasing company/customer. |
| `PHONE` | Text | Customer contact phone number. |
| `ADDRESSLINE1` | Text | Customer street address (line 1). |
| `ADDRESSLINE2` | Text | Customer street address (line 2, often blank). |
| `CITY` | Text | Customer city. |
| `STATE` | Text | Customer state/province (often blank outside the USA). |
| `POSTALCODE` | Text | Customer postal/ZIP code. |
| `COUNTRY` | Text | Customer country. |
| `TERRITORY` | Text | Broader sales territory (e.g. EMEA, APAC, Japan). |
| `CONTACTLASTNAME` | Text | Last name of the customer contact person. |
| `CONTACTFIRSTNAME` | Text | First name of the customer contact person. |
| `DEALSIZE` | Text | Deal size category: Small, Medium, or Large. |

## Business Objective

Analyze historical sales transactions to understand revenue drivers,
customer value, seasonal demand patterns, and product/territory performance,
in order to support data-driven decisions around inventory planning,
account management, and sales strategy.

## Possible Business Use Cases

- Sales performance dashboards (monthly/quarterly/yearly revenue trends)
- Customer segmentation and churn-risk identification
- Product line and SKU-level performance analysis
- Territory and country-level market prioritization
- Deal-size and order-value benchmarking for the sales team
- Seasonal demand forecasting and inventory planning

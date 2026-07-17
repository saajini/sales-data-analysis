# 📊 Sales Analysis SQL Project

A complete, interview-ready SQL portfolio project built in **MySQL
Workbench**, analyzing the Kaggle **Sample Sales Data** dataset. This
project demonstrates SQL fundamentals through advanced analytics,
following a real-world Data Analyst workflow: database design → data
import → data cleaning → exploratory analysis → business questions →
advanced SQL → optimization → final insights.

---

## 🧭 Project Overview

This project analyzes ~2,800 retail order transactions (scale-model
vehicles sold to retailers worldwide) to uncover revenue trends, top
customers, seasonal demand patterns, and product/territory performance —
the kind of analysis a Data Analyst, Business Analyst, or BI Analyst
would be expected to deliver in a real role.

## 📁 Dataset

- **Name:** Sample Sales Data
- **Source:** [Kaggle - kyanyoga/sample-sales-data](https://www.kaggle.com/datasets/kyanyoga/sample-sales-data)
- **Rows:** 2,823
- **Columns:** 25
- Full column-by-column description in [`documentation/01_dataset_overview.md`](documentation/01_dataset_overview.md)

## 🎯 Objectives

- Design a clean, normalized-enough relational schema for the raw CSV data
- Perform thorough data cleaning and data quality validation
- Write 45+ EDA queries covering the full range of core SQL syntax
- Answer 28 realistic business questions with data-backed insights
- Demonstrate advanced SQL: recursive CTEs, window functions, cohort analysis
- Build reusable views, stored procedures, stored functions, and indexes
- Document and demonstrate query optimization techniques
- Summarize findings into actionable business recommendations

## 🗂️ Project Structure

```
Sales-Analysis-SQL-Project/
│
├── README.md
├── LICENSE
├── dataset/                          # Place sales_data_sample.csv here
├── documentation/
│   ├── 01_dataset_overview.md
│   └── 02_how_to_run.md
├── images/                           # Screenshots go here
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_import_dataset.sql
│   ├── 03_data_cleaning.sql
│   ├── 04_exploratory_data_analysis.sql
│   ├── 05_business_questions.sql
│   ├── 06_advanced_sql.sql
│   ├── 07_views.sql
│   ├── 08_indexes.sql
│   ├── 09_stored_procedures.sql
│   ├── 10_transactions.sql
│   ├── 11_optimization.sql
│   └── 12_final_insights.sql
└── results/                          # Exported query results (CSV/screenshots)
```

## 🛠️ Tools Used

- **MySQL Workbench** — schema design, query development, execution
- **MySQL 8.0** (SQL dialect) — all scripts use standard MySQL syntax
- **GitHub** — version control and portfolio hosting

## 🧠 SQL Skills Demonstrated

| Category | Concepts |
|---|---|
| Fundamentals | `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`, `DISTINCT`, `LIMIT` |
| Data types & design | `CREATE DATABASE`, `CREATE TABLE`, primary keys, constraints, indexes |
| Data cleaning | Duplicate detection/removal, NULL handling, `TRIM`, `UPPER`/`LOWER`, date validation |
| Conditional logic | `CASE WHEN`, `COALESCE` |
| Date functions | `YEAR`, `MONTH`, `DATE_FORMAT`, `DATEDIFF`, `DAYNAME` |
| Pattern matching | `LIKE`, `BETWEEN`, `IN` |
| Subqueries | Scalar, correlated, `FROM`-clause subqueries |
| CTEs | Standard CTEs, **recursive CTEs** |
| Joins | `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `CROSS JOIN`, self join |
| Set operations | `UNION`, `UNION ALL` |
| Window functions | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LEAD`, `LAG`, running totals, moving averages |
| Reusable objects | Views, temporary tables, stored procedures, stored functions |
| Transactions | `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT` |
| Performance | `EXPLAIN`, index design, sargable query rewrites |

## 🏗️ Database Schema

Single core table `sales_data` (surrogate primary key `row_id`,
composite unique constraint on `ORDERNUMBER` + `ORDERLINENUMBER`), plus
supporting single-column and composite indexes. Full DDL in
[`sql/01_create_database.sql`](sql/01_create_database.sql).

## ❓ Business Questions Answered

28 business questions spanning monthly/yearly trends, revenue by country
and city, top/bottom customers, product line performance, deal-size
analysis, average order value, customer segmentation, churn-risk
identification, and Pareto (80/20) revenue concentration. See
[`sql/05_business_questions.sql`](sql/05_business_questions.sql) for the
full list with SQL and written insights.

## 💡 Key Insights

1. Revenue is heavily concentrated — the top 20% of customers generate a
   disproportionate share of total revenue (Pareto pattern).
2. The USA is the largest single market; **Classic Cars** is consistently
   the top-performing product line.
3. Sales are strongly seasonal, peaking in **Q4** (particularly November).
4. "Medium" deals are the most frequent, but "Large" deals contribute a
   disproportionately higher share of revenue per order.
5. A measurable subset of customers show no recent activity — a concrete,
   actionable churn-risk list.

Full findings, recommendations, and future improvements in
[`sql/12_final_insights.sql`](sql/12_final_insights.sql).

## 🖼️ Screenshots

> Add MySQL Workbench screenshots of key query results here.

- `images/01_schema_diagram.png`
- `images/02_monthly_revenue_query.png`
- `images/03_top_customers_result.png`

## ▶️ How to Run

See the full step-by-step guide in
[`documentation/02_how_to_run.md`](documentation/02_how_to_run.md).

Quick start:
1. Download `sales_data_sample.csv` from the [Kaggle dataset page](https://www.kaggle.com/datasets/kyanyoga/sample-sales-data) into `dataset/`.
2. Run `sql/01_create_database.sql` in MySQL Workbench.
3. Import the CSV using the method documented in `sql/02_import_dataset.sql`.
4. Run the remaining scripts in numerical order (`03` → `12`).

## 🚀 Future Enhancements

- Normalize into a proper star schema (separate customers/products dimension tables)
- Connect the views in `sql/07_views.sql` to Power BI or Tableau for interactive dashboards
- Incorporate cost/margin data to shift from revenue-based to profit-based analysis
- Automate the ETL pipeline for a live/updating data source

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

*Built as a portfolio project to demonstrate SQL proficiency for Data
Analyst, Business Analyst, SQL Developer, Reporting Analyst, and
Business Intelligence roles.*

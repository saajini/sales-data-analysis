# How to Run This Project

## Prerequisites

- MySQL Server 8.0+ installed
- MySQL Workbench installed
- The dataset file `sales_data_sample.csv` downloaded from
  [Kaggle](https://www.kaggle.com/datasets/kyanyoga/sample-sales-data)
  and placed inside the `dataset/` folder

## Step-by-Step Setup

1. **Create the database and table**
   Open `sql/01_create_database.sql` in MySQL Workbench and run the entire
   script. This creates the `sales_analysis` database and the `sales_data`
   table with proper data types, keys, and indexes.

2. **Import the dataset**
   Open `sql/02_import_dataset.sql` for two documented import options:
   - MySQL Workbench's **Table Data Import Wizard** (GUI-based, beginner
     friendly)
   - `LOAD DATA INFILE` (SQL-based, scriptable/repeatable)

   After importing, verify the row count:
   ```sql
   SELECT COUNT(*) FROM sales_data;  -- should return 2823
   ```

3. **Run data cleaning**
   Execute `sql/03_data_cleaning.sql` to check for duplicates, handle NULL
   values, standardize text formatting, and validate data quality.

4. **Explore the data**
   Run `sql/04_exploratory_data_analysis.sql` for 45 SQL queries covering
   fundamentals through intermediate SQL (joins, subqueries, CTEs, window
   functions).

5. **Answer business questions**
   Run `sql/05_business_questions.sql` for 28 real-world business questions,
   each with a query and a written insight.

6. **Explore advanced SQL**
   Run `sql/06_advanced_sql.sql` for recursive CTEs, cohort analysis, and
   advanced window function patterns.

7. **Create views**
   Run `sql/07_views.sql` to build 5 reusable views for reporting/BI tools.

8. **Review indexing strategy**
   Run `sql/08_indexes.sql` to see index justification and `EXPLAIN` output
   confirming index usage.

9. **Create stored procedures/functions**
   Run `sql/09_stored_procedures.sql` to install 3 stored procedures and 2
   stored functions.

10. **Review transaction handling**
    Run `sql/10_transactions.sql` to see `COMMIT`/`ROLLBACK`/`SAVEPOINT`
    examples using an archive-table pattern.

11. **Review optimization examples**
    Run `sql/11_optimization.sql` for 5 before/after query optimization
    case studies with `EXPLAIN` output.

12. **Review final insights**
    Run `sql/12_final_insights.sql` for the consolidated summary queries
    behind the top findings and recommendations.

## Running Everything at Once (MySQL CLI)

```bash
mysql -u root -p < sql/01_create_database.sql
mysql -u root -p < sql/02_import_dataset.sql
mysql -u root -p < sql/03_data_cleaning.sql
mysql -u root -p < sql/04_exploratory_data_analysis.sql
mysql -u root -p < sql/05_business_questions.sql
mysql -u root -p < sql/06_advanced_sql.sql
mysql -u root -p < sql/07_views.sql
mysql -u root -p < sql/08_indexes.sql
mysql -u root -p < sql/09_stored_procedures.sql
mysql -u root -p < sql/10_transactions.sql
mysql -u root -p < sql/11_optimization.sql
mysql -u root -p < sql/12_final_insights.sql
```

## Notes

- All scripts use standard **MySQL syntax** (tested against MySQL 8.0).
- Scripts are numbered to reflect the logical order of a real analytics
  project: setup → import → clean → explore → analyze → optimize.
- Each script can also be run independently as long as `01` and `02` have
  been run first.

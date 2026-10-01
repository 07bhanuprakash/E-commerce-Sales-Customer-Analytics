# E-commerce Sales & Customer Analytics

**Tools:** MySQL, Power BI, DAX, Power Query, Excel  
**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Overview
An end-to-end business intelligence portfolio project exploring sales, product categories, customer purchasing behavior, cohort retention, delivery performance, and customer reviews. The workflow includes data inspection and validation, relational modeling, DAX calculations, and interactive Power BI reporting.

## Business questions
- How do revenue and order volume change over time?
- Which categories contribute most to revenue and order count?
- How do one-time and repeat customers differ?
- How does customer activity change after the first purchase?
- What are typical delivery times and late-delivery rates?
- How do review scores vary across delivery-status groups?

## Workflow
1. Inspect source CSVs and understand each table's grain.
2. Import data into MySQL and perform quality checks.
3. Validate nulls, duplicate keys, status values, foreign-key coverage, and timestamp anomalies.
4. Connect Power BI and build relationships, including a dedicated date table.
5. Develop DAX measures and calculated columns.
6. Create three report pages: Executive Overview, Customer & Product Analysis, and Delivery & Review Analysis.
7. Reconcile metrics and document definitions, findings, and limitations.

## Dashboard pages
### Executive Overview
KPI cards for revenue, orders, customers, average order value, and review score; monthly revenue and order trends; leading categories; interactive slicers.

### Customer & Product Analysis
Repeat-customer metrics, one-time/repeat revenue contribution, new and returning customer activity, cohort retention matrix, and category performance.

### Delivery & Review Analysis
Average delivery days, late-delivery rate, delivered orders, delivery-time distribution, review-score distribution, and review comparisons by delivery status.

## Metric definitions
- **Revenue:** Sum of item `price`; freight is excluded unless explicitly added.
- **Orders:** Distinct `order_id`, not item-row count.
- **Unique customers:** Use `customer_unique_id` to represent persistent customer identity.
- **AOV:** Revenue divided by distinct orders; document the revenue basis.
- **Average delivery days:** Calendar-day difference between purchase and customer delivery timestamps, requiring both dates.
- **Late delivery rate:** Late delivered orders divided by delivered orders with a valid actual delivery date.
- **Cohort retention:** Active customers in a cohort/month divided by the cohort's month-zero size. Blank future cells for recent cohorts mean unobserved periods, not zero retention.

## Observations to verify against the final PBIX
Previously calculated values included approximately 13.59M in item-price revenue (freight excluded), 98.7K distinct orders, and 137.73 average item-price revenue per order. Average delivery time was approximately 19.69 days (2016), 12.98 (2017), and 12.06 (2018); late-delivery rate was approximately 1.50%, 6.63%, and 9.37% respectively. Revalidate all values after refreshing the model and confirming filters and metric definitions.

## Reproduce
1. Download the Olist dataset from Kaggle.
2. Import the CSVs into a local MySQL database.
3. Connect Power BI to the database and verify table names/relationships.
4. Refresh the report and reconcile KPI values.
5. Add screenshots to `images/` and place the `.pbix` in `powerbi/` if sharing is appropriate.

## Limitations
Historical observational data; missing values affect eligible records; associations do not prove causation; recent cohorts have incomplete future periods; customer counts depend on identifier choice; item-price revenue excludes freight.

## Repository
See `docs/project_documentation.md`,  `sql/data_quality_checks.sql`.

**Author:** Bhanu Prakash Kanakamedala | B.Tech, Artificial Intelligence and Data Science

# Detailed Project Documentation

## 1. Purpose
Transform Olist's multi-table public e-commerce data into a reliable analytical model and interactive report for sales, customer, product, fulfillment, and review analysis.

## 2. Business questions
**Sales:** revenue and order trends, average order value, category contribution.  
**Customers:** unique customer count, repeat purchasing, customer-type revenue, cohort retention.  
**Delivery:** delivery duration, late-delivery rate, delivery-time distribution, changes over time.  
**Reviews:** score distribution and differences by delivery status.

## 3. Dataset and grain
The Olist dataset contains separate files for orders, customers, order items, products, payments, reviews, sellers, geolocation, and category translations. Grain differs by table: an order table is order-level, while order items are item-level and can contain multiple rows per order. Therefore, use distinct order counts when analyzing item-level data.

Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## 4. Data preparation and quality checks
- Profile row counts, data types, nulls, and distinct values.
- Validate candidate keys and investigate duplicates.
- Check foreign-key coverage between orders/customers, items/products, and reviews/orders.
- Review order-status distribution.
- Investigate timestamp anomalies and missing dates.
- Separate expected missing delivery dates (e.g. non-delivered orders) from data-quality issues.
- Use `customer_unique_id` for cross-order customer identity; `customer_id` is associated with an order-level customer record.
- Preserve raw source data and document transformations.

## 5. Modeling principles
- Use `order_id` to connect order-level entities.
- Use order items for product-level revenue and category analysis.
- Create a continuous date table with Date, Year, Month Number, Month Name, and Year-Month.
- Sort Month Name by Month Number and relate the calendar to purchase date.
- Avoid ambiguous relationships and unintended many-to-many joins.
- Confirm filter direction and prevent order-level measures from being multiplied by item rows.

## 6. KPI specification
| KPI | Definition / rule |
|---|---|
| Total Revenue | Sum of item `price`; freight excluded unless added explicitly .
| Total Orders | Distinct count of `order_id` .
| Unique Customers | Distinct `customer_unique_id`, excluding blanks.
| Average Order Value | Revenue / distinct orders.
| Average Review Score | Average of available review scores |
| Average Delivery Days | Purchase-to-customer-delivery day difference; both timestamps required .
| Late Orders | Distinct delivered orders with actual delivery later than estimated date .
| Late Delivery Rate | Late orders / delivered orders with valid actual delivery date .
| Repeat Customer | More than one distinct order in a stated period (monthly, yearly, or lifetime) .
| Cohort Retention | Active customers in month N / cohort size in month 0 .

## 7. Report pages
### Page 1 - Executive Overview
KPI cards, monthly revenue and order trends, category revenue/order rankings, and slicers for year, payment type, and order status.

### Page 2 - Customer & Product Analysis
Repeat behavior, customer-type revenue contribution, new/returning activity, cohort retention matrix, and category analysis. Cohort month 0 is the first purchase month. Later blank cells for recent cohorts indicate months not yet observed.

### Page 3 - Delivery & Review Analysis
Average delivery duration, late orders/rate, delivered orders, delivery-time buckets (0-5, 6-10, 11-15, 16-20, 21-25, 26-30, above 30 days), review distribution, and review comparisons by delivery status. Use chronological sorting for bucket labels.

## 8. Findings 
Previously observed: item-price revenue 13.59M (freight excluded); ~99K distinct orders; AOV ~137.75. Average delivery days were 19.69 in 2016, 12.98 in 2017, and 12.06 in 2018. Late-delivery rates were 1.50%, 6.63%, and ~9.37% for those years. Average review scores differed between late and on-time deliveries in the analyzed subset. These are descriptive observations.

## 9. Limitations
Historical data, missing values, right-censored recent cohorts, metric sensitivity to filter context and customer identifier, freight excluded from item-price revenue.

## 10. Final publication checklist
- Refresh and reconcile the report.
- Verify customer and revenue definitions.
- Test all slicers and relationships.
- Capture legible screenshots.
- Remove credentials, personal paths, and raw customer-level files.
- Update reported findings to match the final PBIX.

/*
Customer Report
============================================================
Purpose
	- This report gives insights for key customer metrics and behaviours

Highlights
	1. Gather essential data
	2. Segment Customers
	3. Aggregate customer-level metrics
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (months)
	4. Valualble KPI's
		- recency (months since last order)
		- average order value
		- average monthly spend
============================================================
*/
CREATE VIEW gold.report_customers AS
WITH base_query AS(
--Retrives core columns
SELECT
c.customer_key,
c.customer_number,
CONCAT (c.first_name,' ',c.last_name) AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) AS age,
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE order_date IS NOT NULL
)
, customer_aggregation AS(
--Summarizes key metrics at the customer level
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS life_span
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 WHEN age between 50 and 29 THEN '50-64'
	 ELSE 'Above 65'
END AS age_group,
CASE WHEN total_sales > 5000 and life_span >= 12 THEN 'VIP'
	 WHEN total_sales <= 5000 and life_span >= 12 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment,
total_orders,
last_order,
DATEDIFF(month, last_order, GETDATE()) AS recency,
total_sales,
total_quantity,
total_products,
life_span,
--Average order value
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders 
END AS avg_order_value,
--Monthly average spend
CASE WHEN life_span = 0 THEN total_sales
	 ELSE total_sales / life_span 
END AS avg_monthly_spend
from customer_aggregation

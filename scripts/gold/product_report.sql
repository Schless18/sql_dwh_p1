/*
Product Report
=====================================================================================
Purpose:
	- This report consolidates key products metics and behaviours

Highlights:
	1. Gather essential fileds 
	2. Segemnt products by revenue
	3. Agreggate product lvel-metrics:
		- total orders 
		- total sales
		- total quantity sold
		- total customers
		- lifespan (months)
	4. Calculate valuable KPI's
		- recency
		- average order revenue
		- average monthly
*/
CREATE VIEW gold.report_products AS
WITH base_query AS(
--Base query, retrieves core columns from fact_sales and dim_products
SELECT
s.order_number,
s.order_date,
s.customer_key,
s.sales_amount,
s.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
), product_aggregations AS(
SELECT 
product_key,
product_name,
category,
subcategory,
cost,

DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) AS last_sale_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY product_key, product_name, category, subcategory, cost
)
--Final query, combines all product results
SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
CASE WHEN total_sales > 50000 THEN 'High Performer'
	 WHEN total_sales >= 10000 THEN 'Mid Range'
	 ELSE 'Low Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,total_quantity,
total_customers,
avg_selling_price,
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_revenue,
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregations



select * from gold.report_products

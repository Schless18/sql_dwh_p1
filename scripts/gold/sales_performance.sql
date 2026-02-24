--Average sales vs provious year sales
WITH yearly_product_sales AS(
SELECT
YEAR(s.order_date) AS order_year,
p.product_name,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(s.order_date), p.product_name
)
SELECT order_year, 
product_name, 
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
	 ELSE 'Average'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py, 
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decreased'
	 ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year


--Which categories contributed to most sales?
WITH category_sales AS(
SELECT
p.category,
SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.category
)
SELECT 
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT)/ (SUM(total_sales) OVER ())) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

--Data Segmetation, Segment products into cost ranges, and count how many products fall into that category
WITH product_segments AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost >= 100 AND cost < 500 THEN '100-500'
	 WHEN cost >= 500 AND cost < 700 THEN '500-700'
	 WHEN cost >= 700 AND cost < 100 THEN '100-500'
	 ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products)
SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

--Group customers into three segements based on their spending behaviour
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(s.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS life_span
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
SELECT
customer_key,
total_spending,
life_span,
CASE WHEN total_spending > 5000 and life_span >= 12 THEN 'VIP'
	 WHEN total_spending <= 5000 and life_span >= 12 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment
FROM customer_spending)t
GROUP BY customer_segment
ORDER BY total_customers DESC


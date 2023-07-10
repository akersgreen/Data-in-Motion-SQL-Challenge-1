/***************************************************/
/* SQL Case Study - Tiny Shop Sales (Data supplied by Data in Motion) */
/***************************************************/

* Please check other file for how to create the DB in your IDE*

-- 1) Which product has the highest price? Only return a single row.

select product_name as prod_max_price
from (
select product_name, max(price)
from products) as dm;

-- 2) Which customer has made the most orders?

select o.customer_id, first_name, last_name, count(*) as order_count
from orders o
left join customers
using (customer_id)
group by o.customer_id, o.customer_id, first_name, last_name
limit 3;

-- 3) What’s the total revenue per product?

select product_id, product_name, sum((price * quantity)) as revenue
from products p
left join order_items oi
using (product_id)
group by product_id, product_name
order by revenue;

-- 4) Find the day with the highest revenue

SELECT order_date, sum(quantity * price) as revenue
from orders o 
left join order_items oi
using (order_id)
left join products p
using (product_id)
group by order_date
order by revenue desc
limit 1;

-- 5) Find the first order (by date) for each customer.

select c.customer_id, first_name, last_name, min(order_date) as first_order_date
from customers c
left join orders o 
using (customer_id)
group by c.customer_id;

-- 6) Find the top 3 customers who have ordered the most distinct products

SELECT customer_id, first_name, last_name, count(distinct product_id) as unique_product
from customers c
left join orders o
using (customer_id)
left join order_items oi
using (order_id)
group by customer_id
order by unique_product desc
limit 3;

-- 7) Which product has been bought the least in terms of quantity?

SELECT product_name, sum(quantity) total_qty
from order_items oi
left join products p
using (product_id)
group by product_id
order by total_qty asc
limit 3;

-- 8) What is the median order total?

WITH CTE AS (
  SELECT
    SUM(price * quantity) AS revenue,
    product_name,
    product_id
  FROM
    products p
  JOIN
    order_items oi USING (product_id)
  GROUP BY
    product_name,
    product_id
  ORDER BY
    revenue ASC
)
SELECT
  AVG(revenue) AS median_revenue
FROM (
  SELECT
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue) AS row_num,
    COUNT(*) OVER () AS total_rows
  FROM
    CTE
) subquery
WHERE
  row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2));


-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

select order_id,
       CASE
          WHEN revenue > 300 THEN 'Expensive'
          WHEN revenue > 100 THEN 'Affordable'
          ELSE 'Cheap'
          END AS price_bracket
          from (
select order_id, sum((price * quantity)) as revenue
from products p
left join order_items oi
using (product_id)
group by order_id
) as total_order;

-- 10) Find customers who have ordered the product with the highest price.

select c.customer_id, first_name, last_name
from customers c
left join orders
using (customer_id)
left join order_items oi
using (order_id)
left join products p
using (product_id)
where price = (
select max(price)
from products
);
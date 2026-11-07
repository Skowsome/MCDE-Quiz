-- Name: Abdul Saboor Khan
-- MCDE Batch 07

-- Chapter 1: Querying & Filtering

-- Q1. (LIKE, IN, ORDER BY with multiple columns) 
-- Return the first_name, last_name and city of customers who live in the state NY or CA, 
-- whose email ends in .com and whose last_name starts with the letter M. Sort by city ascending, then last_name ascending.

-- Ans:

Select 
	first_name, 
	last_name, 
	city 
from sales.customers 
where state in ('NY', 'CA') 
and last_name = 'M%%'

-- Q2. (Aliases, calculated column, ORDER BY, pagination) Show product_name, list_price and a calculated column called discounted_price 
-- (10% off) for products with a list_price above 500. Skip the 10 most expensive products and return the next 10 
-- (the 11th to 20th most expensive).

-- Ans:

select 
	product_name, 
	list_price, 
	list_price * .01 as discounted_price 
from production.products 
where list_price > 500 
order by list_price desc 
offset 10 rows fetch next 10 rows only;

-- Q3. (NULL, BETWEEN, AND/OR precedence) Find all orders that are either Pending or Processing, have not shipped yet, 
-- and were placed between 2018-01-01 and 2018-06-30. Return order_id, order_date, required_date and order_status. 
-- Your AND/OR logic must be explicitly grouped.

-- Ans:

select 
	 order_id, 
	 order_date, 
	 required_date, 
	 order_status 
from sales.orders 
where shipped_date is Null 
and order_date between '2018-01-01' and '2018-06-30';

-- Chapter 2: Joins

--Q4. (Multi-table INNER JOIN, 5 tables) 
-- For all Completed orders placed in 2018, return the customer's full name, order_id, order_date, store_name, product_name and quantity. 
-- Sort by order_date, newest first.

select
	 c.first_name + ' ' + c.last_name as Full_Name,
	 o.order_id,
	 o.order_date,
	 s.store_name,
	 p.product_name,
	 oi.quantity
 from sales.customers as c
 inner join sales.orders as o
 on c.customer_id = o.order_id

 -- Q5. (LEFT JOIN + NULL check, 4 tables) List every product that has never been sold, showing product_name, category_name and brand_name.

 -- Ans:

 select
	 p.product_name,
	 c.category_name,
	 b.brand_name
 from production.products as p
 left join sales.order_items as oi
 on p.product_id = oi.product_id
 left join production.categories as c
 on c.category_id = p.category_id
 left join production.brands as b
 on b.brand_id = p.brand_id
 where oi.product_id is null 

-- Q6.(Self join + extra join) Show every staff member's full name, their manager's full name (NULL for the top-level person) 
-- and the name of the store they work in.

-- Ans:
select 
	E.first_name + ' ' + E.last_name as Employee_Name,
	M.first_name + ' ' + M.last_name as Manager_Name,
	s.store_name
from sales.staffs as E
left join sales.staffs as M
on E.manager_id = M.staff_id
inner join sales.stores as s
on s.store_id = E.store_id

-- Q7 (a) Create a view sales.vw_order_details that joins orders, customers, order_items and products and exposes: order_id, order_date, 
-- order_status, customer_id, first_name, last_name, product_name, quantity and a calculated line_total (quantity × list_price × (1 − discount)).

-- Ans:

create view sales.vw_order_details
as
select 
	o.order_id,
	o.order_date,
	o.order_status,
	c.customer_id,
	c.first_name,
	c.last_name,
	p.product_name,
	oi.quantity,
	oi.quantity * p.list_price * (1 - oi.discount) as line_total
from sales.customers as c
inner join sales.orders as o
on o.customer_id = c.customer_id
inner join sales.order_items as oi
on o.order_id = oi.order_id
inner join production.products as p
on p.product_id = oi.order_id

-- Q7 (b) Using only that view, return each customer's total spend on Completed orders, and keep only customers who spent more than 10,000. 
-- Sort by total spend, highest first.

-- Ans:

Select * from sales.vw_order_details
where order_status = 4 and line_total > 10000


-- Q8. (GROUP BY on multiple columns, HAVING, COUNT DISTINCT, joins, top N) For each combination of category_name and brand_name, 
-- return the number of distinct orders and the total revenue. Keep only combinations that appear in at least 20 distinct orders, 
-- and return the top 5 by revenue.

-- Ans:


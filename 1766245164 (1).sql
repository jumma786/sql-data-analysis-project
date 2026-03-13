
-- activity -1 
SELECT * FROM activity.city;
select * from activity.customers;
select * from activity.products;
select * from activity.sales;
-- activity 2 
-- find null values 
select * from sales 
	where sale_id = null
    or sale_date= null
    or product_id=null
    or quantity=null
    or customer_id=null
    or total_amount=null
    or rating=null;
    
select * from city 
	where city_id =null
    or city_name =null
    or population=null
    or estimated_rent=null
    or city_rank=null;

select* from customers
	where customer_id =null
    or customer_name=null
    or city_id=null;
    
select * from products 
	where product_id=null
    or product_name=null
    or price=null;
    
-- acitivty 2 
-- Q.2 FIND DUPLICATS
select customer_name, city_id, count(*) as total 
from customers 
group by customer_name , city_id 
having count(*) >1;


-- FIND MISMATED BETWEEN TOTAL AMOUNT AND CALCULATED AMOUNT
select 
	s.sale_id,
    s.sale_date,
    s.quantity,
    s.rating,
    p.product_id,
    p.product_name,
    p.price,
    cu.customer_id,
    cu.customer_name,
    ci.city_id,
    ci.city_name,
    ci.population,
    ci.estimated_rent,
    ci.city_rank,
    s.total_amount,
    (p.price* s.quantity) as calculated_amount
from sales s
join products p
	on s.product_id=p.product_id
join customers cu 
	on s.customer_id =cu.customer_id
join city ci
	on cu.city_id=ci.city_id
where p.price * s.quantity <> s.total_amount
order by calculated_amount desc;



-- acitivty 3 COMPERHENSIVE SALE REPORT WITH CUSTOMERS AND PRODUCTS 
SELECT 
	s.sale_id,
    s.sale_date,
    s.quantity,
    s.total_amount,
    s.rating,
    p.product_id,
    p.product_name ,
    (s.quantity*p.price) as calculated_amount,
    p.price as product_price,
    c.customer_id,
    c.customer_name,
    ci.city_id
from sales s 
join customers c on c.customer_id=s.customer_id
join products p on p.product_id=s.product_id
join city ci on ci.city_id = c.city_id
order by sale_date, sale_id desc;


-- acitivity 4 
-- q.1 total sales per city 
select ci.city_name, sum(s.quantity) as total_unit_sold
from sales s 
join customers cu on s.customer_id= cu.customer_id
join city ci on ci.city_id=cu.city_id
group by ci.city_name
order by total_unit_sold desc;


-- Q.2 TOTAL TRANSCTIONS PER CITY 
select ci.city_name, count(*) as total_transction
from sales s 
join customers cu on s.customer_id= cu.customer_id
join city ci on ci.city_id=cu.city_id
group by ci.city_name
order by total_transction desc;

-- Q.3 UNIQUE CUSTOMER PER CITY 
SELECT 
	ci.city_id,
    ci.city_name,
    count(distinct cu.customer_id) as unique_customers
from customers cu 
join city ci on ci.city_id=cu.city_id
group by ci.city_id, ci.city_name
order by unique_customers desc;


-- Q.4 AVERAGE ORDERs VALUES PER CITY 
SELECT 
	ci.city_id,
    ci.city_name,
    avg(cu.customer_id) as avg_order
from customers cu 
join city ci on ci.city_id=cu.city_id
group by ci.city_id, ci.city_name
order by avg_order desc;

-- Q.5 PRODUCT DEMAND PER CITY 
SELECT 
	ci.city_id,
    p.product_id,
    p.product_name,
    ci.city_name,
    sum(s.quantity) as total_demand 
from sales s
join products p on s.product_id=p.product_id
join customers cu on cu.customer_id= s.customer_id
join city  ci on cu.city_id=ci.city_id
group by ci.city_id, p.product_id, p.product_name,ci.city_name
order by ci.city_name, total_demand desc;

-- Q.6 MONTHLY SALES TREND 
SELECT 
    DATE_FORMAT(STR_TO_DATE(s.sale_date, '%m/%d/%Y'), '%Y-%m') AS month,
    SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY DATE_FORMAT(STR_TO_DATE(s.sale_date, '%m/%d/%Y'), '%Y-%m')
ORDER BY month;


DESCRIBE sales;



--  Q.7  avg rating analysis
SELECT
    ci.city_id,
    ci.city_name,
    p.product_id,
    p.product_name,
    AVG(s.rating) AS avg_rating,
    COUNT(s.sale_id) AS total_ratings
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
JOIN customers cu
    ON s.customer_id = cu.customer_id
JOIN city ci
    ON cu.city_id = ci.city_id
WHERE s.rating IS NOT NULL
GROUP BY
    ci.city_id,
    ci.city_name,
    p.product_id,
    p.product_name
ORDER BY
    ci.city_name,
    avg_rating DESC;


-- ACTIVITY 5
SELECT
    ci.city_id,
    ci.city_name,
    SUM(s.total_amount) AS total_sales,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    COUNT(s.sale_id) AS order_count
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_id, ci.city_name;


WITH city_metrics AS (
    SELECT
        ci.city_id,
        ci.city_name,
        SUM(s.total_amount) AS total_sales,
        COUNT(DISTINCT s.customer_id) AS unique_customers,
        COUNT(s.sale_id) AS order_count
    FROM sales s
    JOIN customers cu ON s.customer_id = cu.customer_id
    JOIN city ci ON cu.city_id = ci.city_id
    GROUP BY ci.city_id, ci.city_name
)

SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS sales_rank,
        ROW_NUMBER() OVER (ORDER BY unique_customers DESC) AS customer_rank,
        ROW_NUMBER() OVER (ORDER BY order_count DESC) AS order_rank
    FROM city_metrics
) ranked
WHERE sales_rank <= 3
   OR customer_rank <= 3
   OR order_rank <= 3
ORDER BY city_name;

-- FINAL RECOMMENDATIONS 
-- Pune is the strongest city for expansion, ranking first in sales and orders.
-- Chennai and Bangalore show consistent performance and are low-risk choices.
-- Jaipur and Delhi have high customers but lower sales efficiency.
-- Expansion should start with Pune, followed by Chennai and Bangalore.

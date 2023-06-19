use gdb023;

select * from dim_customer;
select * from dim_product;

select * from fact_sales_monthly
where fiscal_year=2021;

-- Provide the list of markets in which customer "Atliq Exclusive" operates itsbusiness in the APAC region.--

select market,customer,region from dim_customer
where customer="Atliq Exclusive" and region="APAC" order by market;

select * from dim_customer
where customer="Atliq Exclusive";

-- What is the percentage of unique product increase in 2021 vs. 2020? 

select x.a as unique_product_2020,y.b as unique_product_2021,round((b-a)*100/a,2) as prct_chng
from
(
 ( select count(distinct(product_code)) as a from
 fact_sales_monthly
 where fiscal_year=2020) x,
 (select count(distinct(product_code)) as b from 
 fact_sales_monthly 
 where fiscal_year =2021) y
 );


--  Provide a report with all the unique product counts for each segment andsort them in descending order of product counts.
  -- The final output contains2 fields--
  
select * from dim_product;
  
select segment,count(distinct(product_code)) as count_segment from dim_product
group by segment order by count_segment desc;
  
-- Follow-up: Which segment had the most increase in unique products in
-- 2021 vs 2020? The final output contains these fields

use gdb023;

With cte1 as 
(select p.segment as a,count(distinct(fs.product_code)) as b
from dim_product p, fact_sales_monthly fs 
where p.product_code = fs.product_code
group by fs.fiscal_year,p.segment
having fs.fiscal_year ="2020"),
cte2 as
(select p.segment as c,count(distinct(fs.product_code)) as d
from dim_product p, fact_sales_monthly fs
where p.product_code = fs.product_code
group by fs.fiscal_year,p.segment 
having fs.fiscal_year ="2021")
select a as segment,b as count_2020,d as 
count_2021,d-b as diff from cte1,cte2
where cte1.a=cte2.c;


 select * from fact_sales_monthly
 where fiscal_year ='2021';



select * from fact_sales_monthly;

-- Get the products that have the highest and lowest manufacturing costs.
-- The final output should contain these fields
  
select * from fact_manufacturing_cost;

select m.product_code,p.product,m.manufacturing_cost from fact_manufacturing_cost m
join dim_product p on m.product_code=p.product_code 
where manufacturing_cost in 
(select max(manufacturing_cost) from fact_manufacturing_cost
union
select min(manufacturing_cost) from fact_manufacturing_cost)
order by manufacturing_cost desc;

-- Generate a report which contains the top 5 customers who received an
-- average high pre_invoice_discount_pct for the fiscal year 2021 and in the
-- Indian market. The final output contains these fields,

select * from dim_customer;
select * from fact_pre_invoice_deductions;

   with cte1 as
(
  select c.customer_code,c.customer,avg(p.pre_invoice_discount_pct) as avg_disct 
  from dim_customer c
  join fact_pre_invoice_deductions p on c.customer_code = p.customer_code
  where fiscal_year="2021" and market="india"
  group by p.customer_code)
  select customer_code,customer,round(avg_disct,4) as disct_prcnt from cte1
  group by customer_code order by disct_prcnt desc limit 5;
  
  
-- Get the complete report of the Gross sales amount for the customer “Atliq
-- Exclusive” for each month. This analysis helps to get an idea of low and
-- high-performing months and take strategic decisions 
  
select * from fact_sales_monthly; 
select * from fact_manufacturing_cost; 
select * from fact_gross_price;

select * from dim_customer;
select * from fact_sales_monthly;

select concat(monthname(sm.date), ' (',year(sm.date), ')') 
as mnt,sm.fiscal_year,round(sum(gp.gross_price*sm.sold_quantity),2) as gross_sales_amount 
from fact_sales_monthly sm join dim_customer c on sm.customer_code=c.customer_code
						   join fact_gross_price gp on sm.product_code=gp.product_code   
where c.customer="Atliq Exclusive"
group by mnt,sm.fiscal_year
order by sm.fiscal_year;

-- In which quarter of 2020, got the maximum total_sold_quantity? The final
-- output contains these fields sorted by the total_sold_quantity

use gdb023;


select 
case 
when date between '2019-09-01' and '2019-11-30' then concat('q1',"-",monthname(date))
when date between '2019-12-01' and '2020-02-29' then concat('q2',"-",monthname(date))
when date between '2020-03-01' and '2020-05-31' then concat('q2',"-",monthname(date))
when date between '2020-06-01' and '2020-08-31' then concat('q1',"-",monthname(date))
end as Quarters,
sum(sold_quantity) as total_sold_qnty from fact_sales_monthly
where fiscal_year="2020"
group by Quarters;

-- Which channel helped to bring more gross sales in the fiscal year 2021
-- and the percentage of contribution? The final output contains these fields,

select * from fact_gross_price;
select * from dim_product;

select * from dim_customer;

WITH Output AS
(
SELECT C.channel,
       ROUND(SUM(G.gross_price*FS.sold_quantity/1000000), 2) AS Gross_sales_mln
FROM fact_sales_monthly FS JOIN dim_customer C ON FS.customer_code = C.customer_code
						   JOIN fact_gross_price G ON FS.product_code = G.product_code
WHERE FS.fiscal_year = 2021
GROUP BY channel
)
SELECT channel, CONCAT(Gross_sales_mln,' M') AS Gross_sales_mln,CONCAT(ROUND(Gross_sales_mln*100/total , 2), ' %') AS percentage
FROM
(
(SELECT SUM(Gross_sales_mln) AS total FROM Output) A,
(SELECT * FROM Output) B
)
ORDER BY percentage DESC;





  
  
  
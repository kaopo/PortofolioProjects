-- New database for the project
create database Retail; 
use retail;
-- Data insert

create table retail(
product_id varchar(255),
product_category_name varchar(255),
month_year varchar(255),
quantity int,
total_price decimal(10,2),
freight_price decimal(10,5),
unit_price decimal(10,5),
product_score decimal(2,1),	
customers int,	
volume int);


SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE "C:/Users/csv/retail_price.csv"
INTO TABLE retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

truncate retail;
-- Total revenue per month/year

select * from retail;

-- First i need to change the data type or month_year column

select replace(month_year,'-','/') from retail;
update retail 
set month_year = replace(month_year,'-','/') ;

select str_to_date(month_year, '%d/%m/%Y') from retail;

update retail
set month_year = str_to_date(month_year, '%d/%m/%Y') ;

 -- Monthly revenue
 
select sum(total_price) as revenue_may from retail
where month_year = '2017-05-01';

select sum(total_price) as revenue_june from retail
where month_year = '2017-06-01';

-- Yearly revenue

select sum(total_price) as revenue_2017 from retail
where year(month_year) = '2017';

select sum(total_price) as revenue_2018 from retail
where year(month_year) = '2018';

 -- Best-selling products and categories.

select product_id,avg(product_score) as Most_popular_product,sum(quantity) as products_sold,sum(total_price) as Most_money_made_product from retail
group by product_id
order by avg(product_score) desc,sum(quantity) desc;

-- Customer segmentation based on spending.


select product_id, product_category_name, sum(customers) as customers,sum(total_price) as total_spent from retail
group by product_id, product_category_name
order by sum(customers) desc;

-- Profit margin calculations.

select product_id,avg(unit_price),sum(total_price) from retail         -- i want to calculate the gross profit margin
group by product_id
order by avg(unit_price) desc;

select product_category_name, 
    SUM(total_price) AS total_revenue, 
    SUM(unit_price) AS total_cost,
    ((sum(total_price)-avg(unit_price))/sum(total_price))*100 as gross_profit_margin from retail  
group by product_category_name
order by gross_profit_margin desc;


select * from retail;

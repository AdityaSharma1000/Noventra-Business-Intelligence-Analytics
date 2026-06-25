--------------------------------------------------------------------------------------------------------------------------------------------
--Creating a database for an Noventra E-commerce
--------------------------------------------------------------------------------------------------------------------------------------------

create database Noventra_ecommerce;
use Noventra_ecommerce;

---------------------------------------------------------------------------------------------------------------------------------------------
--Creating a raw dataset table representing unnormalized online shopping data
---------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE raw_data
(
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    customer_age INT,
    state VARCHAR(100),
    country VARCHAR(100),
    market VARCHAR(100),
    region VARCHAR(100),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255),
    units_sold varchar(20),
    quantity INT,
    discount varchar(20), 
    order_priority VARCHAR(20)
);

-------------------------------------------------------------------------------------------------------------------------------------------------
--Inserting data in the created table 
-------------------------------------------------------------------------------------------------------------------------------------------------

BULK INSERT raw_data
FROM 'C:\Users\Aditya\Desktop\SuperStoreOrders - SuperStoreOrders 3.csv'
WITH (
    FIRSTROW = 2,          
    FORMAT = 'CSV',              
    FIELDTERMINATOR = ',', 
    FIELDQUOTE = '"',            
    ROWTERMINATOR = '\n',  
    TABLOCK
);

--------------------------------------------------------------------------------------------------------------------------------------------------
-- Checking for nulls if any 
--------------------------------------------------------------------------------------------------------------------------------------------------

select
    sum(case when order_id is null then 1 else 0 end) as order_id_nulls,
    sum(case when order_date is null then 1 else 0 end) as order_date_nulls,
    sum(case when ship_date is null then 1 else 0 end) as ship_date_nulls,
    sum(case when ship_mode is null then 1 else 0 end) as ship_mode_nulls,
    sum(case when customer_name is null then 1 else 0 end) as customer_name_nulls,
    sum(case when segment is null then 1 else 0 end) as segment_nulls,
    sum(case when customer_age is null then 1 else 0 end) as customer_age_nulls,
    sum(case when state is null then 1 else 0 end) as state_nulls,
    sum(case when country is null then 1 else 0 end) as country_nulls,
    sum(case when market is null then 1 else 0 end) as market_nulls,
    sum(case when region is null then 1 else 0 end) as region_nulls,
    sum(case when category is null then 1 else 0 end) as category_nulls,
    sum(case when sub_category is null then 1 else 0 end) as sub_category_nulls,
    sum(case when product_name is null then 1 else 0 end) as product_name_nulls,
    sum(case when units_sold is null then 1 else 0 end) as units_sold_nulls,
    sum(case when quantity is null then 1 else 0 end) as quantity_nulls,
    sum(case when discount is null then 1 else 0 end) as discount_nulls,
    sum(case when order_priority is null then 1 else 0 end) as order_priority_nulls
from raw_data;

select * from raw_data;

-------------------------------------------------------------------------------------------------------------------------------------------------------
--Normalizing the bulk data into 3NF form 
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- creating customer table (dim)

create table customers 
(
customer_id int identity(10001,1) primary key,
customer_name varchar(50),
customer_segment varchar(20),
customer_age int
);

-- creating products table (dim)

create table products 
(
product_id int identity(50001,1) primary key,
product_name varchar(200),
product_subcategory varchar(30),
product_category varchar(30)
);

-- creating location table (dim)

create table locations 
(
location_id int identity(1234,1) primary key,
region varchar(80),
country varchar(80),
state varchar(80),
market varchar(80)
);

-- creating dates table (dim)

create table dates
(
    date_value date primary key,
    year int,
    quarter varchar(2),
    month_name varchar(20),
    month_number int,
    day_name varchar(20),
    day_number int
);

-- creating orders table (fact)

create table orders
(
order_id varchar(20),
order_date date,
ship_date date,
delivery_days int,
ship_mode varchar(20),
order_priority varchar(20),
customer_id int,
foreign key (customer_id)
references customers(customer_id),
product_id int ,
foreign key (product_id)
references products(product_id),
location_id int,
foreign key (location_id)
references locations(location_id),
units_sold int ,
quantity int,
discount varchar(10),
revenue int 
);

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Inserting data from the unnormalized raw_data table to normalized tables
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--Inserting data in products table

insert into products (product_name , product_subcategory , product_category)
select distinct product_name , sub_category , category from raw_data;

--Inserting data in customers table

insert into customers (customer_name , customer_segment , customer_age)
select distinct customer_name , segment , customer_age from raw_data;

--Inserting data in locations table

insert into locations (region , country , state , market)
select distinct region , country , state , market from raw_data;

--Inserting data in dates table

DECLARE @StartDate DATE = '2011-01-01';
DECLARE @EndDate DATE = '2014-12-31';
WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dates(date_value)
    VALUES (@StartDate);

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;

UPDATE dates
SET 
    year = YEAR(date_value),
    month_number = MONTH(date_value),
    month_name = DATENAME(MONTH, date_value),
    quarter = concat( 'Q' , DATEPART(QUARTER, date_value)),
    day_number = DAY(date_value),
    day_name = DATENAME(WEEKDAY, date_value);

--Inserting data in orders table

INSERT INTO orders
(order_id , order_date , ship_date , delivery_days , ship_mode , order_priority , customer_id , product_id , location_id , units_sold , quantity , discount , revenue)
SELECT sd.order_id, sd.order_date, sd.ship_date, DATEDIFF(day, sd.order_date, sd.ship_date), sd.ship_mode,
sd.order_priority, c.customer_id, p.product_id, l.location_id, sd.units_sold, sd.quantity, sd.discount,
sd.units_sold * sd.quantity * (1 - CAST(REPLACE(sd.discount, '%', '') AS DECIMAL(5,2)) / 100)
FROM raw_data AS sd
JOIN customers AS c
ON c.customer_name = sd.customer_name
AND c.customer_segment = sd.segment
AND c.customer_age = sd.customer_age
JOIN products AS p
ON p.product_name = sd.product_name
AND p.product_category = sd.category
AND p.product_subcategory = sd.sub_category
JOIN locations AS l
ON l.region = sd.region
AND l.country = sd.country
AND l.state = sd.state
AND l.market = sd.market;

----------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking inserted data
----------------------------------------------------------------------------------------------------------------------------------------------------------

select * from orders;
select * from products;
select * from customers;
select * from locations;
select * from dates;

----------------------------------------------------------------------------------------------------------------------------------------------------------
--Creating indexes on necessary columns to improve query performance
----------------------------------------------------------------------------------------------------------------------------------------------------------

create index idx_order_product_id on orders(product_id);
create index idx_order_customer_id on orders(customer_id);
create index idx_order_location_id on orders(location_id);
create index idx_order_order_date on orders(product_id);
create index idx_product_category on products(product_category);
create index idx_country on locations(region);

select t.name AS table_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       i.is_primary_key,
       i.is_unique
from sys.indexes i
join sys.tables t
    on i.object_id = t.object_id
where i.index_id > 0
order by t.name, i.name;
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating Analytical Views 
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Product Performance View

create view product_performance_view as
with product_summery as 
(
select 
       dense_rank() over (order by sum(o.revenue) desc) as product_rank,
       p.product_name, p.product_subcategory, p.product_category,
       sum(o.quantity) as total_quantity_sold,
       format(sum(o.revenue),'N0') as total_revenue,
       count(distinct order_id) as Total_orders_placed
from products as p 
join orders as o on 
p.product_id=o.product_id
group by product_name, product_subcategory, product_category
)
select  * from product_summery
where product_rank <= 10;
      
select * from product_performance_view;

-- Customer demographics and segment insights view

create view customer_segment_insights as 
with CSI as 
(
select 
      dense_rank() over (order by sum(o.revenue) desc) as Rank,
      c.customer_segment as customer_segment,
      CASE 
        WHEN c.customer_age < 25 THEN 'Under 25 (Gen Z)'
        WHEN c.customer_age BETWEEN 25 AND 40 THEN '25-40 (Millennial)'
        WHEN c.customer_age BETWEEN 41 AND 60 THEN '41-60 (Gen X)'
        ELSE '60+ (Senior)'
      END AS age_group,
      count(distinct c.customer_id) as total_customers,
      format(sum(o.revenue),'N0') as total_revenue,
      avg(o.revenue) as average_order_value
from customers as c
join orders as o on 
c.customer_id=o.customer_id
group by customer_segment,
      CASE 
        WHEN c.customer_age < 25 THEN 'Under 25 (Gen Z)'
        WHEN c.customer_age BETWEEN 25 AND 40 THEN '25-40 (Millennial)'
        WHEN c.customer_age BETWEEN 41 AND 60 THEN '41-60 (Gen X)'
        ELSE '60+ (Senior)'
      END
)
select * from CSI 
where rank<= 10;

select * from customer_segment_insights;

--shipping & logistics efficiency view 

create view shipping_logistics as 
with SL as 
(
select 
       dense_rank() over (order by count(distinct order_id) desc) as rank,
       ship_mode,
       order_priority,
       avg(delivery_days) as average_delivery_days,
       max(delivery_days) as max_delivery_days,
       format(count(distinct order_id),'N0') as total_shipments
from orders
group by  ship_mode, order_priority
)
select * from SL
where rank<=10;

select * from shipping_logistics;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Business analysis queries 
---------------------------------------------------------------------------------------------------------------------------------------------

-- MOM analsysis 

with monthly_analysis as 
(
select d.year,
       d.month_number,
       d.month_name,
       sum(o.revenue) as Total_revenue
from dates as d 
       join orders as o on 
       d.date_value = o.order_date
group by 
       d.year,
       d.month_number,
       d.month_name
)

select year , month_name , total_revenue , 
       isnull(lag(Total_revenue) over (order by year,month_number asc),0) as previous_month_revenue,
       isnull(cast(
        ((total_revenue - lag(total_revenue) over(order by year, month_number))  * 100.0     )
       /
       nullif(
        lag(total_revenue) over(order by year, month_number),0
          ) as decimal(10,2)),0) as [mom%]
from monthly_analysis
order by year , month_number;

-- YOY analysis 

with yearly_sales as
(
select d.year,
       sum(o.revenue) as total_revenue
from orders as o
       join dates as d
       on o.order_date = d.date_value
group by d.year
)

select year,
       format(total_revenue,'n0') as total_revenue,
       isnull(format(lag(total_revenue) over(order by year),'n0'),0) as previous_year_revenue,
       concat(isnull(cast(
                    ((total_revenue - lag(total_revenue) over(order by year)) * 100.0)
                    /
                    nullif(lag(total_revenue) over(order by year),0)as decimal(10,2) ),0),'%') as yoy_growth
from yearly_sales;

-- Top 5 products 

select top 5
    dense_rank() over(order by sum(o.revenue) desc) as product_rank,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    sum(o.quantity) as total_quantity_sold,
    count(distinct o.order_id) as total_orders,
    format(sum(o.revenue),'n0') as total_revenue,
    format(avg(o.revenue),'n0') as average_order_value
from products as p
join orders as o
    on p.product_id = o.product_id
group by
    p.product_name,
    p.product_category,
    p.product_subcategory
order by sum(o.revenue) desc;

-- Bottom 5 products 

select top 5
    dense_rank() over(order by sum(o.revenue) desc) as product_rank,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    sum(o.quantity) as total_quantity_sold,
    count(distinct o.order_id) as total_orders,
    format(sum(o.revenue),'n0') as total_revenue,
    format(avg(o.revenue),'n0') as average_order_value
from products as p
join orders as o
    on p.product_id = o.product_id
group by
    p.product_name,
    p.product_category,
    p.product_subcategory
order by sum(o.revenue) asc;

-- Customer lifetime value 

with customer_clv as
(
    select
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        count(distinct o.order_id) as total_orders,
        sum(o.revenue) as lifetime_value,
        avg(o.revenue) as average_order_value
    from customers as c
    join orders as o
        on c.customer_id = o.customer_id
    group by
        c.customer_id,
        c.customer_name,
        c.customer_segment
)

select
    dense_rank() over(order by lifetime_value desc) as customer_rank,
    customer_name,
    customer_segment,
    total_orders,
    format(lifetime_value,'n0') as lifetime_value,
    format(average_order_value,'n0') as average_order_value
from customer_clv
order by customer_rank asc;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating  store procedures 
------------------------------------------------------------------------------------------------------------------------------------------------------------

-- customer pruchase history store procedure 

create procedure sp_customer_history @customer_id int as
begin
select o.order_id,
       o.order_date,
       p.product_name,
       o.quantity,
       o.revenue
from orders o
       join products p
       on o.product_id = p.product_id
where o.customer_id = @customer_id
order by o.order_date;
end;

exec sp_customer_history 10001;

-- Sales between two dates store procedure  

create procedure sp_sales_between_dates
@start_date date,
@end_date date as
begin
select  count(distinct order_id) as total_orders,
        sum(revenue) as total_revenue,
        sum(quantity) as total_quantity
from orders
where order_date between @start_date and @end_date;

end;

exec sp_sales_between_dates '2012-01-01', '2012-12-31';

-- Customer churn analysis store procedure

create procedure sp_customer_churn_analysis
@days int as
begin
select c.customer_id,
       c.customer_name,
       c.customer_segment,
       max(o.order_date) as last_order_date,
       datediff(day, max(o.order_date), '2014-12-31') as days_since_last_order,
       sum(o.revenue) as lifetime_revenue
from customers as c
join orders as o
     on c.customer_id = o.customer_id
group by c.customer_id,
         c.customer_name,
         c.customer_segment
having datediff(day, max(o.order_date), getdate()) >= @days
order by lifetime_revenue desc;
end;

exec sp_customer_churn_analysis 90;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating Trigger for insert, update & delete 
------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating a trigger table 

create table order_audit
(
audit_id int identity(1,1) primary key,
order_id varchar(20),
action_type varchar(10),
action_date datetime default getdate()
);

-- Insert trigger 

create trigger insert_after_orders on orders
after insert as
begin
insert into order_audit
(order_id,action_type)
select order_id, 'insert' 
from inserted;
end;

-- Update trigger 

create trigger update_after_orders on orders
after update as
begin
insert into order_audit
(order_id,action_type)
select order_id,'update'
from inserted;
end;

-- Delete Trigger 

create trigger trg_orders_delete on orders
after delete as
begin
insert into order_audit
(order_id,action_type)
select order_id,'delete'
from deleted;
end;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Testing created triggers
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- testing insert trigger 

insert into orders
(order_id,order_date,ship_date,delivery_days,ship_mode,order_priority,product_id,location_id,customer_id,units_sold,quantity,discount,revenue)
values ('TEST001','2014-12-30','2015-01-02',3,'Standard Class','Medium',50001,1234,10001,100,2,'0%',200);

-- testing update trigger

update orders
set revenue = 500
where order_id = 'TEST001';

-- testing delete trigger

delete
from orders
where order_id = 'TEST001';

select * from order_audit;





























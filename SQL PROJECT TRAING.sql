create database SQLPROJECT;
show databases;
use sqlproject;

select * from orders_store2;

-- 	Q1.  Select all columns for every order in the Electronics category
select *
from orders_dirty
where category = "electronics";

-- Q2.  Get the distinct list of products ever ordered
select distinct product
from orders_dirty;

-- Q3  List all orders where the price is greater than 10,000
select *
from orders_dirty
where price > 10000;

-- Q4  Find all orders placed between 2024-01-15 and 2024-02-01

SELECT *
from Orders_dirty
where OrderDate between '2024-01-15' and '2024-02-01';

-- Q5  Find all customers whose name starts with the letter “A” or “F”.
select *
from Orders_dirty
where CustomerName like 'A%'
   or CustomerName like 'F%';
-- Q6 Select CustomerName, Product, and Price, aliasing Price as UnitPrice
select 
customername,
product,
price as unitprice
from orders_dirty;

-- Q7  Find all orders where the product name contains the word “Cable”.
select *
from Orders_dirty
where product like '%cable%';

-- Q8  List orders where Category is either Accessories or Home
select *
from orders_dirty
where category = "accessories" or "home";
-- Q9 Write a statement to add a new column TotalAmount (numeric) to the Orders table
alter table Orders_dirty
add column TotalAmount decimal(15,2);

-- Q10 Write a statement to rename the column Price to UnitPrice

alter table Orders_dirty
rename column Price to UnitPrice;

-- Q11 Write a statement to change the data type of OrderDate from text to DATE
select 
orderdate,
str_to_date(orderdate,'%m/%d/%Y') as correct_date;

-- Q12  Write a statement to drop a column called Notes from Orders (assume it exists)
alter table orders_dirty
drop column note;

-- Q13 Write a statement to add a NOT NULL constraint to the CustomerID column
alter table Orders_dirty
modify column CustomerID varchar(50) not null;

-- Q14  Increase the price of all Electronics products by 10%

update orders_dirty
set unitprice = unitprice*1.10
where category = 'electronics';

-- Q15 Set Quantity to 1 for any order where Quantity is currently NULL or 0.

update Orders_dirty
set Quantity = 1
where Quantity is null
   or Quantity = 0;
-- Q16 Update the category of the product “Webcam” from Electronics to Accessories

update orders_dirty
set category = 'accessories'
where product = 'webcam'
and category = 'electronics';

-- Q17 Update CustomerName to “Alice Johnson” for CustomerID = 'CUST1'
update orders_dirty
set customername = 'Alice Johnson'
where customerid = 'cust1';

-- Q18  For every order placed in January 2024, add a 500 flat discount to Price (don’t let price go below
update Orders_dirty
set unitPrice = greatest(unitPrice - 500, 0)
where OrderDate >= '2024-01-01'
  and OrderDate < '2024-02-01';

-- Q19  Find the total revenue (SUM(Quantity * Price)) generated overall

select sum(quantity * unitprice) as new_price
from orders_dirty;

-- Q20  Find the total quantity sold per Category

select 
category,
sum(quantity) as total_quatity_sold
from orders_dirty
group by category;

-- Q21  Find the average price of products in each Category
select 
category,
avg(quantity) as total_quatity_sold
from orders_dirty
group by category;

-- Q22 Find the highest and lowest priced order for each Product
select 
product,
min(unitprice) as minprice,
max(unitprice) as maxprice
from orders_dirty
group by product;

-- Q23 Count how many orders each customer has placed

select
    CustomerID,
    CustomerName,
    count(*) as TotalOrders
from Orders_dirty
group by CustomerID, CustomerName
order by TotalOrders desc;
-- Q24  Find the total revenue per customer, sorted from highest to lowest.

select
    CustomerID,
    CustomerName,
    SUM(Quantity * unitPrice) as TotalRevenue
from Orders_dirty
group by CustomerID, CustomerName
order by TotalRevenue desc;

-- Q25 Group orders by Category and show total revenue per category, ordered by revenue descending

select
    Category,
    sum(Quantity * unitPrice) as TotalRevenue
from Orders_dirty
group by Category
order by TotalRevenue desc;

-- Q26 Group orders by CustomerID and show the count of orders, only for customers with more than 3

select
    CustomerID,
    count(*) AS TotalOrders
from Orders_dirty
group by CustomerID
having count(*) > 3;

-- Q27  Using PARTITION BY Category, show each order alongside the average price of its category
select
    OrderID,
    Product,
    Category,
    unitPrice,
    avg(unitPrice) over (
        partition by Category
    ) as CategoryAveragePrice
from Orders_dirty;

/*Q28  Using PARTITION BY CustomerID ORDER BY OrderDate, show each customer’s orders
numbered in the sequence they were placed*/

select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    OrderDate,
    row_number() over (
        partition by CustomerID
        order by OrderDate, OrderID
    ) as CustomerOrderNumber
from Orders_dirty;

-- Q29  Show total quantity sold per Category per month, ordered by month then category

select
    date_format(OrderDate, '%Y-%m') as OrderMonth,
    Category,
    sun(Quantity) as TotalQuantitySold
from Orders_dirty
group by
    DATE_FORMAT(OrderDate, '%Y-%m'),
    Category
order by
    OrderMonth,
    Category;

-- Q30 Use ROW_NUMBER() to number each customer’s orders from earliest to latest

select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    OrderDate,
    row_number() over (
        partition by CustomerID
        order by OrderDate asc, 
        OrderID asc
    ) as RowNumber
from Orders_dirty;
-- Q31 Use RANK() to rank products by total revenue, highest first 

select
    Product,
    TotalRevenue,
    rank() over (
        order by TotalRevenue desc
    ) as RevenueRank
from (
    select
        Product,
        SUM(Quantity * unitPrice) as TotalRevenue
    from Orders_dirty
    group by Product
) as ProductRevenue;

-- Q 32 Use DENSE_RANK() to rank customers by total amount spent

select
    CustomerID,
    CustomerName,
    TotalSpent,
    dense_rank() over (
        order by TotalSpent desc
    ) as SpendingRank
from (
    select
        CustomerID,
        CustomerName,
        SUM(Quantity * unitPrice) as TotalSpent
    from Orders_dirty
    group by CustomerID, CustomerName
) as CustomerSpending;

-- Q33 Return the 5 most recent orders

select *
from Orders_dirty
order by OrderDate desc, 
OrderID desc
limit 5;

-- Q34  Return the top 3 highest-priced orders

select *
from Orders_dirty
order by unitPrice desc, 
OrderID desc
limit 3;

-- Q35  Return the 5 customers with the highest total spend (combine with aggregation + LIMIT)
select
    CustomerID,
    CustomerName,
    SUM(Quantity * unitPrice) as TotalSpend
from Orders_dirty
group by CustomerID, CustomerName
order by TotalSpend desc
limit 5;

-- Q36  Skip the first 10 orders and return the next 5 (pagination, LIMIT ... OFFSET ...)

select *
from Orders_dirty
order by OrderID asc
limit 5 offset 10;

-- Q37  Identify and remove exact duplicate rows
select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    Category,
    Quantity,
    unitPrice,
    OrderDate,
    COUNT(*) as DuplicateCount
from Orders_dirty
group by
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    Category,
    Quantity,
    unitPrice,
    OrderDate
having COUNT(*) > 1;
create table Orders_Clean as
select distinct *
from Orders_dirty;

-- Q38 Trim leading/trailing whitespace from CustomerName
update Orders_dirty
set CustomerName = TRIM(CustomerName)
where CustomerName <> TRIM(CustomerName);
/*Q39 Standardize Category values so "electronics", "ELECTRONICS", and "Electronics" are all treated
as one value.*/

select
    Category,
    COUNT(*) as TotalOrders
FROM Orders_dirty
GROUP BY Category;

update Orders_dirty
set Category = 'Electronics'
where LOWER(TRIM(Category)) = 'electronics';

-- Q40 Find and fix the misspelled category "Electroncs" (should be "Electronics")
select *
from Orders_dirty
where LOWER(TRIM(Category)) = 'electroncs';

update Orders_dirty
set Category = 'Electronics'
where LOWER(TRIM(Category)) = 'electroncs';
select *
from Orders_dirty;
/* Q41 Find rows where Quantity is missing or the text 'NULL', and decide how to handle them (e.g. set
to 1 or exclude).*/

select *
from Orders_dirty
where Quantity IS NULL
   or UPPER(TRIM(Quantity)) = 'NULL'
   or TRIM(Quantity) = '';
-- Q42  Find rows where Price is negative or zero — these are invalid; write a query to flag them.
select *
from Orders_dirty
where unitPrice <= 0;

-- Q44 Find rows where Category is blank/empty and decide on a default value
select *
from Orders_dirty
where Category is null
   or TRIM(Category) = '';
-- Q45 Join Orders to Customers to show each order alongside the customer’s City and LoyaltyTier.

select
    O.OrderID,
    O.CustomerID,
    O.Product,
    O.Category,
    O.Quantity,
    O.unitPrice,
    O.OrderDate,
    C.City,
    C.LoyaltyTier
from Orders_dirty as O
join Customers as C
    on O.CustomerID = C.CustomerID;

-- Q46 Find all customers who have never placed an order (LEFT JOIN + IS NULL)

select
    C.CustomerID,
    C.CustomerName,
    C.City,
    C.Email,
    C.LoyaltyTier
from Customers as C
left join Orders_dirty as O
    on C.CustomerID = O.CustomerID
where O.OrderID is null;

-- Q47 Find all orders placed by customers with a Gold loyalty tier

select
    O.OrderID,
    O.CustomerID,
    C.CustomerName,
    O.Product,
    O.Category,
    O.Quantity,
    O.unitPrice,
    O.OrderDate,
    C.City,
    C.LoyaltyTier
from Orders_dirty as O
inner join Customers as C
    on O.CustomerID = C.CustomerID
where C.LoyaltyTier = 'Gold';

-- Q48 Use an INNER JOIN to show total revenue per city

select
    C.City,
    SUM(O.Quantity * O.unitPrice) as TotalRevenue
from Orders_dirty as O
inner join Customers as C
    on O.CustomerID = C.CustomerID
group by C.City
order by TotalRevenue desc;

/*Q49 Use a LEFT JOIN to list every customer and their total number of orders, including customers
with zero orders.*/

select
    C.CustomerID,
    C.CustomerName,
    C.City,
    C.LoyaltyTier,
    COUNT(O.OrderID) as TotalOrders
from Customers as C
left join Orders_dirty as O
    on C.CustomerID = O.CustomerID
group by
    C.CustomerID,
    C.CustomerName,
    C.City,
    C.LoyaltyTier
order by TotalOrders desc;

/* Q50 Find customers whose Email is missing, then show whether they’ve placed any orders (JOIN +
data cleaning combined)*/

select
C.CustomerID,
    C.CustomerName,
    C.City,
    C.Email,
    case
        when COUNT(O.OrderID) > 0 then 'Has Placed Orders'
        else 'No Orders'
    end as OrderStatus,
    COUNT(O.OrderID) as TotalOrders
from Customers AS C
left join Orders_dirty as O
    on C.CustomerID = O.CustomerID
where C.Email is null
   or TRIM(C.Email) = ''
group by
    C.CustomerID,
    C.CustomerName,
    C.City,
    C.Email;
    
select
    CustomerID,
    CustomerName,
    City,
    Email,
    LoyaltyTier
from Customers
where Email is null
   or TRIM(Email) = '';
   
/*Q51 Combine Orders and Orders_Store2 into a single result set of all orders from both stores using
UNION.*/

select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    Category,
    Quantity,
    UnitPrice,
    OrderDate
from orders_dirty

union

select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    Category,
    Quantity,
    Price,
    OrderDate
from Orders_Store2;

-- Q52 Combine both tables using UNION ALL and explain the difference in results vs. question 51

select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    Category,
    Quantity,
    unitPrice,
    OrderDate
from Orders_dirty

union all

select
    OrderID,
    CustomerID,
    CustomerName,
    Product,
    Category,
    Quantity,
    Price,
    OrderDate
from Orders_Store2;
-- union remove duplicate, wihle
-- union all dont remove duplicate
-- union Usually slower because it removes duplicates
-- union all Usually faster because it retains all rows

/* Q53 Find customers who appear in both Orders and Orders_Store2 (hint: INTERSECT, or UNION +
GROUP BY ... HAVING COUNT(*) > 1)*/

-- Q54  Find products that were sold in Orders_Store2 but never in the original Orders table.

select distinct
    os.Product
from Orders_Store2 as os
where not exists (
    select 1
    from orders_dirty AS od
    WHERE od.Product = os.Product
);

-- Q55  Combine both order tables and compute total combined revenue per category

select
    Category,
    SUM(Quantity * unitPrice) as TotalRevenue
from (
    select
        Category,
        Quantity,
        UnitPrice
    from orders_dirty

    union all

    select
        Category,
        Quantity,
        Price
    from Orders_Store2
) as CombinedOrders
group by Category
order by TotalRevenue desc;







   

   
   














































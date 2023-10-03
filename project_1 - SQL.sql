-- Check dữ liệu null
select * from [Order]
WHERE Row_ID is NULL
    OR Order_ID is NULL
    or Order_Date is NULL
    or Ship_Date is NULL
    or Ship_Mode is NULL
    or Customer_ID is NULL
    or Customer_Name is NULL
    or Segment is NULL
    or Country is NULL
    or City is NULL
    or [State] is NULL
    or Postal_Code is NULL
    or Region is NULL
    or Product_ID is NULL
    or Product_Name is NULL
    or Sub_Category is NULL
    or Category is NULL
    or Quantity is NULL
    or Sales is NULL
    or Profit is NULL

--  Đối chiếu số lượng customer ID và Customer Name
select 
    COUNT(distinct Customer_ID) as Number_of_CustomerID, 
    COUNT(distinct Customer_Name) as Number_of_CustomerName
from [Order]

--  Đối chiếu số lượng Product ID và Product Name
SELECT 
    COUNT(distinct Product_ID) as Number_of_ProductID, 
    COUNT(distinct Product_Name) as Number_of_ProductName
FROM [Order]

-- Tạo table Customer
DROP TABLE IF EXISTS Customer
select 
    distinct O1.Customer_ID,
    O2.Customer_Name,
    O2.Segment
into Customer
from [Order] O1 join [Order] O2 on O1.Customer_ID = O2.Customer_ID

select * from Customer


-- Tạo table Product
DROP TABLE IF EXISTS Product

select 
    upper(concat(
        LEFT(Category, 3),
        '-',
        LEFT(Sub_category,3),
        '-',
        (10000000 + ROW_NUMBER() OVER(order by Product_Name)) -- Tạo Product ID
        )) as Product_ID_N,
    Product_name,
    Category,
    sub_category
Into Product
FROM 
    (
    select 
        distinct O1.Product_Name,
        O2.Category,
        O2.Sub_Category
    from [Order] O1 join [Order] O2 on O1.Product_ID = O2.Product_ID
    ) as temp

select * from Product


-- Tạo table Address
DROP TABLE IF EXISTS Address
select 
    distinct UPPER(CONCAT(LEFT(City,2),'-',Postal_Code)) AS Add_ID, -- tạo Address Id dựa vào City và Postal code
    City,
    Postal_Code,
    State,
    Region
Into Address
From [Order]

select * from Address

-- Tạo tablr "Order_F" dựa trên table Order cũ, liên kết Order_F với các table vừa tạo
DROP TABLE IF EXISTS Order_N
Select 
    O.Row_ID,
    O.Order_ID,
    O.Order_Date,
    O.Ship_Date,
    O.Ship_Mode,
    O.Customer_ID,
    P.Product_ID_N,
    A.Add_ID,
    O.Quantity,
    O.Sales,
    O.Profit
Into Order_N
From [Order] O JOIN Product P on O.Product_Name = P.Product_Name
                Join Address A on O.City = A.City
                               and O.Postal_Code = A.Postal_Code

SELECT * from Address

SELECT * from Order_N

select YEAR(Order_Date), COUNT(distinct customer_id )
from Order_N
group by YEAR(Order_Date)

-- Tạo table Number of Customer by State

SELECT 
    a.state,
    COUNT(distinct o.customer_ID) as Number_of_Customer
FROM Address a JOIN Order_N o on a.Add_ID = o.Add_ID
group by a.state
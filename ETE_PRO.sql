CREATE TABLE IF NOT EXISTS DiscountData(
    Month VARCHAR(50),
    Discount_Band VARCHAR(50),
    Discount int
);
DROP TABLE Products;
CREATE TABLE IF NOT EXISTS Products (
    product_id      VARCHAR(50),
    product         VARCHAR(50),
    category        VARCHAR(50),
    cost_price     NUMERIC,
    sale_price     NUMERIC,
    brand           VARCHAR(50),
    description     TEXT,
    image_url       VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS SalesData (
    date            DATE,
    customer_type   VARCHAR(50),
    country         VARCHAR(50),
    product         VARCHAR(50),
    discount_band   VARCHAR(50),
    units_sold      INT
);

SELECT * FROM discountdata;
SELECT * FROM salesdata;
SELECT * FROM products;

COPY  
FROM ''
CSV HEADER;

COPY products(product_id,product,category,cost_price,sale_price,brand,description,image_url) 
FROM 'C:\Users\Hp\OneDrive\Desktop(1)\SQL\ETE Project\Product_data.csv'
WITH (FORMAT csv, ENCODING 'WIN1252', HEADER true);

WITH CTE AS(
SELECT                          -- We wrote all the name for the common values to use a disngle table and apply CTE so we can join to the 3rd table easily
p.product,
p.category,
p.brand,
p.description,
p.cost_price,
p.sale_price,
p.image_url,
s.date,
s.customer_type,
s.discount_band,
s.units_sold,
s.country,
         (p.sale_price*units_sold) AS Revenue,
         (p.cost_price*units_sold) AS Total_cost,
TO_CHAR(s.date,'MON') AS Month,
TO_CHAR(s.date,'YYYY') AS Year
FROM products p
JOIN salesdata s
ON p.product_id=s.product
)

SELECT *,
(1 - discount*0.1/100) * revenue AS discount_revenue
FROM CTE c
JOIN discountdata d
ON TRIM(LOWER(c.discount_band)) = TRIM(LOWER(d.discount_band));



WITH CTE AS (                       ---FOR POWER BI:((
    SELECT                         
        p.product,
        p.category,
        p.brand,
        p.description,
        p.cost_price,
        p.sale_price,
        p.image_url,
        s.date,
        s.customer_type,
        s.discount_band AS sale_discount_band,  -- alias here
        s.units_sold,
        s.country,
        (p.sale_price*units_sold) AS revenue,
        (p.cost_price*units_sold) AS total_cost,
        TO_CHAR(s.date,'MON') AS month,
        TO_CHAR(s.date,'YYYY') AS year
    FROM products p
    JOIN salesdata s
    ON p.product_id = s.product
)
SELECT
    c.product,
    c.category,
    c.brand,
    c.description,
    c.cost_price,
    c.sale_price,
    c.image_url,
    c.date,
    c.customer_type,
    c.sale_discount_band,
    c.units_sold,
    c.country,
    c.revenue,
    c.total_cost,
    c.month,
    c.year,
    d.discount,
    (1 - d.discount*0.1/100) * c.revenue AS discount_revenue
FROM CTE c
JOIN discountdata d
ON TRIM(LOWER(c.sale_discount_band)) = TRIM(LOWER(d.discount_band));







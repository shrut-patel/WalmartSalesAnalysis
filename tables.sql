CREATE DATABASE IF NOT EXISTS salesDataWalmart;

-- creating the table sales 
CREATE TABLE IF NOT EXISTS sales (
		invoice_id varchar(30) NOT NULL PRIMARY KEY,
        branch VARCHAR(5) NOT NULL,
        city VARCHAR(30) NOT NULL,
		customer_type VARCHAR(30) NOT NULL,
        gender VARCHAR(10) NOT NULL,
        product_line VARCHAR(100) NOT NULL,
        unit_price DECIMAL(10 , 2) NOT NULL,
        quantity INT NOT NULL,
        VAT FLOAT(6,4) NOT NULL,
        total DECIMAL(12,4) NOT NULL,
        date DATETIME NOT NULL,
        time TIME NOT NULL,
        payment_method VARCHAR(15) NOT NULL,
        cogs DECIMAL(10,2) NOT NULL,
        gross_margin_pct FLOAT(11,9),
        gross_income DECIMAL(12,4) NOT NULL,
        rating FLOAT(2,1) 

);

-- fixing some of the columns  
ALTER TABLE sales
RENAME COLUMN customer_TYPE TO customer_type,
RENAME COLUMN date TO sale_date,
MODIFY COLUMN VAT DECIMAL(6,4) NOT NULL,
MODIFY COLUMN gross_margin_pct DECIMAL(5,4),
ADD CONSTRAINT chk_rating CHECK (rating BETWEEN 0 AND 10);



-- ---------------------------------------------------------------------------------------------------------
-- ---------------------------------- Feature Engineering --------------------------------------------------

-- time_of_day 

SELECT 
	time,
    (CASE 
		WHEN `time` between "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` between "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
        ) AS time_of_day
FROM sales;

-- lets enter the new column inside the original table 
ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(15);

UPDATE  sales 
SET time_of_day = (
    CASE 
		WHEN `time` between "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` between "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);


-- day_name 

SELECT 
	sale_date,
    DAYNAME(sale_date) AS day_name
FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET day_name = (
			DAYNAME(sale_date)
);


-- month_name 

SELECT 
	sale_date,
    MONTHNAME(sale_date) AS month_name 
FROM sales;

ALTER TABLE sales 
ADD COLUMN month_name VARCHAR(10);

UPDATE sales 
SET month_name = (
				MONTHNAME(sale_date)
);

-- --------------------------------------------------------------------------------------------------------------
-- -------------------------------------------- Generic ---------------------------------------------------------

-- how many unique cities does the data have 

SELECT 
	DISTINCT city
FROM sales;

SELECT 
	DISTINCT branch
FROM sales;

-- Which city contain which branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;



-- -----------------------------------------------------------------------------------------------------------
-- -------------------------------------------- Product ------------------------------------------------------


-- 1. How many unique product lines does the data have?

SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

-- 2.What is the most common payment method?

SELECT 
	payment_method,
	COUNT(payment_method) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC
LIMIT 1 ;

-- 3.What is the most selling product line?
SELECT 
	product_line,
	COUNT( product_line ) AS prd_count
FROM sales 
GROUP BY product_line
ORDER BY prd_count DESC
LIMIT 1 ;

-- 4.What is the total revenue by month?
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5.What month had the largest COGS?

SELECT month_name ,
		SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs;

-- 6.What product line had the largest revenue?

SELECT 
	product_line,
    SUM(total) AS total_revenue 
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 7.What is the city with the largest revenue?

SELECT 
	city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;


-- 8.What product line had the largest VAT?

select product_line,
		AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line 
ORDER BY avg_tax ASC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
    product_line,
    SUM(total) AS total_sales,
    CASE 
        WHEN SUM(total) > (SELECT AVG(total_sales) FROM (
            SELECT SUM(total) AS total_sales
            FROM sales
            GROUP BY product_line
        ) AS avg_subquery)
        THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM sales
GROUP BY product_line
ORDER BY product_line;

-- 10.Which branch sold more products than average product sold?

SELECT 
		branch,
        SUM(quantity) as total_quantity
FROM sales 
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11.What is the most common product line by gender?

SELECT gender,
		product_line,
	   COUNT(product_line) AS cnt
FROM sales
GROUP BY gender, product_line
ORDER BY cnt DESC;


-- 12. What is the average rating of each product line?

SELECT product_line,
		AVG(rating) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating;


-- -------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------- Sales --------------------------------------------------------

-- 1. Number of sales made in each time of the day per weekday 

SELECT 
	time_of_day,
    COUNT(*) as total_sales
FROM  sales 
WHERE day_name = 'Monday'  -- enter the day of which you want the ouyput
GROUP BY time_of_day
ORDER BY total_sales;

-- 2. Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    SUM(total) as total_revenue 
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC ;

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city,
		SUM(VAT) AS total_tax
FROM sales 
GROUP BY city 
ORDER BY total_tax DESC;

-- 4.Which customer type pays the most in VAT?

SELECT customer_type,
		SUM(VAT) AS total_tax
FROM sales 
GROUP BY customer_type
ORDER BY total_tax DESC;


-- --------------------------------------------------------------------------------------------------------
-- ------------------------------------- Customer ---------------------------------------------------------

-- 1.How many unique customer types does the data have?

SELECT 
		DISTINCT customer_type,
		COUNT(*) as total_cust
FROM sales
GROUP BY customer_type
ORDER BY total_cust DESC;


-- 2.How many unique payment methods does the data have and thier respective count?

SELECT 
	DISTINCT payment_method,
    COUNT(*) as total_cnt
FROM sales
GROUP BY payment_method
ORDER BY total_cnt DESC ;

-- 3.Does higher rating correlate with higher spending?

SELECT 
  CASE 
    WHEN rating >= 8 THEN 'High'
    WHEN rating BETWEEN 5 AND 7 THEN 'Medium'
    ELSE 'Low'
  END AS rating_category,
  AVG(total) AS avg_spending
FROM sales
GROUP BY rating_category
ORDER BY avg_spending DESC;

-- 4.Find the busiest hour for each branch?

SELECT 
		branch, 
        HOUR(time) AS hour_of_day, 
        COUNT(*) AS total_sales
FROM sales
GROUP BY branch, hour_of_day
ORDER BY branch, total_sales DESC;

-- 5. Compare daily total sales between consecutive days?

SELECT  
    t1.sale_date AS curr_date,
    t2.sale_date AS next_date,
    t1.total_sales AS current_day_sales,
    t2.total_sales AS next_day_sales,
    (t2.total_sales - t1.total_sales) AS sales_growth
FROM (
    SELECT sale_date, SUM(total) AS total_sales
    FROM sales
    GROUP BY sale_date
) AS t1
JOIN (
    SELECT sale_date, SUM(total) AS total_sales
    FROM salesdatawalmart.sales
    GROUP BY sale_date
) AS t2
ON t1.sale_date = DATE_SUB(t2.sale_date, INTERVAL 1 DAY)
ORDER BY t1.sale_date;

-- 6.Which branch has the most consistent daily revenue (lowest variation)?

SELECT 
    branch,
    ROUND(STDDEV(daily_total), 2) AS daily_sales_stddev
FROM (
    SELECT 
        branch,
        sale_date,
        SUM(total) AS daily_total
    FROM salesdatawalmart.sales
    GROUP BY branch, sale_date
) AS daily_sales
GROUP BY branch
ORDER BY daily_sales_stddev ASC;


-- 7. which customer type is more likely to shop multiple times a day?

SELECT 
    customer_type,
    COUNT(DISTINCT sale_date)*100 / COUNT(DISTINCT invoice_id) AS repeat_pct
FROM sales
GROUP BY customer_type;

-- 8.Find total VAT collected per branch?

SELECT 
		branch,
        SUM(VAT) AS total_vat
FROM sales 
GROUP BY branch 
ORDER BY total_vat;

-- 9. Identify branches with above-average daily sales?

WITH daily_branch_sales AS (
  SELECT branch, sale_date, SUM(total) AS total_sales
  FROM sales
  GROUP BY branch, sale_date
)
SELECT branch, ROUND(AVG(total_sales) ,2) AS avg_daily_sales
FROM daily_branch_sales
GROUP BY branch
HAVING AVG(total_sales) > (SELECT AVG(total_sales) FROM daily_branch_sales);










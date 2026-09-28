# 🛍️ Sales Data Analysis Walmart 

## 📖 Overview
This project performs an in-depth analysis of retail sales data using SQL.  
The goal is to extract **business insights** related to customer behavior, sales trends, and performance across branches — similar to what a company like **Meesho or Walmart** would track.

The project explores **sales growth, customer types, payment modes, and time-based purchasing patterns** using real-world structured SQL queries.

---

## 🧠 Objectives
- Analyze **customer behavior** and identify key purchasing trends.
- Compare **sales performance** across branches and time periods.
- Evaluate **payment preferences** and customer demographics.
- Study **daily/weekly growth** and time-based sales insights.
- Develop **resume-ready, business-oriented SQL case studies**.

---

## 🗃️ Dataset Information
| Column Name       | Description                            |
|--------------------|----------------------------------------|
| `Invoice_ID`       | Unique identifier for each transaction |
| `Branch`           | Store branch (A, B, or C)              |
| `City`             | City where the branch is located       |
| `Customer_Type`    | Type of customer (Member / Normal)     |
| `Gender`           | Gender of the customer                 |
| `Product_Line`     | Category of the purchased product      |
| `Unit_Price`       | Price per unit                         |
| `Quantity`         | Number of units purchased              |
| `Tax_5%`           | Tax applied on the total amount        |
| `Total`            | Total bill amount                      |
| `Date`             | Date of purchase                       |
| `Time`             | Time of purchase                       |
| `Payment`          | Payment method used                    |
| `cogs`             | Cost of goods sold                     |
| `gross_margin%`    | Gross margin percentage                |
| `gross_income`     | Gross profit                           |
| `Rating`           | Customer rating (out of 10)            |

---

## 🧩 Key SQL Analyses Performed

### 🧍 Customer Insights
- How many unique customer types are there?  
- What is the most common customer type?  
- Which customer type buys the most?  
- What is the gender distribution overall and per branch?

### 💳 Payment & Transaction Analysis
- How many unique payment methods exist?  
- Which payment method is most used by customers?  
- Is there a relation between customer type and payment preference?

### ⏰ Time-based Insights
- Which time of day sees the most sales?  
- Which time of the day do customers give the most ratings?  
- Average ratings and sales per **day of week**.  
- Which day has the **highest average ratings** per branch?  
- Calculate **daily sales growth** using self-join:
  ```sql
  SELECT 
      t1.sale_date AS current_date,
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
      FROM sales
      GROUP BY sale_date
  ) AS t2
  ON t1.sale_date = DATE_SUB(t2.sale_date, INTERVAL 1 DAY)
  ORDER BY t1.sale_date;


# 🚀 Data Analyst Internship - Task 6: Sales Trend Analysis

## 🎯 Objective
The primary goal of this task was to perform a sales trend analysis using SQL aggregation functions. [cite_start]Specifically, I calculated the **monthly revenue** and **order volume** and then identified the **top 3 months** by revenue[cite: 4].

## 🛠️ Tools & Dataset
* **Database:** MySQL
* **Dataset:** `online_sales_orders` table (from the `online_retail_II` database).

## 📊 Key SQL Queries & Results

### 1. Monthly Revenue, Order Volume, and MoM Growth

[cite_start]This analysis involved calculating total revenue (`SUM(Quantity * Price)`) and total distinct orders (`COUNT(DISTINCT Invoice)`) grouped by `sales_month_year`[cite: 9, 10, 11].

**Sample Results (Sales & Order Volume):**

| sales\_month\_year | monthly\_revenue | order\_volume |
| :--- | :--- | :--- |
| 2010-12 | 823,746.14 | 1,559 |
| 2011-01 | 691,364.56 | 1,086 |
| 2011-02 | 523,631.89 | 1,100 |

**Sample Results (Month-over-Month (MoM) Growth):**

| sales\_month\_year | current\_month\_revenue | mom\_growth\_percent |
| :--- | :--- | :--- |
| 2011-03 | 717,639.36 | **37.05** |
| 2011-05 | 770,536.02 | **43.27** |

### 2. Identifying the Top 3 Months by Revenue

[cite_start]To find the top-performing months[cite: 24], I used a Common Table Expression (CTE) and the **DENSE\_RANK()** window function, ordering the monthly revenue in descending order.

**Top 3 Months Results:**

| sales\_month\_year | monthly\_revenue | sales\_rank |
| :--- | :--- | :--- |
| **2011-11** | 1,509,496.3300 | 1 |
| **2011-10** | 1,154,979.3000 | 2 |
| **2011-09** | 1,058,590.1720 | 3 |

## ✨ Conclusion

[cite_start]The analysis clearly shows a significant sales trend, with the peak performance occurring in **November 2011**[cite: 16]. This exercise demonstrated proficiency in:
* [cite_start]Grouping data by year and month[cite: 9, 18].
* [cite_start]Calculating key aggregate metrics like Revenue (SUM()) and Order Volume (COUNT(DISTINCT))[cite: 10, 11, 19, 21].
* [cite_start]Applying Window Functions (`DENSE_RANK` and `LAG`) for advanced ranking and percentage change calculations[cite: 24].

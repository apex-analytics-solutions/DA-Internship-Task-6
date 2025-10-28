-- TASK 6: SALES TREND ANALYSIS USING AGGREGATIONS

-- --------------------------------------------------------------------------------------
-- 1. DATA CLEANING & INITIAL CHECKS (Queries 58-60 from previous steps)
-- --------------------------------------------------------------------------------------

-- 1.1. Count total canceled orders (Invoices starting with 'C')
SELECT COUNT(*)
FROM online_sales_orders
WHERE Invoice LIKE 'C%';
-- Result: 9288

-- 1.2. Count total distinct invoices (Used for cancellation rate calculation)
SELECT COUNT(DISTINCT Invoice) AS total_invoices
FROM online_sales_orders;
-- Result: 25900

-- 1.3. Check for non-canceled transactions with NULL Customer ID (Should ideally be 0)
SELECT COUNT(*)
FROM online_sales_orders
WHERE `Customer ID` IS NULL
  AND Invoice NOT LIKE 'C%';
-- Result: 0


-- --------------------------------------------------------------------------------------
-- 2. CORE TREND ANALYSIS: Monthly Revenue and Order Volume (Query 61-71)
-- --------------------------------------------------------------------------------------

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month_year,
    SUM(Quantity * Price) AS monthly_revenue,
    COUNT(DISTINCT Invoice) AS order_volume
FROM online_sales_orders
WHERE
    -- Filter out cancelled orders
    Invoice NOT LIKE 'C%'
    -- Filter out negative/zero quantities and prices (valid sales only)
    AND Quantity > 0
    AND Price > 0
    AND InvoiceDate IS NOT NULL
GROUP BY
    sales_month_year
ORDER BY
    sales_month_year ASC;


-- --------------------------------------------------------------------------------------
-- 3. ADVANCED ANALYSIS: Month-over-Month (MoM) Growth (Query using LAG window function)
-- --------------------------------------------------------------------------------------

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month_year,
        SUM(Quantity * Price) AS current_month_revenue
    FROM online_sales_orders
    WHERE
        Invoice NOT LIKE 'C%'
        AND Quantity > 0
        AND Price > 0
    GROUP BY
        sales_month_year
)
SELECT
    sales_month_year,
    current_month_revenue,
    -- Get revenue from the previous month
    LAG(current_month_revenue, 1) OVER (ORDER BY sales_month_year) AS previous_month_revenue,
    -- Calculate MoM Growth Percentage: ((Current - Previous) / Previous) * 100
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY sales_month_year)) /
        NULLIF(LAG(current_month_revenue, 1) OVER (ORDER BY sales_month_year), 0)) * 100,
        2
    ) AS mom_growth_percent
FROM
    MonthlySales
ORDER BY
    sales_month_year ASC;


-- --------------------------------------------------------------------------------------
-- 4. BUSINESS METRICS: Average Basket Size (Query 96-105)
-- --------------------------------------------------------------------------------------

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month_year,
    -- Average Basket Size: Total Items Sold / Total Orders
    ROUND(
        (SUM(Quantity) / COUNT(DISTINCT Invoice)),
        2
    ) AS average_basket_size
FROM online_sales_orders
WHERE
    Invoice NOT LIKE 'C%'
    AND Quantity > 0
GROUP BY
    sales_month_year
ORDER BY
    sales_month_year ASC;


-- --------------------------------------------------------------------------------------
-- 5. BUSINESS METRICS: Cancellation Rate (Query using CASE statements)
-- --------------------------------------------------------------------------------------

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month_year,
    COUNT(DISTINCT Invoice) AS total_transactions,
    COUNT(DISTINCT CASE WHEN Invoice LIKE 'C%' THEN Invoice END) AS cancelled_orders,
    -- Cancellation Rate: (Cancelled Orders / Total Transactions) * 100
    ROUND(
        (
            CAST(COUNT(DISTINCT CASE WHEN Invoice LIKE 'C%' THEN Invoice END) AS DECIMAL) * 100
        ) /
        NULLIF(COUNT(DISTINCT Invoice), 0),
        2
    ) AS cancellation_rate_percent
FROM
    online_sales_orders
WHERE
    InvoiceDate IS NOT NULL
GROUP BY
    sales_month_year
ORDER BY
    sales_month_year ASC;


-- --------------------------------------------------------------------------------------
-- 6. TASK REQUIREMENT: Top 3 Months by Revenue (Query using DENSE_RANK)
-- --------------------------------------------------------------------------------------

WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month_year,
        SUM(Quantity * Price) AS monthly_revenue
    FROM
        online_sales_orders
    WHERE
        Invoice NOT LIKE 'C%' AND Quantity > 0 AND Price > 0
    GROUP BY
        sales_month_year
),
RankedSales AS (
    SELECT
        sales_month_year,
        monthly_revenue,
        -- Rank the months based on revenue (highest is rank 1)
        DENSE_RANK() OVER (ORDER BY monthly_revenue DESC) AS sales_rank
    FROM
        MonthlyRevenue
)
SELECT
    sales_month_year,
    monthly_revenue,
    sales_rank
FROM
    RankedSales
WHERE
    sales_rank <= 3
ORDER BY
    sales_rank ASC;


-- --------------------------------------------------------------------------------------
-- 7. ADDITIONAL INSIGHTS: Top 5 Countries by Revenue (Query 161-171)
-- --------------------------------------------------------------------------------------

SELECT
    Country,
    SUM(Quantity * Price) AS country_revenue,
    COUNT(DISTINCT Invoice) AS country_order_volume
FROM
    online_sales_orders
WHERE
    Invoice NOT LIKE 'C%' AND Quantity > 0
GROUP BY
    Country
ORDER BY
    country_revenue DESC
LIMIT 5;


-- --------------------------------------------------------------------------------------
-- 8. ADDITIONAL INSIGHTS: Hourly Sales Trend (Query 173-183)
-- --------------------------------------------------------------------------------------

SELECT
    EXTRACT(HOUR FROM InvoiceDate) AS sales_hour,
    SUM(Quantity * Price) AS hourly_revenue,
    COUNT(DISTINCT Invoice) AS hourly_orders
FROM
    online_sales_orders
WHERE
    Invoice NOT LIKE 'C%' AND Quantity > 0
GROUP BY
    sales_hour
ORDER BY
    sales_hour ASC;
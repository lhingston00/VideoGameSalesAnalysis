/*
File: 01_videogames_sales_analysis.sql
Purpose: Analyse total and average sales by platform
Dataset: videogames_sales_data
Notes:
- Sales columns (NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales) are in MILLIONS of copies sold
- Global_Sales = sum of regional sales
*/


-- 1. Showing all video game sales data
-- Useful to inspect the full dataset and verify structure
SELECT * FROM videogames_sales_data

-- 2. Showing the top 10 best-selling games globally
-- Identifies high-impact titles driving the market
SELECT TOP 10 Name, Global_Sales
FROM videogames_sales_data
ORDER BY Global_Sales DESC

-- 3. Showing total global sales grouped by platform
-- Shows which platforms dominate total sales
SELECT Platform, SUM(Global_Sales) AS TotalSales
FROM videogames_sales_data
GROUP BY Platform
ORDER BY TotalSales DESC;

-- 4. Number of games released each year
-- Helps analyse release trends over time
SELECT YEAR, COUNT(*) AS GamesReleased
FROM videogames_sales_data
GROUP BY YEAR
ORDER BY YEAR;

-- 5. Count games with missing or zero year values
-- Important for data cleaning and identifying incomplete records
SELECT ISNULL(Year, 0) AS Year, COUNT(*)
FROM videogames_sales_data
GROUP BY ISNULL(Year, 0)
ORDER BY Year;

-- 6. Finding high-selling games with missing year values
-- Helps identify important titles that lack complete release data
SELECT Name, Platform, Publisher, Global_Sales
FROM videogames_sales_data
WHERE Year IS NULL OR Year = 0
ORDER BY Global_Sales DESC;

-- 7. Showing average regional sales for each genre
-- Shows which genres perform best in different markets
SELECT Genre,
AVG(NA_Sales) AS Avg_NA_Sales,
AVG(EU_Sales) AS Avg_EU_Sales,
AVG(JP_Sales) AS Avg_JP_Sales
FROM videogames_sales_data
GROUP BY Genre;

-- 8. Showing top 10  publishers ranked by total global sales
-- Highlights leading companies in the video game market
SELECT TOP 10 Publisher, SUM(Global_Sales) as TotalSales
FROM videogames_sales_data
GROUP BY Publisher
ORDER BY TotalSales DESC

-- 9. Total and average sales by region per platform
-- Useful for platform-level market analysis
SELECT
Platform,
SUM(NA_Sales) AS Total_NA_Sales,
SUM(EU_Sales) AS Total_EU_Sales,
SUM(JP_Sales) AS Total_JP_Sales,
SUM(Other_Sales) AS Total_Other_Sales,
SUM(Global_Sales) AS Total_Global_Sales,
AVG(Global_Sales) AS Avg_Global_Sales
FROM videogames_sales_data
GROUP BY Platform
ORDER BY Total_Global_Sales DESC;

-- 10. Top selling genres per region
-- Identify genre preferences across markets
SELECT
Genre,
SUM(NA_Sales) AS Total_NA_Sales,
SUM(EU_Sales) AS Total_EU_Sales,
SUM(JP_Sales) AS Total_JP_Sales
FROM videogames_sales_data
GROUP BY Genre
ORDER BY Total_NA_Sales DESC;

-- 11. Yearly trend in global sales
-- Understand sales evolution and identify growth periods
SELECT
Year,
SUM(Global_Sales) AS Total_Global_Sales,
AVG(Global_Sales) AS Avg_Global_Sales_Per_Game
FROM videogames_sales_data
WHERE Year IS NOT NULL
GROUP BY [Year]
ORDER BY Year;

-- 12. Cumulative total global sales per year
-- Shows how total sales accumulate over time
SELECT
SUM(Global_Sales) AS Total_Global_Sales,
AVG(Global_Sales) AS Avg_Global_Sales_Per_Game,
SUM(SUM(Global_Sales)) OVER (ORDER BY Year) AS Cumulative_Global_Sales
FROM videogames_sales_data
WHERE Year IS NOT NULL
GROUP BY [Year]
ORDER BY Year;

-- 13. Year-over-year (YoY) global sales change
-- Measures growth or decline in sales year-to-year
WITH YearlySales AS (
SELECT
Year,
SUM(Global_Sales) AS Total_Global_Sales
FROM videogames_sales_data
WHERE Year IS NOT NULL
GROUP BY [Year]
)
SELECT
Year,
Total_Global_Sales,
LAG(Total_Global_Sales) OVER (ORDER BY Year) AS Prev_Year_Sales,
Total_Global_Sales - LAG(Total_Global_Sales) OVER (ORDER BY Year) AS YoY_Change,
ROUND(
(Total_Global_Sales - LAG(Total_Global_Sales) OVER (ORDER BY Year))
/ NULLIF(LAG(Total_Global_Sales) OVER (ORDER BY Year), 0) * 100,
2
) AS YoY_Percentage_Change
FROM YearlySales
ORDER BY Year;

-- 14. Regional market share percentages
-- Shows the contribution of each region to global sales
SELECT
SUM(NA_Sales) AS NA_Sales,
SUM(EU_Sales) AS EU_Sales,
SUM(JP_Sales) AS JP_Sales,
SUM(Other_Sales) AS Other_Sales,
SUM(Global_Sales) AS Global_Sales,
ROUND(SUM(NA_Sales) / SUM(Global_Sales) * 100, 2) AS NA_Percent,
ROUND(SUM(EU_Sales) / SUM(Global_Sales) * 100, 2) AS EU_Percent,
ROUND(SUM(JP_Sales) / SUM(Global_Sales) * 100, 2) AS JP_Percent,
ROUND(SUM(Other_Sales) / SUM(Global_Sales) * 100, 2) AS Other_Percent
FROM videogames_sales_data
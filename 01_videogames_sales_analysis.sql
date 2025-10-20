/*
File: 01_videogames_sales_analysis.sql
Purpose: Analyse total and average sales by platform
Dataset: videogames_sales_data
Notes:
- Sales columns (NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales) are in MILLIONS of copies sold
- Global_Sales = sum of regional sales
- Year may contain NULLS or zeros
*/

-- SECTION 1: DATA CLEANING & VALIDATION

-- 1.1 Check basic dataset structure
SELECT TOP 5 * FROM videogames_sales_data;

-- 1.2 Identify missing or invalid year values
SELECT
ISNULL(Year, 0) AS Year_Value,
COUNT(*) AS Count_Records
FROM videogames_sales_data
GROUP BY ISNULL(Year, 0)
ORDER BY Year_Value;

-- 1.3 Check for duplicate game titles
SELECT
Name,
Platform,
COUNT(*) AS Duplicate_Count
FROM videogames_sales_data
GROUP BY Name, Platform
HAVING COUNT(*) > 1;

-- 1.4 Validate Global_Sales equals sum of regional sales
SELECT
Name,
Platform,
NA_Sales + EU_Sales + JP_Sales + Other_Sales AS Regional_Sum,
Global_Sales,
ROUND(Global_Sales - (NA_Sales + EU_Sales + JP_Sales + Other_Sales), 2) AS DIFFERENCE
FROM videogames_sales_data
WHERE ROUND(Global_Sales, 2) <> ROUND(NA_Sales + EU_Sales + JP_Sales + Other_Sales, 2);

-- 1.5 Identify games with zero or missing sales
SELECT *
FROM videogames_sales_data
WHERE Global_Sales IS NULL OR Global_Sales = 0;

-- SECTION 2: CORE SALES ANALYSIS

-- 2.1 Top 10 best-selling games globally
-- Identifies high-impact titles driving the market
SELECT TOP 10 Name, Global_Sales
FROM videogames_sales_data
ORDER BY Global_Sales DESC;
/* Insights:
- Nintendo dominates the top 10, especially the Wii platform.
- Mario franchise games appear multiple times, demonstrating franchise strength.
- Classic games like Tetris and Super Mario Bros. have enduring popularity.
- This table indicates consumer preference trends and platform impact on sales.
*/

-- 2.2 Showing total global sales grouped by platform
-- Shows which platforms dominate total sales
SELECT Platform, SUM(Global_Sales) AS TotalSales
FROM videogames_sales_data
GROUP BY Platform
ORDER BY TotalSales DESC;
/* Insights:
- PS2 is the top-selling platform with 1.25 billion units sold globally.
- Xbox 360, PS3, and Wii follow closely, showing strong competition between Sony, Microsoft, and Nintendo.
- Nintendo dominates the portable console segment (DS, GBA, PSP, 3DS).
*/

-- 2.3 Number of games released each year
-- Helps analyse release trends over time
SELECT YEAR, COUNT(*) AS GamesReleased
FROM videogames_sales_data
GROUP BY YEAR
ORDER BY YEAR;
/* Insights:
- 1984-2009 saw rapid growth, peaking at 1,452 releases in 2009.
*/

-- 2.4 Finding high-selling games with missing year values
-- Helps identify important titles that lack complete release data
SELECT Name, Platform, Publisher, Global_Sales
FROM videogames_sales_data
WHERE Year IS NULL OR Year = 0
ORDER BY Global_Sales DESC;
/* Insights:
- High-selling games missing year data could indicate historical records.
- Missing/null data updated and patched to improve trend analysis results.
*/

-- 2.5 Showing average regional sales for each genre
-- Shows which genres perform best in different markets
SELECT Genre,
AVG(NA_Sales) AS Avg_NA_Sales,
AVG(EU_Sales) AS Avg_EU_Sales,
AVG(JP_Sales) AS Avg_JP_Sales
FROM videogames_sales_data
GROUP BY Genre;
/* Insights:
- Combat/Shooter games perform best in North America.
- Racing and Sports games are stronger genres in North America and Europe than Japan.
- Puzzle and Adventure genres are particularly popular in Japan.
*/

-- 2.6 Showing top 10  publishers ranked by total global sales
-- Highlights leading companies in the video game market
SELECT TOP 10 Publisher, SUM(Global_Sales) as TotalSales
FROM videogames_sales_data
GROUP BY Publisher
ORDER BY TotalSales DESC;
/* Insights:
- Nintendo leads with 1.79 billion game copies sold, followed by EA (1.11 billion) and Activision (727 million).
- Sony, Ubisoft, Take-Two, and others show strong market presence across platforms.
- Highlights market dominance by a number of publishers and the competitive landscape of the video game industry.
*/

-- 2.7 Total and average sales by region per platform
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
/* Insights:
- North American is the largest market for most platforms; Japan favours Nintendo consoles (DS, Wii, 3DS).
- Modern consoles (PS4, Xbox One) have lower total sales per game on average, likely due to more releases and diversified libraries.
Additional note: Next generation consoles (PS5, Nintendo Switch, Xbox Series X) are not fully represented; including them would improve analysis of current market trends.
*/

-- 2.8 Top selling genres per region
-- Identify genre preferences across markets
SELECT
Genre,
SUM(NA_Sales) AS Total_NA_Sales,
SUM(EU_Sales) AS Total_EU_Sales,
SUM(JP_Sales) AS Total_JP_Sales
FROM videogames_sales_data
GROUP BY Genre
ORDER BY Total_NA_Sales DESC;

-- 2.9 Yearly trend in global sales
-- Understand sales evolution and identify growth periods
SELECT
Year,
SUM(Global_Sales) AS Total_Global_Sales,
AVG(Global_Sales) AS Avg_Global_Sales_Per_Game
FROM videogames_sales_data
WHERE Year IS NOT NULL
GROUP BY [Year]
ORDER BY Year;
/* Insights:
Early Years (1977-1983):
- Total sales were very low, with few games contributing most of the sales.
- Average sales per game were relatively high for the few titles released.

Growth Period (1984-2008):
- Total global sales increased dramatically, peaking at 690M in 2008.
- Average per-game sales fluctuate, indicating a mix of blockbusters and smaller releases.
- Highlights the expansion of the video game industry and the impact of the popular consoles like the PS2, Wii, and DS.

Decline - Recent Years (1984-2008):
- Total and average sales drop sharply after 2015.
- Likely reflects dataset limitations (missing recent digital/mobile sales) or the rise of digital distribution platforms not included.
*/

-- 2.10 Cumulative total global sales per year
-- Shows how total sales accumulate over time
SELECT
SUM(Global_Sales) AS Total_Global_Sales,
AVG(Global_Sales) AS Avg_Global_Sales_Per_Game,
SUM(SUM(Global_Sales)) OVER (ORDER BY Year) AS Cumulative_Global_Sales
FROM videogames_sales_data
WHERE Year IS NOT NULL
GROUP BY [Year]
ORDER BY Year;
/* Insights:
- Cumulative sales steadily increase, reflecting long-term growth of the video game market.
- Early years contribute little; major growth occurs in the 1980s-2000s with console booms.
- Average per-game sales fluctuate, highlighting hit-driven years vs. high-volume years.
*/

-- 2.11 Year-over-year (YoY) global sales change
-- Measures growth or decline in sales year-to-year
WITH YearlySales AS (
SELECT
Year,
SUM(Global_Sales) AS Total_Global_Sales
FROM videogames_sales_data
WHERE Year IS NOT NULL
GROUP BY Year
)

SELECT
Year,
Total_Global_Sales,
LAG(Total_Global_Sales) OVER (ORDER BY Year) AS Prev_Year_Sales,
Total_Global_Sales - LAG(Total_Global_Sales) OVER (ORDER BY Year) AS YoY_Change,
ROUND(
CASE 

-- Only calculating % change if previous year sales >= 1M
WHEN LAG(Total_Global_Sales) OVER (ORDER BY Year) >= 1
THEN (Total_Global_Sales - LAG(Total_Global_Sales) OVER (ORDER BY Year))
/ LAG(Total_Global_Sales) OVER (ORDER BY Year) * 100
ELSE NULL
END, 2
) AS YoY_Percentage_Change
FROM YearlySales
ORDER BY Year;
/* Insights:
- Early years (1977-1983) have very low total sales.
YoY % is omitted for these years to avoid misleading spikes.
- Absolute growth (YoY_Change) is still meaningful for earlyyears.
- Mid-1980s to 2008 shows real trends: consistent growth aligned with console cycles.
- 2009-2017: Negative YoY indicates market saturation and decline of older platforms.
- 2019-2023: Dataset shows minimal sales; YoY % omitted where totals <1M.
*/

-- 2.12 Regional market share percentages
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
FROM videogames_sales_data;
/* Insight:
North America = 49% of global sales, Europe = 27%, Japan = 14%.
Indicates a Western-dominated market with niche strength in Japan.
*/


-- SECTION 3: BUSINESS INSIGHTS SUMMARY
/* 
1. Market Leaders
Platforms:
-PS2 dominates overall sales, followed by Xbox 360, PS3, and Wii.
- Nintendo dominates portable consoles (DS, GameBoy Advance, 3DS).
- Modern consoles (PS4, Xbox One) show high volume but lower per-game sales.

Publishers:
- Nintendo leads in total global sales (1.79 billion units), followed by EA and Activision.
- Sony, Ubisoft, Take-Two, and other publishers show strong market presence.

2. Game Trends: 
- Mario and Tetris franchises consistently appear among top sellers.
- Classic titles retain long-term popularity.

Genres:
- North America: Combate/Shooter, Sports, and Racing games dominate.
- Europe: Similar preferences to North America, with Racing and Sports stronger.
- Japan: Puzzle, Adventure, and Nintendo-specific titles are more popular.

3. Regional Insights:
- North America contributes 49% of global sales, Europe 27%, Japan 14%, others 10%.
- Western markets drive overall sales; Japan is niche but influential in portable and family-friendly games.

4. Temporal Trends:
Growth Period (1984-2008):
- Rapid increase in total sales, peaking around 2008 (690M units).
- Hit-driven sales evident from fluctuating average sales per game.

Recent Years (post-2015):
- Dataset shows declining total sales; likely reflects missing digital/mobile platforms or new-generation consoles.

Cumulative sales:
- Steady rise, showing long-term growth of the industry.

5. Data Gaps:
- Recent platforms (PS5, Switch, Xbox Series X) and digital sales are underrepresented.
- Regional sales may not capture mobile/online distribution.
*/

-- SECTION 4: REFLECTION & NEXT STEPS
/* While this analysis provides insights into historical video game sales,
several opportunities exist to deepen the study:

1. Expand datasets:
- Incorporate digital sales data (Steam, mobile platforms, online stores).
- Including pricing, revenue or inflation-adjusted metrics.
- Collect user engagement or review ratings to correlate with sales.

2. Forecasting:
- Use time-series models to predict future sales trends.
- Segment by platform, genre, or region to generate scenario forecasts.

3. Industry Comparison:
- Compare video game sales trends to movie box office revenue over the same period.
- Explore market size, seasonal trends, and growth rates to understand relative entertainment industry performance.

4. Additional analysis:
- Analyse genre popularirty shifts over decades.
- Evaluate publisher strategies and platform lifecycle impact.

This reflection shows how further data and modelling could provide strategic insights for publishers, investors, and analysts.
*/

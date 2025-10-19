# VideoGameSalesAnalysis

Analysis of video game sales data using SQL, focusing on sales trends by platform, genre, publisher, and region.

## Dataset
- Source: [Kaggle – Video Game Sales](https://www.kaggle.com/datasets)  
  - Original scrape from [vgchartz.com](https://github.com/GregorUT/vgchartzScrape) using BeautifulSoup (Python)
- Records: 16,598 (2 incomplete records dropped)
- Fields:
  - **Rank** – Overall sales rank
  - **Name** – Game title
  - **Platform** – Platform of release (e.g., PC, PS4)
  - **Year** – Year of release
  - **Genre** – Genre of the game
  - **Publisher** – Publisher of the game
  - **NA_Sales** – Sales in North America (millions)
  - **EU_Sales** – Sales in Europe (millions)
  - **JP_Sales** – Sales in Japan (millions)
  - **Other_Sales** – Sales in the rest of the world (millions)
  - **Global_Sales** – Total worldwide sales (millions)
- Notes: Sales columns are in **millions of copies sold**. Global_Sales = sum of regional sales.

## Business Questions
- Which platforms and genres sell the most globally?
- Which publishers dominate each genre?
- How do yearly sales trends evolve?
- What is the regional market share across regions?

## Insights
- Top-selling games globally and by region
- Year-over-year (YoY) sales growth
- Cumulative sales trends over years
- Regional sales distribution by platform and genre

## Folder Structure
- `sql/` — All SQL queries for analysis
- `tableau/` — Optional dashboards or screenshots
- `data/` — Optional dataset (CSV or Excel)

## Notes
- Missing year values were identified and handled in the analysis
- Queries include cumulative totals, YoY changes, and market share percentages

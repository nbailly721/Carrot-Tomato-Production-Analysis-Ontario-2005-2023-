                                  #### Carrot & Tomato Production Analysis (Ontario, 2005–2023) ####
-This project performs an end-to-end exploratory analysis of carrot and tomato production in Ontario using multi-year Excel data (one sheet per year). The workflow integrates data ingestion, cleaning, summarization, visualization, and statistical comparison across counties/districts.

🖥️ Workflow Overview

Data Ingestion & Cleaning (R Script)
- Load multi-year crop data from Excel workbooks (`carrots.xlsx` and `tomatoes.xlsx`), each containing one sheet per year.
- Use `readxl` to list and read all sheets dynamically.
- Clean and standardize variable names with `janitor::clean_names()`.
- Attach a `year` column extracted from each sheet name using `stringr::str_extract()`.
- Remove incomplete records and province-level aggregates to focus on county/district detail.

Yearly Summaries & Trend Visualization
- Compute total harvested area, marketed production, and farm value per year.
- Convert to long (tidy) format for easy faceted visualization.
- Plot time-series trends using `ggplot2` for:
  - Individual crops (carrots, tomatoes)
  - Combined comparison (both crops on shared facets)

Top Producer Analysis
- Identify top-5 counties by total farm value and total production for each crop.
- Examine overlap between top-value and top-production regions.
- Generate time-series plots showing farm value and production trends among top-producing counties.

Variability & Resilience
- Calculate the **coefficient of variation (CV)** for each county’s production and farm value to measure stability across years.
- Visualize CV rankings with horizontal bar charts (low CV = more stable production).

Yield vs. Price Dynamics
- Aggregate average yield (000 lbs/acre) and average price ($/lb) per year.
- Compare yield–price trends across crops using faceted line plots.

Long-Term Period Comparison
- Split the dataset into two eras: **2005–2013** and **2014–2023**.
- Calculate mean production and farm value for each period and crop.
- Plot side-by-side bar charts to visualize long-term shifts in productivity and value.

📁 Dataset
Excel workbooks (each with multiple sheets, one per year):

- `carrots.xlsx`; `tomatoes.xlsx` (source:https://data.ontario.ca/dataset/ontario-fruit-and-vegetable-production)  

Each sheet contains:
- County/District names  
- Harvested area (acres)  
- Average yield (000 lbs/acre)  
- Marketed production (000 lbs)  
- Average price (cents/lb)  
- Farm value (000 $)

🔧 Tools & Packages

R Packages:
- **readxl** – Read Excel files and sheet metadata  
- **tidyverse** – Data manipulation, summarization, and reshaping  
- **ggplot2** – Visualization and trend analysis  
- **janitor** – Cleaning and standardizing variable names  
- **stringr** – String manipulation for extracting years  

📊 Key Results

- Clear multi-year trends in carrot and tomato production, area, and farm value.  
- Identification of the top-performing counties by production and economic value.  
- Quantified variability (CV) to assess production stability across regions.  
- Yield and price co-movement patterns highlight market and productivity shifts.  
- Distinct contrasts between the 2005–2013 and 2014–2023 periods in both output and value.

📂 Files

- `carrot_tomato_analysis.R`: Complete R script covering data ingestion, cleaning, visualization, and statistical analysis.

🧠 Notes

This workflow demonstrates a full data exploration pipeline in R — from reading multi-year Excel data to summarizing agricultural trends with reproducible plots.  
It can be easily adapted for other crops, regions, or time spans by updating file paths and sheet structures.

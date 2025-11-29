                                  #### Carrot & Tomato Production Analysis (Ontario, 2005–2023) ####
**Description**

This project performs an end-to-end exploratory analysis of carrot and tomato production in Ontario from 2005–2023 using multi-year Excel data (one sheet per year). It integrates data ingestion, cleaning, summarization, visualization, and comparative statistical analysis across counties and districts. The workflow evaluates long-term production trends, top-producing regions, variability in output and value, yield–price dynamics, and long-term shifts across two major agricultural periods.

**Workflow Overview**
  1. Data Ingestion & Preparation (R)

Load multi-year Excel workbooks (carrots.xlsx, tomatoes.xlsx), each containing one sheet per year.

Use readxl to dynamically list and import all sheets.

Clean and standardize column names using janitor::clean_names().

Extract year values from sheet names using stringr::str_extract().

Remove incomplete or aggregated (province-level) rows to focus on county/district data.

   2. Yearly Summaries & Trend Visualization

Compute yearly totals for harvested area, marketed production, and farm value.

Convert datasets into tidy long format for visualization.

Generate time-series plots using ggplot2 for:

Carrot trends

Tomato trends

Combined crop comparisons (shared facets)

    3. Top Producer Analysis

Identify top 5 counties by:

Total farm value

Total marketed production

Analyze overlap between top-value and top-production regions.

Produce time-series visualizations for top regions for both crops.

    4. Variability & Resilience

Calculate coefficient of variation (CV) for each county’s:

Production

Farm value

Visualize production and value stability across counties (lower CV = more stable performance).

    5. Yield vs. Price Dynamics

Compute yearly averages for:

Yield (000 lbs/acre)

Price (cents/lb)

Visualize yield–price relationships using faceted line plots.

     6. Long-Term Period Comparison

Divide the dataset into:

2005–2013

2014–2023

Calculate mean production and farm value for both crops in each period.

Visualize long-term differences using side-by-side bar charts.

**Datasets Used** 

Primary Dataset: Ontario Fruit and Vegetable Production Data
Source: https://data.ontario.ca/dataset/ontario-fruit-and-vegetable-production

Processed/Generated Files

carrots.xlsx – Multi-year county-level carrot production (one sheet per year)

tomatoes.xlsx – Multi-year county-level tomato production (one sheet per year)

Each sheet includes:

County/District

Harvested area (acres)

Average yield (000 lbs/acre)

Marketed production (000 lbs)

Average price (cents/lb)

Farm value (000 $)

**Packages Used**

R Packages

readxl – Import Excel files and sheet metadata

tidyverse – Data manipulation, reshaping, visualization

ggplot2 – Time-series and comparative plotting

janitor – Standardizing column names

stringr – Extracting year metadata

Bash / Unix Tools

(None required beyond R execution environment)

**Key Results**

Average Farm Value (2005–2013 vs. 2014–2023)

Average Production (2005–2013 vs. 2014–2023)

Comparison of Carrot vs. Tomato Trends Over Time

Farm Value of Tomatoes – Top 5 Counties

Farm Value of Carrots – Top 5 Counties

Production of Carrots – Top 5 Counties

Production of Tomatoes – Top 5 Counties

Trend Analysis: Production, Area, and Value (for each crop)

Variability Analyses:

Carrot Production CV by County

Carrot Value CV by County

Tomato Production CV by County

Tomato Value CV by County

**Files in This Repository**

carrot_tomato_analysis.R – Full R workflow for ingestion, cleaning, exploration, and visualization.

**Important Notes**

This workflow provides a reproducible pipeline for exploring multi-year agricultural datasets in R.

Easily adaptable to other crops, regions, or year ranges by updating file paths and sheet structures.

Visualizations and analyses are fully automated once the Excel data structure is standardized.

**Real-World Relevance**

Supports evidence-based decision-making for Ontario’s agri-food sector.

Identifies top-producing and high-value counties, informing investment and regional planning.

Measures long-term production stability to support risk management and crop insurance strategies.

Highlights yield–price relationships relevant to market forecasting and sustainability.

Provides a scalable, reproducible workflow useful for policy, agricultural economics, and regional planning.

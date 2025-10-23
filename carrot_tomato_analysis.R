## ========================================================
## Project: Carrot & Tomato Production Analysis (Ontario) 
## Description:
##   End-to-end exploratory workflow for county/district-level carrots and 
##   tomatoes data stored across multiple Excel sheets (one sheet per year).
##   The script:
##     1) Ingests and cleans both workbooks (sheet names contain years).
##     2) Produces yearly summaries (area, production, farm value) and trends.
##     3) Identifies top-5 counties by production and farm value; visualizes
##        their time-series behavior.
##     4) Quantifies variability/resilience with coefficient of variation (CV).
##     5) Compares yield vs. price over time for each crop.
##     6) Compares long-term periods (2005–2013 vs. 2014–2023).
## ========================================================

# _ Set up environment  ------------
install.packages('readxl')                     
install.packages('tidyverse')                  
install.packages('ggplot2')                    
install.packages('janitor')                    
install.packages('stringr')                    

library('readxl')                              
library('tidyverse')                           
library('ggplot2')                             
library('janitor')                             
library('stringr')                             

# __ File locations  ----------

carrot_file<- '..../data/datasets/carrots.xlsx'
tomato_file <- '.../data/tomatoes.xlsx'

# __ Discover sheets  ----------
carrot_sheets <- excel_sheets(carrot_file)
# The 'carrot_file' excel file contains several sheets. This function lists all the sheets.

tomato_sheets <- excel_sheets(tomato_file)
# The 'tomato_file' excel file contains several sheets. This function lists all the sheets.

print(carrot_sheets)
# Quality check to ensure that the sheet names contain years.

print(tomato_sheets)
# Quality check to ensure that the sheet names contain years.

first_sheet_carrot <- carrot_sheets[1]
# Captures first sheet name for a quick peek.

carrot_first_year <- read_excel(carrot_file, sheet=first_sheet_carrot, skip=2)
# Reads one sheet to inspect structure; skip=2 removes the header in the first two lines.

head(carrot_first_year)
# Confirms the columns and a few rows before bulk import.

first_sheet_tomato <- tomato_sheets[1]
# Captures first sheet name for a quick peek.

tomato_first_year <- read_excel(tomato_file, sheet=first_sheet_tomato, skip=2)
# Mirrors the carrot preview step; consistent skip.

head(tomato_first_year)
# Confirm structures align with carrot workflow.

# __ Read & combine all carrot sheets  ----------

carrot_data_list <- lapply(
  carrot_sheets,
  function(sheet) {
    read_excel(carrot_file, sheet=sheet, skip=2) %>%  
      janitor::clean_names() %>%                      
      mutate(year = as.integer(str_extract(sheet, '\\d{4}'))) 
  }
)
# Builds a list of per-sheet tibbles, each annotated with 'year'.

carrot_bind <- bind_rows(carrot_data_list)
# Stacks all carrot sheets into one long tibble.

head(carrot_bind)
# Spot-check the combined structure and 'year' column.

# __ Read & combine all tomato sheets  ----------

print(tomato_sheets)
# Verify tomato sheets too (should carry years in names).

tomato_data_list <- lapply(
  tomato_sheets,
  function(sheet) {
    read_excel(tomato_file, sheet=sheet, skip=2) %>%
      janitor::clean_names() %>%
      mutate(year = as.integer(str_extract(sheet, '\\d{4}')))
  }
)
# Same list-building pattern; ensures 'year' is attached.

tomato_bind <- bind_rows(tomato_data_list)
# Unified tomato dataset.

head(tomato_bind)
# Quick preview of tomato combined data.

# _ Clean data sets  ------------

clean_tomato <- tomato_bind %>% 
  select('counties_and_districts','harvested_area_acres','average_yield_000lbs_acre',
         'marketed_production_000_lbs','average_price_cents_lb','farm_value_000','year')
# Keep only fields used downstream; reduces clutter and errors.

clean_tomato <- na.omit(clean_tomato)
# Drop incomplete records; simplifies summaries.

unique(clean_tomato$year)
# Verify year coverage for tomatoes.

clean_carrot <- carrot_bind %>% 
  select('counties_and_districts','harvested_area_acres','average_yield_000lbs_acre',
         'marketed_production_000_lbs','average_price_cents_lb','farm_value_000','year')
# Mirror the tomato selection for consistent schemas.

clean_carrot <- na.omit(clean_carrot)
# Ensure clean carrot dataset as well.

unique(clean_carrot$year)
# Verify carrot year coverage.

clean_carrot <- clean_carrot %>% filter(counties_and_districts != "Province")
# Remove province-level totals to avoid double-counting.

clean_tomato <- clean_tomato %>% filter(counties_and_districts != "Province")
# Same for tomatoes; focus on county/district granularity.

# _ Phase 1: Yearly summaries & trend plots  -----------

# __ Step 1: Summaries by year  ------------

carrot_yearly_summary <- clean_carrot %>% 
  group_by(year) %>% 
  summarise(
    total_area = sum(harvested_area_acres),
    total_value = sum(farm_value_000),
    total_production = sum(marketed_production_000_lbs),
    .groups = 'drop'
  )
# Aggregates core carrot metrics per year for plotting/comparison.

tomato_yearly_summary <- clean_tomato %>% 
  group_by(year) %>% 
  summarise(
    total_area = sum(harvested_area_acres),
    total_value = sum(farm_value_000),
    total_production = sum(marketed_production_000_lbs),
    .groups = 'drop'
  )
# Same for tomatoes; maintains a parallel structure.

# __ Step 1b: Long format for faceting  ------------

carrot_long <- carrot_yearly_summary %>% 
  pivot_longer(
    cols = c(total_area, total_value, total_production),
    names_to = 'variable',
    values_to = 'value'
  )
# Long format allows facetting variables on separate panels.

print(carrot_long)
# Check for expected reshaping.

tomato_long <- tomato_yearly_summary %>%
  pivot_longer(
    cols = c(total_area, total_value, total_production),
    names_to = 'variable',
    values_to = 'value'
  )
# Mirrors carrot reshaping for consistent plotting.

print(tomato_long)
# Check for expected reshaping.

# __ Step 2: Single-crop trend plots  --------------

label_names <- c(
  total_area = "Harvested Area (acres)",               
  total_value = "Farm Value (000)",
  total_production = "Marketed Production (000 lbs)"
)
# Clean labels improve readability on facets.

ggplot(carrot_long, aes(x=year, y=value)) +
  geom_line(color='red') +
  geom_point(color='red') +
  facet_wrap(~ variable, scales='free_y', labeller=labeller(variable=label_names)) +
  labs(
    x='Year',
    y='Value',
    title='Trends in Carrot Production, Area, and Value Over Time'
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust=0.5))
# 'Free_y' keeps each panel legible.

ggplot(tomato_long, aes(x=year, y=value)) +
  geom_line(color='blue') +
  geom_point(color='blue') +
  facet_wrap(~ variable, scales='free_y', labeller=labeller(variable=label_names)) +
  labs(
    x='Year',
    y='Value',
    title='Trends in Tomato Production, Area, and Value Over Time'
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust=0.5))
# Same pattern for tomatoes; consistent aesthetics aid comparison.

# __ Step 3: Combined crop comparison  ------------

carrot_long <- carrot_long %>% mutate(crop='Carrot')
# Tag rows to enable color mapping by crop.

tomato_long <- tomato_long %>% mutate(crop='Tomato')
# Same for tomato rows.

combined_long_data <- bind_rows(carrot_long, tomato_long)
# Merge for a single comparative plot.

ggplot(combined_long_data, aes(x=year, y=value, color=crop)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ variable, scales='free_y', labeller=labeller(variable=label_names)) +
  labs(
    x='Year',
    y='Value',
    title='Comparison of Carrot and Tomato Trends Over Time',
    color='Crop'
  ) +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5))
# Direct visual comparison across crops per metric/year.

# _ Phase 2: Top producers & regional trends  -------------

# __ Step 1: Identify top 5 by value and production  ---------

top_carrot_value <- clean_carrot %>% 
  group_by(counties_and_districts) %>%
  summarise(
    total_value = sum(farm_value_000),
    total_production = sum(marketed_production_000_lbs),
    .groups='drop'
  ) %>%
  arrange(desc(total_value)) %>%
  slice_max(total_value, n=5)
# Finds carrot counties with the highest cumulative farm value.

top_carrot_production <- clean_carrot %>% 
  group_by(counties_and_districts) %>%
  summarise(
    total_value = sum(farm_value_000),
    total_production = sum(marketed_production_000_lbs),
    .groups='drop'
  ) %>%
  arrange(desc(total_production)) %>%
  slice_max(total_production, n=5)
# Finds carrot counties with the highest cumulative marketed production.

top_tomato_value <- clean_tomato %>% 
  group_by(counties_and_districts) %>%
  summarise(
    total_value = sum(farm_value_000),
    total_production = sum(marketed_production_000_lbs),
    .groups='drop'
  ) %>%
  arrange(desc(total_value)) %>%
  slice_max(total_value, n=5)
# Same logic for tomatoes (value leaders).

top_tomato_production <- clean_tomato %>% 
  group_by(counties_and_districts) %>%
  summarise(
    total_value = sum(farm_value_000),
    total_production = sum(marketed_production_000_lbs),
    .groups='drop'
  ) %>%
  arrange(desc(total_production)) %>%
  slice_max(total_production, n=5)
# Same logic for tomatoes (production leaders).

# __ Step 2: Overlap & time trends for top counties  ----------

intersect(top_carrot_production, top_carrot_value)
# Quick check: which carrot counties rank top in both metrics.

intersect(top_tomato_value, top_tomato_production)
# Same overlap check for tomato counties.

# -- Carrots ----------

top_carrot_counties_value <- top_carrot_value$counties_and_districts
print(top_carrot_counties_value)
# Keep list for filtering; print to confirm.

carrot_county_trends_value <- clean_carrot %>%
  filter(counties_and_districts %in% top_carrot_counties_value) %>%
  group_by(year, counties_and_districts) %>%
  summarise(total_value = sum(farm_value_000), .groups='drop')
# Builds yearly time series of farm value for top carrot counties.

top_carrot_counties_production <- top_carrot_production$counties_and_districts
print(top_carrot_counties_production)
# Check the production top-5 list.

carrot_county_trends_production <- clean_carrot %>%
  filter(counties_and_districts %in% top_carrot_counties_production) %>%
  group_by(year, counties_and_districts) %>%
  summarise(total_production = sum(marketed_production_000_lbs), .groups='drop')
# Yearly production trends for top carrot producers.

# -- Tomatoes ----------------

top_tomato_county_value <- top_tomato_value$counties_and_districts
print(top_tomato_county_value)
# Store tomato top-5 (value) for filtering.

tomato_county_trends_value <- clean_tomato %>% 
  filter(counties_and_districts %in% top_tomato_county_value) %>%
  group_by(year, counties_and_districts) %>% 
  summarise(total_value = sum(farm_value_000), .groups = 'drop')
# Yearly value trends for top 5 tomato counties.

top_tomato_county_production <- top_tomato_production$counties_and_districts
print(top_tomato_county_production)
# Store tomato top-5 (production) for filtering.

tomato_county_trends_production <- clean_tomato %>%
  filter(counties_and_districts %in% top_tomato_county_production) %>%
  group_by(year, counties_and_districts) %>%
  summarise(total_production = sum(marketed_production_000_lbs), .groups='drop')
# Yearly production trends for top 5 tomato counties.

# __ Step 2b: Regional trend graphs  --------------

# Tomato production over time (top producers)
ggplot(tomato_county_trends_production, aes(x=year, y=total_production, color = counties_and_districts)) +
  geom_line() +
  geom_point() +
  labs(x='Year', y='Production (000 lbs)', title='Production of Tomatoes per Year (Top 5 Counties)', color='County/district') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5))
# Fixed axis labels: x=Year, y=Production for clarity.

# Tomato value over time (top value counties)
ggplot(tomato_county_trends_value, aes(x=year, y=total_value, color=counties_and_districts)) +
  geom_line() +
  geom_point() + 
  labs(x='Year', y='Farm Value ($000)', title='Farm Value of Tomatoes per Year (Top 5 Counties)', color='County/district') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5))
# Straightforward time series of value; consistent labeling.

# Carrot production over time (top producers)
ggplot(carrot_county_trends_production, aes(x=year, y=total_production, color=counties_and_districts)) +
  geom_line() +
  geom_point() +
  labs(x='Year', y='Production (000 lbs)', title='Production of Carrots per Year (Top 5 Counties)', color='County/district') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5))
# Same structure, carrots.

# Carrot value over time (top value counties)
ggplot(carrot_county_trends_value, aes(x=year, y=total_value, color=counties_and_districts)) +
  geom_line() +
  geom_point() + 
  labs(x='Year', y='Farm Value ($000)', title='Farm Value of Carrots per Year (Top 5 Counties)', color='County/district') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5))
# Mirrors tomato plot for a clean side-by-side comparison.

# _ Phase 3: Variability & resilience  --------------

# __ Step 1: Coefficient of variation per county  ----------

carrot_variability <- clean_carrot %>% 
  group_by(counties_and_districts) %>%
  summarise(
    mean_production = mean(marketed_production_000_lbs),
    sd_production   = sd(marketed_production_000_lbs),
    cv_production   = sd_production / mean_production,
    mean_value      = mean(farm_value_000),
    sd_value        = sd(farm_value_000),
    cv_value        = sd_value / mean_value,
    .groups = 'drop'
  ) %>% 
  arrange(cv_production)
# CV highlights stability (lower CV = more stable across years).

tomato_variability <- clean_tomato %>%
  group_by(counties_and_districts) %>%
  summarise(
    mean_production = mean(marketed_production_000_lbs),
    sd_production   = sd(marketed_production_000_lbs),
    cv_production   = sd_production / mean_production,
    mean_value      = mean(farm_value_000),
    sd_value        = sd(farm_value_000),
    cv_value        = sd_value / mean_value,
    .groups = 'drop'
  ) %>% 
  arrange(cv_production)
# Same variability metrics for tomatoes.

# __ Step 2: Rank counties by CV (bar charts)  ---------

ggplot(carrot_variability, aes(y=cv_production, x=reorder(counties_and_districts, cv_production))) +
  geom_col(fill='red') +
  labs(x='County/District', y='Coefficient of Variation', title='Variability in Carrot Production by County') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5)) + 
  coord_flip()
# Ordered bars reveal most/least stable producers.

ggplot(carrot_variability, aes(y=cv_value, x=reorder(counties_and_districts, cv_value))) +
  geom_col(fill='red') +
  labs(x='County/District', y='Coefficient of Variation', title='Variability in Carrot Value by County') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5)) + 
  coord_flip()
# Same, focusing on value stability.

ggplot(tomato_variability, aes(y=cv_production, x=reorder(counties_and_districts, cv_production))) +
  geom_col(fill='steelblue') +
  labs(x='County/District', y='Coefficient of Variation', title='Variability in Tomato Production by County') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5)) + 
  coord_flip()
# Tomato production CV ranking.

ggplot(tomato_variability, aes(y=cv_value, x=reorder(counties_and_districts, cv_value))) +
  geom_col(fill='steelblue') +
  labs(x='County/District', y='Coefficient of Variation', title='Variability in Tomato Value by County') +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5)) + 
  coord_flip()
# Tomato value CV ranking.

# __ Step 3: Yield vs price over time  --------------

comparison_tomato <- clean_tomato %>% 
  select('average_yield_000lbs_acre', 'year','average_price_cents_lb') %>% 
  group_by(year) %>%
  summarise(
    avg_yield = mean(average_yield_000lbs_acre),
    avg_price = mean(average_price_cents_lb),
    .groups   = 'drop'
  ) %>%
  mutate(avg_price_dollars = avg_price / 100)
# Aggregates average yield and price per year; converts price to dollars.

comparison_carrot <- clean_carrot %>% 
  select('average_yield_000lbs_acre', 'year','average_price_cents_lb')  %>% 
  group_by(year) %>%
  summarise(
    avg_yield = mean(average_yield_000lbs_acre),
    avg_price = mean(average_price_cents_lb),
    .groups   = 'drop'
  ) %>%
  mutate(avg_price_dollars = avg_price / 100)
# Same for carrots; consistent units.

comparison_tomato <- comparison_tomato %>% mutate(crop='Tomato')
# Tag crop for color mapping.

comparison_carrot <- comparison_carrot %>% mutate(crop='Carrot')
# Tag crop likewise.

combined_crop <- bind_rows(comparison_carrot, comparison_tomato) %>% 
  select('crop', 'year', 'avg_yield', 'avg_price_dollars')
# Single tidy table with just what we need.

combined_crop_long <- pivot_longer(
  data = combined_crop,
  cols = c(avg_yield, avg_price_dollars),
  names_to = 'variable',
  values_to = 'value'
)
# Long format to facet yield vs price.

print(combined_crop_long)
# Sanity check of reshaped data.

label_names_2 <- c(
  avg_price_dollars = "Average Price ($/lb)",
  avg_yield = "Average Yield (000 lbs/acre)"
)
# Clarify units to avoid confusion.

ggplot(combined_crop_long, aes(x=year, y=value, color=crop)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ variable, scales='free_y', labeller=labeller(variable=label_names_2)) +
  labs(
    x='Year',
    y='Value',
    title='Average Yield and Price by Crop (2004–2023)'
  ) +
  theme_minimal()
# Faceted view highlights co-movement and differences by crop.

# __ Step 4: Long-term period comparison  ------------

long_term_carrot <- clean_carrot %>% 
  select('farm_value_000','marketed_production_000_lbs','year') %>% 
  mutate(crop='Carrot')
# Reduce to key metrics and tag crop.

long_term_tomato <- clean_tomato %>% 
  select('farm_value_000','marketed_production_000_lbs','year') %>% 
  mutate(crop='Tomato')
# Same for tomatoes.

combined_term <- bind_rows(long_term_carrot, long_term_tomato)
# Merge for period analysis.

combined_term <- combined_term %>% 
  mutate(period = ifelse(year <= 2013, '2005–2013', '2014–2023'))
# Splits into two eras; adjust cut if your data starts/ends differently.

long_term_summary <- combined_term %>%
  group_by(period, crop) %>%
  summarise(
    avg_production = mean(marketed_production_000_lbs),
    avg_value      = mean(farm_value_000),
    .groups = 'drop'
  )
# Period averages enable simple before/after comparisons.

ggplot(long_term_summary, aes(x=period, y=avg_production, fill=crop)) +
  geom_col(position='dodge') +
  labs(
    x='Period',
    y='Average Production (000 lbs)',
    title='Average Production by Crop (2005–2013 vs. 2014–2023)',
    fill='Crop'
  ) +
  theme_minimal()
# Side-by-side bars make period deltas obvious.

ggplot(long_term_summary, aes(x=period, y=avg_value, fill=crop)) +
  geom_col(position='dodge') +
  labs(
    x='Period',
    y='Average Farm Value ($000)',
    title='Average Farm Value by Crop (2005–2013 vs. 2014–2023)',
    fill='Crop'
  ) +
  theme_minimal()
# Complements production with value comparisons across periods.

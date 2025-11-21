# Flextable Function Summary

## Overview
Built `create_es_sites_flextable()` function to generate formatted tables of Environmental Sample (ES) sites by country and region using the flextable package.

## Function: `create_es_sites_flextable()`

### Purpose
Generates a nicely formatted flextable displaying the total number of Environmental Sample monitoring sites by country and WHO region.

### Usage
```r
# Load the function
source("R/09_es_sites_flextable.R")

# Option 1: Auto-load from RDS file
ft <- create_es_sites_flextable()

# Option 2: Use existing data
ft <- create_es_sites_flextable(envsample_data = my_tibble, verbose = TRUE)
```

### Parameters
- `envsample_data` - Optional tibble/data frame with columns: Admin0Name, WHORegion, SiteName (auto-loads from data/EnvSample.rds if NULL)
- `verbose` - Display status messages (default: TRUE)

### Returns
A flextable object with:
- **Country** - Country name
- **WHO Region** - WHO geographic region (AFRO, EMRO, SEARO, WPRO, EURO)
- **Number of Sites** - Count of distinct monitoring sites per country
- **Total Samples** - Total environmental samples collected from that country

### Output Example
The function generated a table from 2,000 EnvSample records showing:

| WHO Region | Total Countries | Number of Sites | Total Samples |
|-----------|----------------|-----------------|---------------|
| AFRO      | 34             | 399             | 1382          |
| EMRO      | 11             | 133             | 294           |
| SEARO     | 5              | 56              | 174           |
| WPRO      | 3              | 50              | 128           |
| EURO      | 2              | 13              | 22            |

## Function: `create_es_regional_summary()`

### Purpose
Generates a summary table aggregated by WHO Region only (no country breakdown).

### Returns
A flextable with:
- **WHO Region** - Region name
- **Countries** - Count of countries in that region
- **Number of Sites** - Total sites in region
- **Total Samples** - Total samples in region

## Function: `export_es_summary_csv()`

### Purpose
Exports the summary data to CSV files for use in Excel, other tools, or further analysis.

### Output Files
- `output/ES_Sites_by_Country_Region.csv` - Country-level breakdown
- `output/ES_Sites_Regional_Summary.csv` - Regional aggregation

## Key Features

✅ **Automatic Data Loading** - Loads EnvSample.rds if available
✅ **Data Validation** - Checks for required columns
✅ **Flextable Formatting** - Professional styling with:
   - Bold headers
   - Gray background header
   - Centered alignment
   - Borders
   - Automatic column width

✅ **Dual Summary Levels** - Country-region breakdown AND regional summary
✅ **CSV Export** - Data saved for spreadsheet use
✅ **Flexible Input** - Works with passed data or auto-loads from file

## Usage Workflow

```r
# Step 1: Run the full script to auto-generate tables
source("R/09_es_sites_flextable.R")

# Step 2: Access the flextable object directly
ft <- create_es_sites_flextable()
print(ft)  # Display in console

# Step 3: Get data for further analysis
summaries <- export_es_summary_csv(envsample_data)
head(summaries$country_region)      # Country-level
head(summaries$regional)             # Regional summary
```

## Files Created

- **R/09_es_sites_flextable.R** - Main script with all functions
- **output/ES_Sites_by_Country_Region.csv** - Country breakdown (exported)
- **output/ES_Sites_Regional_Summary.csv** - Regional summary (exported)

## Dependencies

```r
library(flextable)  # For table formatting
library(dplyr)      # For data manipulation
```

## Integration

The script is part of the Polio Assignment workflow:
1. EnvSample data fetched via `R/07_fetch_envsample_full.R`
2. Stored in `data/EnvSample.rds`
3. Summarized with `R/09_es_sites_flextable.R`
4. Exported to CSV for reporting

---
**Date Created**: November 21, 2025
**Status**: ✅ Complete and tested

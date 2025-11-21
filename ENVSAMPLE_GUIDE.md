# EnvSample Data Download Guide

## Overview
This guide explains how to download the entire EnvSample table from the WHO POLIS API and store it locally for analysis.

## Files Available

### API Configuration
- **`R/03_poli_api_config.R`** - Main POLI API configuration and connection functions
- **`R/05_fetch_envsample.R`** - Complete EnvSample download script
- **`R/diagnose_api.R`** - Diagnostic tools for troubleshooting API connections
- **`R/diagnose_api_advanced.R`** - Advanced API testing utilities

### Helper Scripts
- **`R/git_helpers.R`** - GitHub Flow helper functions
- **`R/01_github_init.R`** - Git repository initialization
- **`R/02_github_flow_setup.R`** - GitHub Flow workflow setup

## Quick Start

### Step 1: Download EnvSample Data

```r
# Load and run the download script
source("R/05_fetch_envsample.R")
```

This script will:
1. Test API connection
2. Fetch the envsample endpoint
3. Process and structure the data
4. Save in multiple formats (JSON, CSV, RDS)
5. Verify Git exclusion (not uploaded to GitHub)

### Step 2: Load the Data in Future Sessions

```r
# Recommended: Load RDS (most efficient for R)
envsample <- readRDS('data/EnvSample.rds')

# Alternative: Load CSV
envsample <- read.csv('data/EnvSample.csv')

# Alternative: Load JSON
envsample <- jsonlite::fromJSON('data/EnvSample.json')
```

## API Configuration Details

### Endpoint Structure
- **Base URL**: `https://extranet.who.int/polis/`
- **API V2 Base**: `https://extranet.who.int/polis/api/v2/`
- **EnvSample Endpoint**: `https://extranet.who.int/polis/api/v2/envsample`

### Authentication
- **Method**: Bearer Token (Authorization header)
- **Format**: `Authorization: Bearer [API_KEY]`
- **API Key**: Stored in `03_poli_api_config.R`

### Available POLIS API V2 Endpoints
```
- virus
- case
- humanspecimen
- envsample
- activity
- subactivity
- indicators
```

## File Outputs

The download script saves data in three formats to `data/`:

### 1. JSON Format (`EnvSample.json`)
- **Purpose**: Full data structure preservation
- **Best for**: Web applications, JavaScript compatibility
- **Size**: Largest file size
- **Usage**:
  ```r
  data <- jsonlite::fromJSON('data/EnvSample.json')
  ```

### 2. CSV Format (`EnvSample.csv`)
- **Purpose**: Spreadsheet compatibility, data import
- **Best for**: Excel, Google Sheets, other tools
- **Size**: Medium file size
- **Limitation**: May lose some data type information
- **Usage**:
  ```r
  data <- read.csv('data/EnvSample.csv')
  ```

### 3. RDS Format (`EnvSample.rds`)
- **Purpose**: R-native binary format
- **Best for**: R analysis, preserves all data types and structures
- **Size**: Smallest file size (most compressed)
- **Recommended**: Yes, for R workflows
- **Usage**:
  ```r
  data <- readRDS('data/EnvSample.rds')
  ```

### Metadata (`EnvSample_metadata.json`)
Contains download information:
```r
metadata <- jsonlite::fromJSON('data/EnvSample_metadata.json')
metadata$fetch_time  # When data was downloaded
metadata$status      # HTTP status code
metadata$records     # Number of records
metadata$columns     # Number of columns
```

## Git Configuration

### Data Directory Exclusion
The `data/` directory is automatically excluded from Git to prevent uploading large local files:

```gitignore
data/
```

Verify with:
```bash
git status  # Should not show data/ files
```

## Troubleshooting

### API Connection Issues

If you receive HTTP 400/500 errors:

1. **Verify API Key**
   ```r
   source("R/03_poli_api_config.R")
   poli_test_connection()
   ```

2. **Run Diagnostics**
   ```r
   source("R/diagnose_api.R")
   source("R/diagnose_api_advanced.R")
   ```

3. **Check Internet Connection**
   ```r
   # Test basic connectivity
   result <- httr::GET("https://extranet.who.int/polis/")
   ```

4. **Contact WHO Support**
   - Email: polis@who.int
   - Request API documentation and endpoint specifications

### Data Loading Issues

If files don't exist or are corrupted:

1. **Re-download data**
   ```r
   source("R/05_fetch_envsample.R")
   ```

2. **Check file sizes**
   ```r
   file.size("data/EnvSample.rds") / (1024^2)  # Size in MB
   ```

3. **Verify data integrity**
   ```r
   data <- readRDS("data/EnvSample.rds")
   str(data)  # View structure
   nrow(data)  # Count records
   ```

## API Functions

### Main Functions in `03_poli_api_config.R`

#### poli_test_connection()
Tests API connectivity
```r
result <- poli_test_connection(verbose = TRUE)
result$connected     # TRUE/FALSE
result$base_status   # HTTP status
result$api_status    # HTTP status
```

#### poli_request()
Makes authenticated API requests
```r
result <- poli_request(
  endpoint = "envsample",
  method = "GET",
  params = list(Skip = 0, Take = 2000),
  verbose = TRUE
)

result$success  # TRUE/FALSE
result$data     # Returned data
result$status   # HTTP status code
```

#### poli_save_data()
Saves API responses to files
```r
poli_save_data(
  response = result,
  filename = "envsample.csv",
  format = "both"  # "csv", "json", or "both"
)
```

## Advanced Usage

### Fetching Multiple Batches
If dataset is larger than 2000 records:

```r
all_data <- list()
skip_value <- 0
take_value <- 2000

repeat {
  result <- poli_request(
    endpoint = "envsample",
    params = list(Skip = skip_value, Take = take_value)
  )
  
  if (!result$success || length(result$data) == 0) break
  
  all_data <- c(all_data, result$data)
  skip_value <- skip_value + take_value
}
```

### Data Filtering
After loading, filter data as needed:

```r
library(dplyr)

envsample <- readRDS('data/EnvSample.rds')

# Filter by country
filtered <- envsample %>%
  filter(Country == "Nigeria")

# Filter by date range
filtered <- envsample %>%
  filter(CollectionDate >= "2025-01-01")
```

### Data Analysis Examples

```r
envsample <- readRDS('data/EnvSample.rds')

# Summary statistics
summary(envsample)

# Count by country
table(envsample$Country)

# Visualize data
library(ggplot2)
ggplot(envsample, aes(x = Country)) +
  geom_bar() +
  theme_minimal()
```

## Important Notes

1. **Data Privacy**: Downloaded data should be handled according to WHO guidelines
2. **Backup**: Periodically backup the data/EnvSample.rds file
3. **Updates**: Rerun the download script to get latest data
4. **Git**: Never commit data/ files to GitHub (they're in .gitignore)
5. **File Sizes**: RDS is most compact; JSON and CSV are larger

## Support & Documentation

- **POLIS Main**: https://extranet.who.int/polis/
- **API Documentation**: Available within POLIS Help section
- **WHO Support**: polis@who.int
- **GitHub Repository**: https://github.com/ariwhiteman1/Polio_Assignment

## Version History

- **v1.0** (2025-11-21): Initial EnvSample download implementation
  - API V2 endpoint configuration
  - Multiple format support (JSON, CSV, RDS)
  - Git integration and exclusion
  - Diagnostic tools

---

**Last Updated**: November 21, 2025

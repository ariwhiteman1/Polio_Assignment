# Fetch entire EnvSample table and store locally
# Usage: source("R/07_fetch_envsample_full.R")

cat("\n========================================\n")
cat("   Fetch EnvSample - Complete Table\n")
cat("========================================\n")

# Load API configuration
source("R/03_poli_api_config.R")

# ============================================================================
# Fetch entire EnvSample table
# ============================================================================
cat("\n=== Step 1: Fetching EnvSample Data ===\n")
cat("Endpoint: EnvSample (case-sensitive)\n")
cat("Requesting all available rows...\n\n")

# Start with a large batch size to get all data
# POLIS API typically supports Take parameter up to 2000-5000
envsample_data <- poli_fetch_table(
  endpoint = "EnvSample",
  n_rows = 100000,  # Request large number to get all available data
  verbose = TRUE
)

if (is.null(envsample_data)) {
  cat("\n✗ Failed to fetch EnvSample data\n")
  cat("Possible reasons:\n")
  cat("  1. API connection issue\n")
  cat("  2. Case-sensitive endpoint name incorrect\n")
  cat("  3. API key/authentication issue\n")
  cat("\nTrying alternative endpoint names...\n")
  
  # Try alternative case variations
  alt_endpoints <- c("envsample", "EnvironmentalSample", "environmental-sample")
  
  for (alt_ep in alt_endpoints) {
    cat(sprintf("\nTrying: %s\n", alt_ep))
    envsample_data <- poli_fetch_table(
      endpoint = alt_ep,
      n_rows = 100000,
      verbose = FALSE
    )
    
    if (!is.null(envsample_data)) {
      cat(sprintf("✓ Success with endpoint: %s\n", alt_ep))
      break
    }
  }
}

# ============================================================================
# Store data locally if successful
# ============================================================================
if (!is.null(envsample_data)) {
  cat("\n=== Step 2: Storing Data Locally ===\n")
  cat(sprintf("Total rows retrieved: %d\n", nrow(envsample_data)))
  cat(sprintf("Total columns: %d\n", ncol(envsample_data)))
  
  # Create data directory if it doesn't exist
  if (!dir.exists("data")) {
    dir.create("data", showWarnings = FALSE)
  }
  
  # Save in multiple formats
  cat("\nSaving in multiple formats...\n")
  
  # 1. RDS format (most efficient for R)
  rds_file <- "data/EnvSample.rds"
  saveRDS(envsample_data, rds_file)
  cat(sprintf("✓ Saved RDS: %s\n", rds_file))
  
  # 2. CSV format (spreadsheet compatible)
  csv_file <- "data/EnvSample.csv"
  write.csv(envsample_data, csv_file, row.names = FALSE)
  cat(sprintf("✓ Saved CSV: %s\n", csv_file))
  
  # 3. JSON format (for data sharing)
  json_file <- "data/EnvSample.json"
  json_str <- jsonlite::toJSON(envsample_data, pretty = TRUE)
  writeLines(json_str, json_file)
  cat(sprintf("✓ Saved JSON: %s\n", json_file))
  
  # 4. Save metadata
  metadata <- list(
    endpoint = "EnvSample",
    fetch_time = Sys.time(),
    total_records = nrow(envsample_data),
    total_columns = ncol(envsample_data),
    columns = names(envsample_data),
    data_types = sapply(envsample_data, class),
    file_sizes = c(
      rds = file.size(rds_file),
      csv = file.size(csv_file),
      json = file.size(json_file)
    )
  )
  
  metadata_file <- "data/EnvSample_metadata.json"
  writeLines(jsonlite::toJSON(metadata, pretty = TRUE), metadata_file)
  cat(sprintf("✓ Saved metadata: %s\n", metadata_file))
  
  # ========================================================================
  # Display data summary
  # ========================================================================
  cat("\n=== Step 3: Data Summary ===\n")
  cat(sprintf("Dimensions: %d rows × %d columns\n\n", nrow(envsample_data), ncol(envsample_data)))
  
  cat("Column names and types:\n")
  col_info <- data.frame(
    Column = names(envsample_data),
    Type = sapply(envsample_data, class),
    Non_NA = colSums(!is.na(envsample_data)),
    NA_Count = colSums(is.na(envsample_data))
  )
  print(col_info)
  
  cat("\n\nFirst 10 rows:\n")
  print(head(envsample_data, 10))
  
  cat("\n\nData structure:\n")
  str(envsample_data)
  
  # ========================================================================
  # Verify Git exclusion
  # ========================================================================
  cat("\n=== Step 4: Verify Git Exclusion ===\n")
  gitignore_file <- ".gitignore"
  if (file.exists(gitignore_file)) {
    gitignore_content <- readLines(gitignore_file)
    if (any(grepl("^data/", gitignore_content))) {
      cat("✓ data/ directory is excluded in .gitignore\n")
      cat("✓ EnvSample files will NOT be uploaded to GitHub\n")
    } else {
      cat("⚠ Warning: data/ directory may not be in .gitignore\n")
    }
  }
  
  # ========================================================================
  # Usage instructions
  # ========================================================================
  cat("\n=== Step 5: How to Use the Data ===\n")
  
  cat("\nLoad data in future R sessions:\n\n")
  cat("# Method 1: RDS (recommended for R)\n")
  cat("envsample <- readRDS('data/EnvSample.rds')\n\n")
  
  cat("# Method 2: CSV\n")
  cat("envsample <- read.csv('data/EnvSample.csv')\n\n")
  
  cat("# Method 3: JSON\n")
  cat("envsample <- jsonlite::fromJSON('data/EnvSample.json')\n\n")
  
  cat("# View data\n")
  cat("head(envsample)              # First 6 rows\n")
  cat("dim(envsample)               # Dimensions\n")
  cat("names(envsample)             # Column names\n")
  cat("summary(envsample)           # Summary statistics\n\n")
  
  cat("# Filter and analyze\n")
  cat("library(dplyr)\n")
  cat("envsample %>%\n")
  cat("  filter(column_name == 'value') %>%\n")
  cat("  select(col1, col2, col3)\n")
  
} else {
  cat("\n✗ Failed to fetch EnvSample data after trying all endpoint variations\n")
  cat("\nPlease verify:\n")
  cat("  1. API key is valid: POLI_API_KEY in 03_poli_api_config.R\n")
  cat("  2. Internet connection is working\n")
  cat("  3. WHO POLIS API V2 is accessible\n")
  cat("  4. Contact WHO POLIS support for correct endpoint details\n")
}

cat("\n========================================\n")
cat("   EnvSample Fetch Complete\n")
cat("========================================\n\n")

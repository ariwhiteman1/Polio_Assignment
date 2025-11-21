# Download EnvSample Endpoint - Complete Dataset
# This script downloads the entire Environmental Sample table from POLI API
# and stores it locally (NOT uploaded to GitHub)
# Usage: source("R/05_fetch_envsample.R")

cat("\n========================================\n")
cat("   Downloading EnvSample Data\n")
cat("========================================\n")

# Load API configuration
source("R/03_poli_api_config.R")

# ============================================================================
# Step 1: Test connection
# ============================================================================
cat("\n=== Step 1: Testing API Connection ===\n")
connection_test <- poli_test_connection(verbose = TRUE)

if (!connection_test$connected) {
  cat("\n✗ Cannot connect to API\n")
  stop("API connection failed")
}

# ============================================================================
# Step 2: Fetch EnvSample data
# ============================================================================
cat("\n=== Step 2: Fetching EnvSample Data ===\n")

# Using correct endpoint name from POLIS API V2
# API requires pagination parameters: Skip and Take
cat("Fetching envsample endpoint...\n")

# First fetch with default pagination (Skip=0, Take=2000)
env_sample_result <- poli_request(
  endpoint = "envsample",
  method = "GET",
  params = list(
    Skip = 0,
    Take = 2000
  ),
  verbose = TRUE
)

# ============================================================================
# Step 3: Check results
# ============================================================================
cat("\n=== Step 3: Handling Data Structure ===\n")

all_data <- env_sample_result$data

if (env_sample_result$success && !is.null(all_data)) {
  # Check if response is paginated (contains 'data' and 'pageInfo' fields)
  if (is.list(all_data) && !is.null(all_data$data)) {
    cat("✓ Data is paginated\n")
    
    all_records <- all_data$data
    
    # Check for pagination info
    if (!is.null(all_data$pageInfo)) {
      page_info <- all_data$pageInfo
      cat(sprintf("  Current page size: %d records\n", length(all_records)))
      
      if (!is.null(page_info$totalNumber)) {
        cat(sprintf("  Total records available: %d\n", page_info$totalNumber))
      }
    }
    
    data_to_save <- all_records
    
  } else if (is.data.frame(all_data)) {
    cat("✓ Data is a data frame\n")
    cat(sprintf("  Rows: %d\n", nrow(all_data)))
    cat(sprintf("  Columns: %d\n", ncol(all_data)))
    cat(sprintf("  Column names: %s\n", paste(names(all_data), collapse=", ")))
    data_to_save <- all_data
    
  } else if (is.list(all_data)) {
    cat("✓ Data is a list structure\n")
    cat(sprintf("  Elements: %d\n", length(all_data)))
    cat(sprintf("  Names: %s\n", paste(names(all_data), collapse=", ")))
    data_to_save <- all_data
  } else {
    cat("✓ Data retrieved\n")
    data_to_save <- all_data
  }
  
} else {
  cat("✗ Failed to retrieve EnvSample data\n")
  cat(sprintf("Status: %d\n", env_sample_result$status))
  if (!is.null(env_sample_result$error)) {
    cat(sprintf("Error: %s\n", env_sample_result$error))
  }
  stop("EnvSample fetch failed")
}

# ============================================================================
# Step 4: Save data locally (NOT to GitHub)
# ============================================================================
cat("\n=== Step 4: Saving Data Locally ===\n")

# Ensure .gitignore excludes data files
if (file.exists(".gitignore")) {
  gitignore_content <- readLines(".gitignore")
  if (!any(grepl("^data/", gitignore_content))) {
    cat("data/\n", file = ".gitignore", append = TRUE)
    cat("✓ Updated .gitignore to exclude data/ directory\n")
  }
}

# Create data directory if needed
if (!dir.exists("data")) {
  dir.create("data", showWarnings = FALSE)
}

# Save as JSON (preserves structure)
json_file <- "data/EnvSample.json"
json_str <- jsonlite::toJSON(data_to_save, pretty = TRUE)
writeLines(json_str, json_file)
json_size <- file.size(json_file) / (1024 * 1024)  # Size in MB
cat(sprintf("✓ Saved JSON: %s (%.2f MB)\n", json_file, json_size))

# Save as CSV if it's a data frame
if (is.data.frame(data_to_save)) {
  csv_file <- "data/EnvSample.csv"
  write.csv(data_to_save, csv_file, row.names = FALSE)
  csv_size <- file.size(csv_file) / (1024 * 1024)
  cat(sprintf("✓ Saved CSV: %s (%.2f MB)\n", csv_file, csv_size))
}

# Save as RDS (R native format, most efficient)
rds_file <- "data/EnvSample.rds"
saveRDS(data_to_save, rds_file)
rds_size <- file.size(rds_file) / (1024 * 1024)
cat(sprintf("✓ Saved RDS: %s (%.2f MB)\n", rds_file, rds_size))

# Save metadata
metadata <- list(
  endpoint = "envsample",
  fetch_time = Sys.time(),
  status = env_sample_result$status,
  data_type = class(data_to_save),
  records = if(is.data.frame(data_to_save)) nrow(data_to_save) else if(is.list(data_to_save)) length(data_to_save) else NA,
  columns = if(is.data.frame(data_to_save)) ncol(data_to_save) else NA,
  api_url = POLI_API_V2
)

metadata_json <- jsonlite::toJSON(metadata, pretty = TRUE)
writeLines(metadata_json, "data/EnvSample_metadata.json")
cat(sprintf("✓ Saved metadata: data/EnvSample_metadata.json\n"))

# ============================================================================
# Step 5: Data preview
# ============================================================================
cat("\n=== Step 5: Data Preview ===\n")

if (is.data.frame(data_to_save)) {
  cat(sprintf("\nDataFrame with %d rows and %d columns\n", nrow(data_to_save), ncol(data_to_save)))
  cat("\nFirst 5 rows:\n")
  print(head(data_to_save, n = 5))
  
  cat("\n\nColumn names:\n")
  print(names(data_to_save))
  
} else if (is.list(data_to_save) && !is.data.frame(data_to_save)) {
  cat(sprintf("List with %d elements\n", length(data_to_save)))
  cat("\nData structure:\n")
  str(data_to_save, max.level = 2)
}

# ============================================================================
# Step 6: Verify .gitignore
# ============================================================================
cat("\n=== Step 6: Verifying Git Exclusion ===\n")

if (file.exists(".gitignore")) {
  gitignore_content <- readLines(".gitignore")
  if (any(grepl("^data/", gitignore_content))) {
    cat("✓ data/ directory is excluded from Git\n")
  } else {
    cat("⚠ data/ directory may not be properly excluded\n")
  }
} else {
  cat("⚠ .gitignore file not found\n")
}

# ============================================================================
# Summary
# ============================================================================
cat("\n========================================\n")
cat("      EnvSample Download Complete\n")
cat("========================================\n")

cat("\nFiles saved to data/ (NOT in GitHub):\n")
cat("  - EnvSample.json            (Full JSON structure)\n")
if (is.data.frame(data_to_save)) {
  cat("  - EnvSample.csv             (CSV format)\n")
}
cat("  - EnvSample.rds             (R native format - recommended)\n")
cat("  - EnvSample_metadata.json   (Download metadata)\n")

cat("\nTo load data in future R sessions:\n")
cat("  # Load RDS (recommended)\n")
cat("  envsample <- readRDS('data/EnvSample.rds')\n")
cat("  \n")
cat("  # Load CSV\n")
cat("  envsample <- read.csv('data/EnvSample.csv')\n")
cat("  \n")
cat("  # Load JSON\n")
cat("  envsample <- jsonlite::fromJSON('data/EnvSample.json')\n")

cat("\nFile location: data/EnvSample.*\n")
cat("Git status: EXCLUDED (not tracked by Git)\n")

cat("\n========================================\n")

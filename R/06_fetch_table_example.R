# Example: Fetch POLIS Table Endpoint Data
# This script demonstrates how to use poli_fetch_table() to retrieve data
# from any POLIS API V2 endpoint and return it as a tibble
#
# Usage: source("R/06_fetch_table_example.R")

cat("\n========================================\n")
cat("   POLI Table Fetch Example\n")
cat("========================================\n")

# Load API configuration
source("R/03_poli_api_config.R")

# ============================================================================
# Example 1: Fetch EnvSample endpoint (50 rows)
# ============================================================================
cat("\n\n=== EXAMPLE 1: Fetch EnvSample (50 rows) ===\n")
cat("Function call: env_data <- poli_fetch_table('envsample', n_rows = 50)\n\n")

env_data <- poli_fetch_table(endpoint = "envsample", n_rows = 50, verbose = TRUE)

if (!is.null(env_data)) {
  cat("\n✓ Successfully retrieved EnvSample data as tibble\n")
  cat(sprintf("Dimensions: %d rows × %d columns\n", nrow(env_data), ncol(env_data)))
  
  cat("\nColumn names:\n")
  print(names(env_data))
  
  cat("\nFirst 6 rows:\n")
  print(head(env_data))
  
  cat("\nData summary:\n")
  print(summary(env_data))
} else {
  cat("✗ Failed to retrieve data (check API connection and credentials)\n")
}

# ============================================================================
# Example 2: Fetch other endpoints
# ============================================================================
cat("\n\n=== EXAMPLE 2: Other Available Endpoints ===\n")

available_endpoints <- list(
  virus = "Virus records",
  case = "Polio cases",
  humanspecimen = "Human specimen samples",
  envsample = "Environmental samples",
  activity = "Activities/events",
  subactivity = "Sub-activities",
  indicators = "Indicators"
)

cat("\nYou can fetch any of these endpoints using poli_fetch_table():\n")
for (ep_name in names(available_endpoints)) {
  cat(sprintf("  • %s - %s\n", ep_name, available_endpoints[[ep_name]]))
}

cat("\nExample usage:\n")
cat("  cases <- poli_fetch_table('case', n_rows = 100)\n")
cat("  virus <- poli_fetch_table('virus', n_rows = 50)\n")
cat("  specimens <- poli_fetch_table('humanspecimen', n_rows = 200)\n")

# ============================================================================
# Example 3: Working with returned tibble
# ============================================================================
if (!is.null(env_data)) {
  cat("\n\n=== EXAMPLE 3: Working with Tibble Data ===\n")
  
  # Convert to regular data frame if needed
  cat("\nConvert to data frame:\n")
  df <- as.data.frame(env_data)
  cat(sprintf("  class(df) = %s\n", class(df)[1]))
  
  # Filter rows
  cat("\nFilter rows (using base R):\n")
  cat("  filtered <- env_data[env_data$column_name == 'value', ]\n")
  
  # Select columns
  cat("\nSelect specific columns (if they exist):\n")
  cat("  subset <- env_data[, c('col1', 'col2', 'col3')]\n")
  
  # Use dplyr if available
  cat("\nWith dplyr package:\n")
  cat("  library(dplyr)\n")
  cat("  env_data %>%\n")
  cat("    filter(column_name == 'value') %>%\n")
  cat("    select(col1, col2, col3) %>%\n")
  cat("    arrange(column_name)\n")
  
  # Save to file
  cat("\nSave tibble to file:\n")
  cat("  write.csv(env_data, 'envsample_export.csv', row.names = FALSE)\n")
  cat("  saveRDS(env_data, 'envsample_export.rds')\n")
}

# ============================================================================
# Function Reference
# ============================================================================
cat("\n\n=== Function Reference: poli_fetch_table() ===\n")

cat("\nFunction signature:\n")
cat("  poli_fetch_table(endpoint, n_rows = 100, verbose = TRUE)\n")

cat("\nParameters:\n")
cat("  endpoint (character)  - POLIS API V2 endpoint name\n")
cat("                         Valid: 'virus', 'case', 'humanspecimen',\n")
cat("                                 'envsample', 'activity', 'subactivity',\n")
cat("                                 'indicators'\n")
cat("  n_rows (numeric)      - Number of rows to retrieve (default: 100)\n")
cat("                         API pagination uses Skip=0, Take=n_rows\n")
cat("  verbose (logical)     - Display status messages (default: TRUE)\n")

cat("\nReturn value:\n")
cat("  A tibble with the requested data, or NULL if fetch fails\n")

cat("\nFeatures:\n")
cat("  ✓ Automatic pagination handling (Skip/Take parameters)\n")
cat("  ✓ Converts response to tibble format\n")
cat("  ✓ Handles nested JSON structures\n")
cat("  ✓ Validates endpoint names\n")
cat("  ✓ Provides verbose status messages\n")
cat("  ✓ Error handling with informative messages\n")

# ============================================================================
# Troubleshooting
# ============================================================================
cat("\n\n=== Troubleshooting ===\n")

cat("\nIf poli_fetch_table() returns NULL:\n")
cat("  1. Check API connection:\n")
cat("     source('R/03_poli_api_config.R')\n")
cat("     poli_test_connection()\n\n")
cat("  2. Verify API key is valid\n")
cat("     Edit R/03_poli_api_config.R and check POLI_API_KEY\n\n")
cat("  3. Confirm endpoint name is correct\n")
cat("     Use one of: virus, case, humanspecimen, envsample,\n")
cat("                 activity, subactivity, indicators\n\n")
cat("  4. Check for API rate limits\n")
cat("     Wait a few seconds and try again\n\n")
cat("  5. Contact WHO POLIS support\n")
cat("     Email: polis@who.int\n")
cat("     Request API V2 documentation and authentication details\n")

cat("\n========================================\n")
cat("   Example Complete\n")
cat("========================================\n\n")

# Polio Data Fetching Script
# This script fetches polio case data from the POLI API and saves it
# Usage: source("R/04_fetch_polio_data.R")

cat("\n========================================\n")
cat("   Fetching Polio Data from POLI API\n")
cat("========================================\n")

# Load API configuration
source("R/03_poli_api_config.R")

# ============================================================================
# Step 1: Test connection
# ============================================================================
cat("\n=== Step 1: Testing API Connection ===\n")
connection_ok <- poli_test_connection()

if (!connection_ok) {
  cat("\n✗ API connection failed. Please check:\n")
  cat("  1. Internet connection\n")
  cat("  2. API key validity\n")
  cat("  3. API endpoint accessibility\n")
  stop("Cannot continue without API connection")
}

# ============================================================================
# Step 2: Fetch cases data
# ============================================================================
cat("\n=== Step 2: Fetching Polio Cases ===\n")
cases_result <- poli_get_cases()

if (!is.null(cases_result$data)) {
  # Save cases data
  poli_save_response(cases_result, "polio_cases.csv")
} else {
  cat("✗ Failed to fetch cases data\n")
  if (!is.null(cases_result$error)) {
    cat("Error: ", cases_result$error, "\n")
  }
}

# ============================================================================
# Step 3: Fetch countries data
# ============================================================================
cat("\n=== Step 3: Fetching Countries ===\n")
countries_result <- poli_get_countries()

if (!is.null(countries_result$data)) {
  # Save countries data
  poli_save_response(countries_result, "countries.csv")
} else {
  cat("✗ Failed to fetch countries data\n")
}

# ============================================================================
# Step 4: Display summary
# ============================================================================
cat("\n========================================\n")
cat("      Data Fetch Complete\n")
cat("========================================\n")

cat("\nData files saved to: data/\n")
cat("  - polio_cases.csv\n")
cat("  - polio_cases.json\n")
cat("  - countries.csv\n")
cat("  - countries.json\n")

cat("\nNext steps:\n")
cat("  1. Review the fetched data\n")
cat("  2. Clean and process data for analysis\n")
cat("  3. Create visualizations\n")
cat("  4. Generate reports\n")

cat("\n========================================\n")

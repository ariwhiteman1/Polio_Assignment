# POLI API Configuration - Working with WHO POLIS API
# This script provides templates and utilities for connecting to POLIS
# Usage: source("R/03_poli_api_config.R")

cat("\n========================================\n")
cat("    POLI API Configuration\n")
cat("========================================\n")

# ============================================================================
# Install required packages
# ============================================================================
cat("\n=== Installing required packages ===\n")

if (is.null(getOption("repos"))) {
  options(repos = c(CRAN = "https://cran.r-project.org/"))
}

required_packages <- c("httr", "jsonlite")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    tryCatch({
      install.packages(pkg, repos = "https://cran.r-project.org/")
      library(pkg, character.only = TRUE)
    }, error = function(e) {
      cat(sprintf("Warning: Could not install %s\n", pkg))
    })
  }
}

cat("✓ Required packages loaded\n")

# ============================================================================
# POLI API Configuration
# ============================================================================
cat("\n=== API Configuration ===\n")

# API credentials
POLI_API_KEY <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"
POLI_BASE_URL <- "https://extranet.who.int/polis/"
POLI_API_V2 <- "https://extranet.who.int/polis/api/v2/"

# API endpoints based on POLIS API V2 documentation
POLI_ENDPOINTS <- list(
  virus = "virus",
  case = "case",
  human_specimen = "humanspecimen",
  env_sample = "envsample",
  activity = "activity",
  sub_activity = "subactivity",
  indicators = "indicators"
)

cat(sprintf("Base URL: %s\n", POLI_BASE_URL))
cat(sprintf("API V2 Base: %s\n", POLI_API_V2))
cat("✓ API credentials configured\n")

# ============================================================================
# Function: Create API headers
# ============================================================================
poli_get_headers <- function(auth_type = "bearer") {
  if (auth_type == "bearer") {
    return(httr::add_headers(
      Authorization = paste("Bearer", POLI_API_KEY),
      'Content-Type' = 'application/json'
    ))
  }
  return(httr::add_headers('Content-Type' = 'application/json'))
}

# ============================================================================
# Function: Test API connection
# ============================================================================
poli_test_connection <- function(verbose = TRUE) {
  if(verbose) cat("\nTesting API connection to POLIS...\n")
  
  tryCatch({
    # Test main POLIS page
    r1 <- httr::GET(POLI_BASE_URL, httr::timeout(10))
    base_status <- httr::status_code(r1)
    
    # Test API V2 endpoint
    r2 <- httr::GET(
      POLI_API_V2, 
      poli_get_headers(),
      httr::timeout(10)
    )
    api_status <- httr::status_code(r2)
    
    if(verbose) {
      cat(sprintf("  Base POLIS URL: %d\n", base_status))
      cat(sprintf("  API V2 Endpoint: %d\n", api_status))
    }
    
    return(list(
      connected = TRUE,
      base_status = base_status,
      api_status = api_status,
      timestamp = Sys.time()
    ))
  }, error = function(e) {
    if(verbose) {
      cat(sprintf("✗ Connection error: %s\n", e$message))
    }
    return(list(
      connected = FALSE,
      error = e$message,
      timestamp = Sys.time()
    ))
  })
}

# ============================================================================
# Function: Make authenticated API request
# ============================================================================
poli_request <- function(endpoint, method = "GET", params = NULL, body = NULL, verbose = TRUE) {
  url <- paste0(POLI_API_V2, endpoint)
  
  if(verbose) cat(sprintf("Request: %s %s\n", method, endpoint))
  
  tryCatch({
    if (method == "GET") {
      response <- httr::GET(
        url,
        poli_get_headers(),
        query = params,
        httr::timeout(30)
      )
    } else if (method == "POST") {
      response <- httr::POST(
        url,
        poli_get_headers(),
        body = jsonlite::toJSON(body),
        httr::timeout(30)
      )
    } else {
      stop(sprintf("Unsupported method: %s", method))
    }
    
    status <- httr::status_code(response)
    
    if(verbose) cat(sprintf("Status: %d\n", status))
    
    # Try to parse response
    if (status == 200) {
      content_text <- httr::content(response, as = "text")
      data <- tryCatch(
        jsonlite::fromJSON(content_text),
        error = function(e) content_text
      )
      
      return(list(
        status = status,
        data = data,
        success = TRUE,
        timestamp = Sys.time()
      ))
    } else {
      error_text <- httr::content(response, as = "text")
      if(verbose && nchar(error_text) < 200) cat(sprintf("Error: %s\n", error_text))
      
      return(list(
        status = status,
        data = NULL,
        success = FALSE,
        error = error_text,
        timestamp = Sys.time()
      ))
    }
  }, error = function(e) {
    if(verbose) cat(sprintf("✗ Request error: %s\n", e$message))
    return(list(
      status = NA,
      data = NULL,
      success = FALSE,
      error = e$message,
      timestamp = Sys.time()
    ))
  })
}

# ============================================================================
# Function: Save API response to file
# ============================================================================
poli_save_data <- function(response, filename, format = "both") {
  if (!response$success || is.null(response$data)) {
    cat("✗ No data to save\n")
    return(FALSE)
  }
  
  tryCatch({
    if (!dir.exists("data")) {
      dir.create("data", showWarnings = FALSE)
    }
    
    filepath <- file.path("data", filename)
    
    # Save as CSV if data is a data frame
    if ((format == "csv" || format == "both") && is.data.frame(response$data)) {
      write.csv(response$data, filepath, row.names = FALSE)
      cat(sprintf("✓ Saved CSV: %s\n", filename))
    }
    
    # Save as JSON
    if (format == "json" || format == "both") {
      json_file <- sub("\\.csv$", ".json", filepath)
      json_str <- jsonlite::toJSON(response$data, pretty = TRUE)
      writeLines(json_str, json_file)
      cat(sprintf("✓ Saved JSON: %s\n", basename(json_file)))
    }
    
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ Error saving: %s\n", e$message))
    return(FALSE)
  })
}

# ============================================================================
# Display Information
# ============================================================================
cat("\n========================================\n")
cat("   POLI API Configuration Complete\n")
cat("========================================\n")

cat("\n✓ Using POLIS API V2 endpoint structure\n")
cat("API Base URL: https://extranet.who.int/polis/api/v2/\n")

cat("\nAvailable endpoints:\n")
for(ep_name in names(POLI_ENDPOINTS)) {
  cat(sprintf("  - %s: %s\n", ep_name, POLI_ENDPOINTS[[ep_name]]))
}

cat("\nAvailable functions:\n")
cat("  poli_test_connection()         - Test API connectivity\n")
cat("  poli_request(endpoint, method) - Make API request\n")
cat("  poli_save_data(response, file) - Save response to CSV/JSON\n")

cat("\nUsage Example:\n")
cat("  source('R/03_poli_api_config.R')\n")
cat("  poli_test_connection()         # Test connection\n")
cat("  result <- poli_request('envsample')\n")
cat("  if(result$success) {\n")
cat("    poli_save_data(result, 'envsample.csv')\n")
cat("  }\n")

cat("\nWHO POLIS Resources:\n")
cat("  - Main: https://extranet.who.int/polis/\n")
cat("  - API Documentation available in POLIS Help\n")
cat("  - API Key: Configured in this script\n")

cat("\nTroubleshooting:\n")
cat("  1. Verify internet connection\n")
cat("  2. Check API key validity\n")
cat("  3. Confirm endpoint names match POLIS API V2\n")
cat("  4. Contact WHO support for API documentation\n")

cat("\n========================================\n")

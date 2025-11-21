# POLI API Connection Script
# This script connects to the POLI API for data retrieval
# Usage: source("R/03_poli_api.R")

# ============================================================================
# POLI API Configuration
# ============================================================================

# Install and load required packages
required_packages <- c("httr", "jsonlite", "dplyr", "tibble")

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

# API Configuration
POLI_API_BASE_URL <- "https://api.polisci.psu.edu"  # Base URL (verify with documentation)
POLI_API_KEY <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"

# ============================================================================
# Helper Functions for POLI API
# ============================================================================

#' Connect to POLI API
#' 
#' @description Establishes connection to POLI API with authentication
#' 
#' @return Logical - TRUE if connection successful, FALSE otherwise
#'
poli_connect <- function() {
  cat("\n=== Connecting to POLI API ===\n")
  
  tryCatch({
    # Create headers with API key
    headers <- add_headers(
      "Authorization" = paste("Bearer", POLI_API_KEY),
      "Content-Type" = "application/json"
    )
    
    # Test connection with a simple endpoint
    response <- GET(
      paste0(POLI_API_BASE_URL, "/status"),
      headers,
      timeout(10)
    )
    
    # Check response status
    if (status_code(response) == 200) {
      cat("✓ Successfully connected to POLI API\n")
      return(TRUE)
    } else if (status_code(response) == 401) {
      cat("✗ Authentication failed - Check API key\n")
      return(FALSE)
    } else {
      cat(sprintf("✗ Connection error - Status code: %d\n", status_code(response)))
      return(FALSE)
    }
  }, error = function(e) {
    cat(sprintf("✗ Connection error: %s\n", e$message))
    return(FALSE)
  })
}

#' Get POLI API Status
#' 
#' @description Check the current status of the POLI API
#' 
#' @return List containing API status information
#'
poli_status <- function() {
  cat("Checking POLI API status...\n")
  
  tryCatch({
    headers <- add_headers(
      "Authorization" = paste("Bearer", POLI_API_KEY),
      "Content-Type" = "application/json"
    )
    
    response <- GET(
      paste0(POLI_API_BASE_URL, "/status"),
      headers,
      timeout(10)
    )
    
    if (status_code(response) == 200) {
      status_data <- content(response, as = "parsed")
      return(status_data)
    } else {
      cat(sprintf("Error: Status code %d\n", status_code(response)))
      return(NULL)
    }
  }, error = function(e) {
    cat(sprintf("Error: %s\n", e$message))
    return(NULL)
  })
}

#' Query POLI API
#' 
#' @description Make a GET request to the POLI API
#' 
#' @param endpoint Character - API endpoint (e.g., "/polio/cases")
#' @param params List - Optional query parameters
#' 
#' @return List - Response data from API
#'
poli_query <- function(endpoint, params = NULL) {
  cat(sprintf("Querying POLI API: %s\n", endpoint))
  
  tryCatch({
    headers <- add_headers(
      "Authorization" = paste("Bearer", POLI_API_KEY),
      "Content-Type" = "application/json"
    )
    
    url <- paste0(POLI_API_BASE_URL, endpoint)
    
    # Add query parameters if provided
    if (!is.null(params)) {
      response <- GET(url, headers, query = params, timeout(30))
    } else {
      response <- GET(url, headers, timeout(30))
    }
    
    if (status_code(response) == 200) {
      data <- content(response, as = "parsed")
      cat(sprintf("✓ Successfully retrieved data from %s\n", endpoint))
      return(data)
    } else {
      cat(sprintf("✗ Error: Status code %d\n", status_code(response)))
      cat(sprintf("Response: %s\n", content(response, as = "text")))
      return(NULL)
    }
  }, error = function(e) {
    cat(sprintf("✗ Error querying API: %s\n", e$message))
    return(NULL)
  })
}

#' Get Data from POLI API Table Endpoint
#' 
#' @description Retrieve data from any POLI API table endpoint and return as a tibble
#' 
#' @param endpoint Character - API endpoint (e.g., "/polio/cases", "/polio/sir")
#' @param n_rows Numeric - Number of rows to retrieve (default: 100)
#' @param filters List - Optional query filters to apply
#' 
#' @return Tibble - Data from the API endpoint with specified number of rows
#' 
#' @examples
#' \dontrun{
#'   # Get 50 rows from cases endpoint
#'   cases <- poli_get_table("/polio/cases", n_rows = 50)
#'   
#'   # Get 100 rows from SIR endpoint
#'   sir <- poli_get_table("/polio/sir", n_rows = 100)
#'   
#'   # Get cases with country filter
#'   usa_cases <- poli_get_table("/polio/cases", n_rows = 50, 
#'                               filters = list(country = "USA"))
#' }
#'
poli_get_table <- function(endpoint, n_rows = 100, filters = NULL) {
  cat(sprintf("Retrieving %d rows from %s...\n", n_rows, endpoint))
  
  # Create query parameters
  params <- list(limit = n_rows)
  
  # Add any additional filters
  if (!is.null(filters)) {
    params <- c(params, filters)
  }
  
  # Make API query
  data <- poli_query(endpoint, params = params)
  
  if (!is.null(data)) {
    # Handle different response structures
    if (is.list(data) && !is.null(data$data)) {
      # If response has nested 'data' field
      df <- as.data.frame(data$data)
    } else if (is.list(data) && length(data) > 0) {
      # If response is directly a list of records
      df <- as.data.frame(data)
    } else {
      cat("✗ Unexpected data structure returned from API\n")
      return(NULL)
    }
    
    # Convert to tibble
    tbl <- as_tibble(df)
    
    # Display summary
    cat(sprintf("✓ Retrieved %d rows and %d columns\n", nrow(tbl), ncol(tbl)))
    cat(sprintf("Columns: %s\n", paste(names(tbl), collapse = ", ")))
    
    return(tbl)
  }
  
  return(NULL)
}

#' Get Polio Cases
#' 
#' @description Retrieve polio case data from POLI API
#' 
#' @param filters List - Optional filters (e.g., list(country = "USA", year = 2024))
#' 
#' @return Data frame - Polio case data
#'
poli_get_cases <- function(filters = NULL) {
  cat("Retrieving polio case data...\n")
  
  data <- poli_query("/polio/cases", params = filters)
  
  if (!is.null(data)) {
    # Convert to data frame if it's a list
    if (is.list(data) && !is.null(data$data)) {
      df <- as.data.frame(data$data)
      cat(sprintf("✓ Retrieved %d records\n", nrow(df)))
      return(df)
    } else if (is.list(data)) {
      cat("Data structure: List\n")
      return(data)
    }
  }
  return(NULL)
}

#' Get Polio SIR Data
#' 
#' @description Retrieve SIR (Suspected, Isolated, Reported) data
#' 
#' @param filters List - Optional filters
#' 
#' @return Data frame - SIR data
#'
poli_get_sir <- function(filters = NULL) {
  cat("Retrieving SIR data...\n")
  
  data <- poli_query("/polio/sir", params = filters)
  
  if (!is.null(data)) {
    if (is.list(data) && !is.null(data$data)) {
      df <- as.data.frame(data$data)
      cat(sprintf("✓ Retrieved %d SIR records\n", nrow(df)))
      return(df)
    } else if (is.list(data)) {
      return(data)
    }
  }
  return(NULL)
}

#' Save API Response to File
#' 
#' @description Save API response data to a CSV file
#' 
#' @param data Data frame - Data to save
#' @param filename Character - Output filename
#' @param dir Character - Output directory (default: "output")
#'
poli_save_data <- function(data, filename, dir = "output") {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  
  filepath <- file.path(dir, filename)
  write.csv(data, filepath, row.names = FALSE)
  cat(sprintf("✓ Data saved to: %s\n", filepath))
}

# ============================================================================
# Display Available Functions
# ============================================================================
cat("\n========================================\n")
cat("    POLI API Helper Functions Loaded\n")
cat("========================================\n")
cat("\nAvailable functions:\n")
cat("  poli_connect()              - Test connection to POLI API\n")
cat("  poli_status()               - Check API status\n")
cat("  poli_query(endpoint)        - Make custom API query\n")
cat("  poli_get_table()            - Get data from any table endpoint as tibble\n")
cat("  poli_get_cases()            - Get polio cases\n")
cat("  poli_get_sir()              - Get SIR data\n")
cat("  poli_save_data()            - Save data to CSV\n")
cat("\nExample usage:\n")
cat("  poli_connect()                                # Test connection\n")
cat("  cases <- poli_get_table('/polio/cases', n_rows = 50)\n")
cat("  sir <- poli_get_table('/polio/sir', n_rows = 100)\n")
cat("  poli_save_data(cases, 'cases.csv')\n")
cat("========================================\n\n")

# Test various endpoint paths for EnvSample data
# This explores alternative API paths to find the correct endpoint

library(httr)
library(jsonlite)

# API credentials
api_key <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"
headers <- add_headers(Authorization = paste("Bearer", api_key))

cat("\nTesting alternative EnvSample endpoint paths:\n\n")

# Test variations of EnvSample endpoint
endpoints_to_test <- c(
  # Standard paths
  "https://extranet.who.int/polis/api2/EnvSample",
  "https://extranet.who.int/polis/api2/envsample",
  "https://extranet.who.int/polis/api2/env-sample",
  "https://extranet.who.int/polis/api2/env_sample",
  
  # Alternative API versions
  "https://extranet.who.int/polis/api/EnvSample",
  "https://extranet.who.int/polis/api/v2/EnvSample",
  
  # Without trailing path
  "https://extranet.who.int/polis/api2/environmental-sample",
  "https://extranet.who.int/polis/api2/samples",
  "https://extranet.who.int/polis/api2/env-samples",
  
  # Direct base URL with parameters
  "https://extranet.who.int/polis/api2",
  
  # Root API
  "https://extranet.who.int/polis/api"
)

cat("Endpoint Testing Results:\n")
cat(strrep("-", 80), "\n")

for(endpoint in endpoints_to_test) {
  tryCatch({
    r <- GET(endpoint, headers, timeout(10))
    status <- status_code(r)
    
    # Check content type
    content_type <- headers(r)$"content-type"
    content_length <- headers(r)$"content-length"
    
    cat(sprintf("%-65s | %3d | ", substr(endpoint, 1, 65), status))
    
    if(status == 200) {
      content_text <- content(r, as = "text")
      if(nchar(content_text) > 100) {
        cat(sprintf("%s...\n", substr(content_text, 1, 30)))
      } else {
        cat("JSON/Data response\n")
      }
    } else {
      cat("No data\n")
    }
    
  }, error = function(e) {
    cat(sprintf("%-65s | ERR | %s\n", substr(endpoint, 1, 65), e$message))
  })
}

cat(strrep("-", 80), "\n")

cat("\nSummary:\n")
cat("If you see status 200 with JSON content, that's the correct endpoint.\n")
cat("If all endpoints return 404, the API may require:\n")
cat("  1. Different authentication method\n")
cat("  2. Query parameters\n")
cat("  3. Different base URL\n")
cat("  4. Contact WHO for correct API documentation\n\n")

# Script to explore POLI API structure
# This will help identify the correct endpoints

library(httr)
library(jsonlite)

# API credentials
api_key <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"
base_url <- "https://extranet.who.int/polis/api2/"

# Create headers
headers <- add_headers(Authorization = paste("Bearer", api_key))

cat("Testing various API endpoints...\n\n")

# Test 1: Root endpoint
cat("Test 1: Root endpoint\n")
r <- GET(base_url, headers, timeout(10))
cat(sprintf("Status: %d\n", status_code(r)))
if(status_code(r) %in% c(200, 201, 401)) {
  content_text <- content(r, as = "text")
  cat("Response preview:\n")
  cat(substr(content_text, 1, 500), "\n\n")
}

# Test 2: With trailing slash removed
cat("Test 2: Root without trailing slash\n")
base_no_slash <- "https://extranet.who.int/polis/api2"
r <- GET(base_no_slash, headers, timeout(10))
cat(sprintf("Status: %d\n\n", status_code(r)))

# Test 3: Different API versions
cat("Test 3: API version 1\n")
r <- GET("https://extranet.who.int/polis/api/", headers, timeout(10))
cat(sprintf("Status: %d\n\n", status_code(r)))

# Test 4: Cases endpoint variations
endpoints_to_try <- c(
  "https://extranet.who.int/polis/api2/cases",
  "https://extranet.who.int/polis/api/cases",
  "https://extranet.who.int/polis/api2/case",
  "https://extranet.who.int/polis/cases",
  "https://extranet.who.int/polis/api2/list",
  "https://extranet.who.int/polis/api2/data",
  "https://extranet.who.int/polis/api/2/cases"
)

cat("Testing case endpoint variations:\n")
for(ep in endpoints_to_try) {
  tryCatch({
    r <- GET(ep, headers, timeout(10))
    cat(sprintf("  %s: %d\n", ep, status_code(r)))
  }, error = function(e) {
    cat(sprintf("  %s: ERROR\n", ep))
  })
}

cat("\n")
cat("Additional resources:\n")
cat("- Check API documentation at: https://extranet.who.int/polis/\n")
cat("- Contact WHO support for correct API endpoints\n")

# Diagnostic script to test POLI API authentication and endpoints
library(httr)
library(jsonlite)

api_key <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"
base_url <- "https://extranet.who.int/polis/api/v2/"

cat("\n=== Diagnostic Test: POLI API V2 ===\n\n")

# Test 1: Try with Bearer token
cat("Test 1: With Bearer Token Authorization\n")
headers1 <- add_headers(Authorization = paste("Bearer", api_key))
r1 <- GET(paste0(base_url, "envsample?Skip=0&Take=10"), headers1, timeout(10))
cat(sprintf("Status: %d\n", status_code(r1)))
if(status_code(r1) != 200) {
  cat("Response headers:\n")
  print(headers(r1))
  cat("\nResponse content:\n")
  cat(substr(content(r1, as="text"), 1, 300))
}

cat("\n\nTest 2: With Different Auth Header Format\n")
# Try with quotes around the key
headers2 <- add_headers(Authorization = sprintf("Bearer %s", api_key))
r2 <- GET(paste0(base_url, "envsample?Skip=0&Take=10"), headers2, timeout(10))
cat(sprintf("Status: %d\n", status_code(r2)))

cat("\n\nTest 3: Without Authorization Header\n")
r3 <- GET(paste0(base_url, "envsample?Skip=0&Take=10"), timeout(10))
cat(sprintf("Status: %d\n", status_code(r3)))

cat("\n\nTest 4: Check available endpoints at API root\n")
r4 <- GET(base_url, headers1, timeout(10))
cat(sprintf("Status: %d\n", status_code(r4)))
if(status_code(r4) == 200) {
  cat("Content:\n")
  print(content(r4, as="text"))
}

cat("\n\nTest 5: Try different endpoint paths\n")
endpoints <- c(
  "envsample",
  "envsample/",
  "environmental-sample",
  "EnvironmentalSample",
  "EnvironmentalSamples"
)

for(ep in endpoints) {
  tryCatch({
    r <- GET(paste0(base_url, ep, "?Skip=0&Take=1"), headers1, timeout(10))
    cat(sprintf("%-30s: %d\n", ep, status_code(r)))
  }, error = function(e) {
    cat(sprintf("%-30s: ERROR\n", ep))
  })
}

cat("\n=== Diagnostic Complete ===\n")

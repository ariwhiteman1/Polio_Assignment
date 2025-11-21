# Test POST request with parameters in body
# This tests if the POLIS API requires POST with body parameters instead of GET query params

library(httr)
library(jsonlite)

api_key <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"

cat("\n========================================\n")
cat("   Test POLIS API - Alternative Request Formats\n")
cat("========================================\n")

# Test 1: POST with JSON body
cat("\n=== Test 1: POST with JSON body ===\n")
url <- "https://extranet.who.int/polis/api/v2/EnvSample"
cat(sprintf("URL: %s\n", url))
cat("Method: POST\n")
cat("Body: {\"Skip\": 0, \"Take\": 10}\n\n")

r1 <- POST(
  url,
  add_headers(
    Authorization = paste("Bearer", api_key),
    `Content-Type` = "application/json",
    Accept = "application/json"
  ),
  body = toJSON(list(Skip = 0, Take = 10)),
  timeout(10)
)

cat(sprintf("Status: %d\n", status_code(r1)))
content_text <- content(r1, as = "text")
if (nchar(content_text) > 0 && nchar(content_text) < 500) {
  cat(sprintf("Response: %s\n", content_text))
}

# Test 2: GET with query params in URL
cat("\n\n=== Test 2: GET with query params ===\n")
url2 <- "https://extranet.who.int/polis/api/v2/EnvSample?Skip=0&Take=10"
cat(sprintf("URL: %s\n", url2))
cat("Method: GET\n\n")

r2 <- GET(
  url2,
  add_headers(
    Authorization = paste("Bearer", api_key),
    Accept = "application/json"
  ),
  timeout(10)
)

cat(sprintf("Status: %d\n", status_code(r2)))
content_text2 <- content(r2, as = "text")
if (nchar(content_text2) > 0 && nchar(content_text2) < 500) {
  cat(sprintf("Response: %s\n", content_text2))
}

# Test 3: GET with query parameter object
cat("\n\n=== Test 3: GET with query parameter object ===\n")
url3 <- "https://extranet.who.int/polis/api/v2/EnvSample"
cat(sprintf("URL: %s\n", url3))
cat("Method: GET with query params\n\n")

r3 <- GET(
  url3,
  add_headers(
    Authorization = paste("Bearer", api_key),
    Accept = "application/json"
  ),
  query = list(Skip = 0, Take = 10),
  timeout(10)
)

cat(sprintf("Status: %d\n", status_code(r3)))
content_text3 <- content(r3, as = "text")
if (nchar(content_text3) > 0 && nchar(content_text3) < 500) {
  cat(sprintf("Response: %s\n", content_text3))
}

# Test 4: Check if response has useful headers
cat("\n\n=== Response Headers (Test 1) ===\n")
headers <- headers(r1)
for (h in names(headers)) {
  cat(sprintf("%s: %s\n", h, headers[[h]]))
}

cat("\n========================================\n")

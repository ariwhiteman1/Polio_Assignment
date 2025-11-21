# Advanced diagnostic - try alternative API approaches
library(httr)

api_key <- "BRfIZj%2fI9B3MwdWKtLzG%2bkpEHdJA31u5cB2TjsCFZDdMZqsUPNrgiKBhPv3CeYRg4wrJKTv6MP9UidsGE9iIDmaOs%2bGZU3CP5ZjZnaBNbS0uiHWWhK8Now3%2bAYfjxkuU1fLiC2ypS6m8Jy1vxWZlskiPyk6S9IV2ZFOFYkKXMIw%3d"

cat("\n=== Alternative API Endpoint Tests ===\n\n")

# Test different base URLs
base_urls <- c(
  "https://extranet.who.int/polis/api/v2/",
  "https://extranet.who.int/polis/api/",
  "https://extranet.who.int/polis/REST/v1/",
  "https://extranet.who.int/api/v2/",
  "https://polis-api.who.int/v2/"
)

cat("Testing different base URLs:\n")
for(base in base_urls) {
  tryCatch({
    r <- GET(paste0(base, "envsample"), 
             add_headers(Authorization = paste("Bearer", api_key)),
             timeout(5))
    cat(sprintf("%-50s: %d\n", base, status_code(r)))
  }, error = function(e) {
    cat(sprintf("%-50s: ERROR\n", base))
  })
}

cat("\n\nTesting with POST method:\n")
r_post <- POST("https://extranet.who.int/polis/api/v2/envsample",
               add_headers(Authorization = paste("Bearer", api_key),
                          'Content-Type' = 'application/json'),
               body = jsonlite::toJSON(list(Skip = 0, Take = 10)),
               timeout(10))
cat(sprintf("POST Status: %d\n", status_code(r_post)))

cat("\n\nTesting alternative token formats:\n")
# Try URL-encoded token
token_formats <- list(
  paste("Bearer", api_key),
  paste("token=", api_key),
  paste("apikey=", api_key),
  api_key
)

for(i in seq_along(token_formats)) {
  tryCatch({
    r <- GET("https://extranet.who.int/polis/api/v2/envsample?Skip=0&Take=1",
             add_headers(Authorization = token_formats[[i]]),
             timeout(5))
    cat(sprintf("Format %d: %d\n", i, status_code(r)))
  }, error = function(e) {
    cat(sprintf("Format %d: ERROR\n", i))
  })
}

cat("\n=== Alternative Tests Complete ===\n")

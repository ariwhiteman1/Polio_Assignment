# Function to generate flextable of ES sites by country and region
# Usage: source("R/09_es_sites_flextable.R")

cat("\n========================================\n")
cat("   ES Sites Summary by Country & Region\n")
cat("========================================\n\n")

# Install flextable if needed
if (!require("flextable", character.only = TRUE)) {
  cat("Installing flextable package...\n")
  install.packages("flextable", repos = "https://cran.r-project.org/")
  library("flextable")
}

if (!require("dplyr", character.only = TRUE)) {
  cat("Installing dplyr package...\n")
  install.packages("dplyr", repos = "https://cran.r-project.org/")
  library("dplyr")
}

# ============================================================================
# Function: Generate ES Sites Flextable
# ============================================================================
create_es_sites_flextable <- function(envsample_data = NULL, verbose = TRUE) {
  
  if(verbose) cat("\n=== Creating ES Sites Flextable ===\n")
  
  # Load data if not provided
  if (is.null(envsample_data)) {
    if(verbose) cat("Loading EnvSample data from RDS...\n")
    
    if (!file.exists("data/EnvSample.rds")) {
      cat("✗ EnvSample.rds not found\n")
      cat("Please run R/07_fetch_envsample_full.R first to download the data\n")
      return(NULL)
    }
    
    envsample_data <- readRDS("data/EnvSample.rds")
  }
  
  # Verify data structure
  if (!is.data.frame(envsample_data)) {
    cat("✗ Input must be a data frame or tibble\n")
    return(NULL)
  }
  
  required_cols <- c("Admin0Name", "WHORegion", "SiteName")
  missing_cols <- setdiff(required_cols, names(envsample_data))
  
  if (length(missing_cols) > 0) {
    cat(sprintf("✗ Missing required columns: %s\n", paste(missing_cols, collapse=", ")))
    return(NULL)
  }
  
  if(verbose) cat(sprintf("Processing %d records...\n", nrow(envsample_data)))
  
  # Create summary by country and region
  sites_summary <- envsample_data %>%
    filter(!is.na(Admin0Name) & !is.na(WHORegion) & !is.na(SiteName)) %>%
    group_by(Admin0Name, WHORegion) %>%
    summarise(
      TotalSites = n_distinct(SiteName),
      TotalSamples = n(),
      .groups = 'drop'
    ) %>%
    arrange(WHORegion, Admin0Name)
  
  if(verbose) {
    cat(sprintf("✓ Found %d countries across %d regions\n", 
                n_distinct(sites_summary$Admin0Name),
                n_distinct(sites_summary$WHORegion)))
  }
  
  # Create flextable
  ft <- flextable(sites_summary)
  
  # Format and style the table
  ft <- ft %>%
    set_header_labels(
      Admin0Name = "Country",
      WHORegion = "WHO Region",
      TotalSites = "Number of Sites",
      TotalSamples = "Total Samples"
    ) %>%
    autofit() %>%
    bold(part = "header") %>%
    bg(bg = "#E7E6E6", part = "header") %>%
    align(align = "center", part = "header") %>%
    align(j = c("TotalSites", "TotalSamples"), align = "center") %>%
    border_outer(border = officer::fp_border()) %>%
    border_inner_h(border = officer::fp_border()) %>%
    border_inner_v(border = officer::fp_border())
  
  if(verbose) cat("✓ Flextable created successfully\n")
  
  return(ft)
}

# ============================================================================
# Function: Generate regional summary (aggregated by WHO Region only)
# ============================================================================
create_es_regional_summary <- function(envsample_data = NULL, verbose = TRUE) {
  
  if(verbose) cat("\n=== Creating ES Regional Summary ===\n")
  
  # Load data if not provided
  if (is.null(envsample_data)) {
    if(verbose) cat("Loading EnvSample data from RDS...\n")
    
    if (!file.exists("data/EnvSample.rds")) {
      cat("✗ EnvSample.rds not found\n")
      return(NULL)
    }
    
    envsample_data <- readRDS("data/EnvSample.rds")
  }
  
  # Create regional summary
  regional_summary <- envsample_data %>%
    filter(!is.na(WHORegion) & !is.na(SiteName)) %>%
    group_by(WHORegion) %>%
    summarise(
      TotalCountries = n_distinct(Admin0Name),
      TotalSites = n_distinct(SiteName),
      TotalSamples = n(),
      .groups = 'drop'
    ) %>%
    arrange(desc(TotalSites))
  
  if(verbose) {
    cat(sprintf("✓ Summary by %d regions created\n", nrow(regional_summary)))
  }
  
  # Create flextable
  ft <- flextable(regional_summary)
  
  # Format and style
  ft <- ft %>%
    set_header_labels(
      WHORegion = "WHO Region",
      TotalCountries = "Countries",
      TotalSites = "Number of Sites",
      TotalSamples = "Total Samples"
    ) %>%
    autofit() %>%
    bold(part = "header") %>%
    bg(bg = "#4472C4", part = "header") %>%
    color(color = "white", part = "header") %>%
    align(align = "center", part = "header") %>%
    align(j = c("TotalCountries", "TotalSites", "TotalSamples"), align = "center") %>%
    border_outer(border = officer::fp_border()) %>%
    border_inner_h(border = officer::fp_border()) %>%
    border_inner_v(border = officer::fp_border())
  
  return(ft)
}

# ============================================================================
# Function: Export flextable data to CSV
# ============================================================================
export_es_summary_csv <- function(envsample_data, verbose = TRUE) {
  
  if(verbose) cat("\n=== Exporting Data to CSV ===\n")
  
  # Create output directory
  if (!dir.exists("output")) {
    dir.create("output", showWarnings = FALSE)
  }
  
  # Country & Region summary
  sites_summary <- envsample_data %>%
    filter(!is.na(Admin0Name) & !is.na(WHORegion) & !is.na(SiteName)) %>%
    group_by(Admin0Name, WHORegion) %>%
    summarise(
      TotalSites = n_distinct(SiteName),
      TotalSamples = n(),
      .groups = 'drop'
    ) %>%
    arrange(WHORegion, Admin0Name)
  
  csv_file1 <- file.path("output", "ES_Sites_by_Country_Region.csv")
  write.csv(sites_summary, csv_file1, row.names = FALSE)
  cat(sprintf("✓ Saved: %s\n", csv_file1))
  
  # Regional summary
  regional_summary <- envsample_data %>%
    filter(!is.na(WHORegion) & !is.na(SiteName)) %>%
    group_by(WHORegion) %>%
    summarise(
      TotalCountries = n_distinct(Admin0Name),
      TotalSites = n_distinct(SiteName),
      TotalSamples = n(),
      .groups = 'drop'
    ) %>%
    arrange(desc(TotalSites))
  
  csv_file2 <- file.path("output", "ES_Sites_Regional_Summary.csv")
  write.csv(regional_summary, csv_file2, row.names = FALSE)
  cat(sprintf("✓ Saved: %s\n", csv_file2))
  
  return(list(
    country_region = sites_summary,
    regional = regional_summary
  ))
}

# ============================================================================
# Main execution
# ============================================================================

# Load EnvSample data
cat("\nLoading EnvSample data...\n")
if (file.exists("data/EnvSample.rds")) {
  envsample <- readRDS("data/EnvSample.rds")
  cat(sprintf("✓ Loaded %d records\n", nrow(envsample)))
  
  # Create flextable by country and region
  cat("\n--- Creating Country & Region Summary ---\n")
  ft_country_region <- create_es_sites_flextable(envsample, verbose = TRUE)
  
  if (!is.null(ft_country_region)) {
    cat("\nFlextable Preview:\n")
    print(ft_country_region)
    
    # Export data as CSV
    cat("\n--- Exporting Data to CSV ---\n")
    csv_files <- export_es_summary_csv(envsample, verbose = TRUE)
  }
  
  # Create regional summary
  cat("\n--- Creating Regional Summary ---\n")
  ft_regional <- create_es_regional_summary(envsample, verbose = TRUE)
  
  if (!is.null(ft_regional)) {
    cat("\nRegional Summary:\n")
    print(ft_regional)
  }
  
} else {
  cat("✗ EnvSample.rds not found\n")
  cat("Please run R/07_fetch_envsample_full.R first\n")
}

cat("\n========================================\n")
cat("   Complete\n")
cat("========================================\n\n")

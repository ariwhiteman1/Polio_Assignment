# Publication-ready bar graph of active ES sites by country and year
# Usage: source("R/10_es_sites_bargraph.R")

cat("\n========================================\n")
cat("   ES Sites Bar Graph - Country & Year\n")
cat("========================================\n\n")

# Install required packages
required_packages <- c("ggplot2", "dplyr", "scales", "gridExtra")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg, repos = "https://cran.r-project.org/")
    library(pkg, character.only = TRUE)
  }
}

# ============================================================================
# Function: Create bar graph of ES sites by country and year
# ============================================================================
create_es_sites_bargraph <- function(envsample_data = NULL, 
                                     top_countries = 15,
                                     title = "Environmental Sample Surveillance Sites by Country and Year",
                                     theme_style = "publication",
                                     verbose = TRUE) {
  
  if(verbose) cat("\n=== Creating ES Sites Bar Graph ===\n")
  
  # Load data if not provided
  if (is.null(envsample_data)) {
    if(verbose) cat("Loading EnvSample data from RDS...\n")
    
    if (!file.exists("data/EnvSample.rds")) {
      cat("✗ EnvSample.rds not found\n")
      cat("Please run R/07_fetch_envsample_full.R first\n")
      return(NULL)
    }
    
    envsample_data <- readRDS("data/EnvSample.rds")
  }
  
  # Verify required columns
  required_cols <- c("Admin0Name", "ReportingYear", "SiteName")
  missing_cols <- setdiff(required_cols, names(envsample_data))
  
  if (length(missing_cols) > 0) {
    cat(sprintf("✗ Missing columns: %s\n", paste(missing_cols, collapse=", ")))
    return(NULL)
  }
  
  if(verbose) cat(sprintf("Processing %d records...\n", nrow(envsample_data)))
  
  # Prepare data: count unique sites per country per year
  sites_by_year <- envsample_data %>%
    filter(!is.na(Admin0Name) & !is.na(ReportingYear) & !is.na(SiteName)) %>%
    group_by(Admin0Name, ReportingYear) %>%
    summarise(
      NumberOfSites = n_distinct(SiteName),
      .groups = 'drop'
    ) %>%
    arrange(desc(NumberOfSites))
  
  # Get top countries by total sites
  top_countries_list <- sites_by_year %>%
    group_by(Admin0Name) %>%
    summarise(TotalSites = sum(NumberOfSites), .groups = 'drop') %>%
    arrange(desc(TotalSites)) %>%
    slice(1:min(top_countries, nrow(.))) %>%
    pull(Admin0Name)
  
  # Filter for top countries only
  sites_filtered <- sites_by_year %>%
    filter(Admin0Name %in% top_countries_list) %>%
    mutate(Admin0Name = factor(Admin0Name, levels = top_countries_list))
  
  if(verbose) {
    cat(sprintf("✓ Top %d countries identified\n", length(top_countries_list)))
    cat(sprintf("Year range: %d - %d\n", 
                min(sites_filtered$ReportingYear), 
                max(sites_filtered$ReportingYear)))
  }
  
  # Create the bar graph
  p <- ggplot(sites_filtered, aes(x = factor(ReportingYear), y = NumberOfSites, fill = Admin0Name)) +
    geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.8) +
    
    # Labels and titles
    labs(
      title = title,
      x = "Reporting Year",
      y = "Number of Active Sites",
      fill = "Country",
      caption = paste("Source: WHO POLIS EnvSample Endpoint | Data current as of", format(Sys.Date(), "%B %d, %Y"))
    ) +
    
    # Set color palette
    scale_fill_manual(values = get_publication_colors(length(top_countries_list))) +
    scale_y_continuous(
      breaks = scales::pretty_breaks(n = 8),
      labels = scales::label_comma(),
      expand = expansion(mult = c(0, 0.1))
    ) +
    
    # Apply publication theme
    if(theme_style == "publication") {
      theme_publication()
    } else {
      theme_minimal()
    }
  
  if(verbose) cat("✓ Bar graph created successfully\n")
  
  return(p)
}

# ============================================================================
# Function: Create faceted bar graph (separate panels per country)
# ============================================================================
create_es_sites_faceted_bargraph <- function(envsample_data = NULL,
                                             top_countries = 12,
                                             title = "Active Environmental Sample Sites by Year",
                                             verbose = TRUE) {
  
  if(verbose) cat("\n=== Creating Faceted Bar Graph ===\n")
  
  # Load data if not provided
  if (is.null(envsample_data)) {
    if(verbose) cat("Loading EnvSample data from RDS...\n")
    
    if (!file.exists("data/EnvSample.rds")) {
      cat("✗ EnvSample.rds not found\n")
      return(NULL)
    }
    
    envsample_data <- readRDS("data/EnvSample.rds")
  }
  
  # Prepare data
  sites_by_year <- envsample_data %>%
    filter(!is.na(Admin0Name) & !is.na(ReportingYear) & !is.na(SiteName)) %>%
    group_by(Admin0Name, ReportingYear) %>%
    summarise(
      NumberOfSites = n_distinct(SiteName),
      .groups = 'drop'
    )
  
  # Get top countries
  top_countries_list <- sites_by_year %>%
    group_by(Admin0Name) %>%
    summarise(TotalSites = sum(NumberOfSites), .groups = 'drop') %>%
    arrange(desc(TotalSites)) %>%
    slice(1:min(top_countries, nrow(.))) %>%
    pull(Admin0Name)
  
  # Filter data
  sites_filtered <- sites_by_year %>%
    filter(Admin0Name %in% top_countries_list)
  
  if(verbose) {
    cat(sprintf("✓ Creating faceted graph for %d countries\n", length(top_countries_list)))
  }
  
  # Create faceted plot
  p <- ggplot(sites_filtered, aes(x = ReportingYear, y = NumberOfSites, fill = Admin0Name)) +
    geom_bar(stat = "identity", alpha = 0.8) +
    facet_wrap(~Admin0Name, scales = "free_y", ncol = 4) +
    
    labs(
      title = title,
      x = "Reporting Year",
      y = "Number of Active Sites",
      caption = paste("Source: WHO POLIS EnvSample | Data as of", format(Sys.Date(), "%B %d, %Y"))
    ) +
    
    scale_x_continuous(breaks = scales::pretty_breaks(n = 4)) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 4)) +
    
    scale_fill_viridis_d(option = "turbo", alpha = 0.8) +
    
    theme_publication() +
    theme(
      strip.text = element_text(size = 9, face = "bold"),
      legend.position = "none",
      panel.spacing = unit(1, "lines")
    )
  
  return(p)
}

# ============================================================================
# Function: Create line graph (alternative to bar)
# ============================================================================
create_es_sites_linegraph <- function(envsample_data = NULL,
                                      top_countries = 10,
                                      title = "Active Environmental Sample Sites Trends by Country",
                                      verbose = TRUE) {
  
  if(verbose) cat("\n=== Creating Line Graph ===\n")
  
  # Load data if not provided
  if (is.null(envsample_data)) {
    if(verbose) cat("Loading EnvSample data from RDS...\n")
    
    if (!file.exists("data/EnvSample.rds")) {
      cat("✗ EnvSample.rds not found\n")
      return(NULL)
    }
    
    envsample_data <- readRDS("data/EnvSample.rds")
  }
  
  # Prepare data
  sites_by_year <- envsample_data %>%
    filter(!is.na(Admin0Name) & !is.na(ReportingYear) & !is.na(SiteName)) %>%
    group_by(Admin0Name, ReportingYear) %>%
    summarise(
      NumberOfSites = n_distinct(SiteName),
      .groups = 'drop'
    )
  
  # Get top countries
  top_countries_list <- sites_by_year %>%
    group_by(Admin0Name) %>%
    summarise(TotalSites = sum(NumberOfSites), .groups = 'drop') %>%
    arrange(desc(TotalSites)) %>%
    slice(1:min(top_countries, nrow(.))) %>%
    pull(Admin0Name)
  
  # Filter data
  sites_filtered <- sites_by_year %>%
    filter(Admin0Name %in% top_countries_list)
  
  if(verbose) {
    cat(sprintf("✓ Creating line graph for %d countries\n", length(top_countries_list)))
  }
  
  # Create line plot
  p <- ggplot(sites_filtered, aes(x = ReportingYear, y = NumberOfSites, color = Admin0Name, group = Admin0Name)) +
    geom_line(size = 1, alpha = 0.8) +
    geom_point(size = 2.5, alpha = 0.8) +
    
    labs(
      title = title,
      x = "Reporting Year",
      y = "Number of Active Sites",
      color = "Country",
      caption = paste("Source: WHO POLIS EnvSample | Data as of", format(Sys.Date(), "%B %d, %Y"))
    ) +
    
    scale_x_continuous(breaks = scales::pretty_breaks(n = 8)) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 8)) +
    
    scale_color_manual(values = get_publication_colors(length(top_countries_list))) +
    
    theme_publication() +
    theme(
      legend.position = "right",
      legend.key.size = unit(0.5, "cm")
    )
  
  return(p)
}

# ============================================================================
# Helper Function: Publication theme for ggplot
# ============================================================================
theme_publication <- function() {
  theme_minimal() +
  theme(
    # Fonts
    text = element_text(family = "sans", size = 11, color = "#333333"),
    plot.title = element_text(
      size = 14, 
      face = "bold", 
      color = "#000000",
      margin = margin(b = 10)
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "#555555",
      margin = margin(b = 8)
    ),
    plot.caption = element_text(
      size = 9,
      color = "#777777",
      hjust = 0,
      margin = margin(t = 10)
    ),
    
    # Axes
    axis.title = element_text(
      size = 11,
      face = "bold",
      color = "#333333"
    ),
    axis.text = element_text(
      size = 10,
      color = "#555555"
    ),
    axis.line = element_line(
      color = "#cccccc",
      size = 0.5
    ),
    axis.ticks = element_line(
      color = "#cccccc",
      size = 0.5
    ),
    
    # Grid
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      color = "#e5e5e5",
      size = 0.3,
      linetype = "dotted"
    ),
    panel.grid.minor = element_blank(),
    
    # Legend
    legend.position = "right",
    legend.title = element_text(
      size = 11,
      face = "bold"
    ),
    legend.text = element_text(size = 10),
    legend.background = element_rect(
      fill = "#f9f9f9",
      color = "#cccccc",
      size = 0.3
    ),
    legend.margin = margin(10, 10, 10, 10),
    
    # Background
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    panel.background = element_rect(
      fill = "#fafafa",
      color = NA
    )
  )
}

# ============================================================================
# Helper Function: Get publication color palette
# ============================================================================
get_publication_colors <- function(n) {
  if (n <= 9) {
    # Use Set1 palette for small n
    colors <- RColorBrewer::brewer.pal(n, "Set1")
  } else if (n <= 12) {
    # Use Set3 for medium n
    colors <- RColorBrewer::brewer.pal(n, "Set3")
  } else {
    # Use hue palette for larger n
    colors <- scales::hue_pal()(n)
  }
  return(colors)
}

# ============================================================================
# Function: Save graph to file
# ============================================================================
save_es_graph <- function(plot_object, filename = NULL, format = "png", width = 12, height = 7, dpi = 300, verbose = TRUE) {
  
  if (is.null(filename)) {
    filename <- sprintf("ES_Sites_Graph_%s.%s", 
                       format(Sys.Date(), "%Y%m%d"), format)
  }
  
  filepath <- file.path("output", filename)
  
  # Create output directory
  if (!dir.exists("output")) {
    dir.create("output", showWarnings = FALSE)
  }
  
  tryCatch({
    if (format == "png") {
      ggsave(filepath, plot = plot_object, width = width, height = height, 
             dpi = dpi, bg = "white")
    } else if (format == "pdf") {
      ggsave(filepath, plot = plot_object, width = width, height = height, 
             bg = "white")
    } else if (format == "tiff") {
      ggsave(filepath, plot = plot_object, width = width, height = height, 
             dpi = dpi, bg = "white")
    } else {
      ggsave(filepath, plot = plot_object, width = width, height = height)
    }
    
    if(verbose) cat(sprintf("✓ Saved: %s\n", filepath))
    return(TRUE)
    
  }, error = function(e) {
    cat(sprintf("✗ Error saving graph: %s\n", e$message))
    return(FALSE)
  })
}

# ============================================================================
# Main execution
# ============================================================================

cat("\nLoading EnvSample data...\n")
if (file.exists("data/EnvSample.rds")) {
  envsample <- readRDS("data/EnvSample.rds")
  cat(sprintf("✓ Loaded %d records\n", nrow(envsample)))
  
  # Check year range
  year_range <- range(envsample$ReportingYear, na.rm = TRUE)
  cat(sprintf("Year range: %d - %d\n\n", year_range[1], year_range[2]))
  
  # Create bar graph (main visualization)
  cat("--- Graph 1: Bar Chart (Dodged by Country) ---\n")
  p_bar <- create_es_sites_bargraph(
    envsample, 
    top_countries = 15,
    title = "Active Environmental Sample Surveillance Sites by Country and Year"
  )
  
  if (!is.null(p_bar)) {
    print(p_bar)
    save_es_graph(p_bar, filename = "ES_Sites_BarChart.png", format = "png", 
                  width = 14, height = 8, dpi = 300)
    save_es_graph(p_bar, filename = "ES_Sites_BarChart.pdf", format = "pdf",
                  width = 14, height = 8)
  }
  
  # Create faceted bar graph
  cat("\n--- Graph 2: Faceted Bar Chart (by Country) ---\n")
  p_faceted <- create_es_sites_faceted_bargraph(
    envsample,
    top_countries = 12
  )
  
  if (!is.null(p_faceted)) {
    print(p_faceted)
    save_es_graph(p_faceted, filename = "ES_Sites_FacetedChart.png", format = "png",
                  width = 16, height = 10, dpi = 300)
    save_es_graph(p_faceted, filename = "ES_Sites_FacetedChart.pdf", format = "pdf",
                  width = 16, height = 10)
  }
  
  # Create line graph (trends)
  cat("\n--- Graph 3: Line Graph (Trends) ---\n")
  p_line <- create_es_sites_linegraph(
    envsample,
    top_countries = 10
  )
  
  if (!is.null(p_line)) {
    print(p_line)
    save_es_graph(p_line, filename = "ES_Sites_LineGraph.png", format = "png",
                  width = 14, height = 8, dpi = 300)
    save_es_graph(p_line, filename = "ES_Sites_LineGraph.pdf", format = "pdf",
                  width = 14, height = 8)
  }
  
} else {
  cat("✗ EnvSample.rds not found\n")
  cat("Please run R/07_fetch_envsample_full.R first\n")
}

cat("\n========================================\n")
cat("   Bar Graph Creation Complete\n")
cat("========================================\n\n")

# ES Sites Bar Graph & Visualization Functions

## Overview
Created comprehensive visualization functions in `R/10_es_sites_bargraph.R` to generate publication-ready graphics of Environmental Sample (ES) surveillance sites by country and year.

## Main Functions

### 1. `create_es_sites_bargraph()`
**Purpose:** Generate a publication-ready bar chart showing active ES sites by country and year.

**Usage:**
```r
source("R/10_es_sites_bargraph.R")

# Auto-load from RDS
p_bar <- create_es_sites_bargraph(top_countries = 15)

# With custom data
p_bar <- create_es_sites_bargraph(
  envsample_data = my_data,
  top_countries = 12,
  title = "Custom Title"
)

print(p_bar)
```

**Parameters:**
- `envsample_data` - Tibble with EnvSample data (auto-loads from RDS if NULL)
- `top_countries` - Number of top countries to display (default: 15)
- `title` - Graph title (default: "Environmental Sample Surveillance Sites by Country and Year")
- `theme_style` - Theme to apply: "publication" or "minimal" (default: "publication")
- `verbose` - Display status messages (default: TRUE)

**Output:** Publication-ready ggplot2 object with professional styling

---

### 2. `create_es_sites_faceted_bargraph()`
**Purpose:** Create a faceted bar chart with separate panels for each country (better for comparing trends within countries).

**Usage:**
```r
p_faceted <- create_es_sites_faceted_bargraph(
  envsample_data = NULL,
  top_countries = 12,
  title = "Active Environmental Sample Sites by Year"
)

print(p_faceted)
```

**Parameters:**
- `envsample_data` - EnvSample data
- `top_countries` - Number of top countries to show (default: 12)
- `title` - Graph title
- `verbose` - Display status messages

**Features:**
- Separate panel for each country
- Allows free y-axis scaling (better for different site counts)
- Compact 4-column layout
- Color-coded by country

---

### 3. `create_es_sites_linegraph()`
**Purpose:** Create a line graph showing trends in active sites over time for each country.

**Usage:**
```r
p_line <- create_es_sites_linegraph(
  top_countries = 10,
  title = "Active Environmental Sample Sites Trends by Country"
)

print(p_line)
```

**Parameters:**
- `envsample_data` - EnvSample data
- `top_countries` - Number of top countries (default: 10)
- `title` - Graph title
- `verbose` - Display status messages

**Features:**
- Line and point visualization
- Shows temporal trends clearly
- Legend shows all countries
- Year-over-year comparison

---

## Supporting Functions

### `save_es_graph()`
Export graphs to publication-quality files.

**Usage:**
```r
save_es_graph(
  plot_object = p_bar,
  filename = "custom_name.png",
  format = "png",  # or "pdf", "tiff"
  width = 14,
  height = 8,
  dpi = 300,
  verbose = TRUE
)
```

**Formats:**
- **PNG** - For web, presentations (default 300 dpi)
- **PDF** - For print, publications
- **TIFF** - For high-resolution printing

---

### `theme_publication()`
Professional ggplot2 theme with publication-quality styling.

**Features:**
- Clean, minimalist design
- Optimized fonts and sizing
- Light gray gridlines
- Professional legend styling
- White background for printing
- Proper margins and spacing

---

### `get_publication_colors()`
Smart color palette selection based on number of countries.

**Logic:**
- ≤9 countries: Set1 palette (vibrant colors)
- ≤12 countries: Set3 palette (pastel colors)
- 13+ countries: Hue palette (continuous spectrum)

---

## Output Files Generated

The script creates 6 publication-ready files:

```
output/
├── ES_Sites_BarChart.png          # Bar chart (PNG, 300 dpi)
├── ES_Sites_BarChart.pdf          # Bar chart (PDF, print-ready)
├── ES_Sites_FacetedChart.png      # Faceted chart (PNG)
├── ES_Sites_FacetedChart.pdf      # Faceted chart (PDF)
├── ES_Sites_LineGraph.png         # Line graph (PNG)
└── ES_Sites_LineGraph.pdf         # Line graph (PDF)
```

---

## Data Summary

From the 2,000 EnvSample records:

**Year Range:** 2014 - 2025 (12 years of data)

**Top 15 Countries by Total Sites:**
The bar charts visualize:
- Number of active sites per country per year
- Temporal trends in surveillance expansion
- Geographic distribution of monitoring effort
- Year-to-year changes in site counts

---

## Publication-Quality Features

✅ **Professional Styling**
- Optimized fonts (sans-serif)
- Proper color contrast
- Clean gridlines (horizontal only)
- Professional legend styling

✅ **High Resolution**
- PNG: 300 dpi (publication standard)
- PDF: Vector format (scalable)
- Both formats suitable for journals/presentations

✅ **Accessibility**
- Color-blind friendly palettes
- Clear labels and titles
- Proper data source attribution
- Readable font sizes

✅ **Customization Options**
- Adjustable number of countries
- Custom titles and subtitles
- Multiple visualization types
- Flexible sizing

---

## Usage Workflow

```r
# 1. Load the script
source("R/10_es_sites_bargraph.R")

# 2. Script auto-generates all 3 graphs
# - Bar chart saved as output/ES_Sites_BarChart.png
# - Faceted chart saved as output/ES_Sites_FacetedChart.png
# - Line graph saved as output/ES_Sites_LineGraph.png

# 3. Or create custom visualizations
envsample <- readRDS("data/EnvSample.rds")
p <- create_es_sites_bargraph(envsample, top_countries = 10)
save_es_graph(p, filename = "custom_graph.pdf", format = "pdf")
```

---

## Dependencies

```r
library(ggplot2)      # Visualization
library(dplyr)        # Data manipulation
library(scales)       # Axis formatting
library(gridExtra)    # Multi-plot arrangements (optional)
library(RColorBrewer) # Color palettes
```

---

## Integration with Project

Part of the complete EnvSample analysis pipeline:

1. **Data Fetching:** `R/07_fetch_envsample_full.R` → Downloads 2,000 records
2. **Summary Tables:** `R/09_es_sites_flextable.R` → Creates tabular summaries
3. **Visualizations:** `R/10_es_sites_bargraph.R` → Creates publication-ready graphs ⬅ You are here
4. **Analysis Ready:** All outputs in `output/` directory

---

## Technical Notes

- All graphs use consistent color schemes
- Professional theme ensures consistency across outputs
- Automatic pagination for top countries
- Handles missing data gracefully
- Works with data from 2014-2025

---

**Date Created:** November 21, 2025
**Status:** ✅ Complete and tested
**Output Quality:** Publication-ready (suitable for journals, reports, presentations)

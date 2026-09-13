# EU Fuel Price Response to the Strait of Hormuz Closure

## Project Overview

This project examines how weekly retail **petrol (gasoline)** and **diesel pump prices** evolved in the **Netherlands, Germany, and Belgium** before and after the Strait of Hormuz closure event.

The analysis uses a descriptive event-study style framework and an interactive dashboard to compare:

- absolute weekly fuel prices in euros per litre;
- normalized fuel-price indices;
- percentage changes from the final pre-event observation;
- pre- versus post-event average prices;
- pre- versus post-event price volatility;
- post-event peak prices and peak dates;
- cross-country differences in the magnitude of retail fuel-price adjustment.

The project is designed as a reproducible economics/data-analysis portfolio project using **R**, **Plotly**, and **GitHub Pages**.

---

## Research Question

**How did petrol and diesel pump prices in the Netherlands, Germany, and Belgium evolve before and after the Strait of Hormuz closure, and how heterogeneous was the retail fuel-price response across these three national markets?**

A secondary objective is to assess whether the post-event period was associated not only with higher retail fuel prices, but also with greater price volatility.

---

## Countries Included

- Netherlands
- Germany
- Belgium

---

## Fuel Types

- Gasoline / petrol
- Diesel

Prices are measured in **euros per litre (€ / L)**.

---

## Data Source

The weekly fuel-price dataset was downloaded from:

**EU EnergyPrices – Open Data: European energy prices as CSV**

[Open data: European energy prices as CSV | EU EnergyPrices](https://www.euenergyprices.eu/en/data?utm_source=chatgpt.com)

The project uses the **petrol and diesel pump-price series** from this dataset.

Source file:

```text
euenergyprices-fuel-prices.csv
```

The raw dataset contains weekly retail fuel-price observations for European countries.

---

## Study Period

The event date used in this project is:

**28 February 2026**

The analytical window begins approximately **six months before the event** and continues through the latest available weekly observation in the downloaded dataset.

In the current dataset, the latest observation used in the analysis is:

**7 September 2026**

---

## Analytical Design

The analysis follows a **descriptive comparative event-study style approach**.

The Strait of Hormuz event is treated as a common external shock, while the analysis compares how strongly retail fuel prices adjusted across the three countries.

The dashboard includes:

1. Raw retail fuel prices
2. Normalized price indices
3. Percentage changes from the pre-event baseline
4. Pre/post average prices
5. Pre/post volatility
6. Post-event peak prices
7. Event-time variables for possible econometric extensions

---

# Methodology

## 1. Data Cleaning

The CSV file is imported into R and filtered to retain:

- Netherlands
- Germany
- Belgium
- gasoline
- diesel
- observations within the study window

Main variables:

```text
date
country
fuel_type
price_eur_l
```

The `date` field is converted to an R `Date` object and prices are treated as numeric values.

---

## 2. Pre-Event Baseline

For each country and fuel type, the final weekly observation before the event date is used as the reference price:

\[
P_{i,0}=P_{i,t<event}^{last}
\]

where:

- \(P_{i,0}\) = pre-event baseline price
- \(P_{i,t}\) = observed weekly retail fuel price

For the current dataset, the final weekly observation before the event is **23 February 2026**.

---

## 3. Normalized Fuel-Price Index

To remove structural differences in starting price levels, each country's fuel-price series is normalized to 100 at the final pre-event observation:

\[
Index_{it}
=
100\times\frac{P_{it}}{P_{i,0}}
\]

Interpretation:

- `100` = unchanged from baseline
- `110` = 10% above baseline
- `120` = 20% above baseline
- `95` = 5% below baseline

---

## 4. Percentage Change from Baseline

The percentage change from the pre-event baseline is calculated as:

\[
\Delta P_{it}(\%)
=
100
\left(
\frac{P_{it}}{P_{i,0}}-1
\right)
\]

This measure is used to compare the magnitude and timing of the post-event price response.

---

## 5. Pre- and Post-Event Average Prices

Pre-event average:

\[
\bar{P}^{pre}_i
=
\frac{1}{T_{pre}}
\sum P_{it}
\]

Post-event average:

\[
\bar{P}^{post}_i
=
\frac{1}{T_{post}}
\sum P_{it}
\]

Percentage difference:

\[
100
\left(
\frac{\bar P^{post}_i}
{\bar P^{pre}_i}-1
\right)
\]

This helps identify whether the post-event period was associated with a persistent change in the average retail fuel-price level.

---

## 6. Price Volatility

Weekly retail-price volatility is measured using the standard deviation of weekly fuel prices.

The analysis compares:

- pre-event standard deviation
- post-event standard deviation

A larger post-event standard deviation indicates greater price instability.

---

## 7. Post-Event Peak Price

For every country and fuel category, the analysis identifies:

- highest post-event price
- date of the peak
- percentage increase of the peak relative to baseline

---

## 8. Event-Time Variable

For econometric extensions:

\[
EventWeek_t
=
\left\lfloor
\frac{Date_t-EventDate}{7}
\right\rfloor
\]

Interpretation:

- negative values = weeks before the event
- `0` = event week
- positive values = weeks after the event

---

# Interactive Dashboard

The R script generates an interactive HTML dashboard with three main visual perspectives.

## Raw Fuel-Price View

Weekly gasoline or diesel prices in **euros per litre**.

## Indexed Price View

Each country's final pre-event observation is normalized to **100**.

This is the most useful chart for comparing the relative price response.

## Percentage-Change View

Shows the percentage increase or decrease in weekly retail prices relative to the final pre-event observation.

### Interactive Features

- country-level comparison
- gasoline and diesel analysis
- hover values
- weekly dates
- event-date marker
- raw prices
- indexed values
- percentage changes
- pre/post statistics
- volatility measures
- peak prices
- economic interpretation

The dashboard is exported as:

```text
index.html
```

---

# Main Descriptive Findings

## Gasoline

| Country | Latest change from baseline |
|---|---:|
| Belgium | +28.9% |
| Germany | +27.8% |
| Netherlands | +19.6% |

## Diesel

| Country | Latest change from baseline |
|---|---:|
| Belgium | +38.5% |
| Germany | +34.3% |
| Netherlands | +30.4% |

---

## Post-Event Peak Diesel Response

| Country | Peak diesel increase |
|---|---:|
| Belgium | +42.9% |
| Germany | +40.5% |
| Netherlands | +38.0% |

---

## Pre/Post Average Price Changes

### Gasoline

| Country | Post vs pre average |
|---|---:|
| Germany | +20.1% |
| Belgium | +19.8% |
| Netherlands | +17.5% |

### Diesel

| Country | Post vs pre average |
|---|---:|
| Netherlands | +30.3% |
| Germany | +28.1% |
| Belgium | +27.1% |

---

## Price Volatility

The post-event period also shows higher price instability.

For example, gasoline weekly price volatility in Germany increased approximately from:

```text
Pre-event SD:  €0.041/L
Post-event SD: €0.122/L
```

This suggests that the post-event period was associated with both higher retail prices and greater week-to-week variability.

---

# Economic Interpretation

The three countries are exposed to the same broad international oil-market disruption, but the transmission of that shock into retail fuel prices can differ across national markets.

Possible mechanisms include:

- fuel taxation
- excise duties
- VAT
- refinery structure
- wholesale-market conditions
- inventory buffers
- supply contracts
- crude-oil sourcing
- transportation costs
- exchange-rate exposure
- retail competition
- national policy interventions
- differences in crude-oil-to-pump-price pass-through

The indexed charts are especially important because **absolute price level and relative price response are different economic concepts**.

---

# Important Interpretation Note

This project is a **descriptive comparative event analysis**.

The results should not be interpreted as a fully identified causal effect of the Strait of Hormuz closure.

The analysis documents:

- timing
- magnitude
- persistence
- volatility
- cross-country heterogeneity

---

# Limitations

## 1. No Full Causal Identification

The event occurs at the same time for all three countries, so there is no unaffected comparison country within the current design.

## 2. Retail Prices Have Multiple Determinants

Relevant factors include:

- Brent crude prices
- EUR/USD exchange rate
- excise duties
- VAT
- refinery margins
- inventories
- transportation costs
- wholesale contracts
- retail competition
- policy interventions

## 3. Country Tax Structures Differ

This is why the normalized index is particularly important.

## 4. Limited Number of Countries

The current analysis focuses on three countries only.

## 5. Short Post-Event Window

The current analysis uses data available through September 2026.

---

# Software

The full analysis is conducted in **R**.

R is used for:

- data import
- cleaning
- transformation
- descriptive statistics
- event-time construction
- visualization
- dashboard generation
- data export

---

# R Packages

## tidyverse

Used for:

- data manipulation
- filtering
- grouping
- aggregation
- variable construction
- CSV import/export

Includes tools such as:

- `dplyr`
- `readr`
- `tidyr`
- `stringr`
- `ggplot2`

## lubridate

Used for date conversion and event-window construction.

## plotly

Used for interactive time-series visualization.

## htmltools

Used to build the HTML dashboard.

## DT

Used to generate the interactive summary table.

## scales

Used for formatting numerical values and percentages.

## glue

Used to generate dynamic dashboard text and interpretation.

---

# Optional Econometric Packages

## fixest

Useful for:

- fixed-effects regression
- event-study specifications
- panel models
- interaction models
- clustered standard errors

## broom

Useful for converting model output into tidy data frames.

---

# Reproducibility

Example local project path:

```text
C:/Users/DELL/OneDrive/Desktop/Fuel prices/
```

Example data import:

```r
file_path <- "C:/Users/DELL/OneDrive/Desktop/Fuel prices/euenergyprices-fuel-prices.csv"

fuel_raw <- readr::read_csv(
  file_path,
  show_col_types = FALSE
)
```

---

# Repository Structure

Recommended structure:

```text
EU-Hormuz-Fuel-Price-Analysis/
│
├── README.md
├── index.html
│
├── data/
│   └── euenergyprices-fuel-prices.csv
│
├── scripts/
│   └── hormuz_eu_fuel_analysis.R
│
├── results/
│   └── hormuz_eu_fuel_event_study_metrics_R.csv
│
└── figures/
```

A simpler first version can keep all files in the root directory.

---

# How to Run the Analysis

## Step 1

Download or clone the repository.

## Step 2

Open:

```text
hormuz_eu_fuel_analysis.R
```

in RStudio.

## Step 3

Install the required packages if needed.

Core packages:

```r
packages <- c(
  "tidyverse",
  "lubridate",
  "plotly",
  "htmltools",
  "DT",
  "scales",
  "glue"
)
```

## Step 4

Confirm the CSV file path.

## Step 5

Run the R script from top to bottom.

Main outputs include:

```text
index.html
hormuz_eu_fuel_event_study_metrics_R.csv
gasoline_index_chart.html
diesel_index_chart.html
gasoline_change_chart.html
diesel_change_chart.html
```

---

# Publishing with GitHub Pages

## Step 1

Create a public GitHub repository, for example:

```text
EU-Hormuz-Fuel-Price-Analysis
```

## Step 2

Upload at least:

```text
README.md
index.html
hormuz_eu_fuel_analysis.R
euenergyprices-fuel-prices.csv
hormuz_eu_fuel_event_study_metrics_R.csv
```

## Step 3

Go to:

```text
Settings → Pages
```

## Step 4

Under **Build and deployment**, select:

```text
Deploy from a branch
```

## Step 5

Choose:

```text
Branch: main
Folder: / (root)
```

## Step 6

GitHub Pages will publish the `index.html`.

Public dashboard URL format:

```text
https://YOUR-USERNAME.github.io/EU-Hormuz-Fuel-Price-Analysis/
```

---

# Suggested Repository Description

> Interactive R-based event-study analysis of weekly gasoline and diesel price responses in the Netherlands, Germany, and Belgium around the Strait of Hormuz closure.

---

# Econometric Extension

The next stage can extend the descriptive analysis into a panel-data study.

Useful additional variables include:

- Brent crude oil price
- EUR/USD exchange rate
- national fuel excise duties
- VAT
- refinery indicators
- oil inventories
- national policy interventions

Possible specification:

\[
\ln(P_{it})
=
\alpha_i
+
\beta_1 Brent_t
+
\beta_2 Post_t
+
\beta_3(Brent_t\times Country_i)
+
\gamma X_{it}
+
\epsilon_{it}
\]

where:

- \(P_{it}\) = retail fuel price
- \(\alpha_i\) = country-specific effects
- \(Brent_t\) = international crude-oil benchmark
- \(Post_t\) = post-event indicator
- \(X_{it}\) = additional controls

---

# Example Fixed-Effects Extension in R

```r
fuel_event <- fuel_event %>%
  mutate(
    event_time_days = as.numeric(date - event_date),
    event_week = floor(event_time_days / 7)
  )
```

Example model:

```r
library(fixest)

model_fe <- feols(
  log(price_eur_l) ~ i(event_week, ref = -1) |
    country + date,
  data = fuel_event %>%
    filter(fuel_type == "diesel"),
  cluster = ~country
)

summary(model_fe)
iplot(model_fe)
```

Because the event occurs at the same time for all three countries, a standard common-event specification with full time fixed effects has important identification limitations.

A stronger extension would focus on heterogeneous pass-through and interactions with country-specific characteristics.

---

# Future Extensions

- extend the analysis to all EU countries
- add Brent crude-oil prices
- estimate crude-to-pump pass-through
- incorporate excise duties and VAT
- add EUR/USD exchange rates
- estimate distributed-lag models
- conduct panel-data analysis
- compare gasoline and diesel adjustment speeds
- test whether post-event volatility increased statistically
- identify structural breaks
- create an EU-wide map
- automate weekly dashboard updates

---

# Project Outputs

## 1. Reproducible R Code

The R script contains the full analytical workflow.

## 2. Interactive HTML Dashboard

The `index.html` file contains the interactive results.

## 3. Summary Dataset

Calculated event-study metrics are exported in CSV format.

---

# Data Acknowledgement

Fuel-price data used in this project were downloaded from:

**EU EnergyPrices – Open Data: European energy prices as CSV**

[https://www.euenergyprices.eu/en/data](https://www.euenergyprices.eu/en/data?utm_source=chatgpt.com)

The analysis uses the petrol and diesel pump-price series.

---

# Disclaimer

This project is an independent descriptive analysis.

The results should not be interpreted as investment advice, policy advice, or definitive causal evidence.

---

## Author

**Muhammad Imran**

PhD in Economics and Management

Research interests include:

- sustainability
- green transition
- applied economics
- energy markets
- ESG
- quantitative analysis
- data visualization
- policy evaluation

---

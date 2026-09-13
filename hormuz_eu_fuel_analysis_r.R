
# ============================================================
# EU Fuel Price Response to the Strait of Hormuz Closure
# Interactive Event-Study Dashboard in R
# ============================================================

# ---------------------------
# 1. PACKAGES
# ---------------------------

packages <- c(
  "tidyverse",
  "lubridate",
  "plotly",
  "htmltools",
  "DT",
  "scales",
  "glue"
)

installed <- rownames(installed.packages())
for (p in packages) {
  if (!p %in% installed) {
    install.packages(p, dependencies = TRUE)
  }
}

library(tidyverse)
library(lubridate)
library(plotly)
library(htmltools)
library(DT)
library(scales)
library(glue)

# ---------------------------
# 2. FILE PATH
# ---------------------------

file_path <- "C:/Users/DELL/OneDrive/Desktop/Fuel prices/euenergyprices-fuel-prices.csv"

# ---------------------------
# 3. IMPORT DATA
# ---------------------------

fuel_raw <- readr::read_csv(file_path, show_col_types = FALSE)

# Inspect structure
glimpse(fuel_raw)
names(fuel_raw)

# Expected core variables:
# date
# country
# fuel_type
# price_eur_l

# ---------------------------
# 4. DEFINE STUDY PARAMETERS
# ---------------------------

countries <- c("Netherlands", "Germany", "Belgium")
fuels <- c("gasoline", "diesel")

# Event date used in the dashboard
event_date <- as.Date("2026-02-28")

# Six months before the event
start_date <- event_date %m-% months(6)

# Latest available observation in dataset
latest_date <- max(as.Date(fuel_raw$date), na.rm = TRUE)

cat("Study starts:", as.character(start_date), "\n")
cat("Event date:", as.character(event_date), "\n")
cat("Latest observation:", as.character(latest_date), "\n")

# ---------------------------
# 5. CLEAN AND FILTER DATA
# ---------------------------

fuel_data <- fuel_raw %>%
  mutate(
    date = as.Date(date),
    country = as.character(country),
    fuel_type = tolower(as.character(fuel_type)),
    price_eur_l = as.numeric(price_eur_l)
  ) %>%
  filter(
    country %in% countries,
    fuel_type %in% fuels,
    date >= start_date,
    date <= latest_date
  ) %>%
  arrange(fuel_type, country, date)

# Quick quality checks
fuel_data %>% count(country, fuel_type)
fuel_data %>% summarise(
  min_date = min(date),
  max_date = max(date),
  missing_prices = sum(is.na(price_eur_l))
)

# ---------------------------
# 6. CREATE PRE-EVENT BASELINE
# ---------------------------

# Baseline = last weekly observation before the closure
baseline <- fuel_data %>%
  filter(date < event_date) %>%
  group_by(country, fuel_type) %>%
  slice_max(order_by = date, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(
    country,
    fuel_type,
    baseline_date = date,
    baseline_price = price_eur_l
  )

print(baseline)

# ---------------------------
# 7. CALCULATE INDEX AND % CHANGE
# ---------------------------

fuel_event <- fuel_data %>%
  left_join(
    baseline,
    by = c("country", "fuel_type")
  ) %>%
  mutate(
    index_100 = 100 * price_eur_l / baseline_price,
    change_pct = 100 * (price_eur_l / baseline_price - 1),
    period = if_else(date < event_date, "Pre-closure", "Post-closure")
  )

# ---------------------------
# 8. PRE/POST SUMMARY STATISTICS
# ---------------------------

summary_stats <- fuel_event %>%
  group_by(fuel_type, country) %>%
  summarise(
    baseline_date = first(baseline_date),
    baseline_price = first(baseline_price),

    pre_avg = mean(price_eur_l[date < event_date], na.rm = TRUE),
    post_avg = mean(price_eur_l[date >= event_date], na.rm = TRUE),

    post_vs_pre_avg_pct =
      100 * (post_avg / pre_avg - 1),

    pre_sd = sd(price_eur_l[date < event_date], na.rm = TRUE),
    post_sd = sd(price_eur_l[date >= event_date], na.rm = TRUE),

    latest_date = max(date),
    latest_price = price_eur_l[which.max(date)],
    latest_change_pct = change_pct[which.max(date)],

    post_peak_price = max(
      price_eur_l[date >= event_date],
      na.rm = TRUE
    ),

    peak_date = date[
      which.max(
        if_else(
          date >= event_date,
          price_eur_l,
          -Inf
        )
      )
    ],

    peak_change_pct =
      100 * (post_peak_price / baseline_price - 1),

    .groups = "drop"
  ) %>%
  mutate(
    Fuel = str_to_title(fuel_type),
    Country = country
  ) %>%
  select(
    Fuel,
    Country,
    baseline_date,
    baseline_price,
    pre_avg,
    post_avg,
    post_vs_pre_avg_pct,
    pre_sd,
    post_sd,
    latest_date,
    latest_price,
    latest_change_pct,
    post_peak_price,
    peak_date,
    peak_change_pct
  )

print(summary_stats)

# Export full metrics
write_csv(
  summary_stats,
  "hormuz_eu_fuel_event_study_metrics_R.csv"
)

# ---------------------------
# 9. HELPER FUNCTION:
#    RAW PRICE CHART
# ---------------------------

make_raw_chart <- function(data, fuel_name) {

  d <- data %>%
    filter(fuel_type == fuel_name)

  p <- plot_ly()

  for (cty in countries) {

    temp <- d %>% filter(country == cty)

    p <- p %>%
      add_lines(
        data = temp,
        x = ~date,
        y = ~price_eur_l,
        name = cty,
        text = ~paste0(
          "<b>", country, "</b>",
          "<br>Date: ", format(date, "%d %b %Y"),
          "<br>Price: €", round(price_eur_l, 4), "/L"
        ),
        hoverinfo = "text"
      ) %>%
      add_markers(
        data = temp,
        x = ~date,
        y = ~price_eur_l,
        name = cty,
        showlegend = FALSE,
        hoverinfo = "skip",
        marker = list(size = 5)
      )
  }

  p %>%
    layout(
      title = list(
        text = paste0(
          str_to_title(fuel_name),
          " retail prices (€ per litre)"
        )
      ),

      xaxis = list(
        title = "Week"
      ),

      yaxis = list(
        title = "€ per litre"
      ),

      hovermode = "x unified",

      shapes = list(
        list(
          type = "line",
          x0 = event_date,
          x1 = event_date,
          y0 = 0,
          y1 = 1,
          xref = "x",
          yref = "paper",
          line = list(
            dash = "dash",
            width = 2
          )
        )
      ),

      annotations = list(
        list(
          x = event_date,
          y = 1,
          xref = "x",
          yref = "paper",
          text = "Strait of Hormuz closure<br>28 Feb 2026",
          showarrow = FALSE,
          xanchor = "left",
          yanchor = "bottom"
        )
      ),

      legend = list(
        title = list(text = "Country")
      ),

      margin = list(
        l = 60,
        r = 30,
        b = 60,
        t = 90
      )
    )
}

# ---------------------------
# 10. HELPER FUNCTION:
#     INDEXED CHART
# ---------------------------

make_index_chart <- function(data, fuel_name) {

  d <- data %>%
    filter(fuel_type == fuel_name)

  p <- plot_ly()

  for (cty in countries) {

    temp <- d %>% filter(country == cty)

    p <- p %>%
      add_lines(
        data = temp,
        x = ~date,
        y = ~index_100,
        name = cty,
        text = ~paste0(
          "<b>", country, "</b>",
          "<br>Date: ", format(date, "%d %b %Y"),
          "<br>Index: ", round(index_100, 1)
        ),
        hoverinfo = "text"
      )
  }

  p %>%
    layout(
      title = list(
        text = paste0(
          str_to_title(fuel_name),
          " price index (last pre-closure week = 100)"
        )
      ),

      xaxis = list(
        title = "Week"
      ),

      yaxis = list(
        title = "Index"
      ),

      hovermode = "x unified",

      shapes = list(
        list(
          type = "line",
          x0 = event_date,
          x1 = event_date,
          y0 = 0,
          y1 = 1,
          xref = "x",
          yref = "paper",
          line = list(
            dash = "dash",
            width = 2
          )
        ),
        list(
          type = "line",
          x0 = min(d$date),
          x1 = max(d$date),
          y0 = 100,
          y1 = 100,
          xref = "x",
          yref = "y",
          line = list(
            dash = "dot",
            width = 1
          )
        )
      ),

      annotations = list(
        list(
          x = event_date,
          y = 1,
          xref = "x",
          yref = "paper",
          text = "Closure",
          showarrow = FALSE,
          xanchor = "left",
          yanchor = "bottom"
        )
      ),

      legend = list(
        title = list(text = "Country")
      ),

      margin = list(
        l = 60,
        r = 30,
        b = 60,
        t = 90
      )
    )
}

# ---------------------------
# 11. HELPER FUNCTION:
#     % CHANGE CHART
# ---------------------------

make_change_chart <- function(data, fuel_name) {

  d <- data %>%
    filter(fuel_type == fuel_name)

  p <- plot_ly()

  for (cty in countries) {

    temp <- d %>% filter(country == cty)

    p <- p %>%
      add_lines(
        data = temp,
        x = ~date,
        y = ~change_pct,
        name = cty,
        text = ~paste0(
          "<b>", country, "</b>",
          "<br>Date: ", format(date, "%d %b %Y"),
          "<br>Change: ", round(change_pct, 1), "%"
        ),
        hoverinfo = "text"
      )
  }

  p %>%
    layout(
      title = list(
        text = paste0(
          str_to_title(fuel_name),
          " cumulative change from pre-closure baseline"
        )
      ),

      xaxis = list(
        title = "Week"
      ),

      yaxis = list(
        title = "Change (%)"
      ),

      hovermode = "x unified",

      shapes = list(
        list(
          type = "line",
          x0 = event_date,
          x1 = event_date,
          y0 = 0,
          y1 = 1,
          xref = "x",
          yref = "paper",
          line = list(
            dash = "dash",
            width = 2
          )
        ),
        list(
          type = "line",
          x0 = min(d$date),
          x1 = max(d$date),
          y0 = 0,
          y1 = 0,
          xref = "x",
          yref = "y",
          line = list(
            dash = "dot",
            width = 1
          )
        )
      ),

      legend = list(
        title = list(text = "Country")
      ),

      margin = list(
        l = 60,
        r = 30,
        b = 60,
        t = 90
      )
    )
}

# ---------------------------
# 12. CREATE SIX CHART OBJECTS
# ---------------------------

gas_raw <- make_raw_chart(
  fuel_event,
  "gasoline"
)

gas_index <- make_index_chart(
  fuel_event,
  "gasoline"
)

gas_change <- make_change_chart(
  fuel_event,
  "gasoline"
)

diesel_raw <- make_raw_chart(
  fuel_event,
  "diesel"
)

diesel_index <- make_index_chart(
  fuel_event,
  "diesel"
)

diesel_change <- make_change_chart(
  fuel_event,
  "diesel"
)

# ---------------------------
# 13. OPTIONAL:
#     VIEW INDIVIDUAL CHARTS
# ---------------------------

gas_raw
gas_index
gas_change

diesel_raw
diesel_index
diesel_change

# ---------------------------
# 14. ECONOMIC INTERPRETATION
# ---------------------------

gas_summary <- summary_stats %>%
  filter(Fuel == "Gasoline") %>%
  arrange(desc(latest_change_pct))

diesel_summary <- summary_stats %>%
  filter(Fuel == "Diesel") %>%
  arrange(desc(latest_change_pct))

gas_leader <- gas_summary %>% slice(1)
gas_laggard <- gas_summary %>% slice(n())

diesel_leader <- diesel_summary %>% slice(1)
diesel_laggard <- diesel_summary %>% slice(n())

gas_volatility <- gas_summary %>%
  arrange(desc(post_sd)) %>%
  slice(1)

diesel_volatility <- diesel_summary %>%
  arrange(desc(post_sd)) %>%
  slice(1)

economic_text <- tags$div(
  tags$p(
    HTML(
      glue(
        "<b>Gasoline:</b> {gas_leader$Country} recorded the largest latest increase ",
        "({round(gas_leader$latest_change_pct,1)}%), while ",
        "{gas_laggard$Country} recorded the smallest ",
        "({round(gas_laggard$latest_change_pct,1)}%). ",
        "Post-event volatility was highest in ",
        "{gas_volatility$Country}."
      )
    )
  ),

  tags$p(
    HTML(
      glue(
        "<b>Diesel:</b> {diesel_leader$Country} recorded the largest latest increase ",
        "({round(diesel_leader$latest_change_pct,1)}%), while ",
        "{diesel_laggard$Country} recorded the smallest ",
        "({round(diesel_laggard$latest_change_pct,1)}%). ",
        "Post-event volatility was highest in ",
        "{diesel_volatility$Country}."
      )
    )
  ),

  tags$p(
    "The indexed and percentage-change views are more informative for cross-country comparison ",
    "because they remove structural differences in initial price levels and make the relative ",
    "pass-through of the common external shock easier to compare."
  ),

  tags$p(
    "Potential economic mechanisms include taxation and excise duties, refinery structure, ",
    "inventory buffers, wholesale contracts, exchange-rate exposure, retail competition, ",
    "and differences in the speed of crude-oil pass-through."
  ),

  tags$p(
    tags$b("Important: "),
    "this dashboard is descriptive rather than causal. A causal analysis should add Brent crude ",
    "prices, exchange rates, taxes, inventory variables and country/time fixed effects."
  )
)

# ---------------------------
# 15. FORMAT SUMMARY TABLE
# ---------------------------

dashboard_table <- summary_stats %>%
  transmute(
    Fuel,
    Country,
    `Baseline €/L` = round(baseline_price, 4),
    `Pre avg €/L` = round(pre_avg, 4),
    `Post avg €/L` = round(post_avg, 4),
    `Post vs pre avg %` = round(post_vs_pre_avg_pct, 1),
    `Pre SD` = round(pre_sd, 4),
    `Post SD` = round(post_sd, 4),
    `Latest €/L` = round(latest_price, 4),
    `Latest change %` = round(latest_change_pct, 1),
    `Peak change %` = round(peak_change_pct, 1)
  )

dt_table <- datatable(
  dashboard_table,
  rownames = FALSE,
  options = list(
    pageLength = 10,
    autoWidth = TRUE,
    scrollX = TRUE
  )
)

# ---------------------------
# 16. BUILD INTERACTIVE HTML DASHBOARD
# ---------------------------

dashboard <- tagList(

  tags$head(
    tags$title(
      "EU Fuel Price Response to the Strait of Hormuz Closure"
    ),

    tags$style(
      HTML("
        body {
          font-family: Arial, Helvetica, sans-serif;
          background: #f5f7fb;
          color: #172033;
          margin: 0;
        }

        .container {
          max-width: 1180px;
          margin: auto;
          padding: 28px;
        }

        .card {
          background: white;
          padding: 22px;
          border-radius: 14px;
          margin-bottom: 20px;
          box-shadow: 0 4px 18px rgba(0,0,0,0.06);
        }

        h1 {
          margin-top: 0;
          font-size: 30px;
        }

        h2 {
          margin-top: 0;
        }

        .subtitle {
          color: #5d6678;
          line-height: 1.5;
        }

        .note {
          font-size: 13px;
          color: #667085;
          line-height: 1.6;
        }

        .grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 20px;
        }

        @media(max-width: 850px) {
          .grid {
            grid-template-columns: 1fr;
          }
        }

        .tab-buttons button {
          padding: 10px 14px;
          margin-right: 8px;
          margin-bottom: 8px;
          border: 1px solid #cfd5df;
          background: white;
          border-radius: 8px;
          cursor: pointer;
          font-weight: bold;
        }
      ")
    )
  ),

  tags$div(
    class = "container",

    # HERO
    tags$div(
      class = "card",

      tags$h1(
        "EU Fuel Price Response to the Strait of Hormuz Closure"
      ),

      tags$p(
        class = "subtitle",
        glue(
          "Weekly retail gasoline and diesel prices in the Netherlands, Germany and Belgium. ",
          "Event date: 28 February 2026. Study window: ",
          "{start_date} to {latest_date}."
        )
      )
    ),

    # GASOLINE
    tags$div(
      class = "card",

      tags$h2("Gasoline"),

      tags$h3("Raw price"),
      gas_raw,

      tags$h3("Indexed price: pre-event baseline = 100"),
      gas_index,

      tags$h3("Percentage change from baseline"),
      gas_change
    ),

    # DIESEL
    tags$div(
      class = "card",

      tags$h2("Diesel"),

      tags$h3("Raw price"),
      diesel_raw,

      tags$h3("Indexed price: pre-event baseline = 100"),
      diesel_index,

      tags$h3("Percentage change from baseline"),
      diesel_change
    ),

    # ECONOMIC INTERPRETATION
    tags$div(
      class = "grid",

      tags$div(
        class = "card",
        tags$h2("Economic interpretation"),
        economic_text
      ),

      tags$div(
        class = "card",

        tags$h2("Event-study interpretation"),

        tags$p(
          "The three countries experience the same broad international oil-market shock, ",
          "but retail price pass-through may differ because of national fuel taxes, refinery ",
          "conditions, inventory levels, contracts, exchange rates and market competition."
        ),

        tags$p(
          "The indexed chart is therefore particularly useful because it separates relative ",
          "price response from structural differences in pump-price levels."
        )
      )
    ),

    # TABLE
    tags$div(
      class = "card",

      tags$h2("Pre/post summary statistics"),

      dt_table
    ),

    # METHODOLOGY
    tags$div(
      class = "card",

      tags$h2("Methodology"),

      tags$p(
        class = "note",
        "Baseline = each country's last weekly observation before 28 February 2026."
      ),

      tags$p(
        class = "note",
        "Index = 100 × Price / Baseline Price."
      ),

      tags$p(
        class = "note",
        "Percentage Change = 100 × (Price / Baseline Price − 1)."
      ),

      tags$p(
        class = "note",
        "Volatility = standard deviation of weekly retail prices in each period."
      ),

      tags$p(
        class = "note",
        "This dashboard compares retail road-fuel prices rather than crude-oil prices."
      )
    )
  )
)

# ---------------------------
# 17. SAVE DASHBOARD
# ---------------------------

htmltools::save_html(
  dashboard,
  file = "index.html"
)

cat("\nDashboard successfully saved as: index.html\n")

# ---------------------------
# 18. OPTIONAL:
#     SAVE STANDALONE PLOTS
# ---------------------------

htmlwidgets::saveWidget(
  gas_index,
  "gasoline_index_chart.html",
  selfcontained = TRUE
)

htmlwidgets::saveWidget(
  diesel_index,
  "diesel_index_chart.html",
  selfcontained = TRUE
)

htmlwidgets::saveWidget(
  gas_change,
  "gasoline_change_chart.html",
  selfcontained = TRUE
)

htmlwidgets::saveWidget(
  diesel_change,
  "diesel_change_chart.html",
  selfcontained = TRUE
)

# ---------------------------
# 19. ECONOMETRIC EXTENSION:
#     EVENT-TIME VARIABLE
# ---------------------------

# Weekly event-time distance from closure
fuel_event <- fuel_event %>%
  mutate(
    event_time_days = as.numeric(date - event_date),
    event_week = floor(event_time_days / 7)
  )

# Example:
fuel_event %>%
  select(
    date,
    country,
    fuel_type,
    price_eur_l,
    index_100,
    change_pct,
    event_week
  ) %>%
  arrange(fuel_type, country, date) %>%
  print(n = 20)

# ---------------------------
# 20. OPTIONAL PANEL MODEL
# ---------------------------

# If you later want a formal panel regression:
#
# install.packages(c("fixest", "broom"))
#
# library(fixest)
# library(broom)
#
# Example descriptive fixed-effects model:
#
# model_fe <- feols(
#   log(price_eur_l) ~ i(event_week, ref = -1) |
#     country + date,
#   data = fuel_event %>%
#     filter(fuel_type == "diesel"),
#   cluster = ~country
# )
#
# summary(model_fe)
# iplot(model_fe)
#
# NOTE:
# With only three countries and one common event, causal identification
# is limited. This model becomes substantially stronger after adding:
#
# - Brent crude oil price
# - EUR/USD exchange rate
# - fuel excise taxes
# - VAT
# - oil inventories
# - refinery indicators
# - national policy interventions
#
# ---------------------------
# END
# ---------------------------

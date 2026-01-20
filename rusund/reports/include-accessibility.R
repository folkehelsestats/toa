### Figure line


drkFig <- make_hist(d = drkDT,
          x = year,
          y = percentage,
          group = kjonn2,
          n = count,
          title = "Alkoholbruk siste 12 måneder 2012-2024",
          subtitle = "Kilde: Rusundersøkelse 2012-2014 ",
          type = "line",
          dot_size = 6,
          flip = FALSE)

library(htmlwidgets)
saveWidget(drkFig, "line-access01.html", selfcontained = T)

## ---------------------

list_data <- mapply(function(low, high) list(low = low, high = high),
                         enhetTbl$lower_enhet, enhetTbl$upper_enhet,
                         SIMPLIFY = FALSE)

hcAll <- highchart() |>
  hc_chart(type = "line") |>
  hc_title(text = "Alkoholbruk siste 4 uker") |>
  hc_xAxis(categories = enhetTbl$year) |>
  hc_yAxis(
    title = list(text = "Antall alkoholeneheter"),
    min = 0 ) |>
  hc_add_series(name = "Antall enheter ", data = enhetTbl$adj_enhet, type = "line") |>
  hc_add_series(
    name = "95% CI",
    data = list_data,
    type = "arearange",
    linkedTo = ":previous",
    color = hex_to_rgba("#206276", 0.3),
    ## color = hex_to_rgba("#7cb5ec", 0.3),
    fillOpacity = 0.3
  ) |>
  hc_tooltip(shared = TRUE) |>
  hc_exporting(enabled = TRUE) |>
  hc_legend(enabled = FALSE)

hcDep <- hcAll |>
  hc_add_dependency(name = "modules/exporting.js") |>
  hc_add_dependency(name = "modules/export-data.js") |>
  hc_add_dependency(name = "modules/accessibility.js")


htmlwidgets::saveWidget(hcDep, "figure-access-01.html", selfcontained = T)

#### --------------------------------------------

library(highcharter)
library(htmlwidgets)
library(htmltools)

# Create your chart
hcAll <- highchart() |>
  hc_chart(type = "line") |>
  hc_title(text = "Alkoholbruk siste 4 uker") |>
  hc_xAxis(categories = enhetTbl$year) |>
  hc_yAxis(
    title = list(text = "Antall alkoholeneheter"),
    min = 0
  ) |>
  hc_add_series(
    name = "Antall enheter",
    data = enhetTbl$adj_enhet,
    type = "line"
  ) |>
  hc_add_series(
    name = "95% CI",
    data = list_data,
    type = "arearange",
    linkedTo = ":previous",
    color = hex_to_rgba("#206276", 0.3),
    fillOpacity = 0.3
  ) |>
  hc_tooltip(shared = TRUE) |>
  hc_exporting(enabled = TRUE) |>
  hc_legend(enabled = FALSE)

# Add accessibility options
hcAll$x$hc_opts$accessibility <- list(
  enabled = TRUE,
  description = "Linjediagram som viser alkoholbruk over tid med konfidensintervall",
  keyboardNavigation = list(enabled = TRUE)
)

# Wrap chart with all three modules
chart_with_modules <- tagList(
  tags$script(src = "https://code.highcharts.com/modules/exporting.js"),
  tags$script(src = "https://code.highcharts.com/modules/export-data.js"),
  tags$script(src = "https://code.highcharts.com/modules/accessibility.js"),
  hcAll
)

# Save as standalone HTML
saveWidget(
  chart_with_modules,
  file = "alkoholbruk_chart_access.html",
  selfcontained = TRUE
)


#### -------------------------------------------

library(highcharter)
library(htmlwidgets)

# Create your chart
hcAll <- highchart() |>
  hc_chart(type = "line") |>
  hc_title(text = "Alkoholbruk siste 4 uker") |>
  hc_xAxis(categories = enhetTbl$year) |>
  hc_yAxis(
    title = list(text = "Antall alkoholeneheter"),
    min = 0
  ) |>
  hc_add_series(
    name = "Antall enheter",
    data = enhetTbl$adj_enhet,
    type = "line"
  ) |>
  hc_add_series(
    name = "95% CI",
    data = list_data,
    type = "arearange",
    linkedTo = ":previous",
    color = hex_to_rgba("#206276", 0.3),
    fillOpacity = 0.3
  ) |>
  hc_tooltip(shared = TRUE) |>
  hc_exporting(enabled = TRUE) |>
  hc_legend(enabled = FALSE)

# Add accessibility options
hcAll$x$hc_opts$accessibility <- list(
  enabled = TRUE,
  description = "Linjediagram som viser alkoholbruk over tid",
  keyboardNavigation = list(enabled = TRUE)
)

# Save the widget
saveWidget(hcAll, "temp_chart.html", selfcontained = TRUE)

# Read and modify the HTML file
html_content <- readLines("temp_chart.html", warn = FALSE)

# Find where to insert scripts (after highcharts.js)
insert_pos <- grep("highcharts", html_content, ignore.case = TRUE)
if (length(insert_pos) > 0) {
  insert_pos <- insert_pos[1]
} else {
  # If not found, insert before </head>
  insert_pos <- grep("</head>", html_content)[1] - 1
}

# Create the three module scripts
modules_scripts <- c(
  '<script src="https://code.highcharts.com/modules/exporting.js"></script>',
  '<script src="https://code.highcharts.com/modules/export-data.js"></script>',
  '<script src="https://code.highcharts.com/modules/accessibility.js"></script>'
)

# Insert all three scripts
html_content <- append(html_content, modules_scripts, after = insert_pos)

# Write the final HTML
writeLines(html_content, "alkoholbruk_chart.html")

# Clean up temp file
file.remove("temp_chart.html")

cat("Chart saved with all modules included: alkoholbruk_chart.html\n")

### ------------------------------------
library(highcharter)

data <- data.frame(
    fruit = c("apple", "banana", "orange", "pear"),
    count = c(2, 3, 5, 4)
    )

highchart() |>
  hc_add_dependency(name = "modules/accessibility.js") |>
  hc_add_dependency(name = "modules/exporting.js") |>
  hc_add_dependency(name = "modules/export-data.js") |>
  hc_title(text = "Fruits") |>
  hc_xAxis(categories = data$fruit) |>
  hc_add_series(
    data = data$count,
    type = "column",
    name = "Count"
  ) |>
  hc_exporting(
    enabled = TRUE,
    accessibility = list(
      enabled = TRUE
    )
  ) |>
    hc_plotOptions(
      accessibility = list(
        enabled = TRUE,
        keyboardNavigation = list(enabled = TRUE)
    )
  )

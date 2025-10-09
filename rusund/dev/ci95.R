source(file.path(here::here(), "rusund/dev/sample-data.R"))

## ---------------
library(highcharter)

list_data <- mapply(\(low, high) list(low = low, high = high),
                         dtx$lower_enhet, dtx$upper_enhet,
                         SIMPLIFY = FALSE)

highchart() |>
  hc_chart(type = "line") |>
  hc_title(text = "Alkoholbruk siste 4 uker") |>
  hc_xAxis(categories = dtx$year) |>
  hc_yAxis(
    title = list(text = "Antall alkoholeneheter"),
    min = 0 ) |>
  hc_add_series(name = "Antall enheter ", data = dtx$adj_enhet, type = "line") |>
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

### Steps-by-steps
### --------------
library(highcharter)
hdcolor <- c('#206276',
            '#7C145C',
            '#3699B6',
            '#D17A00',
            '#67978A',
            '#BB7BDA',
            '#959588',
            '#CD3D57',
            '#47A571')

subtit <- "Tallene er justert for forskjeller
i kjønn og alder i befolkningen for å gjøre det
sammenlignbare over tid"

hcx <- highchart(height = 600) |>
  hc_title(text = "Alkoholbruk siste 4 uker med 95% CI",
           margin = 20, #space btw title (or subtitle) and plot [default = 15]
           align = "left",
           style = list(useHTML = TRUE)) |>
  hc_subtitle(text = subtit,
              align = "left")

hc1 <- hcx |>
  hc_add_series(
    data = dtx,
    name = "Antall enheter",
    type = "line",
    id = "ci",
    hcaes(x = year, y = adj_enhet),
    lineWidth = 4,
    showInLegend = FALSE,
    color = hex_to_rgba("#206276"),
    marker = list(
      symbol = "circle",
      enabled = TRUE,
      radius = 6
    )
  )


hc2 <- hc1 |>
  hc_yAxis(title = list(text = "Antall alkoholenheter"),
           accessibility = list(
             enabled = TRUE,
             description = "antall alkoholenheter")) |>
  hc_xAxis(title = list(text = "År"),
           accessibility = list(
             enabled = TRUE,
             description = "årgangene fra 2014 til 2024")) |>
  highcharter::hc_caption(text = "Tall om alkohol") |>
  highcharter::hc_credits(
                 enabled = TRUE,
                 text = "Helsedirektoratet",
                 href = "https://www.helsedirektoratet.no/"
               )

hc3 <- hc2 |>
  hc_add_series(
    data = dtx,
    name = "95% CI",
    type = "arearange",
    hcaes(x = year, low = lower_enhet, high = upper_enhet),
    linkedTo = "ci",
    showInLegend = FALSE,
    color = hex_to_rgba("#206276"),
    fillOpacity = 0.6,
    lineWidth = 0, # No border line
    marker = list(enabled = FALSE)
  )

hc4 <- hc3 |>
  hc_tooltip(shared = TRUE) |>
  hc_exporting(enabled = TRUE) |>
  hc_add_dependency(name = "modules/accessibility.js")

## hc3 <- hc2 |>
##   hc_tooltip(
##     headerFormat = "<b>{series.name}</b><b>",
##     pointFormat = "Antall enhet: {point.y}"
##   )

## hc5 <- hc4 |>
##     hc_exporting(
##     accessibility = list(
##       enabled = TRUE # default value is TRUE
##       ),
##     enabled = TRUE,
##     filename = "Alkohol-enheter"
##   ) |>
##   hc_plotOptions(
##     accessibility = list(
##       enabled = TRUE, #default value is TRUE
##       keyboardNavigation = list(enabled = TRUE)
##       )
##     )


library(htmlwidgets)
saveWidget(hc4, file = "figure_med_ci-hdir.html", selfcontained = TRUE)

## Alternative

library(htmltools)

# Wrap the widget in a tag with height styling
html <- tags$html(
  tags$head(),
  tags$body(
    style = "margin:0;",
    div(style = "height:600px;", hc4)
  )
)

# Save the HTML
save_html(html, "figure_med_ci_custom.html")


### Function
### --------

create_ci_chart(dtx)

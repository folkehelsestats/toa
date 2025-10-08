## Data with 95% CI
## -----------------

dtx <- structure(list(year = 2012:2024, adj_mean = c(29.5688209339657,
26.3820822909092, 30.2479196947085, 24.9407936417228, 25.1552075711594,
27.7067665662496, 26.6906409447569, 25.42515335889, 22.5086285695818,
25.7139807039742, 26.9308848055768, 26.2342670110854, 27.3435961548168
), SE = c(1.31401820814255, 0.898223842915539, 1.22017849767529,
0.95793914417514, 1.07138968311867, 0.953327936942327, 1.04394544742553,
0.982999807380587, 0.964926259096372, 1.06360056066082, 1.0789167751084,
1.04762055989222, 0.738525586449375), lower_95CI = c(26.9917880872796,
24.6205796839977, 27.855050217472, 23.0622482786204, 23.0540848610283,
25.8372467955423, 24.64340986896, 23.4974198595011, 20.6163601352583,
23.6282017414799, 24.8149252900896, 24.1797904994534, 25.8957573623527
), upper_95CI = c(32.1458537806517, 28.1435848978207, 32.6407891719449,
26.8193390048252, 27.2563302812906, 29.5762863369569, 28.7378720205538,
27.3528868582788, 24.4008970039054, 27.7997596664685, 29.0468443210639,
28.2887435227175, 28.7914349472809), adj_enhet = c(19.7, 17.6,
20.2, 16.6, 16.8, 18.5, 17.8, 17, 15, 17.1, 18, 17.5, 18.2),
    SE_enhet = c(0.9, 0.6, 0.8, 0.6, 0.7, 0.6, 0.7, 0.7, 0.6,
    0.7, 0.7, 0.7, 0.5), lower_enhet = c(18, 16.4, 18.6, 15.4,
    15.4, 17.2, 16.4, 15.7, 13.7, 15.8, 16.5, 16.1, 17.3), upper_enhet = c(21.4,
    18.8, 21.8, 17.9, 18.2, 19.7, 19.2, 18.2, 16.3, 18.5, 19.4,
    18.9, 19.2)), row.names = c(NA, -13L), class = c("data.table",
"data.frame"))

## Dataset with gender
dtkj <-
structure(list(kjonn = structure(c("1", "1", "1", "1", "1", "1",
"1", "1", "1", "1", "1", "1", "1", "2", "2", "2", "2", "2", "2",
"2", "2", "2", "2", "2", "2", "2"), label = "IOs kjønn", format.stata = "%1s"),
    year = c(2012L, 2013L, 2014L, 2015L, 2016L, 2017L, 2018L,
    2019L, 2020L, 2021L, 2022L, 2023L, 2024L, 2012L, 2013L, 2014L,
    2015L, 2016L, 2017L, 2018L, 2019L, 2020L, 2021L, 2022L, 2023L,
    2024L), adj_mean = c(39.9534494013342, 36.4366085172396,
    40.1218495785967, 33.5071360168982, 33.7999998752252, 34.040777818593,
    34.4416520612159, 31.9644150234791, 28.3125963087004, 34.6111331093156,
    36.0934348693515, 34.3912521953534, 35.4129728498304, 19.2158069961129,
    16.2987229537049, 20.4071713171405, 16.3684523600746, 16.5144875220262,
    21.4046942833816, 18.8811860315978, 18.8902437612745, 16.6742604519355,
    16.7988662922662, 17.7598442065029, 18.1477985410824, 19.2754560917665
    ), SE = c(2.37961465920224, 1.58875647328087, 2.0546200666149,
    1.63223247158931, 1.93202810956405, 1.49238954144028, 1.72844402301914,
    1.69287641926771, 1.6662851934948, 1.86851200933235, 1.91289210595667,
    1.80516167675502, 1.1224943436911, 1.05842075962892, 0.80552800815461,
    1.31567166848581, 1.00102712568771, 0.868936995947683, 1.18378539463991,
    1.13242241796748, 0.926270989221476, 0.933798980264774, 0.992891194548132,
    0.97504817595482, 1.04561834491425, 0.959290561727631), lower_95CI = c(35.2837640271631,
    33.3191400660918, 36.0902209662602, 30.3044984625179, 30.0088950080674,
    31.1124633028755, 31.0502826663131, 28.6428742031312, 25.0431691496594,
    30.9448270211323, 32.3395415558719, 30.8492011715322, 33.211834282392,
    17.13871073118, 14.7180739832504, 17.8255902148302, 14.4043696550135,
    14.8093609774397, 19.0819939701495, 16.6591559746197, 17.07261426562,
    14.841987044638, 14.8506720256205, 15.8463948865643, 16.096031819571,
    17.3943660331341), upper_95CI = c(44.6231347755052, 39.5540769683875,
    44.1534781909331, 36.7097735712786, 37.591104742383, 36.9690923343105,
    37.8330214561188, 35.2859558438269, 31.5820234677415, 38.2774391974988,
    39.8473281828311, 37.9333032191746, 37.6141114172689, 21.2929032610458,
    17.8793719241594, 22.9887524194509, 18.3325350651357, 18.2196140666127,
    23.7273945966138, 21.103216088576, 20.707873256929, 18.5065338592329,
    18.7470605589119, 19.6732935264414, 20.1995652625939, 21.1565461503989
    ), adj_enhet = c(26.6, 24.3, 26.7, 22.3, 22.5, 22.7, 23,
    21.3, 18.9, 23.1, 24.1, 22.9, 23.6, 12.8, 10.9, 13.6, 10.9,
    11, 14.3, 12.6, 12.6, 11.1, 11.2, 11.8, 12.1, 12.9), SE_enhet = c(1.6,
    1.1, 1.4, 1.1, 1.3, 1, 1.2, 1.1, 1.1, 1.2, 1.3, 1.2, 0.7,
    0.7, 0.5, 0.9, 0.7, 0.6, 0.8, 0.8, 0.6, 0.6, 0.7, 0.7, 0.7,
    0.6), lower_enhet = c(23.5, 22.2, 24.1, 20.2, 20, 20.7, 20.7,
    19.1, 16.7, 20.6, 21.6, 20.6, 22.1, 11.4, 9.8, 11.9, 9.6,
    9.9, 12.7, 11.1, 11.4, 9.9, 9.9, 10.6, 10.7, 11.6), upper_enhet = c(29.7,
    26.4, 29.4, 24.5, 25.1, 24.6, 25.2, 23.5, 21.1, 25.5, 26.6,
    25.3, 25.1, 14.2, 11.9, 15.3, 12.2, 12.1, 15.8, 14.1, 13.8,
    12.3, 12.5, 13.1, 13.5, 14.1)), row.names = c(NA, -26L), class = c("data.table",
"data.frame"))


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
    color = hex_to_rgba("#3699B6", 0.6),
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
saveWidget(hc4, file = "figure_med_ci.html", selfcontained = TRUE)

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

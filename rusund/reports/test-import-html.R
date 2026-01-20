
hc <- make_hist(d = drkDT,
          x = year,
          y = percentage,
          group = kjonn2,
          n = count,
          title = "Alkoholbruk siste 12 måneder 2012-2024",
          subtitle = "Kilde: Rusundersøkelse 2012-2014 ",
          type = "line",
          dot_size = 6,
          flip = FALSE)

htmlwidgets::saveWidget(hc,
                        file = "test-01.html",
                        selfcontained = FALSE)

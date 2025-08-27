## Alkohol enhet
pth <- "~/Git-hdir/toa/rusund"
source(file.path(pth, "rus-draft.R"))


## Alkoholmegnde pr drikkesort, ren alkohol cl



## Regner alkohol enhet fra ren alkohol
alcohol_unit <- function(ren_alkohol_cl) {
  # Alkoholmengde per enhet
  ol_enhet <- 50 * 0.045     # 0,5 l øl med 4,5 %
  vin_enhet12 <- 12.5 * 0.12     # 12.5 cl vin med 12 %
  vin_enhet15 <- 15 * 0.12     # 15 cl vin med 12 %
  sprit_enhet <- 4 * 0.40    # 4 cl sprit med 40 %

  # Beregning av antall enheter
  ol_antall <- ren_alkohol_cl / ol_enhet
  vin_antall12 <- ren_alkohol_cl / vin_enhet12
  vin_antall15 <- ren_alkohol_cl / vin_enhet15
  sprit_antall <- ren_alkohol_cl / sprit_enhet

  # Resultattabell
  data.frame(
    Drikke = c("Øl (50 cl, 4,5%)", "Vin (12.5 cl, 12%)", "Vin (15 cl, 12%)","Sprit (4 cl, 40%)"),
    Antall_enheter = round(c(ol_antall, vin_antall12, vin_antall15, sprit_antall), 2)
  )
}

alcohol_unit(9)

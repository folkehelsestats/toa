## Alkohol enhet
pth <- "~/Git-hdir/toa/rusund"
source(file.path(pth, "rus-draft.R"))


## Alkoholmegnde pr drikkesort, ren alkohol cl



## Regner alkohol enhet fra ren alkohol
alkohol_enhetskalkulator <- function(ren_alkohol_cl) {
  # Alkoholmengde per enhet
  ol_enhet <- 50 * 0.045     # 0,5 l øl med 4,5 %
  vin_enhet <- 15 * 0.12     # 15 cl vin med 12 %
  sprit_enhet <- 4 * 0.40    # 4 cl sprit med 40 %

  # Beregning av antall enheter
  ol_antall <- ren_alkohol_cl / ol_enhet
  vin_antall <- ren_alkohol_cl / vin_enhet
  sprit_antall <- ren_alkohol_cl / sprit_enhet

  # Resultattabell
  data.frame(
    Drikke = c("Øl (0,5 l, 4,5%)", "Vin (15 cl, 12%)", "Sprit (4 cl, 40%)"),
    Antall_enheter = round(c(ol_antall, vin_antall, sprit_antall), 2)
  )
}

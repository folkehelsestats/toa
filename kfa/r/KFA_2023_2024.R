
# Databehandling og analyser ifm publisering av ToA og KFA-data fra 2023 (samlet inn i 2024)
# Filen er under arbeid.

library(data.table)
library(haven)  # for å lese Stata-filer

# Les inn kommuneinndeling
kommuner <- as.data.table(read_dta("o:/Prosjekt/Rusdata/Kommunenes forvaltning/Alkoholloven/Analyser 2023_2024/kommuner2023.dta"))
kommuner[, utvalg_kommunenummer := as.integer(code)]
kommuner <- kommuner[utvalg_kommunenummer != 9999]
setnames(kommuner, "name", "name2023")

# Les inn KFA-data
kfa <- as.data.table(read_dta("o:/Prosjekt/Rusdata/Kommunenes forvaltning/Alkoholloven/Analyser 2023_2024/KFA_2023_2024_original.dta"))


#Før merge, se om det er match mtp kommunenr:
  # Full outer join for å se alt
  sjekk <- merge(kommuner, kfa, by = "utvalg_kommunenummer", all = TRUE)
  
  # Lag en kolonne som tilsvarer _merge i Stata
  sjekk[, merge_status := fifelse(!is.na(name2023) & !is.na(q1_1), "match",
                                  fifelse(!is.na(name2023) & is.na(q1_1), "kun_i_kommuner",
                                          fifelse(is.na(name2023) & !is.na(q1_1), "kun_i_kfa", NA_character_)))]
  # Oppsummer
  sjekk[, .N, by = merge_status]
  # Fra merge_status ser jeg at Ålesund kommune har feil kommunenavn i kfa, som må endres.

# Merge
data <- merge(kfa, kommuner, by = "utvalg_kommunenummer", all.x = TRUE)


# Fiks Ålesunds kommunenummer 
data[utvalg_kommunenummer == 1508, utvalg_kommunenummer := 1507]

  # må jeg legge inn info fra Ålesund i følgende variabler? code, name2023, validTo ?



#Bente, forsett her!



# Legge til total salgs- og skjenkebevillinger -  Les inn kvalitetssjekk-data
kvalitet <- as.data.table(read_dta("kvalitetsjekk_bevilling_2023_2024.dta"))
data <- merge(data, kvalitet, by = "utvalg_kommunenummer", all.x = TRUE)


# Imputering av manglende verdier fra tidligere år .- Les inn kvalitetssjekk-data
# Eksempel for dagligvare
data[, dagligvare := fifelse(!is.na(q1_1_1_resp), q1_1_1_resp,
                             fifelse(!is.na(q1_1_1_resp_2022), q1_1_1_resp_2022,
                                     q1_1_1_resp_2020))]

# Gruppering av salgsbevillinger
data[, salgsbevillingsgruppe := fcase(
  tot_salg23 >= 1 & tot_salg23 <= 5, 1,
  tot_salg23 >= 6 & tot_salg23 <= 10, 2,
  tot_salg23 >= 11 & tot_salg23 <= 20, 3,
  tot_salg23 >= 21 & tot_salg23 <= 30, 4,
  tot_salg23 >= 31 & tot_salg23 <= 50, 5,
  tot_salg23 > 50, 6
)]

# Oppsummeringstabeller
# Antall salgsbevillinger per gruppe
data[, .N, by = salgsbevillingsgruppe]

# Total antall salgsbevillinger
data[, sum(tot_salg23, na.rm = TRUE)]

# Kommuner med 0 skjenkebevillinger
data[tot_skjenk23 == 0, .(name2023, utvalg_kommunenummer)]







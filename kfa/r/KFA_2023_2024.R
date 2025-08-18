
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
  # Merger alle - så vi får både match og ikke på utvalgskommune:
  sjekk <- merge(kommuner, kfa, by = "utvalg_kommunenummer", all = TRUE)
  
  # Lag en kolonne som tilsvarer _merge i Stata
  sjekk[, merge_status := fifelse(!is.na(name2023) & !is.na(q1_1), "match",
                                  fifelse(!is.na(name2023) & is.na(q1_1), "kun_i_kommuner",
                                          fifelse(is.na(name2023) & !is.na(q1_1), "kun_i_kfa", NA_character_)))]
  # Oppsummer
  sjekk[, .N, by = merge_status]
  # Fra merge_status ser jeg at Ålesund kommune har feil kommunenavn i kfa, som må endres.

#Erstatter verdier fra kommuner til kfa for Ålesund og endrer kommunenr så det blir riktig i henhold til 2023:
  # Kopier verdier fra riktig ID (1507)
  verdier <- sjekk[utvalg_kommunenummer == 1507, .(code, name2023, validTo)]
  
  # Oppdater feil ID (1508) med disse verdiene
  sjekk[utvalg_kommunenummer == 1508, `:=`(
    code = verdier$code,
    name2023 = verdier$name2023,
    validTo = verdier$validTo
  )]
  
  # beholder alle rader unntatt kommune med nummer 1507:
  sjekk <- sjekk[utvalg_kommunenummer != 1507]
                 
  # endrer kommunenummer så det blir korrekt for Ålesund
  sjekk[utvalg_kommunenummer == 1508, utvalg_kommunenummer := 1507]
  
  
# duplikater?
   sjekk[, .N, by = utvalg_kommunenummer][N > 1]
 
# fjerner data og variabler jeg ikke trenger:
   rm(verdier, kfa, kommuner)

   names(sjekk)
   sjekk[, merge_status := NULL]
   names(sjekk)   

# endrer data-navn:
   data <- sjekk
   rm(sjekk)  
   

#Lager variabler med tot_salg og tot_skjenk for 2023
    #Her må missing values imputeres fra fjoråret når variabel fra forrige år er lagt til.

   # Lister kommuner med manglende tall for salgsbevillinger i 2023:
   data[is.na(q1_1), .(utvalg_kommunenummer, name2023)]
   
   # Lister kommuner med manglende tall for skjenkebevillinger i 2023:
   data[is.na(q2_1), .(utvalg_kommunenummer, name2023)]
   
   # se på relevant data som jeg skal endre:
   data[utvalg_kommunenummer %in% c(1874, 5001, 5424, 5428, 5441, 3035), .(utvalg_kommunenummer, q1_1, q2_1)]
   
# Legge til total salgs- og skjenkebevillinger -  Les inn kvalitetssjekk-data og mergeer:
kvalitet <- as.data.table(read_dta("O:/Prosjekt/Rusdata/Kommunenes forvaltning/Alkoholloven/Analyser 2023_2024/kvalitetsjekk_bevilling_2023_2024.dta"))
data <- merge(data, kvalitet, by = "utvalg_kommunenummer", all.x = TRUE)

names(data)  

#sjekker om det er missing på variabelen jeg skal bruke:
data[, .(
  missing_tot_salg23 = sum(is.na(tot_salg23)),
  missing_tot_skjenk23 = sum(is.na(tot_skjenk23))
)]


# salgsbevillinger:
  # Total antall salgsbevillinger
  data[, sum(tot_salg23, na.rm = TRUE)]
  data[, sum(tot_salg23)]

  # For å få salgsbevilling etter utsalgssted må jeg hente inn data for Tana kommune da det mangler.
tana <- as.data.table(read_dta("O:/Prosjekt/Rusdata/Kommunenes forvaltning/Alkoholloven/Data_Stata/2021_behandlet.dta"))

  #Fortsett her BEnte: 
  # Neste steg er å finne antall salgsbevillinger for ulike utsalgssteder, men må først imputere fra tidligere år for kommuner med missing.




# Eksempel for dagligvare
  names(kvalitet) 
  
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


# Antall salgsbevillinger per gruppe
data[, .N, by = salgsbevillingsgruppe]

# Total antall salgsbevillinger
data[, sum(tot_salg23 tot_skjenk23, na.rm = TRUE)]
data[, sum(tot_salg23)]

# Kommuner med 0 skjenkebevillinger
data[tot_skjenk23 == 0, .(name2023, utvalg_kommunenummer)]







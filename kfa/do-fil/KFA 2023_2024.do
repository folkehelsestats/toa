/*Analyser Alkoholloven 2023 med data innhenta 2024*/

** Fil som ser på kommunenes forvaltning av alkoholloven
** Fil som presenterer tall til Tall om alkohol
** Data om 2023, innsamlet i 2024
* Opprettet av Bente Øvrebø, 23/5-25
	* Filen anses som ferdig.
	
******************************************************************************* 
/* Benytter kommuneinndeling for 2023 fra SSB hentet via norgeo ved bruk av Rstudio*/

	/* Laster inn kommuneinndeling i 2023 fra SSB og rensker*/
clear all
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\kommuner2023.dta"

destring code, generate(utvalg_kommunenummer)
rename name name2023
keep name2023 utvalg_kommunenummer

drop if utvalg_kommunenummer == 9999


/* Kobler på KFA-data fra 2023 (innhentet i 2024)*/
merge 1:1 utvalg_kommunenummer using "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\KFA_2023_2024_original.dta"


/* Basert på merge vises det at Ålesund har feil kommunenr i 2023. Det har kommunenr for 2024*/
	* I 2023 har Ålesund kommunenr 1507, men KTA-fila bruker 2024 nummer hvor kommunenr er 1508
	* Endrer derfor kommunenr fra KTA-fila til korrekt kommunenr for 2023, og sletter raden i masterfila for Ålesund.
	
drop if _merge==1 
replace utvalg_kommunenummer = 1507 if utvalg_kommunenummer == 1508 // endrer kommunenr på Ålesund til riktig for 2023

duplicates report utvalg_kommunenummer // ingen duplikater, 356 kommuner
drop _merge

/* Lager variabler med tot_salg og tot_skjenk for 2023*/
	* Her må missing values imputeres fra fjoråret når variabel fra forrige år er lagt til.

		/*Kommuner med missing på salgsbevillinger 2023*/
		list utvalg_kommunenummer name2023 if q1_1==.
		* OBS på at disse kommunene benytter tall fra fjoråret eller tidligere.
		
		/*Kommuner med missing på skjenkebevillinger 2023*/
		list utvalg_kommunenummer name2023 if q2_1==.
		* OBS på at disse kommunene benytter tall fra fjoråret eller tidligere.	
		
	* Siden variabelen er laget i kvalitetssjekken importeres disse variablene ved bruk av frame:

frame create total23
frame total23: use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\kvalitetsjekk_bevilling_2023_2024.dta"
frame total23: keep utvalg_kommunenummer tot_salg23 tot_skjenk23
frlink 1:1 utvalg_kommunenummer, frame(total23)
frget tot_salg23 tot_skjenk23, from(total23)
frame drop total23
drop total23

******************************************************************************* 

/*Antall kommuner som har svart på skjema*/
	tabulate q1_1, mis // benytter antall salgsbevillinger som indikator for besvart.

/*Antall salgsbevillinger*/
		* I 2023 var det 356 kommuner
	summarize tot_salg23
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salgsbevilling = r(sum)
	display "`total_salgsbevilling'"
	

/*Antall salgsbevillinger gruppert etter antall-kategorier*/
	*Må imputere bevillinger etter type fra tidligere år for kommunene med missing.
	* Henter data for 2022:
	frame create typebevilling22
	frame typebevilling22: use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\KFA_bevillinger_2022_2023.dta"
	frame typebevilling22: keep utvalg_kommunenummer q1_1_1_resp_2022 q1_1_2_resp_2022 q1_1_3_resp_2022 q1_1_4_resp_2022 q1_1_5_resp_2022 q2_1_1_resp_2022 q2_1_2_resp_2022 q2_1_3_resp_2022
	frlink 1:1 utvalg_kommunenummer, frame(typebevilling22)
	frget q1_1_1_resp_2022 q1_1_2_resp_2022 q1_1_3_resp_2022 q1_1_4_resp_2022 q1_1_5_resp_2022 q2_1_1_resp_2022 q2_1_2_resp_2022 q2_1_3_resp_2022, from(typebevilling22)
	frame drop typebevilling22
	drop typebevilling22


/*
	/* Lager fil med variablene jeg trenger for å imputere tall for Tana kommune*/
	use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Data_Stata\2021_behandlet.dta"
	list Utvalg_Kommune Utvalg_Kommunenummer if komnr == 5441 // Sjekker at kommunenr for Tana er det samme

	/*Antall salgsbevilling*/
	rename q1_1 q1_1_2020
	rename q1_1_1_resp q1_1_1_resp_2020
	rename q1_1_2_resp q1_1_2_resp_2020
	rename q1_1_3_resp q1_1_3_resp_2020
	rename q1_1_4_resp q1_1_4_resp_2020
	rename q1_1_5_resp q1_1_5_resp_2020

	/* Antall og type skjenkebevilling*/
	rename q2_1 q2_1_2020
	rename q2_1_1_resp q2_1_1_resp_2020
	rename q2_1_2_resp q2_1_2_resp_2020
	rename q2_1_3_resp q2_1_3_resp_2020

	rename Utvalg_Kommunenummer utvalg_kommunenummer

	keep q1_1_1_resp_2020 q1_1_2_resp_2020 q1_1_3_resp_2020 q1_1_4_resp_2020 q1_1_5_resp_2020 q2_1_1_resp_2020 q2_1_2_resp_2020 q2_1_3_resp_2020 utvalg_kommunenummer
	keep if utvalg_kommunenummer == 5441 // Trekker kun ut Tana
	
	save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\KFA_Tana_bevilling_2020_2021.dta", replace
	clear all
*/

		* Henter data for 2020 for Tana:
	frame create typebevilling20
	frame typebevilling20: use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\KFA_Tana_bevilling_2020_2021.dta"
	frame typebevilling20: keep q1_1_1_resp_2020 q1_1_2_resp_2020 q1_1_3_resp_2020 q1_1_4_resp_2020 q1_1_5_resp_2020 q2_1_1_resp_2020 q2_1_2_resp_2020 q2_1_3_resp_2020 utvalg_kommunenummer
	frlink 1:1 utvalg_kommunenummer, frame(typebevilling20)
	frget q1_1_1_resp_2020 q1_1_2_resp_2020 q1_1_3_resp_2020 q1_1_4_resp_2020 q1_1_5_resp_2020 q2_1_1_resp_2020 q2_1_2_resp_2020 q2_1_3_resp_2020, from(typebevilling20)
	frame drop typebevilling20
	drop typebevilling20


* Dagligvare
gen dagligvare = q1_1_1_resp
replace dagligvare = q1_1_1_resp_2022 if missing(dagligvare)
list utvalg_kommune utvalg_kommunenummer if dagligvare==. // Tana kommune mangler
replace dagligvare = q1_1_1_resp_2020 if missing(dagligvare)

* Bryggeri
gen bryggeri = q1_1_2_resp
replace bryggeri = q1_1_2_resp_2022 if missing(bryggeri)
list utvalg_kommune utvalg_kommunenummer if bryggeri==. // Tana mangler
replace bryggeri = q1_1_2_resp_2020 if missing(bryggeri)

* Gardsutsalg
gen gaard = q1_1_3_resp
replace gaard = q1_1_3_resp_2022 if missing(gaard)
list utvalg_kommune utvalg_kommunenummer if gaard==. //Tana mangler
replace gaard = q1_1_3_resp_2020 if missing(gaard)

* Nettsalg
gen nettsalg = q1_1_4_resp
replace nettsalg = q1_1_4_resp_2022 if missing(nettsalg)
list utvalg_kommune utvalg_kommunenummer if nettsalg ==. //Tana mangler
replace nettsalg = q1_1_4_resp_2020 if missing(nettsalg)

* Andre
gen andre = q1_1_5_resp
replace andre = q1_1_5_resp_2022 if missing(andre)
list utvalg_kommune utvalg_kommunenummer if andre ==. //Tana mangler
replace andre = q1_1_5_resp_2020 if missing(andre)

	
/* Antall salgsbevillinger etter type*/

	* Dagligvarebutikk
	summarize dagligvare
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_dagligvare = r(sum)
	display "`total_salg_dagligvare'"
	
	tab dagligvare
	
	
	* Bryggeri
	summarize bryggeri
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_bryggeri = r(sum)
	display "`total_salg_bryggeri'"

	** For å finne antall kommuner og antall bevillinger for bryggeri:
	tab bryggeri
	display 356-267
	
	* Gårdsutsalg
	summarize gaard
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_gardsutsalg = r(sum)
	display "`total_salg_gardsutsalg'"

	* For å finne antall kommuner og antall bevillinger for gårdsutsalg:
	tab gaard
	display 356-298
	
	* Nettsalg
	summarize nett
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_nettsalg = r(sum)
	display "`total_salg_nettsalg'"

	* For å finne antall kommuner og antall bevillinger for nettsalg:
	tab nett
	display 356-226
	
	* Andre typer (ikke vinmonopol)
	summarize andre
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_andre = r(sum)
	display "`total_salg_andre'"

	* For å finne antall kommuner og antall bevillinger for annet:
	tab andre
	display 356-288
	
	*Dersom andre typer, oppgi hvilke
	tab s_9

/* Oppretter grupper med antall kommuner med grupperinger av antall salgsbevillinger */
tab tot_salg23 // Viser spredningen for inntrykk. 80% har under 16 bevillinger.

	* Vurdere å endre til over 30, siden det er så få med antall salgsbevillinger over 30
gen salgsbevillingsgruppe = .
replace salgsbevillingsgruppe = 1 if tot_salg23 >= 1 & tot_salg23 <= 5
replace salgsbevillingsgruppe = 2 if tot_salg23 >= 6 & tot_salg23 <= 10
replace salgsbevillingsgruppe = 3 if tot_salg23 >= 11 & tot_salg23 <= 20
replace salgsbevillingsgruppe = 4 if tot_salg23 >= 21 & tot_salg23 <= 30
replace salgsbevillingsgruppe = 5 if tot_salg23 >= 31 & tot_salg23 <= 50
replace salgsbevillingsgruppe = 6 if tot_salg23 > 50

label define bevgrp 1 "1–5" 2 "6–10" 3 "11–20" 4 "21–30" 5 "31–50" 6 "Over 50"
label values salgsbevillingsgruppe bevgrp

tabulate salgsbevilling

	/*
* Lager variabel hvor antall salgsbevillinger kategoriseres. Usikker på bakgrunnen for denne kategoriseringen. 
	* Ikke jevnt antall i hver gruppe. 
	gen q1_1_gr = q1_1
	recode q1_1_gr (1=1) (2=2)(3=3)(4=4)(5=5)(6/10=6)(11/20=7)(21/30=8)(30/447=9)(.=.)
	
	* Viser antall kommuner med ulikt antall salgsbevillinger som er kategorisert:
	tab q1_1_gr	
*/


/* Antall skjenkebevillinger i 2023*/
	/*total q2_1*/

	summarize tot_skjenk23
	return list
		* r(sum) gir total antall skjenkebevillinger
	local total_skjenkebevilling = r(sum)
	display "`total_skjenkebevilling'"
		
	/* Hvilke kommuner har 0 skjenkebevillinger*/
	list name2023 utvalg_kommune if tot_skjenk23 ==0
	
	/*Lager varibaler for type skjenkebevilling, etter alkoholgruppe, med impurte tall for kommuner med missing fra tidligere år:*/
	
	*Gr1:
	gen gr1 = q2_1_1_resp
	replace gr1 = q2_1_1_resp_2022 if missing(gr1)
	list utvalg_kommune utvalg_kommunenummer if gr1 ==. // Tana mangler
	replace gr1 = q2_1_1_resp_2020 if missing(gr1)
	*Gr1+2:
	gen gr12 = q2_1_2_resp
	replace gr12 = q2_1_2_resp_2022 if missing(gr12)
	list utvalg_kommune utvalg_kommunenummer if gr12 ==. // Tana mangler
	replace gr12 = q2_1_2_resp_2020 if missing(gr12)
	*Gr1+2+3:
	gen gr123 = q2_1_3_resp
	replace gr123 = q2_1_3_resp_2022 if missing(gr123)
	list utvalg_kommune utvalg_kommunenummer if gr123 ==. // Tana mangler
	replace gr123 = q2_1_3_resp_2020 if missing(gr123)
	
	/* Kommuner som ikke har skjenkebevilling for alle alkoholgruppene*/
	list utvalg_kommune utvalg_kommunenummer if gr123 == 0

	/* KOmmuner uten skjenkebevilling (0) */
	list utvalg_kommune utvalg_kommunenummer if tot_skjenk23 == 0

/* Oppretter grupper med antall kommuner med grupperinger av antall skjenkesbevillinger */
	* Vurdere å endre til over 30, siden det er så få med antall skjenkesbevillinger over 30
	tab tot_skjenk23 // stor forskjell i antall skjenkebevillinger per kommune.
	
gen skjenkebevillingsgruppe = .
replace skjenkebevillingsgruppe = 0 if tot_skjenk23 == 0
replace skjenkebevillingsgruppe = 1 if tot_skjenk23 >= 1 & tot_skjenk23 <= 5
replace skjenkebevillingsgruppe = 2 if tot_skjenk23 >= 6 & tot_skjenk23 <= 10
replace skjenkebevillingsgruppe = 3 if tot_skjenk23 >= 11 & tot_skjenk23 <= 20
replace skjenkebevillingsgruppe = 4 if tot_skjenk23 >= 21 & tot_skjenk23 <= 30
replace skjenkebevillingsgruppe = 5 if tot_skjenk23 >= 31 & tot_skjenk23 <= 50
replace skjenkebevillingsgruppe = 6 if tot_skjenk23 > 50

/*label define bevgrp 0 "0" 1 "1–5" 2 "6–10" 3 "11–20" 4 "21–30" 5 "31–50" 6 "Over 50"*/
label values skjenkebevillingsgruppe bevgrp

tabulate skjenkebevillingsgruppe
list utvalg_kommune utvalg_kommunenummer tot_skjenk23 if tot_skjenk23 >=100

	
/* Salgstider */

	* Tot salgsbevilling i 2023 (ikke imputert fra tidligere år)
	total q1_1
	
	*Maksimaltid hverdager øl/rusbrus - lørdager øl/rusbrus (kun de som har svart)
	tab1 q1_3a_1 q1_3a_2

	*For hvor mange av salgsbevillingene gjaldt maksimaltiden der samtlige besvart
	total q1_1 if q1_3b == 1

	*For hvor mange av salgsbevillingene gjald maksimaltiden hvis ikke samtlige?*/
	total q1_3b_n2

	*For å finne totalt antall salgsvevillinger med maksimaltid må disse plusses
		display 4250+209
	*For å finne andel med maksimaltid av alle salgsbevillinger:
		display (4459/4536)*100


/* Skjenketider*/

/*Maksimaltid skjenking øl/rusbrus/vin og brennevin*/
	tab1 q2_6a q2_7a 

	codebook q2_6a
	
	* Tot skjenksbevilling i 2023 (ikke imputert fra tidligere år)
	total q2_1
	
	*For hvor mange av skjenkesbevillingene gjaldt maksimaltiden der samtlige besvart?*/
	codebook q2_6b
	total q2_1 if  q2_6b == 1
	
	/* Antall skjenkebevillinger til maksimaltid om det ikke gjelder alle*/
	total q2_6b_n2
	
	
	display 5576+1263
	
	display (6839/8190)*100
	
		
	/* Salgs og skjenketil for utvalgte kommuner, vedleggstabell */
	
	* Salgstider:
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 301 // Oslo
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  4601 // Bergen
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 5001 // Trondheim
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 1103 // Stavanger
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 4204 // Kristiansand
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3004 // Fredrikstad
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  5401 // Tromsø
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 1108 // Sandnes
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 3005 // Drammen
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3804 // Sandefjord
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3003 // Sarpsborg
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3807 // Skien
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 1804 // Bodø
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3805 // Larvik
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  1508 // Ålesund
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  4203 // Arendal
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer == 3803 // Tønsberg
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3806 // Porsgrunn
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  1106 // Haugesund 
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3002 // Moss
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3407 // Gjøvik
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3403 // Hamar
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3001 // Halden
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3405 // Lillehammer
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3801 // Horten
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  3006 // Kongsberg
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  1506 // Molde
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  5402 // Harstad
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  1505 // Kristiansund
	tab1 q1_3a_1 q1_3a_2 if utvalg_kommunenummer ==  5006 // Steinkjer

	
	* Skjenketider: 
	tab1 q2_6a q2_7a if utvalg_kommunenummer == 301 // Oslo
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  4601 // Bergen
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 5001 // Trondheim
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 1103 // Stavanger
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 4204 // Kristiansand
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3004 // Fredrikstad
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  5401 // Tromsø
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 1108 // Sandnes
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 3005 // Drammen
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3804 // Sandefjord
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3003 // Sarpsborg
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3807 // Skien
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 1804 // Bodø
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3805 // Larvik
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  1508 // Ålesund
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  4203 // Arendal
	tab1 q2_6a q2_7a  if utvalg_kommunenummer == 3803 // Tønsberg
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3806 // Porsgrunn
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  1106 // Haugesund 
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3002 // Moss
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3407 // Gjøvik
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3403 // Hamar
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3001 // Halden
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3405 // Lillehammer
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3801 // Horten
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  3006 // Kongsberg
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  1506 // Molde
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  5402 // Harstad
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  1505 // Kristiansund
	tab1 q2_6a q2_7a  if utvalg_kommunenummer ==  5006 // Steinkjer

	
**

/* Antall kommuner som rapporterte overtredelser*/
	tab1 q1_6a // salg
	tab1 q2_11a // skjenking

/* Totalt antall overtredelser for salg og skjenkebevillinger*/

	* Overtredelser salg, antall:
	egen tot_otg_salg = rowtotal ( q1_6a_1_1_resp q1_6a_1_2_resp q1_6a_1_3_resp q1_6a_1_4_resp q1_6a_1_5_resp q1_6a_1_6_resp q1_6a_1_7_resp q1_6a_1_8_resp q1_6a_1_9_resp q1_6a_1_10_resp q1_6a_1_11_resp q1_6a_1_12_resp q1_6a_1_13_resp q1_6a_1_14_resp )
	
	total tot_otg_salg
	
	* Overtredelser skjenking, antall: 
	
	egen tot_otg_skjenk = rowtotal (q2_11a_1_1_resp q2_11a_1_2_resp q2_11a_1_3_resp q2_11a_1_4_resp q2_11a_1_5_resp q2_11a_1_6_resp q2_11a_1_7_resp q2_11a_1_8_resp q2_11a_1_9_resp q2_11a_1_10_resp q2_11a_1_11_resp q2_11a_1_12_resp q2_11a_1_13_resp q2_11a_1_14_resp q2_11a_1_15_resp q2_11a_1_17_resp q2_11a_1_16_resp q2_11a_1_18_resp q2_11a_1_19_resp q2_11a_1_20_resp q2_11a_1_21_resp q2_11a_1_22_resp q2_11a_1_23_resp)
	
	total tot_otg_skjenk

/* Antall overtredelser knyttet til salgsbevilling etter type*/
	* Salg mindreårig
		summarize q1_6a_1_1_resp
		return list
	*Brudd på kravet om forsvarlig drift 
		summarize q1_6a_1_2_resp
		return list
	*Hindring av kontroll
		summarize q1_6a_1_3_resp
		return list 
	*Salg til åpenbart påvirket person   
		summarize q1_6a_1_4_resp
		return list    
	*Brudd på tidsbestemmelsene 
		summarize q1_6a_1_5_resp
		return list
	*Brudd på reklamebestemmelsene 
		summarize q1_6a_1_6_resp
		return list
	*Brudd på alderskrav til den som selger alkohol 
		summarize q1_6a_1_7_resp
		return list
	*Mangler ved internkontrollen 
		summarize q1_6a_1_8_resp
		return list
	*Brudd på regler om styrer og stedfortreder 
		summarize q1_6a_1_9_resp
		return list
	*Brudd på reglene om plassering av alkoholholdig drikk på salgsstedet 
		summarize q1_6a_1_10_resp
		return list
	*Brudd på vilkår i bevillingsvedtaket 
		summarize q1_6a_1_11_resp
		return list
	*Manglende levering av omsetningsoppgave innen kommunens frist 
		summarize q1_6a_1_12_resp
		return list
	*Manglende betaling av bevillingsgebyr innen kommunens frist 
		summarize q1_6a_1_13_resp
		return list
	*Annen type overtredelse
		summarize q1_6a_1_14_resp
		return list
		*Hvilke andre overtredelser?
		tabulate q1_6a_1_open
	
/* Antall overtredelser knytte til skjenkebevillinger etter type*/
	* Skjenking til mindreårige:
	summarize q2_11a_1_1_resp
	return list
	* Brudd på bistandsplikten
	summarize q2_11a_1_2_resp
	return list 
	* Brudd på kravet om forsvarlig drift
	summarize q2_11a_1_3_resp
	return list
	* Hindring av kontroll
	summarize q2_11a_1_4_resp
	return list
	* Skjenking til åpenbart påvirket person
	summarize q2_11a_1_5_resp
	return list
	* Brudd på tidsbestemmelsene
	summarize q2_11a_1_6_resp
	return list
	* Brudd på reklamebestemmelsene
	summarize q2_11a_1_7_resp
	return list
	* Skjenking av sprit til person mellom 18-20 år
	summarize q2_11a_1_8_resp
	return list
	* Brudd på alderskrav til den som skjenker alkohol
	summarize q2_11a_1_9_resp
	return list
	* Åpenbart påvirket person i lokalet
	summarize q2_11a_1_10_resp
	return list
	* Mangler ved internkontrollsystemet
	summarize q2_11a_1_11_resp
	return list
	* Brudd på regler om styrer og stedfortreder
	summarize q2_11a_1_12_resp
	return list
	* Gjentatt diskriminering
	summarize q2_11a_1_13_resp
	return list
	* Gjentatt narkotikaomsetning
	summarize q2_11a_1_14_resp
	return list
	* Brudd på regelene om alkoholfrie alternativer
	summarize q2_11a_1_15_resp
	return list
	* Brudd på reglene om plassering av alkoholholdig drikk på skjenkestedet
	summarize q2_11a_1_16_resp
	return list
	* Brudd på reflene om skjenkemengde for brennevin
	summarize q2_11a_1_17_resp
	return list
	* Brudd på vilkår i bevillingsvedtaket
	summarize q2_11a_1_18_resp
	return list
	* KOnsum av medbrakt alkohol
	summarize q2_11a_1_19_resp
	return list
	* Gjester tar med alkohol ut
	summarize q2_11a_1_20_resp
	return list
	* Manglende levering av omsetningsoppgave innen kommunens frist
	summarize q2_11a_1_21_resp
	return list
	* Manglende betaling av bevillingsgebyr innen kommunens frist
	summarize q2_11a_1_22_resp
	return list
	* Andre typer overtredelser:
	summarize q2_11a_1_23_resp
	return list
	tab q2_11a_1_open
	
/* Antall inndragning av salgs- og skjenkebevillinger og antall*/
	* Salg, permanent:
	summarize q1_7_1
	return list
	* Salg, midlertidig:
	summarize q1_8_1
	return list
	* Skjenke, permanent:
	summarize q2_12_1
	return list
	* Skjenke, midlertidig:
	summarize q2_13_1
	return list

	
/* Antall nye salgsbevillinger*/
	* Innvilget:
	tabulate q1_13a_1_resp // fordeling av antall innvilget
	summarize q1_13a_1_resp
	return list
	* Avslått: 
	tabulate q1_13a_2_resp
	summarize q1_13a_2_resp
	return list
	* Begrunnelse for avslag:
		* Vandelskrev
		summarize q1_13b_1_resp
		return list
		* Lokalpolitiske hensyn
		summarize q1_13b_2_resp
		return list
		* Annet:
		summarize q1_13b_3_resp
		return list // får opp 1 her, men antar den som feil pga oppgivelse av grunn:
		tab q1_13b_open

	
/* Antall nye skjenkesteder*/
	* Innvilget: 
	tabulate q2_8a_1_resp
	summarize q2_8a_1_resp
	return list
	* Avslått: 
	tabulate q2_8a_2_resp 
	summarize q2_8a_2_resp
	return list
	
	* Begrunnelse for avslag:
		* Vandelskrev
		summarize q2_8b_1_resp
		return list
		* Lokalpolitiske hensyn
		summarize q2_8b_2_resp
		return list
		* Annet:
		summarize q2_8b_3_resp
		return list 
		tab q2_8b_open
	
	
/*skjenkebevillinger for en enkelt anledning og/eller ambulerende skjenkebevillinger i 2023?*/
	summarize q2_3
	return list // viser spredningen og totalt antall ambulerende skjenkebev i 2023
	
	* Kategoriserer antall ambulerende bevillinger:
	gen ambev = .
	replace ambev = 0 if q2_3 == 0
	replace ambev = 1 if q2_3 >= 1 & q2_3 <= 10
	replace ambev = 2 if q2_3 >= 11 & q2_3 <= 20
	replace ambev = 3 if q2_3 >= 21 & q2_3 <= 30
	replace ambev = 4 if q2_3 >= 31 & q2_3 <= 40
	replace ambev = 5 if q2_3 >= 41 & q2_3 <= 50
	replace ambev = 6 if q2_3 > 50
	replace ambev = . if q2_3 ==.

	label define ambev 0 "0" 1 "1–10" 2 "11-20" 3 "21–30" 4 "31–40" 5 "41–50" 6 ">50"
	label values ambev ambev

	tabulate ambev


/*Hvordan gjennomføres fornyelse av salgs- og skjenkebevillinger*/

	tab q2_11
	codebook q2_11


/* Vilkår skjenkebevilling*/

	/*Var det i 2023 et tak på antall bevillinger til skjenking i kommunen?*/
	tab q2_5
	codebook q2_5

	/*Hvilke vilkår? - Ordensvakt - Kursing - Nedre aldersgrense - Matservering - Annet*/
	tab1 q2_5_1_1 q2_5_1_2 q2_5_1_3 q2_5_1_4 q2_5_1_5 if q2_5 == 1

	/*Dersom annet, hvilke?*/
	tab q2_5_1_open

	/* Kommuner med 1+ vilkår*/
	gen vilkaar = q2_5_1_1 + q2_5_1_2 + q2_5_1_3 + q2_5_1_4 + q2_5_1_5
	tabulate vilkaar
	tabulate vilkaar if q2_5 == 1


* Filen slutter her.
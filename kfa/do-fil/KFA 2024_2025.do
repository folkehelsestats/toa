

/*Analyser Alkoholloven 2024 med data innhenta 2025*/

** Fil som ser på kommunenes forvaltning av alkoholloven
** Fil som presenterer tall til Tall om alkohol
** Data om 2024, innsamlet i 2025.
* Opprettet av Bente Øvrebø, 16/9-25
	* Filen anses som ....
	
	
/*
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Data_Stata\kfa_org_2024_2025.dta"
destring kommunenummer, generate(knr)
drop kommunenummer
rename knr kommunenummer
save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2024_2025_behandlet.dta", replace
*/

/*
clear all
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Kommuner\kommuneendring_2025.dta"
destring oldCode, generate(gammelknr)
destring currentCode, generate (nyknr)
destring changeOccurred, generate (endringsaar)

keep if endringsaar>=2023

rename nyknr kommunenummer

drop oldCode currentCode changeOccurred
export excel using "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Kommuner\Kommuneendring_2024.xls", firstrow(variables)
clear all
import excel "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Kommuner\Kommuneendring_2024.xls", sheet("Sheet1") firstrow
rename kommunenummer nyknr
rename gammelknr kommunenummer

duplicates report kommunenummer
*Dropper Ålesund 1507 til 1508 for å ikke få duplikater 
drop if nyknr == 1508



******************************************************************************* 
/* Benytter kommuneinndeling for 2024 fra SSB hentet via norgeo ved bruk av Rstudio*/
/*
	/* Laster inn kommuneinndeling i 2024 fra SSB og rensker*/
clear all
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Kommuner\kommuner2024.dta"

destring code, generate(kommunenummer)
rename name name2024

drop if kommunenummer == 9999
save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Kommuner\kommuner2024.dta", replace
*/


/* Kobler på KFA-data fra 2024 (innhentet i 2025)*/
merge 1:1 kommunenummer using "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2024_2025_behandlet.dta"

drop if _merge == 1 // sletter Ålesund da den er i KFA-fila med korrekt kommunenummer for 2024.


duplicates report kommunenummer // ingen duplikater, 356 kommuner
drop _merge

gen knr = .
replace knr = nyknr if nyknr !=.
replace knr = kommunenummer if knr ==.

gen name = newName
replace name = kommune if name == ""
rename name kommunenavn2024

drop oldName nyknr newName endringsaar kommunenummer
rename knr kommunenummer

save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2024_2025_behandlet.dta", replace
*/


clear all
/*
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2024_2025_behandlet.dta"

merge 1:m kommune using "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\kommunenavn_originalKFA.dta"
drop _merge

/*
clear all
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2023_2024_kobletall.dta"
gen knr = kommune
save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2023_2024_kobletall.dta", replace
clear all
*/
ds
foreach var in `r(varlist)' {
    rename `var' `var'_2024
}
rename knr_2024 knr

merge 1:m knr using "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2023_2024_kobletall.dta"

rename knr knr_gammel

save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2024_2025_behandlet_v2.dta", replace
*/
** OBS på at Ålesund er siste år blitt til 2 kommuner.

use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2024_2025_behandlet_v2.dta"

	* Her må missing values imputeres fra fjoråret når variabel fra forrige år er lagt til.


/*
use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\KFA_2023_2024_beh.dta"
ds
foreach var in `r(varlist)' {
    rename `var' `var'_2023
}
rename utvalg_kommunenummer_2023 kommune
save "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2024_2025\KFA_2023_2024_kobletall.dta", replace
clear all
*/



*/
******************************************************************************* 
	*** Kvalitetsjekk av fila:

*******************************************************************************
* Kommunenummer som numerisk variabel:
/*destring kommunenummer, generate(knum)
duplicates report knum // ingen */
duplicates report kommunenummer_2024

*Det er variabel kommunenummer_2024 som er korrekt kommunenr for det året.
* knr_gammel er kommunenummer for året før (Ålesund er splittet til to kommuner)



* Sjekket at antall kommuner stemmer med SSBs inndeling i 2024.
/* https://www.ssb.no/klass/klassifikasjoner/131/endringer */

/*Antall kommuner som har svart på skjema*/
	tabulate q1_1_sum_2024, mis // benytter antall salgsbevillinger som indikator for besvart. 8 kommuner med missing
	

	
** Dropper Ålesund fra i fjor for at det skal bli korrekt antall kommuner
drop if _merge ==2

********************************************************************************

/* Svar prosent på kommunene*/

tabulate qintro_2_1_4_2024
di (348/357)*100 // svarprosent

/* Hvem har svart på skjemaet (stilling)*/
tabulate qintro_2_1_4_2024 // stor variasjon. Tar det videre i excel og copilot
	

/*Antall salgsbevillinger*/

	gen tot_salg24 = (q1_1_1_2024+ q1_1_2_2024+ q1_1_3_2024+ q1_1_4_2024+ q1_1_5_2024+ q1_1_6_2024+ q1_1_7_2024)
	gen ulikt = q1_1_sum_2024- tot_salg24
	tab ulikt
	
	list kommune_2024 kommune if q1_1_sum_2024 == 0 // Indikerer at to kommuner ikke har noen salgsbevillinger - det er feil.
	
	list kommune_2024 if q1_1_sum_2024 == .
	
	* Ser på tallene for i fjoråret
	list kommune_2024 q1_1_sum_2024 tot_salg24 tot_salg23_2023  if q1_1_sum_2024 == 0
	list kommune_2024 q1_1_sum_2024 tot_salg24 tot_salg23_2023 if q1_1_sum_2024 == .
	
	* Setter inn fjorårets tall for kommuner med missing og 0, salgsbevilling total:
	replace tot_salg24 = tot_salg23_2023 if q1_1_sum_2024 == .
	replace tot_salg24 = tot_salg23_2023 if q1_1_sum_2024 == 0
	
	list kommune_2024 q1_1_sum_2024 tot_salg23_2023 tot_salg24 if q1_1_sum_2024 == 0
	list kommune_2024 q1_1_sum_2024 tot_salg23_2023 tot_salg24 if q1_1_sum_2024 == .
		* I 2024 var det 357 kommuner

	summarize tot_salg24
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salgsbevilling = r(sum)
	display "`total_salgsbevilling'"
	
	total tot_salg24
	tab tot_salg24


/*Antall salgsbevillinger gruppert etter antall-kategorier*/

* Dagligvare
total q1_1_1_2024
tab q1_1_1_2024, mi
gen dagligvare24 = q1_1_1_2024
list kommune_2024 if dagligvare24 == 0 // sjekker at det er de samme med 0, som det er
list kommune_2024 if dagligvare24 == .
replace dagligvare24 = dagligvare_2023 if missing(dagligvare24)
replace dagligvare24 = dagligvare_2023 if dagligvare24 ==0
tabulate dagligvare24, mi
total dagligvare24

* Bryggeri
gen bryggeri24 = q1_1_2_2024
replace bryggeri24 = bryggeri_2023 if missing(bryggeri24)
replace bryggeri24 = bryggeri_2023 if kommune == 1576 // Aure
replace bryggeri24 = bryggeri_2023 if kommune == 5421 // Senja
list kommune_2024 if bryggeri24==. 
tabulate bryggeri24, mi
total bryggeri24

* Gardsutsalg
gen gaard24 = q1_1_3_2024
replace gaard24 = gaard_2023 if missing(gaard24)
replace gaard24 = gaard_2023 if kommune == 1576 // Aure
replace gaard24 = gaard_2023 if kommune == 5421 // Senja
list kommune_2024 if gaard24==. //
tabulate gaard24, mi
total gaard24

* Nettsalg
gen nettsalg24 = q1_1_4_2024
replace nettsalg24 = nettsalg_2023 if missing(nettsalg24)
replace nettsalg24 = nettsalg_2023 if kommune == 1576 // Aure
replace nettsalg24 = nettsalg_2023 if kommune == 5421 // Senja
list kommune_2024 if nettsalg24 ==. 
tabulate nettsalg24, mi
total nettsalg24

* Øl- og mineralvannutsalg
tabulate q1_1_5_2024, mi
total q1_1_5_2024

* Kultur
tabulate q1_1_6_2024, mi
total q1_1_6_2024

* Andre // Endrer missing, selv om noen av missing kan være at skal inn i øl- og mineravannutsalg og kultur for kommunene med missing.
gen andre24 = q1_1_7_2024
tabulate andre24, mi
replace andre24 = andre_2023 if missing(andre24)
replace andre24 = andre_2023 if kommune == 1576 // Aure
replace andre24 = andre_2023 if kommune == 5421 // Senja
tabulate andre24, mi
total andre24
tabulate andre24
	
	
gen ulikt2 = q1_1_sum_2024- tot_salg24
tab ulikt2
gen olutsalg24 = q1_1_5_2024
replace olutsalg24 = 0 if missing(q1_1_5_2024)
gen kultur24 = q1_1_6_2024
replace kultur24 = 0 if missing(q1_1_6_2024)
gen sjekk = (dagligvare24+ bryggeri24+ gaard24+ nettsalg24+ andre24+olutsalg24+kultur24)
gen ulikt3 = sjekk - tot_salg24
tab ulikt3


/* Antall salgsbevillinger etter type*/

	* Dagligvarebutikk
	summarize dagligvare24
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_dagligvare = r(sum)
	display "`total_salg_dagligvare'"
	
	tab dagligvare24
	
	
	* Bryggeri
	summarize bryggeri24
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_bryggeri = r(sum)
	display "`total_salg_bryggeri'"

	** For å finne antall kommuner og antall bevillinger for bryggeri:
	tab bryggeri24
	di 357-273
	
	* Gårdsutsalg
	summarize gaard24
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_gardsutsalg = r(sum)
	display "`total_salg_gardsutsalg'"

	* For å finne antall kommuner og antall bevillinger for gårdsutsalg:
	tab gaard24
	display 357-303
	
	* Nettsalg
	summarize nettsalg24
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_nettsalg = r(sum)
	display "`total_salg_nettsalg'"

	* For å finne antall kommuner og antall bevillinger for nettsalg:
	tab nettsalg24
	display 357-241
	
	* Øl- og mineralvannutsalg
	summarize q1_1_5_2024 
	return list 
	
	tab q1_1_5_2024, mi
	display 357-324


	* Kultur
	summarize q1_1_6_2024
	return list
	
	tab q1_1_6_2024
	display 357- 339
	total q1_1_6_2024
	
	* Andre typer (ikke vinmonopol)
	summarize andre24
	return list
		* r(sum) gir total antall salgsbevillinger
	local total_salg_andre = r(sum)
	display "`total_salg_andre'"

	* For å finne antall kommuner og antall bevillinger for annet:
	tab andre24
	display 357-306
	
	summarize 

/* Oppretter grupper med antall kommuner med grupperinger av antall salgsbevillinger */
tab tot_salg24 // Viser spredningen for inntrykk. 79% har under 16 bevillinger.

	* Vurdere å endre til over 30, siden det er så få med antall salgsbevillinger over 30
gen salgsbevillingsgruppe = .
replace salgsbevillingsgruppe = 1 if tot_salg24 >= 1 & tot_salg24 <= 5
replace salgsbevillingsgruppe = 2 if tot_salg24 >= 6 & tot_salg24 <= 10
replace salgsbevillingsgruppe = 3 if tot_salg24 >= 11 & tot_salg24 <= 20
replace salgsbevillingsgruppe = 4 if tot_salg24 >= 21 & tot_salg24 <= 30
replace salgsbevillingsgruppe = 5 if tot_salg24 >= 31 & tot_salg24 <= 50
replace salgsbevillingsgruppe = 6 if tot_salg24 > 50

/*label define bevgrp 1 "1–5" 2 "6–10" 3 "11–20" 4 "21–30" 5 "31–50" 6 "Over 50"*/
label values salgsbevillingsgruppe bevgrp

tabulate salgsbevillingsgruppe

/* Antall skjenkebevillinger i 2024*/
	/*q2_1_sum_2024*/

	
* Kommuner som har missing:
	list kommune_2024 if q2_1_sum_2024 ==.
	
	
	summarize q2_1_sum_2024
	return list
		* r(sum) gir total antall skjenkebevillinger
	local total_skjenkebevilling = r(sum)
	display "`total_skjenkebevilling'"
	
	
	* Undergrupper skjenkebevilling blir tot:
	gen tot_skjenk24 = (q2_1_1_2024+ q2_1_2_2024+ q2_1_3_2024)
	total tot_skjenk24
	total q2_1_sum_2024 // viser likt som når jeg legger de ulike sammen. 
	/*
	gen uliktskjenk = tot_skjenk24 - q2_1_sum_2024
	tabulate uliktskjenk, mi
	drop uliktskjenk // ingen forskjell, sum er korrekt.
	*/
	
	* Ertatter kommuner med missing, med skjenke fra tidligere:
	replace tot_skjenk24 = tot_skjenk23_2023 if missing(q2_1_sum_2024)
	
	summarize tot_skjenk24 
	return list
		* r(sum) gir total antall skjenkebevillinger, med impurtert fra tidligere
	local total_skjenkebevilling = r(sum)
	display "`total_skjenkebevilling'"
	
	/* Hvilke kommuner har 0 skjenkebevillinger*/
	tabulate q2_1_sum_2024 // 6 kommuner rapporterer 0 skjenkebevillinger
	list kommune_2024 if q2_1_sum_2024 ==0
	* Sjekker de to kommunene med 0 skjenkebevillinger (år og i fjor)
	list q2_1_sum_2024 tot_skjenk23 if kommune == 1576 // Aure
	list q2_1_sum_2024 tot_skjenk23 if kommune == 5421 // Senja
	
	
	/*Lager varibaler for type skjenkebevilling, etter alkoholgruppe, med impurte tall for kommuner med missing fra tidligere år:*/
	
	*Gr1:
	gen gr1 = q2_1_1_2024
	replace gr1 = gr1_2023 if missing(q2_1_1_2024)
	list kommune_2024 if gr1 ==. // 
	total gr1
	summarize gr1
	return list
	
	*Gr1+2:
	gen gr12 = q2_1_2_2024
	replace gr12 = gr12_2023 if missing(q2_1_2_2024)
		list kommune_2024 if gr12 ==. // 
	total gr12
	summarize gr12
	return list
	
	*Gr1+2+3:
	gen gr123 = q2_1_3_2024
	replace gr123 = gr123_2023 if missing(q2_1_3_2024)
		list kommune_2024 if gr123 ==. // 
	total gr123
	summarize gr123
	return list
	

	
	/* Kommuner som ikke har skjenkebevilling for alle alkoholgruppene*/
	list kommune_2024 if gr123 == 0

	/* KOmmuner uten skjenkebevilling (0) */
	list kommune_2024 if tot_skjenk24 == 0

/* Oppretter grupper med antall kommuner med grupperinger av antall skjenkesbevillinger */
	* Vurdere å endre til over 30, siden det er så få med antall skjenkesbevillinger over 30
	tab tot_skjenk24 // stor forskjell i antall skjenkebevillinger per kommune.
	
gen skjenkebevillingsgruppe = .
replace skjenkebevillingsgruppe = 0 if tot_skjenk24 == 0
replace skjenkebevillingsgruppe = 1 if tot_skjenk24 >= 1 & tot_skjenk24 <= 5
replace skjenkebevillingsgruppe = 2 if tot_skjenk24 >= 6 & tot_skjenk24 <= 10
replace skjenkebevillingsgruppe = 3 if tot_skjenk24 >= 11 & tot_skjenk24 <= 20
replace skjenkebevillingsgruppe = 4 if tot_skjenk24 >= 21 & tot_skjenk24 <= 30
replace skjenkebevillingsgruppe = 5 if tot_skjenk24 >= 31 & tot_skjenk24 <= 50
replace skjenkebevillingsgruppe = 6 if tot_skjenk24 > 50

/*label define bevgrp 0 "0" 1 "1–5" 2 "6–10" 3 "11–20" 4 "21–30" 5 "31–50" 6 "Over 50"*/
label values skjenkebevillingsgruppe bevgrp

tabulate skjenkebevillingsgruppe
list kommune_2024 tot_skjenk24 if tot_skjenk24 >=100
/*
********************************************************************************
********************************************************************************
* Sjekker bevillinger opp mot fjoråret:

*******************************************************************************
	*Kvalitetssjekk av tallene på salgsbevillinger for 2024
*******************************************************************************
*******************************************************************************

/*Endring i total antall salgbevillinger fra 2023 til 2024 med >30%*/

gen salgsbevilling = tot_salg24 - tot_salg23_2023
label variable salgsbevilling "absolutt endring i antall bevillinger fra 2023 til 2024"
tab salgsbevilling 

gen salgsbevillingpros = (salgsbevilling/tot_salg23_2023)*100
gen salgpros = int(salgsbevillingpros)
label variable salgpros "% endring i antall bevillinger fra 2023 til 2024"
tab salgpros

	* Kommuner som har en 30% (eller mer) endring i antall bevillinger fra 2023 til 2024.
tab kommune_2024 if abs(salgpros) >30 // Viser kommunene som har en endring på +/- 30%

list kommune_2024 kommunenummer_2024 tot_salg23_2023 tot_salg24 salgsbevilling salgpros kommunenummer_2024 if abs(salgpros) >30
* Lister over viser stor endring for noen av kommunene. 
* Her må det gjøres en vurdering om hva som er plausibelt og ikke
* Se wordfil for info.

	* Total salgsbevillinger fra 2023-2024, for kommunene med usikre tall:
/*
list kommune_2024 kommunenummer_2024 tot_salg21 tot_salg22 tot_salg23_2023 tot_salg24 salgsbevilling salgpros kommunenummer_2024 if abs(salgpros) >30 & abs(salgsbevilling)>1 */

	* dagligvare
	list kommunenummer_2024 kommune_2024 salgsbevilling q1_1_1_resp_2023 q1_1_1_2024 if abs(salgpros) >30 & abs(salgsbevilling)>1
	* bryggeri
	list kommunenummer_2024 kommune_2024 salgsbevilling q1_1_2_resp_2023 q1_1_2_2024 if abs(salgpros) >30 & abs(salgsbevilling)>1
	* gårdsutsalg
	list kommunenummer_2024 kommune_2024 salgsbevilling q1_1_3_resp_2023 q1_1_3_2024 if abs(salgpros) >30 & abs(salgsbevilling)>1
	* nettsalg
	list kommunenummer_2024 kommune_2024 salgsbevilling q1_1_4_resp_2023 q1_1_4_2024 if abs(salgpros) >30 & abs(salgsbevilling)>1
	* andre
	list kommunenummer_2024 kommune_2024  salgsbevilling q1_1_5_resp_2023 q1_1_7 if abs(salgpros) >30 & abs(salgsbevilling)>1 
	
* Det har kommet inn to nye gruppper over (øl- og mineralvannutsalg og kultur), så ikke så annet vil sannsynligvis endres.
	

*****************************************************************************
*******************************************************************************
*******************************************************************************
	*Kvalitetssjekk av tallene på skjenkebevillinger for 2024*

*******************************************************************************
*******************************************************************************

/* Endring i total antall skjenkeveillinger fra 2023 til 2024 med >30%*/
gen skjenkbevilling = tot_skjenk24 - tot_skjenk23_2023
label variable skjenkbevilling "absolutt endring i antall bevillinger fra 2023 til 2024"
tab skjenkbevilling // Viser noen store endringer fra året før

gen skjenkbevillingpros = (skjenkbevilling/tot_skjenk23_2023)*100 // 15 missing generated

	* Sjekker opp i de missing-verdiene som genereres
list kommunenummer_2024 kommune_2024 skjenkbevilling tot_skjenk23_2023 tot_skjenk24 if skjenkbevillingpros ==.


gen skjenkpros = int(skjenkbevillingpros)
label variable skjenkpros "% endring i antall bevillinger fra 2023 til 2024"
tab skjenkpros

* Lister opp kommuner som har en endring i antall skjenkebevillinger på over 30% og hvor absolutt endring er over 1:
list kommunenummer_2024 kommune_2024 tot_skjenk23_2023 tot_skjenk24 skjenkbevilling skjenkpros if abs(skjenkpros) >30 & abs(skjenkbevilling) >1
* Listen viser kommuner med endring over 30% i antall bevillinger fra 2023 til 2024.
* Må gjøres en vurdering om hva som er plausibelt og ikke. Se wordfil med info.

* Sjekker det samme, men de som har en absolutt endring ove r6 (6-cut off er fra FHI)
list kommunenummer_2024 kommune_2024 tot_skjenk23_2023 tot_skjenk24 skjenkbevilling skjenkpros if abs(skjenkpros) >30 & abs(skjenkbevilling) >6

* Ser på antall skjenkebevilling etter type over år:

* Gruppe 1:
list kommunenummer_2024 kommune_2024 skjenkbevilling q2_1_1_resp_2023 q2_1_1_2024 if abs(skjenkpros) >30 & abs(skjenkbevilling) >1
* Gruppe 1 og 2:
list kommunenummer_2024 kommune_2024 skjenkbevilling  q2_1_2_resp_2023 q2_1_1_2024 if abs(skjenkpros) >30 & abs(skjenkbevilling) >1

* Gruppe 1, 2 og 3:
list kommunenummer_2024 kommune_2024 skjenkbevilling q2_1_3_resp_2023 q2_1_1_2024 if abs(skjenkpros) >30 & abs(skjenkbevilling) >1

*/

********************************************************************************
********************************************************************************
********************************************************************************

*Fortsetter med analyser: 


/* Hvor mange kommuner har bevilling til skjenking av alkohol på andre steder enn barer, diskotek, klubber, kafeer og restauranter i 2024? */
tabulate q2_2_2024

/* For alle undergruppene, aldershjem, kantine, turisthyttte, kino, festival, mm.*/

	* Lag en liste med variabler
	local varlist q2_2_1_1_2024 q2_2_1_2_2024 q2_2_1_3_2024 q2_2_1_4_2024 q2_2_1_5_2024 q2_2_1_6_2024 q2_2_1_7_2024 q2_2_1_8_2024 q2_2_1_9_2024 q2_2_1_10_2024 q2_2_1_11_2024 q2_2_1_12_2024

	* Tabulate og total for hver variabel
	foreach var of local varlist {
		di "Tabulate for `var'"
		tabulate `var'

		di "Total for `var'"
		total `var'
	}


/* Antall skjenkebevillinger for en enkeltanledning og/eller ambulerende skjenkebevillinger ble gitt i 2024*/

tabulate q2_3_2024
total q2_3_2024

	* Oslo har ekstremt mange:
	list kommunenavn2024_2024 kommunenummer_2024 if q2_3_2024 == 2088

summarize q2_3_2024
return list

/*skjenkebevillinger for en enkelt anledning og/eller ambulerende skjenkebevillinger i 2023?*/
	summarize q2_3_2024
	return list // viser spredningen og totalt antall ambulerende skjenkebev i 2023
	histogram q2_3_2024, discrete frequency
	
	* Kategoriserer antall ambulerende bevillinger:
	gen ambev = .
	replace ambev = 0 if q2_3_2024 == 0
	replace ambev = 1 if q2_3_2024 >= 1 & q2_3_2024 <= 10
	replace ambev = 2 if q2_3_2024 >= 11 & q2_3_2024 <= 20
	replace ambev = 3 if q2_3_2024 >= 21 & q2_3_2024 <= 30
	replace ambev = 4 if q2_3_2024 >= 31 & q2_3_2024 <= 40
	replace ambev = 5 if q2_3_2024 >= 41 & q2_3_2024 <= 50
	replace ambev = 6 if q2_3_2024 > 50
	replace ambev = . if q2_3_2024 ==.

	/*label define ambev 0 "0" 1 "1–10" 2 "11-20" 3 "21–30" 4 "31–40" 5 "41–50" 6 ">50"*/
	label values ambev ambev

	tabulate ambev



/* Vilkår skjenkebevilling*/
* Var det vilkår knyttet til noen av skjenkebevillingene i 2024?
tabulate q2_5_2024

	/*Hvilke vilkår? - Ordensvakt - Kursing - Nedre aldersgrense - Matservering - Begrensning skjenketid - Annet - ingen vilkår benyttet */
	
	* Lag en liste med variabler
	local varlist_vilkar q2_5_1_1_2024 q2_5_1_2_2024 q2_5_1_3_2024 q2_5_1_4_2024 q2_5_1_5_2024 q2_5_1_6_2024 q2_5_1_7_2024

	* Tabulate og total for hver variabel
	foreach var of local varlist_vilkar {
		di "Tabulate for `var'"
		tabulate `var'

	}
	

	/* Kommuner med 1+ vilkår*/

	gen vilkaar = q2_5_1_1_2024+ q2_5_1_3_2024+ q2_5_1_4_2024+ q2_5_1_5_2024+ q2_5_1_6_2024
	tabulate vilkaar


/* KOntroller*/

	* Hvem utførte salgskontroller:
	tabulate q1_4_2024

	* Antall salgskontroller i 2024:
	summarize q1_5_2024
	return list

	* Antall skjenkekontroller i 2024:
	summarize q2_10_2024
	return list

/* Salgstider 2024*/

tabulate q1_3a_1_2024 // hverdager
tabulate q1_3a_2_2024 // lørdag

tabulate q1_3b_2024 // antall salgsbevillinger som gjaldt maksimaltiden
tabulate q1_3b_2_other_2024 // antall som gjaldt maksimaltid om det ikke var samtlige




/* Skjenketider*/

tabulate q2_6a_2024 // maksimaltid øl/rusbrus og vin, for helg om ulik tid
tabulate q2_6b_2024 // antall av bevillingene som gjaldt maksimaltid
destring q2_6b_2_other_2024, generate(antallmaks) // dersom ikke alle, gir dette antall på MED maksimaltid
total antallmaks

/*Maksimaltid skjenking øl/rusbrus/vin og brennevin*/
	tab1 q2_7a_2024 // klokkeslett for maks skjenk av brennevin

	
	*For hvor mange av skjenkesbevillingene gjaldt maksimaltiden der samtlige besvart?*/
	tabulate q2_7b_2024
	
	
	/* Antall skjenkebevillinger til maksimaltid om det ikke gjelder alle*/
	tabulate q2_7b_2_other_2024
	destring q2_7b_2_other_2024, gen(antallmaksbrennevin)
	total antallmaksbrennevin
	
		
	/* Salgs og skjenketil for utvalgte kommuner, vedleggstabell */
	/*
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
*/
	
****************************************************
/* Overtredelser*/

* Salg*
	* Overtrelser knyttet til salgsbevillinger i 2024
tabulate q1_6_2024
	* Hvis det var overtredelser knyttet til salg i 2024, hvilke?
	
* Lag en liste med variabler
	local varlist_bruddsalg q1_6a_1_1_2024 q1_6a_1_2_2024 q1_6a_1_3_2024 q1_6a_1_4_2024 q1_6a_1_5_2024 q1_6a_1_6_2024 q1_6a_1_7_2024 q1_6a_1_8_2024 q1_6a_1_9_2024 q1_6a_1_10_2024 q1_6a_1_11_2024 q1_6a_1_12_2024 q1_6a_1_13_2024 q1_6a_1_14_2024 q1_6a_1_15_2024 q1_6a_1_16_2024

	* Tabulate og total for hver variabel
	foreach var of local varlist_bruddsalg {
		di "Tabulate for `var'"
		tabulate `var'
		
		di "Total for `var'"
		total `var'
	}
	
	* Legge sammen antall salgsbevilling OTG:

	egen tot_otg_salg = rowtotal (q1_6a_1_1_2024 q1_6a_1_2_2024 q1_6a_1_3_2024 q1_6a_1_4_2024 q1_6a_1_5_2024 q1_6a_1_6_2024 q1_6a_1_7_2024 q1_6a_1_8_2024 q1_6a_1_9_2024 q1_6a_1_10_2024 q1_6a_1_11_2024 q1_6a_1_12_2024 q1_6a_1_13_2024 q1_6a_1_14_2024 q1_6a_1_15_2024 q1_6a_1_16_2024)
	
	tabulate tot_otg_salg 
	total tot_otg_salg 
	summarize tot_otg_salg
	return list
	
	list kommune_2024 tot_otg_salg if tot_otg_salg >0
	
	/*2023*/
	summarize tot_otg_salg_2023
	return list
	

/* Antall overtredelser knyttet til salgsbevilling etter type*/
	* Salg mindreårig
		summarize q1_6a_1_1_2024
		return list
	*Brudd på kravet om forsvarlig drift 
		summarize q1_6a_1_2_2024
		return list
	*Hindring av kontroll
		summarize q1_6a_1_3_2024
		return list 
	*Salg til åpenbart påvirket person   
		summarize q1_6a_1_4_2024
		return list    
	*Brudd på tidsbestemmelsene 
		summarize q1_6a_1_5_2024
		return list
	*Brudd på reklamebestemmelsene 
		summarize q1_6a_1_6_2024
		return list
	*Brudd på alderskrav til den som selger alkohol 
		summarize q1_6a_1_7_2024
		return list
	*Mangler ved internkontrollen 
		summarize q1_6a_1_8_2024
		return list
	*Brudd på regler om styrer og stedfortreder 
		summarize q1_6a_1_9_2024
		return list
	*Brudd på reglene om plassering av alkoholholdig drikk på salgsstedet 
		summarize q1_6a_1_10_2024
		return list
	*Brudd på vilkår i bevillingsvedtaket 
		summarize q1_6a_1_11_2024
		return list
	*Manglende levering av omsetningsoppgave innen kommunens frist 
		summarize q1_6a_1_12_2024
		return list
	*Manglende betaling av bevillingsgebyr innen kommunens frist 
		summarize q1_6a_1_13_2024
		return list
	*Omseting med rabatt
		summarize q1_6a_1_14_2024
		return list
	*Ubetjent salg
		summarize q1_6a_1_15_2024
		return list
	*Annen type overtredelse
		summarize q1_6a_1_16_2024
		return list
	

	
	* Årsak til ingen overtredeler:
	tabulate q1_6c_1_2024 // ingen overtredeler avdekket
	tabulate q1_6c_2_2024 // kommunen har ikke gjort kontroll/ressurser til kontroll
	tabulate q1_6c_3_2024 // prioritert annen veiledning
	tabulate q1_6c_4_2024 // annet

	
	* Overtredelser skjenking, antall: 
	tabulate q2_11_2024 // var det overtredelser knyttet til skjenking i 2024, ja/nei
	
	gen tot_otg_skjenk = (q2_11a_1_1_2024 + q2_11a_1_2_2024 + q2_11a_1_3_2024 + q2_11a_1_4_2024 + q2_11a_1_5_2024 + q2_11a_1_6_2024 + q2_11a_1_7_2024 + q2_11a_1_8_2024 + q2_11a_1_9_2024 + q2_11a_1_10_2024 + q2_11a_1_11_2024 + q2_11a_1_12_2024 + q2_11a_1_13_2024 + q2_11a_1_14_2024 + q2_11a_1_15_2024 + q2_11a_1_16_2024 + q2_11a_1_17_2024 + q2_11a_1_18_2024 + q2_11a_1_19_2024 + q2_11a_1_20_2024 + q2_11a_1_21_2024 + q2_11a_1_22_2024 + q2_11a_1_23_2024)
	
	tabulate tot_otg_skjenk 
	total tot_otg_skjenk
	summarize tot_otg_skjenk
	return list
	
	/*
	egen tot_otg_skjenk2 = rowtotal (q2_11a_1_1_2024 q2_11a_1_2_2024 q2_11a_1_3_2024 q2_11a_1_4_2024 q2_11a_1_5_2024 q2_11a_1_6_2024 q2_11a_1_7_2024 q2_11a_1_8_2024 q2_11a_1_9_2024 q2_11a_1_10_2024 q2_11a_1_11_2024 q2_11a_1_12_2024 q2_11a_1_13_2024 q2_11a_1_14_2024 q2_11a_1_15_2024 q2_11a_1_16_2024 q2_11a_1_17_2024 q2_11a_1_18_2024 q2_11a_1_19_2024 q2_11a_1_20_2024 q2_11a_1_21_2024 q2_11a_1_22_2024 q2_11a_1_23_2024)
	

	summarize tot_otg_skjenk2
	return list
	*/
	list kommune_2024 tot_otg_salg if tot_otg_salg >0
	
	
	
/* Antall overtredelser knytte til skjenkebevillinger etter type*/
	* Skjenking til mindreårige:
	summarize q2_11a_1_1_2024
	return list
	* Brudd på bistandsplikten
	summarize q2_11a_1_2_2024
	return list 
	* Brudd på kravet om forsvarlig drift
	summarize q2_11a_1_3_2024
	return list
	* Hindring av kontroll
	summarize q2_11a_1_4_2024
	return list
	* Skjenking til åpenbart påvirket person
	summarize q2_11a_1_5_2024
	return list
	* Brudd på tidsbestemmelsene
	summarize q2_11a_1_6_2024
	return list
	* Brudd på reklamebestemmelsene
	summarize q2_11a_1_7_2024
	return list
	* Skjenking av sprit til person mellom 18-20 år
	summarize q2_11a_1_8_2024
	return list
	* Brudd på alderskrav til den som skjenker alkohol
	summarize q2_11a_1_9_2024
	return list
	* Åpenbart påvirket person i lokalet
	summarize q2_11a_1_10_2024
	return list
	* Mangler ved internkontrollsystemet
	summarize q2_11a_1_11_2024
	return list
	* Brudd på regler om styrer og stedfortreder
	summarize q2_11a_1_12_2024
	return list
	* Gjentatt diskriminering
	summarize q2_11a_1_13_2024
	return list
	* Gjentatt narkotikaomsetning
	summarize q2_11a_1_14_2024
	return list
	* Brudd på regelene om alkoholfrie alternativer
	summarize q2_11a_1_15_2024
	return list
	* Brudd på reglene om plassering av alkoholholdig drikk på skjenkestedet
	summarize q2_11a_1_16_2024
	return list
	* Brudd på reflene om skjenkemengde for brennevin
	summarize q2_11a_1_17_2024
	return list
	* Brudd på vilkår i bevillingsvedtaket
	summarize q2_11a_1_18_2024
	return list
	* KOnsum av medbrakt alkohol
	summarize q2_11a_1_19_2024
	return list
	* Gjester tar med alkohol ut
	summarize q2_11a_1_20_2024
	return list
	* Manglende levering av omsetningsoppgave innen kommunens frist
	summarize q2_11a_1_21_2024
	return list
	* Manglende betaling av bevillingsgebyr innen kommunens frist
	summarize q2_11a_1_22_2024
	return list
	* Andre typer overtredelser:
	summarize q2_11a_1_23_2024
	return list
	
	*/
/* Antall inndragning av salgs- og skjenkebevillinger og antall*/
	* Salg, permanent:
	tabulate q1_7_2024
	tabulate q1_7_1_2024

	summarize q1_7_1_2024
	return list
	
	* Salg, midlertidig:
	tabulate q1_8_2024
	tabulate q1_8_1_2024
	
	summarize q1_8_1_2024
	return list
	
	
	
	* Skjenke, permanent:
	tabulate q2_12_2024 // inndratt permanent ja/nei
	summarize q2_12_1_2024 // antall permanent
	return list
	* Skjenke, midlertidig:
	tabulate q2_13_2024 // inndratt midlertidig ja/nei
	summarize q2_13_1_2024 // antall
	return list

	
/* Antall nye salgsbevillinger*/
	* Innvilget:
	tabulate q1_13a_1_2024 // fordeling av antall innvilget
	summarize q1_13a_1_2024
	return list
	
	* Avslått: 
	tabulate q1_13a_2_2024
	summarize q1_13a_2_2024
	return list
	* Begrunnelse for avslag:
		* Vandelskrev
		summarize q1_13b_1_2024
		return list
		* Lokalpolitiske hensyn
		summarize q1_13b_2_2024
		return list
		* Manglende dokumentasjon fra søker
		summarize q1_13b_3_2024
		return list
		* Annet:
		summarize q1_13b_4_2024
		return list 
	
	
/* Antall nye skjenkebevillinger*/ 
	* Innvilget: 
	tabulate q2_8a_1_2024
	summarize q2_8a_1_2024
	return list
	* Avslått: 
	tabulate q2_8a_2_2024
	summarize q2_8a_2_2024
	return list
	
	* Begrunnelse for avslag:
		* Vandelskrev
		summarize q2_8b_1_1_2024
		return list
		* Lokalpolitiske hensyn
		summarize q2_8b_1_2_2024
		return list
		* Manglende dokumentasjon
		summarize q2_8b_1_3_2024
		return list
		* Manglende godkjenning fra andre offentlige myndigheter
		summarize q2_8b_1_4_2024
		return list
		* Annet:
		summarize q2_8b_1_5_2024
		return list 
	
	/*
	
/*skjenkebevillinger for en enkelt anledning og/eller ambulerende skjenkebevillinger i 2023?*/
	summarize q2_3
	return list // viser spredningen og totalt antall ambulerende skjenkebev i 2023
	histogram q2_3, discrete frequency
	
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
*/

/*Hvordan gjennomføres fornyelse av salgs- og skjenkebevillinger*/

tabulate q4_1_2024
/* Alkoholpolitikk */

* Har kommunen gjennomgått alkoholpolitikken og vurdert bevillingspolitikken etter kommunevalget i 2024. OBS! det var ikke kommunevalg i 2024.
tabulate q4_1_2024
tabulate q4_2_2024

* Har kommunen utarbeidet alkoholpolitisk handlingsplan (eller liknende føringer for alkoholpolitikken, for eksempel retningslinjer)?
tabulate q4_3_2024

/* Saksbehandling av salgs- og skjenkebevillinger*/

*Hva opplever kommunen som de største utfordringene i saksbehandlingen etter alkoholloven? (flere svar mulig)
tabulate q5_1_1_2024 // innhenting av uttalelser fra høringsinstansene
tabulate q5_1_2_2024  // manglende saksbehandlingssysten
tabulate q5_1_3_2024 // registrering av bevillinger i TBR
tabulate q5_1_4_2024 // spørsmål fra bevillingssøker
tabulate q5_1_5_2024 // vandelsvurdering
tabulate q5_1_6_2024 // mangel på tilgjengelig veiledning og informasjon om regelverket
tabulate q5_1_7_2024 // komplisert regelverk
tabulate q5_1_8_2024 // annet
tabulate q5_1_9_2024 // ikke noe

* Har kommunen mottatt veiledning i 2024? 
tabulate q5_2_2024

* Hvem fikk kommunen veiledning fra (flere svar mulig)
tabulate q5_2a_1_2024 // statsforvalter
tabulate q5_2a_2_2024 // annen kommuner
tabulate q5_2a_3_2024 // KORUS
tabulate q5_2a_4_2024 // Kommunalt alkoholfaglig saksbehandlerforum (KAS)
tabulate q5_2a_5_2024 // Annet

* Registrerer kommunen bevillinger i TBR?
tabulate q5_3_2024

* Filen slutter her.
/*
*Gammel kode:


		/*Kommuner med missing på salgsbevillinger 2023*/
		list utvalg_kommunenummer name2023 if q1_1==.
		* OBS på at disse kommunene benytter tall fra fjoråret eller tidligere.
		
		/*Kommuner med missing på skjenkebevillinger 2023*/
		list utvalg_kommunenummer name2023 if q2_1==.
		* OBS på at disse kommunene benytter tall fra fjoråret eller tidligere.	
		
	* Siden variabelen er laget i kvalitetssjekken importeres disse variablene ved bruk av frame:

frame create total23
frame total23: use "O:\Prosjekt\Rusdata\Kommunenes forvaltning\Alkoholloven\Analyser 2023_2024\kvalitetsjekk_bevilling_2023_2024.dta"
frame total23: keep utvalg_kommunenummer tot_salg23 tot_skjenk23 gr1 gr12 gr123
frlink m:1 utvalg_kommunenummer, frame(total23)
frget tot_salg23 tot_skjenk23, from(total23)
frame drop total23
drop total23
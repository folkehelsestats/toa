*******************************************************************************
*	Importere ARN-omsetning fra Excel, klargjøre fil samt,
*	estimere omsetning for Haugesund.
*
*  Formål:  Importere tall fra ARN-omsetning. Fila estimerer også omsetning 
*			for ved å sammenligne tre estimeringsmetoder 
*			for manglende liter-tall ved Haugesund Q1 2023 og del 1 av Q2 2023.
*
*  Metoder:
*    M1  — Sesongfaktor: l/enhet_antall beregnet fra kjente perioder,
*           multiplisert med faktisk enhet_antall for ukjente perioder.
*           enhet_antall finnes for alle kvartal og alle år. Estimatene er for
*			brennevin estimert med vekter for omsetning etter undergrupper.
*    M2  — Tidsserieregresjon på Haugesunds egne data:
*           ln(l) = Gruppe-FE + beta*t + sesongdummies
*    M3  — Proxymodell med Ålesund:
*           ln(l_Haugesund) = Gruppe-FE + beta*ln(l_Ålesund)
*
*  Validering av M1, M2 og M3:
*    Modellene estimeres på 2024-data og predikerer Q3/Q4 2023
*    som vi har faktiske observasjoner for.
*    Predikasjonsfeil måles med MAPE per Gruppe.
*
*  Opprettet av: Bente Øvrebø, Hdir, 2025.
*  Utarbeidet ved hjelp av Claude.ai og Copilot.
*******************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"

********************************************************************************
** STEG 1: Import og rens ARN 2023-2025
********************************************************************************

import excel "ARN 2023-2025.xlsx", sheet("Ark1") firstrow clear

capture confirm variable År
if !_rc {
    gen Kvt = yq(År, Kvartal)
    drop År Kvartal
}
format %tq Kvt
label var Kvt "Kvartal"

drop if Flyplass == ""

capture rename liter l

gen Gruppe = ""
replace Gruppe = "Øl"        if Varegruppe == "230 - Beer & softdrinks"
replace Gruppe = "Vin"       if Varegruppe == "200 - Tablewine"
replace Gruppe = "Hetvin"    if Varegruppe == "210 - Fortified wine"
replace Gruppe = "Brennevin" if Varegruppe == "220 - Liquor"
replace Gruppe = "Øl"        if Varegruppe == "Beer"
replace Gruppe = "Vin"       if Varegruppe == "Champagne"
replace Gruppe = "Vin"       if Varegruppe == "Sparkling Wine"
replace Gruppe = "Vin"       if Varegruppe == "Wine"
replace Gruppe = "Hetvin"    if Varegruppe == "Sherry & Port & Fruit"
replace Gruppe = "Hetvin"    if Varegruppe == "Vermouth"
replace Gruppe = "Brennevin" if Varegruppe == "Aquavit"
replace Gruppe = "Brennevin" if Varegruppe == "Armagnac"
replace Gruppe = "Brennevin" if Varegruppe == "Brandy"
replace Gruppe = "Brennevin" if Varegruppe == "Clear Spirits (with additives)"
replace Gruppe = "Brennevin" if Varegruppe == "Cognac"
replace Gruppe = "Brennevin" if Varegruppe == "Digestif & Aperitif"
replace Gruppe = "Brennevin" if Varegruppe == "Fruitbrandy & Grappa"
replace Gruppe = "Brennevin" if Varegruppe == "Fruity Spirits & Other Premix"
replace Gruppe = "Brennevin" if Varegruppe == "Gin & Genever"
replace Gruppe = "Brennevin" if Varegruppe == "Liqueur"
replace Gruppe = "Brennevin" if Varegruppe == "miscellaneous spirit"
replace Gruppe = "Brennevin" if Varegruppe == "Rum"
replace Gruppe = "Brennevin" if Varegruppe == "Tequila"
replace Gruppe = "Brennevin" if Varegruppe == "Vodka"
replace Gruppe = "Brennevin" if Varegruppe == "Whisk(e)y"

drop if Varegruppe == "Grand Total"
drop if Varegruppe == "Cigarette paper"
drop if Gruppe == ""
drop if inlist(Gruppe, "AllTobakk", "Sigaretter", "Sigarer", "Snus", "Tobakk")
drop kg
drop if Kvt >= tq(2025q1) // bruker nærmeste år (2024) i estimering

/* Variabel som markerer "annerledes leveranse"*/
gen antall_leveranse = 0
replace antall_leveranse = 1 if Varegruppe == "230 - Beer & softdrinks"
replace antall_leveranse = 1 if Varegruppe == "200 - Tablewine"
replace antall_leveranse = 1 if Varegruppe == "210 - Fortified wine"
replace antall_leveranse = 1 if Varegruppe == "220 - Liquor"
label var antall_leveranse "1 = kun antall, mangler liter"

replace l = 0 if l == . & antall_leveranse == 0

/* Retter i Utsalgsvariabel og renamer variabler */
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang"  if Utsalg == "Departure"
replace Utsalg = "Total"   if Utsalg == ""
replace Utsalg = "Total"   if Utsalg == "Nonschengen"

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

gen k_nr = quarter(dofq(Kvt))
label var k_nr "Kvartalsnummer (1–4)"

********************************************************************************
** DEL A1: Stabil flaskestørrelse per underkategori (Varegruppe-nivå)
**
**  For alle ARN-rader med antall_leveranse == 0 (faktisk liter tilgjengelig):
**  beregn gjennomsnittlig l/enhet_antall per Varegruppe.
**  Disse er svært stabile og trenger ikke sesongkorrigering.
********************************************************************************
/*
preserve
keep if Gruppe == "Brennevin" & antall_leveranse == 0 & l > 0
gen faktor_sub = l / enhet_antall
tab Varegruppe

    collapse (mean) faktor_sub (count) n_obs = faktor_sub, by(Varegruppe)
	list Varegruppe faktor_sub n_obs
	
    label var faktor_sub "Gj.snitt l/enhet_antall per underkategori"
    label var n_obs      "Antall rad-observasjoner bak faktoren"

    display as text _newline "=== Flaskestørrelse per underkategori (alle) ==="
    list Varegruppe n_obs faktor_sub, noobs

		/*
		=== Flaskestørrelse per underkategori (alle) ===

		. 
		.     list Varegruppe n_obs faktor_sub, noobs

		  +---------------------------------------------------+
		  |                     Varegruppe   n_obs   faktor~b |
		  |---------------------------------------------------|
		  |                        Aquavit     145   .7295182 |
		  |                       Armagnac       1         .7 |
		  |                         Brandy     133   .8109812 |
		  | Clear Spirits (with additives)      11          1 |
		  |                         Cognac     145   .5988428 |
		  |---------------------------------------------------|
		  |            Digestif & Aperitif     144   .3954996 |
		  |           Fruitbrandy & Grappa      79   .8864012 |
		  |  Fruity Spirits & Other Premix     100   .9942978 |
		  |                  Gin & Genever     143   .6220987 |
		  |                        Liqueur     145   .5554313 |
		  |---------------------------------------------------|
		  |                            Rum     139   .8351377 |
		  |                        Tequila      95   .9029561 |
		  |                          Vodka     144   .6750152 |
		  |                      Whisk(e)y     145   .7067462 |
		  |           miscellaneous spirit     135   .9048043 |
		  +---------------------------------------------------+

		*/
	
restore 

*/
********************************************************************************
** DEL A1: Estimere (flaskestørrelse) l per antall for vin, hetvin og øl.
** Estimerer ikke faktor per kvartal, da disse flaskestørrelsene er relativt stabile.
**
**  For Haugesund-rader med antall_leveranse == 0 (faktisk liter tilgjengelig):
**  beregn gjennomsnittlig l/enhet_antall per Varegruppe.
**  Disse antas som stabile og trenger ikke sesongkorrigering, benytter derfor 
**  alle tall fra 2023 og 2024 hvor vi har liter og antall.
********************************************************************************

preserve
keep if Lufthavn == "Haugesund" 
keep if Gruppe == "Vin" | Gruppe == "Hetvin" | Gruppe == "Øl" & antall_leveranse == 0 & l > 0
gen faktor_sub = l / enhet_antall
tab Varegruppe
tab Gruppe
drop if l == .

    collapse (mean) faktor_sub (count) n_obs = faktor_sub, by(Gruppe)
	
    label var faktor_sub "Gj.snitt l/enhet_antall per Gruppe"
    label var n_obs      "Antall rad-observasjoner bak faktoren"

    display as text _newline "=== Flaskestørrelse per Gruppe (Haugesund) ==="
    list Gruppe n_obs faktor_sub, noobs

		/*

		  | Gruppe   n_obs   faktor~b |
		  |---------------------------|
		  | Hetvin      14   .9535293 |
		  |    Vin      21   .7616849 |
		  |     Øl       7    1.90611 |
		  +---------------------------+

		*/
		
	save "faktor_vektet_vin", replace	

restore

********************************************************************************
** DEL A2: Estimere (flaskestørrelse) l per antall for brennevin. 
** Stabil flaskestørrelse per underkategori (Varegruppe-nivå) - Brennevin
**
**  For Haugesund-rader med antall_leveranse == 0 (faktisk liter tilgjengelig):
**  beregn gjennomsnittlig l/enhet_antall per Varegruppe.
**  Disse er svært stabile og trenger ikke sesongkorrigering.
**  alle tall fra 2023 og 2024 hvor vi har liter og antall.

** Siden det er litt forskjell i faktorene ved ulike flyplasser, så må det tas 
** et valg. Basert på at det kan være forskjell i hvem som handler på de ulike 
** flyplassene, benytter jeg i hovedsak tall fra Haugesund der faktorene kan 
** beregnes. Dvs estimater fra DEL A2.
********************************************************************************

preserve
keep if Lufthavn == "Haugesund" & Gruppe == "Brennevin" & antall_leveranse == 0 & l > 0
gen faktor_sub = l / enhet_antall
tab Varegruppe

    collapse (mean) faktor_sub (count) n_obs = faktor_sub, by(Varegruppe)

	
    label var faktor_sub "Gj.snitt l/enhet_antall per underkategori"
    label var n_obs      "Antall rad-observasjoner bak faktoren"

    display as text _newline "=== Flaskestørrelse per underkategori (Haugesund) ==="
    list Varegruppe n_obs faktor_sub, noobs

		/*
		
		
		=== Flaskestørrelse per underkategori (Haugesund) ===

		.     list Varegruppe n_obs faktor_sub, noobs

		  +--------------------------------------------------+
		  |                    Varegruppe   n_obs   faktor~b |
		  |--------------------------------------------------|
		  |                       Aquavit       7   .7388789 |
		  |                        Brandy       7   .8076129 |
		  |                        Cognac       7   .6615113 |
		  |           Digestif & Aperitif       7   .3608862 |
		  |          Fruitbrandy & Grappa       5          1 |
		  |--------------------------------------------------|
		  | Fruity Spirits & Other Premix       7          1 |
		  |                 Gin & Genever       7   .7229071 |
		  |                       Liqueur       7   .5516176 |
		  |                           Rum       7   .8240599 |
		  |                       Tequila       7   .9912698 |
		  |--------------------------------------------------|
		  |                         Vodka       7   .7593357 |
		  |                     Whisk(e)y       7    .683444 |
		  |          miscellaneous spirit       7          1 |
		  +--------------------------------------------------+


		*/
	
	
    save "faktor_sub", replace

	
restore 




********************************************************************************
** DEL B: Sesongmessig omsetningsandel av underkategoriene (per kvartalsnummer)
**
**  For Haugesund-rader med antall_leveranse == 0:
**  beregn andel av total Brennevin-antall per underkategori per k_nr.
**  Eksempel: i Q1 er 25 % av Brennevin-enhetene Vodka, 15 % Aquavit osv.
**  Disse andelene brukes til å vekte flaskestørrelsene i Del C.
********************************************************************************

preserve

    keep if Lufthavn == "Haugesund"         ///
         & Gruppe    == "Brennevin"          ///
         & antall_leveranse == 0             ///
         & enhet_antall > 0

    /* Summer antall per underkategori per kvartalsnummer */
    collapse (sum) ant_sub = enhet_antall, by(Varegruppe k_nr)

    /* Summer total Brennevin-antall per kvartalsnummer */
    bysort k_nr: egen ant_total = sum(ant_sub)

    /* Sesongandel */
    gen andel = ant_sub / ant_total
    label var andel "Andel av Brennevin-enheter i dette kvartalsnummeret"

    /* Kontroll: andelene skal summere til 1 per k_nr */
    bysort k_nr: egen sum_andel = sum(andel)
    assert abs(sum_andel - 1) < 0.001 // Assert: 
	** Assert verifies that exp is true.  
	** If it is true, the command produces no output. 

    display as text _newline "=== Sesongandel per underkategori og kvartalsnummer ==="
    list k_nr Varegruppe andel, sepby(k_nr) noobs

	/*
		
	=== Sesongandel per underkategori og kvartalsnummer ===

	. 
	.     list k_nr Varegruppe andel, sepby(k_nr) noobs

  +--------------------------------------------------+
  | k_nr                       Varegruppe      andel |
  |--------------------------------------------------|
  |    1                              Rum   .0226112 |
  |    1                          Tequila   .0038293 |
  |    1              Digestif & Aperitif   .0747629 |
  |    1                    Gin & Genever   .0762217 |
  |    1             miscellaneous spirit   .0065646 |
  |    1                          Liqueur   .3322392 |
  |    1                          Aquavit   .0532458 |
  |    1                           Brandy   .0175055 |
  |    1   Clear Spirits (with additives)          0 |
  |    1                            Vodka   .1477024 |
  |    1                           Cognac   .0822392 |
  |    1    Fruity Spirits & Other Premix   .0045587 |
  |    1             Fruitbrandy & Grappa          0 |
  |    1                        Whisk(e)y   .1785193 |
  |--------------------------------------------------|
  |    2                          Liqueur   .3476295 |
  |    2             miscellaneous spirit   .0087284 |
  |    2                          Aquavit   .0524333 |
  |    2    Fruity Spirits & Other Premix   .0040816 |
  |    2             Fruitbrandy & Grappa   .0000628 |
  |    2   Clear Spirits (with additives)          0 |
  |    2                           Brandy   .0129984 |
  |    2                            Vodka   .1351334 |
  |    2              Digestif & Aperitif   .0702669 |
  |    2                    Gin & Genever   .1100785 |
  |    2                          Tequila   .0034537 |
  |    2                        Whisk(e)y   .1365777 |
  |    2                           Cognac   .0807535 |
  |    2                              Rum   .0378022 |
  |--------------------------------------------------|
  |    3                    Gin & Genever   .1074938 |
  |    3                          Tequila   .0026161 |
  |    3    Fruity Spirits & Other Premix   .0069182 |
  |    3                        Whisk(e)y   .1474333 |
  |    3                              Rum    .038428 |
  |    3                           Cognac   .0728446 |
  |    3                           Brandy   .0093599 |
  |    3                          Aquavit   .0512761 |
  |    3             miscellaneous spirit   .0093599 |
  |    3                            Vodka   .1404569 |
  |    3   Clear Spirits (with additives)          0 |
  |    3                          Liqueur   .3448637 |
  |    3             Fruitbrandy & Grappa   .0001163 |
  |    3              Digestif & Aperitif   .0688332 |
  |--------------------------------------------------|
  |    4                          Tequila   .0014586 |
  |    4                            Vodka   .1166861 |
  |    4                              Rum   .0262544 |
  |    4             Fruitbrandy & Grappa   .0004376 |
  |    4                           Brandy   .0165548 |
  |    4                           Cognac    .082993 |
  |    4                          Aquavit   .0918903 |
  |    4             miscellaneous spirit    .010283 |
  |    4    Fruity Spirits & Other Premix    .003063 |
  |    4   Clear Spirits (with additives)          0 |
  |    4                        Whisk(e)y   .1764148 |
  |    4                          Liqueur   .3178967 |
  |    4                    Gin & Genever   .0802946 |
  |    4              Digestif & Aperitif    .075773 |
  +--------------------------------------------------+


	  */
    

	keep Varegruppe k_nr andel
	
    save "andel_sesong", replace

	
restore


********************************************************************************
** DEL C: Faktor vektet etter omsetning av underkategori av brennevin per kvartal
**
**  faktor_vektet(k) = Σ (andel_sub(k) × faktor_sub)
**
**  Dette er den faktoren som brukes på total enhet_antall fra
**  "220 - Liquor"-raden for de kvartalene som mangler liter.
********************************************************************************

/* Koble faktor og sesongandel */
use "andel_sesong", clear
merge m:1 Varegruppe using "faktor_sub", keep(match) nogenerate

/* Bidrag per underkategori */
gen bidrag = andel * faktor_sub


/* Summer til vektet faktor per kvartalsnummer */
collapse (sum) faktor_vektet = bidrag, by(k_nr)
label var faktor_vektet "Sesongvektet l/enhet_antall for Brennevin"

display as text _newline "=== Vektet Brennevin-faktor per kvartalsnummer ==="
list k_nr faktor_vektet, noobs

/* 
		=== Vektet Brennevin-faktor per kvartalsnummer ===

		. list k_nr faktor_vektet, noobs

		  +-----------------+
		  | k_nr   faktor~t |
		  |-----------------|
		  |    1    .640949 |
		  |    2   .6427549 |
		  |    3   .6444864 |
		  |    4   .6429531 |
		  +-----------------+

*/

save "faktor_vektet_brennevin", replace



********************************************************************************
** DEL D: Valider faktoren på Q3 og Q4 2023
**
**  Vi har faktisk liter for Haugesund Q3 og Q4 2023.
**  Sjekk: faktor_vektet × ant_kj_brennevin ≈ l_kj_brennevin?
**  Faktoren her beregnes kun fra 2024-data (out-of-sample).

** Forklaring: Hvis vi bare hadde 2024-data tilgjengelig – hvor godt ville den 
** sesongvektede faktoren ha forklart liter for 2023-kvartaler der vi faktisk 
** kjenner fasiten? DEL D tester om en sesongvektet liter-per-enhet-faktor, 
** estimert kun fra 2024, klarer å gjenskape faktisk liter i 2023 Q3–Q4. 
** Resultatet gir empirisk støtte (eller ikke) for å bruke samme metode til å 
** estimere manglende liter i Q1 og Q2 2023.

** Forslag til test, men obs på at Q3 og Q4 har mer detaljerte varegrupper enn 
** Q1 og Q2.
********************************************************************************
/*
clear 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"


********************************************************************************
** Import og rens ARN 2023-2025
********************************************************************************

import excel "ARN 2023-2025.xlsx", sheet("Ark1") firstrow clear

capture confirm variable År
if !_rc {
    gen Kvt = yq(År, Kvartal)
    drop År Kvartal
}
format %tq Kvt
label var Kvt "Kvartal"

drop if Flyplass == ""

capture rename liter l

gen Gruppe = ""
replace Gruppe = "Øl"        if Varegruppe == "230 - Beer & softdrinks"
replace Gruppe = "Vin"       if Varegruppe == "200 - Tablewine"
replace Gruppe = "Hetvin"    if Varegruppe == "210 - Fortified wine"
replace Gruppe = "Brennevin" if Varegruppe == "220 - Liquor"
replace Gruppe = "Øl"        if Varegruppe == "Beer"
replace Gruppe = "Vin"       if Varegruppe == "Champagne"
replace Gruppe = "Vin"       if Varegruppe == "Sparkling Wine"
replace Gruppe = "Vin"       if Varegruppe == "Wine"
replace Gruppe = "Hetvin"    if Varegruppe == "Sherry & Port & Fruit"
replace Gruppe = "Hetvin"    if Varegruppe == "Vermouth"
replace Gruppe = "Brennevin" if Varegruppe == "Aquavit"
replace Gruppe = "Brennevin" if Varegruppe == "Armagnac"
replace Gruppe = "Brennevin" if Varegruppe == "Brandy"
replace Gruppe = "Brennevin" if Varegruppe == "Clear Spirits (with additives)"
replace Gruppe = "Brennevin" if Varegruppe == "Cognac"
replace Gruppe = "Brennevin" if Varegruppe == "Digestif & Aperitif"
replace Gruppe = "Brennevin" if Varegruppe == "Fruitbrandy & Grappa"
replace Gruppe = "Brennevin" if Varegruppe == "Fruity Spirits & Other Premix"
replace Gruppe = "Brennevin" if Varegruppe == "Gin & Genever"
replace Gruppe = "Brennevin" if Varegruppe == "Liqueur"
replace Gruppe = "Brennevin" if Varegruppe == "miscellaneous spirit"
replace Gruppe = "Brennevin" if Varegruppe == "Rum"
replace Gruppe = "Brennevin" if Varegruppe == "Tequila"
replace Gruppe = "Brennevin" if Varegruppe == "Vodka"
replace Gruppe = "Brennevin" if Varegruppe == "Whisk(e)y"

drop if Varegruppe == "Grand Total"
drop if Varegruppe == "Cigarette paper"
drop if Gruppe == ""
drop if inlist(Gruppe, "AllTobakk", "Sigaretter", "Sigarer", "Snus", "Tobakk")
drop kg

gen antall_leveranse = 0
replace antall_leveranse = 1 if Varegruppe == "230 - Beer & softdrinks"
replace antall_leveranse = 1 if Varegruppe == "200 - Tablewine"
replace antall_leveranse = 1 if Varegruppe == "210 - Fortified wine"
replace antall_leveranse = 1 if Varegruppe == "220 - Liquor"
label var antall_leveranse "1 = kun antall, mangler liter"

replace l = 0 if l == . & antall_leveranse == 0

/* Retter i Utsalgsvariabel og renamer variabler */
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang"  if Utsalg == "Departure"
replace Utsalg = "Total"   if Utsalg == ""
replace Utsalg = "Total"   if Utsalg == "Nonschengen"

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

gen k_nr = quarter(dofq(Kvt))
label var k_nr "Kvartalsnummer (1–4)"
drop if Kvt >= tq(2025q1) // bruker nærmeste år (2024) i estimering.


/* Beregn valideringsfaktor kun fra 2024+ */
preserve

    keep if Lufthavn == "Haugesund"         ///
         & Gruppe    == "Brennevin"          ///
         & antall_leveranse == 0             ///
         & enhet_antall > 0                  ///
         & l > 0                             ///
         & Kvt >= tq(2024q1)

    gen faktor_sub_val = l / enhet_antall
    collapse (mean) faktor_sub_val (count) n_obs = faktor_sub_val, by(Varegruppe)

    tempfile faktor_sub_val
    save `faktor_sub_val'

restore

*preserve

    keep if Lufthavn == "Haugesund"         ///
         & Gruppe    == "Brennevin"          ///
         & antall_leveranse == 0             ///
         & enhet_antall > 0                  ///
         & Kvt >= tq(2024q1)

    collapse (sum) ant_sub = enhet_antall, by(Varegruppe k_nr)
    bysort k_nr: egen ant_total = sum(ant_sub)
    gen andel_val = ant_sub / ant_total
    keep Varegruppe k_nr andel_val

    tempfile andel_val
    save `andel_val'

*restore

*use `andel_val', clear
merge m:1 Varegruppe using `faktor_sub_val', keep(match) nogenerate
gen bidrag_val = andel_val * faktor_sub_val
collapse (sum) faktor_vektet_val = bidrag_val, by(k_nr)
tempfile faktor_val
save `faktor_val'


clear

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"



********************************************************************************
** STEG 1: Import og rens ARN 2023-2025
********************************************************************************

import excel "ARN 2023-2025.xlsx", sheet("Ark1") firstrow clear

capture confirm variable År
if !_rc {
    gen Kvt = yq(År, Kvartal)
    drop År Kvartal
}
format %tq Kvt
label var Kvt "Kvartal"

drop if Flyplass == ""

capture rename liter l

gen Gruppe = ""
replace Gruppe = "Øl"        if Varegruppe == "230 - Beer & softdrinks"
replace Gruppe = "Vin"       if Varegruppe == "200 - Tablewine"
replace Gruppe = "Hetvin"    if Varegruppe == "210 - Fortified wine"
replace Gruppe = "Brennevin" if Varegruppe == "220 - Liquor"
replace Gruppe = "Øl"        if Varegruppe == "Beer"
replace Gruppe = "Vin"       if Varegruppe == "Champagne"
replace Gruppe = "Vin"       if Varegruppe == "Sparkling Wine"
replace Gruppe = "Vin"       if Varegruppe == "Wine"
replace Gruppe = "Hetvin"    if Varegruppe == "Sherry & Port & Fruit"
replace Gruppe = "Hetvin"    if Varegruppe == "Vermouth"
replace Gruppe = "Brennevin" if Varegruppe == "Aquavit"
replace Gruppe = "Brennevin" if Varegruppe == "Armagnac"
replace Gruppe = "Brennevin" if Varegruppe == "Brandy"
replace Gruppe = "Brennevin" if Varegruppe == "Clear Spirits (with additives)"
replace Gruppe = "Brennevin" if Varegruppe == "Cognac"
replace Gruppe = "Brennevin" if Varegruppe == "Digestif & Aperitif"
replace Gruppe = "Brennevin" if Varegruppe == "Fruitbrandy & Grappa"
replace Gruppe = "Brennevin" if Varegruppe == "Fruity Spirits & Other Premix"
replace Gruppe = "Brennevin" if Varegruppe == "Gin & Genever"
replace Gruppe = "Brennevin" if Varegruppe == "Liqueur"
replace Gruppe = "Brennevin" if Varegruppe == "miscellaneous spirit"
replace Gruppe = "Brennevin" if Varegruppe == "Rum"
replace Gruppe = "Brennevin" if Varegruppe == "Tequila"
replace Gruppe = "Brennevin" if Varegruppe == "Vodka"
replace Gruppe = "Brennevin" if Varegruppe == "Whisk(e)y"

drop if Varegruppe == "Grand Total"
drop if Varegruppe == "Cigarette paper"
drop if Gruppe == ""
drop if inlist(Gruppe, "AllTobakk", "Sigaretter", "Sigarer", "Snus", "Tobakk")

gen antall_leveranse = 0
replace antall_leveranse = 1 if Varegruppe == "230 - Beer & softdrinks"
replace antall_leveranse = 1 if Varegruppe == "200 - Tablewine"
replace antall_leveranse = 1 if Varegruppe == "210 - Fortified wine"
replace antall_leveranse = 1 if Varegruppe == "220 - Liquor"
label var antall_leveranse "1 = kun antall, mangler liter"

replace l = 0 if l == . & antall_leveranse == 0

/* Retter i Utsalgsvariabel og renamer variabler */
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang"  if Utsalg == "Departure"
replace Utsalg = "Total"   if Utsalg == ""
replace Utsalg = "Total"   if Utsalg == "Nonschengen"

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

gen k_nr = quarter(dofq(Kvt))
label var k_nr "Kvartalsnummer (1–4)"


/* Sammenlign med faktisk Q3/Q4 2023 */
preserve

    keep if Lufthavn   == "Haugesund"        ///
         & Gruppe      == "Brennevin"         ///
         & antall_leveranse == 0              ///
         & inlist(Kvt, tq(2023q3), tq(2023q4))

    collapse (sum) l_faktisk = l (sum) ant = enhet_antall, by(Kvt k_nr)
    merge m:1 k_nr using `faktor_val', keep(master match) nogenerate

    gen l_pred_val = ant * faktor_vektet_val
    gen avvik_pst  = (l_pred_val - l_faktisk) / l_faktisk * 100

    display as text _newline "=== Validering Q3/Q4 2023 — vektet Brennevin-faktor ==="
    list Kvt l_faktisk l_pred_val avvik_pst, noobs
	/* Avvik i % - positiv = overestimert.
	  +------------------------------------------+
	  |    Kvt   l_fakt~k   l_pred~l   avvik_pst |
	  |------------------------------------------|
	  | 2023q3    6570.09   6451.809   -1.800301 |
	  | 2023q4    5179.31   5212.742    .6454856 |
	  +------------------------------------------+
	*/
    display as text "(Avvik i % — positiv = overestimert)"

restore

*/
********************************************************************************
** DEL E: Estimer liter for Haugesund Q1 og Q2-del1 (Brennevin)
**
**  Hent ant_uk fra "220 - Liquor"-raden (antall_leveranse == 1)
**  og multipliser med faktor_vektet for tilhørende k_nr.
********************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"

********************************************************************************
** STEG 1: Import og rens ARN 2023-2025
********************************************************************************

import excel "ARN 2023-2025.xlsx", sheet("Ark1") firstrow clear

capture confirm variable År
if !_rc {
    gen Kvt = yq(År, Kvartal)
    drop År Kvartal
}
format %tq Kvt
label var Kvt "Kvartal"

drop if Flyplass == ""

capture rename liter l

gen Gruppe = ""
replace Gruppe = "Øl"        if Varegruppe == "230 - Beer & softdrinks"
replace Gruppe = "Vin"       if Varegruppe == "200 - Tablewine"
replace Gruppe = "Hetvin"    if Varegruppe == "210 - Fortified wine"
replace Gruppe = "Brennevin" if Varegruppe == "220 - Liquor"
replace Gruppe = "Øl"        if Varegruppe == "Beer"
replace Gruppe = "Vin"       if Varegruppe == "Champagne"
replace Gruppe = "Vin"       if Varegruppe == "Sparkling Wine"
replace Gruppe = "Vin"       if Varegruppe == "Wine"
replace Gruppe = "Hetvin"    if Varegruppe == "Sherry & Port & Fruit"
replace Gruppe = "Hetvin"    if Varegruppe == "Vermouth"
replace Gruppe = "Brennevin" if Varegruppe == "Aquavit"
replace Gruppe = "Brennevin" if Varegruppe == "Armagnac"
replace Gruppe = "Brennevin" if Varegruppe == "Brandy"
replace Gruppe = "Brennevin" if Varegruppe == "Clear Spirits (with additives)"
replace Gruppe = "Brennevin" if Varegruppe == "Cognac"
replace Gruppe = "Brennevin" if Varegruppe == "Digestif & Aperitif"
replace Gruppe = "Brennevin" if Varegruppe == "Fruitbrandy & Grappa"
replace Gruppe = "Brennevin" if Varegruppe == "Fruity Spirits & Other Premix"
replace Gruppe = "Brennevin" if Varegruppe == "Gin & Genever"
replace Gruppe = "Brennevin" if Varegruppe == "Liqueur"
replace Gruppe = "Brennevin" if Varegruppe == "miscellaneous spirit"
replace Gruppe = "Brennevin" if Varegruppe == "Rum"
replace Gruppe = "Brennevin" if Varegruppe == "Tequila"
replace Gruppe = "Brennevin" if Varegruppe == "Vodka"
replace Gruppe = "Brennevin" if Varegruppe == "Whisk(e)y"

drop if Varegruppe == "Grand Total"
drop if Varegruppe == "Cigarette paper"
drop if Gruppe == ""
drop if inlist(Gruppe, "AllTobakk", "Sigaretter", "Sigarer", "Snus", "Tobakk")
drop kg
drop if Kvt >= tq(2025q1) // bruker nærmeste år (2024) i estimering.

gen antall_leveranse = 0
replace antall_leveranse = 1 if Varegruppe == "230 - Beer & softdrinks"
replace antall_leveranse = 1 if Varegruppe == "200 - Tablewine"
replace antall_leveranse = 1 if Varegruppe == "210 - Fortified wine"
replace antall_leveranse = 1 if Varegruppe == "220 - Liquor"
label var antall_leveranse "1 = kun antall, mangler liter"

replace l = 0 if l == . & antall_leveranse == 0

/* Retter i Utsalgsvariabel og renamer variabler */
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang"  if Utsalg == "Departure"
replace Utsalg = "Total"   if Utsalg == ""
replace Utsalg = "Total"   if Utsalg == "Nonschengen"

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

gen k_nr = quarter(dofq(Kvt))
label var k_nr "Kvartalsnummer (1–4)"


    keep if Lufthavn == "Haugesund" 

   
/* Kobler på faktor (l per antall) per kvartal for brennevin */
merge m:1 k_nr using "faktor_vektet_brennevin", keep(master match) nogenerate
replace faktor_vektet = . if antall_leveranse == 0 & Gruppe != "Brennevin"
replace faktor_vektet = . if antall_leveranse == 0 & Gruppe == "Brennevin"

/* Kobler på faktor (l per antall) for vin, hetvin og øl */
	
	merge m:1 Gruppe using "faktor_vektet_vin", keep(master match) nogenerate
	replace faktor_sub = . if antall_leveranse == 0
	replace n_obs = . if antall_leveranse == 0
	replace faktor_vektet = faktor_sub if Gruppe != "Brennevin"
	drop faktor_sub n_obs
	label var faktor_vektet "Estimert liter per antall for varegrupper"

/* Estimerer liter fra antall og beregnet faktor */
sort Kvt 
  gen l_est_M1 = enhet_antall * faktor_vektet if antall_leveranse == 1
  label var l_est_M1 "M1: Estimert liter fra antall og faktor"

    display as text _newline "=== Estimert liter Haugesund Q1/Q2 2023 ==="
    list Kvt enhet_antall faktor_vektet l_est_M1 if antall_leveranse == 1, noobs
	list Kvt l Gruppe antall_leveranse if Kvt >= tq(2023q1) & Kvt <= tq(2023q4)
	
	replace l = l_est_M1 if antall_leveranse == 1
	
	save "temp_M1_referanse.dta", replace
	
	

	
********************************************************************************
********************************************************************************

** Metode 1 er estimert ferdig
** Fortsetter her å jobbe videre med metode 2 og 3.

* Siden metoden er bestemt, er det ikke poeng å gå videre her /*

********************************************************************************
********************************************************************************
	
clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"


********************************************************************************
** STEG 1: Import og rens ARN 2023-2025
********************************************************************************

import excel "ARN 2023-2025.xlsx", sheet("Ark1") firstrow clear

/* Kvt: håndterer både "År+Kvartal" og ferdig formatert kvartalsvariabel */
* 		Hvis variabelen År finnes i datasettet, lag en kvartalsdato (Kvt) basert
*		på År og Kvartal, og slett deretter År og Kvartal. Hvis År ikke finnes, 
*		gjør ingenting. */

capture confirm variable År
if !_rc {
    gen Kvt = yq(År, Kvartal)
    drop År Kvartal
}
format %tq Kvt
label var Kvt "Kvartal"

drop if Flyplass == ""

/* Liter-kolonne kan hete "liter" eller "l" avhengig av kildefil */
capture rename liter l

gen Gruppe = ""
replace Gruppe = "Øl"        if Varegruppe == "230 - Beer & softdrinks"
replace Gruppe = "Vin"       if Varegruppe == "200 - Tablewine"
replace Gruppe = "Hetvin"    if Varegruppe == "210 - Fortified wine"
replace Gruppe = "Brennevin" if Varegruppe == "220 - Liquor"
replace Gruppe = "AllTobakk" if Varegruppe == "300 - Tobacco"
replace Gruppe = "Øl"        if Varegruppe == "Beer"
replace Gruppe = "Vin"       if Varegruppe == "Champagne"
replace Gruppe = "Vin"       if Varegruppe == "Sparkling Wine"
replace Gruppe = "Vin"       if Varegruppe == "Wine"
replace Gruppe = "Hetvin"    if Varegruppe == "Sherry & Port & Fruit"
replace Gruppe = "Hetvin"    if Varegruppe == "Vermouth"
replace Gruppe = "Brennevin" if Varegruppe == "Aquavit"
replace Gruppe = "Brennevin" if Varegruppe == "Armagnac"
replace Gruppe = "Brennevin" if Varegruppe == "Brandy"
replace Gruppe = "Brennevin" if Varegruppe == "Clear Spirits (with additives)"
replace Gruppe = "Brennevin" if Varegruppe == "Cognac"
replace Gruppe = "Brennevin" if Varegruppe == "Digestif & Aperitif"
replace Gruppe = "Brennevin" if Varegruppe == "Fruitbrandy & Grappa"
replace Gruppe = "Brennevin" if Varegruppe == "Fruity Spirits & Other Premix"
replace Gruppe = "Brennevin" if Varegruppe == "Gin & Genever"
replace Gruppe = "Brennevin" if Varegruppe == "Liqueur"
replace Gruppe = "Brennevin" if Varegruppe == "miscellaneous spirit"
replace Gruppe = "Brennevin" if Varegruppe == "Rum"
replace Gruppe = "Brennevin" if Varegruppe == "Tequila"
replace Gruppe = "Brennevin" if Varegruppe == "Vodka"
replace Gruppe = "Brennevin" if Varegruppe == "Whisk(e)y"
replace Gruppe = "Sigaretter"     if Varegruppe == "Cigarettes Duty Free"
replace Gruppe = "Sigarer"        if Varegruppe == "Cigars & Cigarillo DF"
replace Gruppe = "Snus"           if Varegruppe == "Snus"
replace Gruppe = "Tobakk"         if Varegruppe == "Tobacco  DF"

drop if Varegruppe == "Grand Total"
drop if Varegruppe == "Cigarette paper"
drop if Gruppe == ""
drop if Gruppe == "AllTobakk"     /* tobakk i gammel samlet kategori hoppes over */
drop if inlist(Gruppe, "Sigaretter", "Sigarer", "Snus", "Tobakk")

/* Kun alkohol videre */
keep if inlist(Gruppe, "Øl", "Vin", "Hetvin", "Brennevin")


/* Marker rader som kun er rapportert i antall */
gen antall_leveranse = 0
replace antall_leveranse = 1 if Varegruppe == "230 - Beer & softdrinks"
replace antall_leveranse = 1 if Varegruppe == "200 - Tablewine"
replace antall_leveranse = 1 if Varegruppe == "210 - Fortified wine"
replace antall_leveranse = 1 if Varegruppe == "220 - Liquor"
label var antall_leveranse "1 = kun antall, mangler liter"

replace l = 0 if l == . & antall_leveranse == 0

drop kg /* Ikke relevant siden tobakk droppes*/

/* Retter i Utsalgsvariabel og renamer variabler */
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang"  if Utsalg == "Departure"
replace Utsalg = "Total"   if Utsalg == ""
replace Utsalg = "Total"   if Utsalg == "Nonschengen"

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"



********************************************************************************
** STEG 2: Legger til estimater til metode 1 (M1) som er fikset i egen do-fil.
**
** 	Lager variabler som er aktuelle for videre modeller:
**  l_kj   = faktisk liter (rader med antall_leveranse == 0)
**  ant_uk = enhet_antall for rader som mangler liter (antall_leveranse == 1)
**
**  For Q2 2023 Haugesund: begge er positive.
**  For Q1 2023 Haugesund: kun ant_uk er positiv.
**  For alle andre flyplasser og kvartal: kun l_kj er positiv.
********************************************************************************


merge m:m Lufthavn Kvt Gruppe antall_leveranse using "temp_M1_referanse.dta", keep(master match) nogenerate
sort Lufthavn Kvt 
drop k_nr faktor_vektet


replace l_est_M1 = l if antall_leveranse == 0


gen l_kj  = l           if antall_leveranse == 0
* replace l_kj = . if antall_leveranse == 0 & Lufthavn == "Haugesund" & Kvt == tq(2023q2)
/* Usikker på å kjøre den kommandoen over, så ikke gjort per nå */

gen ant_uk = enhet_antall if antall_leveranse == 1

********************************************************************************
/* STOPPER HER; siden jeg ha valgt metode og fortsetter i do-fil ARN.

collapse (sum) l_kj ant_uk enhet_antall l_est_M1, by(Lufthavn Gruppe Kvt)
replace l_kj  = 0 if l_kj  == .
replace ant_uk = 0 if ant_uk == .

label var l_kj  "Faktisk liter (kjent)"
label var ant_uk "Enhet_antall for rader uten liter"

/* Identifiser perioder som trenger estimering */
gen mangler_liter = (Lufthavn == "Haugesund" & ant_uk > 0)
label var mangler_liter "1 = Haugesund mangler liter for deler av dette kvartalet"

/* Tid- og sesongvariabler */
gen t    = Kvt - tq(2023q1)   /* t = 0 ved Q1 2023 */
gen k_nr = quarter(dofq(Kvt))
label var t    "Tid (0 = Q1 2023)"
label var k_nr "Kvartalsnummer"


********************************************************************************
** STEG 3: METODE 1 — Sesongfaktor (l/antall per Gruppe per kvartalsnummer)
** Dette steget er allerede gjort i dofil: 1 Haugesund_2023-2025
** Denne fila er koblet på over, og estimatet ligger i kolonne l_est_M1
** Estimatet for liter (og antall) er allerede kollapset og summert fort Q22023.
**  
********************************************************************************
/* Beholder denne fore løpig 
erase "temp_M1_referanse.dta"
*/

********************************************************************************
** STEG 4: METODE 2 — Tidsserieregresjon på Haugesunds egne data
**  log-lineær tidsseriemodell, med faste effekter for gruppe, lineær tidstrend 
**  og kvartalseffekter. Modellen estimerer manglende verdier for Q1 og Q2 2023.
**  Modell (pooled med Gruppe-FE):
**    ln(l_kj) = α_Gruppe + β·t + γ₂·I(k=2) + γ₃·I(k=3) + γ₄·I(k=4) + ε
**
**  Estimering: kun Haugesund-observasjoner der l_kj > 0
**  Prediksjon: Q1 2023 (t=0, k=1) og Q2 2023 (t=1, k=2) for Haugesund
**  Ikke aktuelt med t^2, pga få datapunkter. Har med t og Kvt i modellen.
**
**  Validering: estimer på 2024-data, prediker Q3/Q4 2023, sammenlign med faktisk.
********************************************************************************
/* Lager log av liter, såfremt liter er positiv verdi*/
gen lnl = ln(l_kj) if l_kj > 0


/* Lager numerisk gruppekode til FE-variabel*/
egen Gruppe_fe = group(Gruppe), label


/* -- Fullmodell: estimer på alle kjente Haugesund-kvartal -- */
	** i.Gruppe_fe → gruppe‑faste effekter
	** t → lineær tidsutvikling
	** i.k_nr → kvartalseffekter (Q2–Q4, Q1 referanse)
	** Modellen fanger variasjon mellom grupper, generell trend over tid og 
	** systematiske sesong(kvartals)mønstre. 

regress lnl i.Gruppe_fe t i.k_nr ///
    if Lufthavn == "Haugesund" & l_kj > 0


/* Stor overestimering uten å logtranformere
regress l_kj i.Gruppe_fe t i.k_nr ///
    if Lufthavn == "Haugesund" & l_kj > 0
	
	predict l_kj_hat_M2, xb 
	drop l_kj_hat_M2 */

/* Smear-korreksjon for lognormal bias */

predict resid_M2, residuals
summarize resid_M2 if Lufthavn == "Haugesund" & l_kj > 0
scalar smear_M2 = exp(r(Var) / 2)

predict lnl_hat_M2, xb


gen l_est_M2_full = exp(lnl_hat_M2) * smear_M2 if Lufthavn == "Haugesund"
label var l_est_M2_full "M2: Regresjon fullmodell"

drop resid_M2 lnl_hat_M2

/* Variant hvor l for q22023 er fjernet i prediksjonsmodellen siden vi kun har deler av q2 i liter*/
/*

replace l = . if mangler_liter == 1 // fjerner q22023 liter
gen lnl_2 = ln(l)

regress lnl_2 i.Gruppe_fe t i.k_nr ///
    if Lufthavn == "Haugesund" & l_kj > 0
	
predict resid_M2_2, residuals
summarize resid_M2_2 if Lufthavn == "Haugesund"
scalar smear_M2_2 = exp(r(Var) / 2)

predict lnl_hat_M2_2, xb


gen l_est_M2_full_2 = exp(lnl_hat_M2_2) * smear_M2_2 if Lufthavn == "Haugesund"
label var l_est_M2_full_2 "M2: Regresjon fullmodell"

drop resid_M2_2 lnl_hat_M2_2 l_est_M2_full_2 
*/

/* -- Valideringsmodell: estimer fra på 2024-25, prediker Q3/Q4 2023 -- */

regress lnl i.Gruppe_fe t  i.k_nr ///
    if Lufthavn == "Haugesund" & l_kj > 0 & Kvt >= tq(2024q1)

predict resid_M2v, residuals
summarize resid_M2v if Lufthavn == "Haugesund" & l_kj > 0 & Kvt >= tq(2024q1)
scalar smear_M2v = exp(r(Var) / 2)

predict lnl_hat_M2v, xb

gen l_pred_M2v = exp(lnl_hat_M2v) * smear_M2v if Lufthavn == "Haugesund"
label var l_pred_M2v "M2: Prediksjon (estimert på 2024)"

drop resid_M2v lnl_hat_M2v

/* Valideringsfeil: Q3 og Q4 2023 */
gen val_feil_M2 = (l_pred_M2v - l_kj) / l_kj * 100 ///
    if Lufthavn == "Haugesund" & inlist(Kvt, tq(2023q3), tq(2023q4)) & l_kj > 0
label var val_feil_M2 "M2 valideringsfeil Q3/Q4 2023 (%)"

display as text _newline "=== M2: Valideringsfeil Q3/Q4 2023 ==="
list Gruppe Kvt l_kj l_pred_M2v val_feil_M2 ///
    if Lufthavn == "Haugesund" & inlist(Kvt, tq(2023q3), tq(2023q4)) & l_kj > 0, ///
    noobs sepby(Gruppe)
	
	/* Tallene predikert fra 2024 til Q3/Q4 viser at modellen underestimerer,
	** sammenliknet med faktiske tall (l_kj). 
	  +------------------------------------------------------+
  |    Gruppe      Kvt       l_kj   l_pre~2v   val_fei~2 |
  |------------------------------------------------------|
  | Brennevin   2023q3    6570.09   4912.394   -25.23095 |
  | Brennevin   2023q4    5179.31   4569.323   -11.77738 |
  |------------------------------------------------------|
  |    Hetvin   2023q3     136.05   129.7653   -4.619392 |
  |    Hetvin   2023q4        172   120.7029   -29.82392 |
  |------------------------------------------------------|
  |       Vin   2023q3   7421.296   5266.582   -29.03421 |
  |       Vin   2023q4   5588.446   4898.775   -12.34101 |
  |------------------------------------------------------|
  |        Øl   2023q3    5897.13   4383.426   -25.66848 |
  |        Øl   2023q4    3952.66   4077.298    3.153261 |
  +------------------------------------------------------+
  
  Modellen underestimerer ganske mye for Q3 og Q4, sammenliknet med faktiske tall.
  
	*/
	

/* Hent estimert verdi for manglende perioder fra fullmodell */
gen l_est_M2 = l_est_M2_full if mangler_liter == 1
label var l_est_M2 "M2: Regresjon — estimat for manglende perioder"


********************************************************************************
** STEG 5: METODE 3 — Proxymodell med Ålesund
**
**  Modell (pooled med Gruppe-FE):
**    ln(l_Haugesund) = α_Gruppe + β·ln(l_Ålesund) + ε
**
**  Ålesund har fullstendige liter-tall gjennom hele perioden.
**  Estimering på kjente Haugesund-kvartal (Q3 2023 og frem).
**  Prediksjon: bruk Ålesunds faktiske Q1/Q2 2023-tall som prediktor.
**
**  Validering: estimer på 2024, prediker Q3/Q4 2023.

**  Argumenter mot denne modellen er at vi ikke vet om Ålesund er en god proxy.
********************************************************************************

/* Reshape wide: Haugesund og Ålesund i samme rad */
keep Lufthavn Gruppe Kvt t k_nr l_kj ant_uk mangler_liter lnl Gruppe_fe ///
     l_est_M1 l_est_M2 l_pred_M2v val_feil_M2

keep if inlist(Lufthavn, "Haugesund", "Ålesund") 

reshape wide l_kj ant_uk mangler_liter lnl l_est_M1 l_est_M2 l_pred_M2v val_feil_M2, ///
    i(Gruppe Kvt t k_nr Gruppe_fe) j(Lufthavn) string

/* Rydder opp variabelnavn etter reshape */
rename l_kjHaugesund     l_H
rename l_kjÅlesund       l_Å
rename lnlHaugesund      lnl_H
rename lnlÅlesund        lnl_Å
rename ant_ukHaugesund   ant_uk_H
rename mangler_literHaugesund  mangler_liter_H
rename l_est_M1Haugesund l_est_M1_H
rename l_est_M2Haugesund l_est_M2_H
rename l_pred_M2vHaugesund l_pred_M2v_H
rename val_feil_M2Haugesund val_feil_M2_H


replace l_H  = 0 if l_H  == .
replace l_Å  = 0 if l_Å  == .
replace ant_uk_H = 0 if ant_uk_H == .

gen lnl_Å2 = ln(l_Å) if l_Å > 0


/* -- Fullmodell: estimer på alle kjente Haugesund-kvartal -- */
regress lnl_H i.Gruppe_fe lnl_Å2 ///
    if l_H > 0 & l_Å > 0

predict resid_M3, residuals
summarize resid_M3 if l_H > 0 & l_Å > 0
scalar smear_M3 = exp(r(Var) / 2)

predict lnl_hat_M3, xb
gen l_est_M3_full = exp(lnl_hat_M3) * smear_M3
drop resid_M3 lnl_hat_M3


/* -- Valideringsmodell: estimer på 2024, prediker Q3/Q4 2023 -- */
regress lnl_H i.Gruppe_fe lnl_Å2 ///
    if l_H > 0 & l_Å > 0 & Kvt >= tq(2024q1)

predict resid_M3v, residuals
summarize resid_M3v if l_H > 0 & l_Å > 0 & Kvt >= tq(2024q1)
scalar smear_M3v = exp(r(Var) / 2)

predict lnl_hat_M3v, xb
gen l_pred_M3v = exp(lnl_hat_M3v) * smear_M3v
drop resid_M3v lnl_hat_M3v

/* Valideringsfeil Q3/Q4 2023 */
gen val_feil_M3 = (l_pred_M3v - l_H) / l_H * 100 ///
    if inlist(Kvt, tq(2023q3), tq(2023q4)) & l_H > 0
label var val_feil_M3 "M3 valideringsfeil Q3/Q4 2023 (%)"

display as text _newline "=== M3: Valideringsfeil Q3/Q4 2023 ==="
list Gruppe Kvt l_H l_pred_M3v val_feil_M3 ///
    if inlist(Kvt, tq(2023q3), tq(2023q4)) & l_H > 0, ///
    noobs sepby(Gruppe)
	
	/*
	 +------------------------------------------------------+
  |    Gruppe      Kvt        l_H   l_pre~3v   val_fei~3 |
  |------------------------------------------------------|
  | Brennevin   2023q3    6570.09   5562.877   -15.33027 |
  | Brennevin   2023q4    5179.31   4959.526   -4.243493 |
  |------------------------------------------------------|
  |    Hetvin   2023q3     136.05   170.0194    24.96829 |
  |    Hetvin   2023q4        172   159.2673   -7.402748 |
  |------------------------------------------------------|
  |       Vin   2023q3   7421.296   5477.771   -26.18848 |
  |       Vin   2023q4   5588.446   4723.571   -15.47612 |
  |------------------------------------------------------|
  |        Øl   2023q3    5897.13    4599.59   -22.00291 |
  |        Øl   2023q4    3952.66   3896.443   -1.422258 |
  +------------------------------------------------------+
	*/
	

/* Estimat for manglende perioder */
gen l_est_M3 = l_est_M3_full if mangler_liter_H == 1
label var l_est_M3 "M3: Ålesund-proxy — estimat for manglende perioder"
drop l_est_M3_full l_pred_M3v


********************************************************************************
** STEG 6: Samlede estimater — l_total = l_kjent + l_estimert
**
**  Q1 2023: l_H = 0, l_est = fullt kvartal
**  Q2 2023: l_H > 0 (kjent del), l_est = estimat for antall-del
**           l_total = l_H + l_est
********************************************************************************

gen l_tot_M1 = l_est_M1_H   if mangler_liter_H == 1
gen l_tot_M2 = l_H + l_est_M2_H   if mangler_liter_H == 1
gen l_tot_M3 = l_H + l_est_M3     if mangler_liter_H == 1

/* For Q2 2023 gjelder: M2 og M3 predikerer fullt kvartal.
   Vi trekker fra kjent del og lar resten representere antall-perioden. */
replace l_est_M2_H = l_est_M2_H - l_H if Kvt == tq(2023q2) & mangler_liter_H == 1
replace l_est_M3   = l_est_M3   - l_H if Kvt == tq(2023q2) & mangler_liter_H == 1
replace l_tot_M2   = l_H + l_est_M2_H if Kvt == tq(2023q2) & mangler_liter_H == 1
replace l_tot_M3   = l_H + l_est_M3   if Kvt == tq(2023q2) & mangler_liter_H == 1


********************************************************************************
** STEG 7: Sammenligningstabeller og figurer
********************************************************************************

display as text _newline "========================================================"
display as text "  SAMMENLIGNING AV ESTIMATER — HAUGESUND Q1 OG Q2 2023"
display as text "========================================================"

/* Tabell: alle estimater side om side */
list Gruppe Kvt l_H l_est_M1_H l_est_M2_H l_est_M3 l_tot_M1 l_tot_M2 l_tot_M3 ///
    if mangler_liter_H == 1, ///
    noobs sepby(Gruppe)                                                          ///
    subvarname

/* MAPE for valideringskvartalene (M2 vs M3) */
display as text _newline "=== MAPE (M2 vs M3) — validering Q3/Q4 2023 ==="
tabstat val_feil_M2_H val_feil_M3 ///
    if inlist(Kvt, tq(2023q3), tq(2023q4)) & l_H > 0, ///
    stat(mean min max) by(Gruppe)


/* -- Figur 1: Valideringsfeil M2 og M3 per Gruppe og kvartal -- */
graph bar val_feil_M2_H val_feil_M3                                              ///
    if inlist(Kvt, tq(2023q3), tq(2023q4)) & l_H > 0,                           ///
    over(Gruppe) over(Kvt)                                                       ///
    bar(1, color(teal%70))                                                       ///
    bar(2, color(cranberry%70))                                                  ///
    legend(label(1 "M2: Regresjon") label(2 "M3: Proxy Ålesund"))               ///
    title("Valideringsfeil Q3/Q4 2023 (%)")                                     ///
    subtitle("Modell estimert på 2024-data, predikert for 2023")                ///
    ytitle("Prosentvis avvik (positiv = overestimert)") yline(0, lcolor(gs8))


/* -- Figur 2: Estimater for Q1 2023 per Gruppe (sammenligning) -- */
preserve
    keep if mangler_liter_H == 1 & Kvt == tq(2023q1)
    keep Gruppe l_est_M1_H l_est_M2_H l_est_M3

    graph bar l_est_M1_H l_est_M2_H l_est_M3,                                   ///
        over(Gruppe, label(angle(30)))                                           ///
        bar(1, color(navy%70))                                                   ///
        bar(2, color(teal%70))                                                   ///
        bar(3, color(cranberry%70))                                              ///
        legend(label(1 "M1: Sesongfaktor")                                      ///
               label(2 "M2: Regresjon")                                         ///
               label(3 "M3: Proxy Ålesund"))                                    ///
        title("Estimert liter Haugesund Q1 2023")                               ///
        ytitle("Liter")
restore


/* -- Figur 3: Tidsserie Haugesund med alle estimater -- */
/* Forbered en lang serie med faktiske og estimerte verdier */
gen l_fakt = l_H if l_H > 0

twoway                                                                           ///
    (connected l_fakt   Kvt, msymbol(circle) mcolor(gs6) lcolor(gs6)            ///
        legend(label(1 "Faktisk liter")))                                        ///
    (scatter   l_tot_M1 Kvt if mangler_liter_H == 1,                            ///
        msymbol(square) mcolor(navy%80)                                          ///
        legend(label(2 "M1: Sesongfaktor")))                                    ///
    (scatter   l_tot_M2 Kvt if mangler_liter_H == 1,                            ///
        msymbol(diamond) mcolor(teal%80)                                         ///
        legend(label(3 "M2: Regresjon")))                                       ///
    (scatter   l_tot_M3 Kvt if mangler_liter_H == 1,                            ///
        msymbol(triangle) mcolor(cranberry%80)                                  ///
        legend(label(4 "M3: Proxy Ålesund"))),                                  ///
    by(Gruppe, yrescale title("Haugesund: faktisk og estimert omsetning") note("")) ///
    xlabel(, angle(45)) ylabel(#3)                                               ///
    xline(`=tq(2023q2)', lpattern(dash) lcolor(gs10))


********************************************************************************
** STEG 8: Beregn valideringsmål sammenfattet per metode
********************************************************************************

display as text _newline "=== Sammendrag: gjennomsnittlig absolutt prosentfeil (MAPE) ==="

gen ape_M2 = abs(val_feil_M2_H)
gen ape_M3 = abs(val_feil_M3)

tabstat ape_M2 ape_M3 ///
    if inlist(Kvt, tq(2023q3), tq(2023q4)) & l_H > 0, ///
    stat(mean) col(stat)
	
	/*
	. tabstat ape_M2 ape_M3 ///
	>     if inlist(Kvt, tq(2023q3), tq(2023q4)) & l_H > 0, ///
	>     stat(mean) col(stat)

		Variable |      Mean
	-------------+----------
		  ape_M2 |  17.70607
		  ape_M3 |  14.62932
	------------------------

	*/

display as text "(Lavere = bedre prediksjon av faktiske Q3/Q4 2023-tall)"
display as text ""
display as text "OBS: M1 kan ikke valideres på samme måte siden den er"
display as text "     basert direkte på l/antall-forholdet og ikke predikerer"
display as text "     fremover i tid."

********************************************************************************
** Konklusjon:
**
** Benytter mmetode 1, sesongfaktor for q1 og deler av q2 i 2023 for Haugesund.
** Fordi: mindre avvik ved estimering for q3 og q4, ser visuelt korrekt ut, 
** mindre kompliserte metoder siden vi har få datapunkter, enklere å forklare.

********************************************************************************

**** Filen slutter her.



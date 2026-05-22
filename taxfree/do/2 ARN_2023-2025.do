*******************************************************************************
*	Fila er opprettet/oppdatert 2025
*	Fila klargjør ARN-data for 2023, 2024 og 2025.
*	Oppdatert versjon av ARN_2022-2025.do
*	Endringer fra forrige versjon:
*		- 2025-leveransen er aktivert (ikke lenger utkommentert)
*		- Samleseksjonen inkluderer nå ARN_2025.dta
*	Fila er opprettet av Bente Øvrebø, Hdir.
*******************************************************************************


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
** STEG 2: Legger til estimater for Q1 og Q2 for Haugesund siden vi kun har antall
********************************************************************************
merge m:m Lufthavn Kvt Gruppe antall_leveranse using "temp_M1_referanse.dta", keep(master match) nogenerate
sort Lufthavn Kvt 
drop k_nr faktor_vektet

/* Legger inn estimater i liter og sletter variabler jeg ikke trenger*/

replace l = l_est_M1 if antall_leveranse == 1
drop antall_leveranse l_est_M1


collapse (sum) l enhet_antall, by(Lufthavn Utsalg Gruppe Kvt)


rename l Antall
label var Antall "Antall i liter"
label var enhet_antall "Antall i enhet"
sort Lufthavn Utsalg Gruppe Kvt
order Lufthavn Utsalg Kvt Gruppe Antall



*******************************************************************************
** STEG 3: Visuell sjekk
*		Se på figurer av omsetning fra ARN-flyplasser
*		
*		Oppsummering: Ser ok ut
***************************************************************************
/
/* Varegruppe by flyplass */


* Brennevin
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Brennevin", ///
		by(Lufthavn, yrescale) ///
		title("Brennevin") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))

	
	* Hetvin
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Hetvin", ///
		by(Lufthavn, yrescale) ///
		title("Hetvin") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	
	
	
	* Vin
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Vin", ///
		by(Lufthavn, yrescale) ///
		yscale(range(0 .)) ///
		title("Vin") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	


	* Øl
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Øl", ///
		by(Lufthavn, yrescale) ///
		title("Øl") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	


drop enhet_antall

sort Lufthavn Utsalg Gruppe Kvt
save "ARN_2023-2025.dta", replace

** Fila er klar for å kobles med TRN.

** Filen slutter her. 


/*
********************************************************************************
** EXTRA: Koble alle ARN-år (2010-2025) til én fil
** OBS: Forutsetter at ARN2010-2021.dta og ARN_2022.dta allerede er laget
**      av tidligere do-filer (ARN_total.do). Kun 2023-2025 er inkludert
**      i denne filen.
********************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"

use "ARN2010-2014.dta", clear
drop if Kvt >= yq(2014,1)
append using "ARN2014.dta"
append using "ARN2015.dta"
append using "ARN2016.dta"
append using "Torp2017.dta"
append using "Torp2018.dta"
append using "ARN2019.dta"
append using "ARN2020-2021.dta"
drop if Kvt >= yq(2022,1)
append using "ARN_2022.dta"
append using "ARN_2023-2025.dta"
drop enhet_antall

compress

/* Kun alkohol videre */
keep if inlist(Gruppe, "Øl", "Vin", "Hetvin", "Brennevin")

	* Torp
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Lufthavn == "Torp", ///
		by(Gruppe, yrescale) ///
		title("Torp") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	

	

sort Lufthavn Utsalg Gruppe Kvt
save "ARN2010-2025.dta", replace





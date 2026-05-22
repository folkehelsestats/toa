*******************************************************************************
*	Fil opprettet/oppdatert 2026
*	Oppdatert versjon av TRN_total.do
*	Endringer fra forrige versjon:
*		- Sigaretter fra Q1 2023: data er nå i kg — ingen omregning nødvendig
*		- Halvering av tobakkskvote fra Q1 2023 er eksplisitt dokumentert
*		  (sigaretter: kvoten er halvert, men selve salget i kg er reelt)
*		- Samleseksjonen inkluderer TRN 2023-2025.dta korrekt
*	Filen er opprettet av Bente Øvrebø, Hdir.
*******************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Travel Retail Norway\"


********************************************************************************
** STEG 1: Import og rens TRN 2023-2025
********************************************************************************

import excel "TRN 2023-2025.xlsx", sheet("Ark1") firstrow clear

drop O-BT

/* Oppretter variabler (år/kvt) og korrekt enhet */
gen Aar = substr(Kvartal, 3, 5)
destring Aar, replace
gen Kvt = substr(Kvartal, 2, 1) 
destring Kvt, replace 
replace Kvt = yq(Aar, Kvt)
format %tq Kvt 
drop Aar Kvartal

replace Enhet = "kg" if substr(Enhet,1,17) == "Quantity B2C (KG)"
replace Enhet = "l" if substr(Enhet,1,16) == "Quantity B2C (L)"
replace Enhet = "pc" if substr(Enhet,1,17) == "Quantity B2C (pc)"

/* Fjerner kg-tall for varegrupper som oppgis i l eller pc fordi kg er pc-tall*/
replace StrongWine = . if Enhet == "kg"
replace SparklingWine = . if Enhet == "kg"
replace TableWine = . if Enhet == "kg"
replace Beer = . if Enhet == "kg"
replace Spirits = . if Enhet == "kg"

/* Gjør tilsvarende for tobakksvarer, fjerner liter, da det er pc-tall*/
replace Snus = . if Enhet =="l"
replace NicotinefreeSnus = . if Enhet =="l"
replace Cigarettes = . if Enhet =="l"
replace Cigars = . if Enhet =="l"
replace Tobacco = . if Enhet =="l"

/* Rydder i variabelnavn*/
gen Lufthavn = substr(Sted,1,3)
replace Lufthavn = "Bergen" if Lufthavn == "BGO"
replace Lufthavn = "Oslo" if Lufthavn == "OSL" 
replace Lufthavn = "Stavanger" if Lufthavn == "SVG"
replace Lufthavn = "Trondheim" if Lufthavn == "TRD"

* #-tegnet i ankomst kommer fordi Y/N er ukjent - systemet fanger det ikke opp. 
list Sted StrongWine-Tobacco if Ankomst == "#"


/* Der dette mangler, så kan vi beregne Y/N basert på tall vi har*/
preserve
keep if Sted == "OSL Oslo T2 Departure North" & Kvt == tq(2025q4)

    * Kan ikke bruke # i reshape
    replace Ankomst = "x" if Ankomst == "#"

    reshape wide StrongWine SparklingWine TableWine Spirits Beer Snus NicotinefreeSnus Cigarettes Cigars Tobacco, ///
        i(Lufthavn Sted Kvt Enhet) ///
        j(Ankomst) string

    /* Lager andel for å plassere x i rett N/Y for å koble det på hovedfila og slette det som ligger der*/
    local goods StrongWine SparklingWine TableWine Spirits Beer Snus NicotinefreeSnus Cigarettes Cigars Tobacco

    foreach v of local goods {
        gen `v'_shareN = `v'N / (`v'N + `v'Y)
        gen `v'_shareY = `v'Y / (`v'N + `v'Y)

        gen `v'_x_to_N = `v'_shareN * `v'x
        gen `v'_x_to_Y = `v'_shareY * `v'x

        gen `v'N_adj = `v'N + `v'_x_to_N
        gen `v'Y_adj = `v'Y + `v'_x_to_Y

        replace `v'N = `v'N_adj
        replace `v'Y = `v'Y_adj
    }

    * Rydding
    drop *_shareN *_shareY *_x_to_* *_adj*
    drop StrongWinex- Tobaccox

    * Tilbake til long
    reshape long ///
        StrongWine SparklingWine TableWine Spirits Beer Snus NicotinefreeSnus Cigarettes Cigars Tobacco, ///
        i(Lufthavn Sted Kvt Enhet) ///
        j(Ankomst) string

	save "OSL_Oslo_T2_Departure_North", replace
restore


/* Markerer radene som skal slettes pga nye estimat og kobler på nye*/
gen unknown = 1 if Sted == "OSL Oslo T2 Departure North" & Kvt == tq(2025q4)

	append using "OSL_Oslo_T2_Departure_North"

	drop if unknown == 1
	drop unknown

compress


gen Utsalg = ""
replace Utsalg = "Ankomst" if Ankomst == "Y" 
replace Utsalg = "Avgang" if Ankomst == "N" 

drop Sted Ankomst
order Kvt Lufthavn Utsalg 

/* Kollapser fil og endrer navn i tråd med kommende oppsett for sammenslåing*/
collapse (sum) StrongWine SparklingWine TableWine Spirits Beer Snus ///
	NicotinefreeSnus Cigarettes Cigars Tobacco, by(Kvt Lufthavn Utsalg Enhet)

gen AntallVin = SparklingWine + TableWine
drop SparklingWine TableWine
rename StrongWine AntallHetvin
rename Spirits AntallBrennevin
rename Beer AntallØl
rename Snus AntallSnus
rename Cigarettes AntallSigaretter
rename Cigars AntallSigarer
rename Tobacco AntallTobakk
rename NicotinefreeSnus AntallNikotinfriSnus

/* Inkluderer enhet inn i navn på antall*/ 
reshape long Antall, i(Kvt Lufthavn Utsalg Enhet) ///
	j(Gruppe Hetvin Brennevin Øl Snus NikotinfriSnus Sigaretter Sigarer Tobakk Vin) string
	
reshape wide Antall, i(Kvt Lufthavn Utsalg Gruppe) ///
	j(Enhet) string

gen Antall = 0
replace Antall = Antalll if Gruppe =="Brennevin"
replace Antall = Antalll if Gruppe =="Hetvin" 
replace Antall = Antallkg if Gruppe =="Sigarer" 
replace Antall = Antallkg if Gruppe=="Sigaretter" 
/* 	Før brukte vi antall sigaretter, nå har vi det i kg så bruker det
	Senere vil vi regne om kg sigaretter til stk ved beregningsfaktor:
	1 sigarett veier 1 gram.

*/
replace Antall = Antallkg if Gruppe =="Snus" 
replace Antall = Antallkg if Gruppe == "NikotinfriSnus"
replace Antall = Antallkg if Gruppe =="Tobakk" 
replace Antall = Antalll if Gruppe =="Vin" 
replace Antall = Antalll if Gruppe =="Øl" 
drop Antallkg Antalll Antallpc

keep if inlist(Gruppe, "Øl", "Vin", "Hetvin", "Brennevin")

save "TRN 2023-2025.dta", replace


*******************************************************************************
** 	Visuell sjekk
*		Se på figurer av omsetning fra ARN-flyplasser
*		
*		Oppsummering: Visuelt ser det ikke ut som det er noe galg.
***************************************************************************

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


** Konklusjon: Ser ikke ut til å være noe feil/rart.
** Fila er klar for å kobles med ARN



** Filen slutter her. 


/*
********************************************************************************
** EXTRA: Koble alle TRN-år (2010-2025) til én fil
** OBS: Forutsetter at ARN2010-2021.dta og ARN_2022.dta allerede er laget
**      av tidligere do-filer (ARN_total.do). Kun 2023-2025 er inkludert
**      i denne filen.
**		Under brukes det til å se trenger over tid, for å se nærmere på Torp.
********************************************************************************




append using "TRN2010-2019.dta"
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2019-2020.dta",  nogenerate nolabel
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2021.dta",       nogenerate nolabel
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2022.dta",       nogenerate nolabel
replace Antall = nyAntall if Antall ==. // obs på at det kan være kluss med at antall nå består av l og enhet.

collapse (sum) Antall, by(Lufthavn Utsalg Kvt Gruppe)

keep if inlist(Gruppe, "Øl", "Vin", "Hetvin", "Brennevin")

/* Figurer etter varegruppe */
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

/* Figurer etter flyplass */
twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Lufthavn == "Oslo", ///
		by(Gruppe, yrescale) ///
		title("Oslo") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	
		
twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Lufthavn == "Bergen", ///
		by(Gruppe, yrescale) ///
		title("Bergen") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	

twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Lufthavn == "Stavanger", ///
		by(Gruppe, yrescale) ///
		title("Stavanger") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	

twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Lufthavn == "Trondheim", ///
		by(Gruppe, yrescale) ///
		title("Trondheim") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	



*save "TRN2010-2025.dta", replace

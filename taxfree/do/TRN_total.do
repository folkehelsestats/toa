*******************************************************************************

	** Fil opprettet for å koble TRN 2024 på tidligere år.
	** Filen tar utgangspunkt i do-fil fra FHI.
	** Denne filen er opprettet 5/8-2025 av Bente Øvrebø, Hdir.
	** Filen er ikke ferdig.
	
/* OBS på at det har vært kvoteendring på tobakk i 2023 (halvvering), dette er det ikke justert for 	foreløpig*/

*******************************************************************************

clear all

/* 	STATA do-fil som beskriver hva som blir gjort for å generere 
	kvartalsvise Tax-Free salgstall for TRN 						 */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Travel Retail Norway\"

/*
/* Hent in data fa 2011 til 2014 */
import excel "TRN 2011-2014.xlsx", sheet("Ark1") firstrow clear
drop if Kvt == .

reshape long Bergen Kristiansand Oslo Stavanger Trondheim, ///
	i(Aar Kvt Vare) j(Utsalg Ankomst Avgang) string
label var Utsalg "Utsalg"

foreach var of varlist Bergen-Trondheim {
	rename `var' Antall`var'
}

reshape long Antall, i(Aar Kvt Vare Utsalg) ///
	j(Flyplass Bergen Kristiansand Oslo Stavanger Trondheim) string

/* Antall kartonger nå antall sigaretter */
replace Antall = Antall*200 if Vare=="Cigarettes"
drop Enhet

gen Gruppe = ""
replace Gruppe="Øl" if Vare=="Beer"
replace Gruppe="Vin" if Vare=="Champagne"
replace Gruppe="Vin" if Vare=="Sparkling Wine"
replace Gruppe="Vin" if Vare=="Table Wine"
replace Gruppe="Hetvin" if Vare=="Strong Wine"
replace Gruppe="Brennevin" if Vare=="Spirits"
replace Gruppe="Sigaretter" if Vare=="Cigarettes"
replace Gruppe="Sigarer" if Vare=="Cigars"
replace Gruppe="Snus" if Vare=="Snus"
replace Gruppe="Tobakk" if Vare=="Tobacco"

label var Gruppe "Gruppe"
drop Vare 

replace Kvt = yq(Aar, Kvt)
drop Aar
format %tq Kvt 
label var Kvt "Kvartal"

collapse (sum) Antall, by(Kvt Flyplass Utsalg Gruppe)
label var Antall "Antall" 
rename Flyplass Lufthavn 
label var Lufthavn "Lufthavn"

save "TRN2011-2014.dta", replace


/* Hent in data fa 2010 */
import excel "TRN 2010 mnd.xlsx", sheet("Ark1") firstrow clear
	
reshape long Bergen Kristiansand Oslo Stavanger Trondheim, ///
	i(Mnd Gruppe Vare) j(Utsalg Ankomst Avgang) string
label var Utsalg "Utsalg"

foreach var of varlist Bergen-Trondheim {
	rename `var' Antall`var'
}

reshape long Antall, i(Mnd Gruppe Vare Utsalg) ///
	j(Flyplass Bergen Kristiansand Oslo Stavanger Trondheim) string
drop Enhet

replace Mnd = ym(Aar, Mnd)
drop Aar
format %tmMonth_CCYY Mnd
label var Mnd "Måned"

gen Kvt = qofd(dofm(Mnd))
format %tq Kvt 
label var Kvt "Kvartal"

replace Gruppe="Øl" if Vare=="Beer"
replace Gruppe="Vin" if Vare=="Champagne"
replace Gruppe="Vin" if Vare=="Sparkling wine"
replace Gruppe="Vin" if Vare=="Wine"
replace Gruppe="Hetvin" if Vare=="Vermouth, Sherry, Port wine"
replace Gruppe="Brennevin" if Vare=="Bitters / Liqueurs"
replace Gruppe="Brennevin" if Vare=="Brandy"
replace Gruppe="Brennevin" if Vare=="Cognac/Armagnac"
replace Gruppe="Brennevin" if Vare=="Gin"
replace Gruppe="Brennevin" if Vare=="Rum"
replace Gruppe="Brennevin" if Vare=="Schnapps, Miscellaneous, Fruit brandies"
replace Gruppe="Brennevin" if Vare=="Vodka"
replace Gruppe="Brennevin" if Vare=="Whisk(e)y"
replace Gruppe="Sigaretter" if Vare=="Cigarettes DutyFree(DF)"
replace Gruppe="Sigarer" if Vare=="Cigars/Small cigars DF"
replace Gruppe="SnusTobakk" if Vare=="Tobacco DF"
label var Gruppe "Gruppe"

drop if Vare=="Soft drinks & Refreshments"
drop Vare

collapse (sum) Antall, by(Kvt Flyplass Utsalg Gruppe)
label var Antall "Antall" 

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

save "TRN2010.dta", replace
*/
/* Hent inn tall for 2015- 2019. Nytt format */
import excel "TRN 2015-2019.xlsx", sheet("Sheet1") firstrow clear

gen Kvt = yq(Aar,Kvartal)
format %tq Kvt 
label var Kvt "Kvartal"
drop Aar Kvartal F 

gen Preorder = ""
replace Preorder = "Preorder" if strpos(E, "preorder") > 0
label var Preorder "Preorder"
drop E

rename RetailLokation Lufthavn
rename ArrivalKennzeichen Utsalg
label var Utsalg "Utsalg" 
label var Lufthavn "Lufthavn"

replace Utsalg = "Ankomst" if Utsalg == "Arrival" 
replace Utsalg = "Avgang" if Utsalg == "Departure" 

replace Lufthavn = "Bergen" if Lufthavn == "BGO Bergen DFS"
replace Lufthavn = "Bergen" if Lufthavn == "BGO Bergen DFS Arrival"
replace Lufthavn = "Bergen" if Lufthavn == "BGO Bergen DFS Arrival T3"
replace Lufthavn = "Kristiansand" if Lufthavn == "KRS Kristiansand DFS"
replace Lufthavn = "Oslo" if Lufthavn == "OSL Oslo DFS Arrival"
replace Lufthavn = "Oslo" if Lufthavn == "OSL Oslo DFS Departure"
replace Lufthavn = "Oslo" if Lufthavn == "OSL Oslo T2 Departure North"
replace Lufthavn = "Oslo" if Lufthavn == "OSL Satellite"
replace Lufthavn = "Stavanger" if Lufthavn == "SVG Stavanger DFS"
replace Lufthavn = "Stavanger" if Lufthavn == "SVG Stavanger DFS Arrival"
replace Lufthavn = "Trondheim" if Lufthavn == "TRD Trondheim DFS"
compress

collapse (sum) StrongWine SparklingWine TableWine Spirits Beer ///
	Snus Cigarettes Cigars Tobacco, by(Lufthavn Utsalg Kvt)

gen AntallVin = SparklingWine + TableWine
drop SparklingWine TableWine
rename StrongWine AntallHetvin
rename Spirits AntallBrennevin
rename Beer AntallØl
rename Snus AntallSnus
rename Cigarettes AntallSigaretter
rename Cigars AntallSigarer
rename Tobacco AntallTobakk

reshape long Antall, i(Kvt Lufthavn Utsalg) ///
	j(Gruppe Hetvin Brennevin Øl Snus Sigaretter Sigarer Tobakk Vin) string
label var Gruppe "Gruppe"
label var Antall "Antall"	
	
/* Antall kartonger nå antall sigaretter */
replace Antall = Antall*200 if Gruppe=="Sigaretter"

append using "TRN2011-2014.dta"
append using "TRN2010.dta"
order Lufthavn Utsalg Gruppe Kvt 
*save "TRN2010-2019.dta", replace  
*use "TRN2010-2019.dta"

sort Lufthavn Utsalg Gruppe Kvt
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2019-2020.dta", nogenerate nolabel
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2021.dta", nogenerat nolabel
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2022-2023.dta", nogenerat nolabel
merge m:m Lufthavn Utsalg Gruppe Kvt using "TRN 2024.dta", nogenerat nolabel

/* FHI har gjort vurderingene under */
 
/* Vin er godkjent */
/*
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Vin", by(Lufthavn, yrescale)
*/
/* Graf over tid for vin */
	*Byttekvoter
	display tq(2014q1) // (innført)
	display tq(2022q1) // (Avviklet)

	twoway ///
    (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
    (line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
    (line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
    (line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
    if Gruppe=="Vin", ///
    by(Lufthavn, yrescale) ///
    title("Vin") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(216 248, lpattern(dash) lcolor(gs10))

	 
/* Brennevin er for lav etter 2Q2019 */

/*twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Brennevin", by(Lufthavn, yrescale)
	*/
	
twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
     if Gruppe=="Brennevin", ///
	    by(Lufthavn, yrescale) ///
    title("Brennevin") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall"))
	

/* Hetvin er altfor høy etter 2Q2019 */
/*
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Hetvin", by(Lufthavn, yrescale)
	 */

twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Hetvin", ///
	by(Lufthavn, yrescale) ///
    title("Hetvin") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall"))


/* Øl - lav etter pandemi - kan skyldes fjerning av "bytte-kvote"?*/
/*twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Øl", by(Lufthavn, yrescale)
	 */

display tq(2014q1)
display tq(2022q1)

twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Øl", ///
	by(Lufthavn, yrescale) ///
    title("Øl") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(216 248, lpattern(dash) lcolor(gs10))


/* Sigaretter - kvoteendringen i 2023 synes ikke */
/*
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Sigaretter", by(Lufthavn, yrescale)
*/

	 display tq(2023q1)
	 
twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Sigaretter", ///
	by(Lufthavn, yrescale) ///
    title("Sigaretter") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	
/*Forslag til å gange med 100 sigaretter (halvere antall etter q12023). Første foreløpig kun ankomst siden det selges ved avgang?*/

	replace nyAntall = nyAntall*0.5 if Gruppe=="Sigaretter" & Utsalg== "Ankomst" & Kvt >= yq(2023,1)
	
	twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Sigaretter", ///
	by(Lufthavn, yrescale) ///
    title("Sigaretter") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	
	

/* Snus er for lav (og på null etter 2023 i visse kvartaler) og feil i snus i Oslo 2023q2? */	 
/*
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Snus", by(Lufthavn, yrescale)
	 */
	 display tq(2023q1)
	 
twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Snus", ///
    title("Snus") ///
	by(Lufthavn, yrescale) ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))

/* Kun Snus i Oslo for å se 0-tallene i Q42022 + q3 og q4 i 2023
	twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Snus" & Lufthavn == "Oslo", ///
	 title("Snus") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
*/

/*tobakk er for høy etter 2019q2*/
/*
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Gruppe=="Tobakk", by(Lufthavn, yrescale)
	 */
	 
	 
twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "Tobakk", ///
    title("Tobakk") ///
	by(Lufthavn, yrescale) ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	


	/*Kun tobakk i Oslo for å se 0-tallene fra og med q3 2023
		
		twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
		if Gruppe == "Tobakk" & Lufthavn == "Oslo", ///
		 title("Tobakk") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
		xline(252 , lpattern(dash) lcolor(gs10))
	*/
		
/* Sigarer er feilregistrert */
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
   	if Gruppe == "Sigarer", ///
    title("Sigarer") ///
	by(Lufthavn, yrescale) ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))


/* Tester å kun benytte "ny antall", da jeg tror det i større grad er i kg og mer sammenlignbart.
twoway ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
   	if Gruppe == "Sigarer", ///
    title("Sigarer") ///
	by(Lufthavn, yrescale) ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - nyAntall" 2 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	
* Og kun i Oslo:
twoway ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
   	if Gruppe == "Sigarer" & Lufthavn == "Oslo", ///
    title("Sigarer") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - nyAntall" 2 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	*/
	
	
	
/* Datakvaliteten er bedre før / endret fra 2Q2019, Snus/Tobakk, og Brennevin/Hetvin må 
   deles opp på nytt etter 2Q2019 */
   /*
gen snustobakk = .
replace snustobakk = nyAntall if Gruppe == "Snus" & Kvt >= yq(2019,3)
replace snustobakk = nyAntall if Gruppe == "Tobakk" & Kvt >= yq(2019,3)

gen snustob_y = .
replace snustob_y = 1 if Gruppe == "Snus"
replace snustob_y = 1 if Gruppe == "Tobakk"

twoway ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if snustob_y == 1, ///
	by(Lufthavn, yrescale) ///
    title("Snus&tobakk") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))

*/

  /* MÅ SJEKKE OM DETTE GJELDER ALLE ÅR ETTER2019*/
replace Antall = nyAntall if Antall ==.
replace Gruppe = "SnusTobakk" if Gruppe == "Snus" & Kvt >= yq(2019,3)
replace Gruppe = "SnusTobakk" if Gruppe == "Tobakk" & Kvt >= yq(2019,3)
replace Gruppe = "BrennevinHetvin" if Gruppe == "Hetvin" & Kvt >= yq(2019,3)
replace Gruppe = "BrennevinHetvin" if Gruppe == "Brennevin" & Kvt >= yq(2019,3)
drop nyAntall

collapse (sum) Antall, by(Lufthavn Utsalg Kvt Gruppe)

save "TRN2010-2024.dta", replace  

/* Kladd for å se på grafer etter sammenslåing av snus og tobakk og brennevin og hetvin.
replace nyAntall = . if Kvt < yq(2019,3)
replace Antall = . if Kvt >= yq(2019,3)

twoway ///
 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
	(line nyAntall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(green)) ///
	(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
	(line nyAntall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(orange)) ///
	if Gruppe == "SnusTobakk", ///
    title("Snus & Tobakk") ///
	by(Lufthavn, yrescale) ///
    xlabel(, angle(45)) ///
  legend(order(1 "Ankomst - Antall" 2 "Ankomst - nyAntall" 3 "Avgang - Antall" 4 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))

twoway ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
   	if Gruppe == "SnusTobakk" & Lufthavn == "Oslo", ///
    title("Snus og tobakk") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - nyAntall" 2 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	
	
	
twoway ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
   	if Gruppe == "BrennevinHetvin" & Lufthavn == "Oslo", ///
    title("Brennevin og hetvin") ///
    xlabel(, angle(45)) ///
    legend(order(1 "Ankomst - nyAntall" 2 "Avgang - nyAntall")) ///
	xline(252 , lpattern(dash) lcolor(gs10))
	*/
	
* Filen slutter her

/* Kode bruk for å se på omsetning av sigaretter

keep if Gruppe == "Sigaretter"
*drop if Utsalg == "Avgang"
collapse (sum) Antall nyAntall, by(Lufthavn Utsalg Kvt)
twoway (line Antall Kvt if Utsalg=="Ankomst") ///
	(line nyAntall Kvt if Utsalg=="Ankomst") ///
	(line Antall Kvt if Utsalg=="Avgang") ///
	(line nyAntall Kvt if Utsalg=="Avgang") /// 
     if Lufthavn == "Oslo"
	 
*/
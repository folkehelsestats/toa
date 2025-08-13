********************************************************************************
	* Fila bygger videre på FHIs fil om passasjerer hentet fra ssb.no
	* Legger til for 2024, samt 2023-data for Kristiansand i Excel-fil SSB2021-2023
	


********************************************************************************


clear all

/* 	STATA do-fil som henter inn passajertall fra SSB */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Passasjerer\"

import excel "Passasjerer SSB 2010 - 2022.xlsx", sheet("Ark1") firstrow clear
* Obs. 2022 har kun tall til og med Q2.

gen Kvt = yq(År, Kvartal)
drop År Kvartal
format %tq Kvt 
label var Kvt "Kvartal"

drop if Kvt >= yq(2021,1)

/* Kun terminalpassasjerer ved ankomst og avgang */
replace AvgangRute = AvgangRute - TransitRute 
replace AvgangCharter = AvgangCharter -TransitCharter 
replace AnkomstRute = AnkomstRute -TransitRute 
replace AnkomstCharter = AnkomstCharter -TransitCharter 

/* Ikke tell transfer dobbelt. Ikke tell transit */
gen TotaltRute = AvgangRute + AnkomstRute - BytteRute
gen TotaltCharter = AvgangCharter + AnkomstCharter - BytteCharter
drop TransitRute TransitCharter BytteRute BytteCharter
compress

reshape long Ankomst Avgang Totalt, i(Kvt Flyplass) j(Type Rute Charter) string
rename Ankomst AntallAnkomst
rename Avgang AntallAvgang
rename Totalt AntallTotalt

reshape long Antall, i(Kvt Flyplass Type) j(Utsalg Ankomst Avgang Totalt) string
reshape wide Antall, i(Kvt Flyplass Utsalg) j(Type Rute Charter) string
gen AntallTotalt = AntallRute + AntallCharter
label var Utsalg "Utsalg"

replace Flyplass = "Bergen" if Flyplass == "Bergen Flesland"
replace Flyplass = "Fagernes" if Flyplass == "Fagernes Leirin"
replace Flyplass = "Evenes" if Flyplass == "Harstad/Narvik Evenes"
replace Flyplass = "Haugesund" if Flyplass == "Haugesund Karmøy"
replace Flyplass = "Kristiansand" if Flyplass == "Kristiansand Kjevik"
replace Flyplass = "Kristiansund" if Flyplass == "Kristiansund Kvernberget"
replace Flyplass = "Lakselv" if Flyplass == "Lakselv Banak"
replace Flyplass = "Molde" if Flyplass == "Molde Årø"
replace Flyplass = "Rygge" if Flyplass == "Moss Rygge"
replace Flyplass = "Oslo" if Flyplass == "Oslo Gardermoen"
replace Flyplass = "Torp" if Flyplass == "Sandefjord Torp"
replace Flyplass = "Tromsø" if Flyplass == "Tromsø Langnes"
replace Flyplass = "Stavanger" if Flyplass == "Stavanger Sola"
replace Flyplass = "Trondheim" if Flyplass == "Trondheim Værnes"
replace Flyplass = "Ålesund" if Flyplass == "Ålesund Vigra"
tabulate Flyplass
compress

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

drop if Lufthavn=="Lakselv" & Kvt >= yq(2014,1)
drop if Lufthavn=="Fagernes" & Kvt >= yq(2016,1)
drop if Lufthavn=="Rygge" & Kvt >= yq(2017,1)



save "Passasjerer SSB 2010 -2020.dta", replace

/* Hent in månedstall fra 2021-2023 */ 

import excel "Passasjerer SSB 2021 - 2024.xlsx", sheet("Ark1") firstrow clear
drop if År == 2024 // sletter 2024 og kjører egen kode da alle flyplassnavn ikke er like

gen Mnd = ym(År, Måned)
gen Kvt = qofd(dofm(Mnd))
drop Mnd År Måned
format %tq Kvt 
label var Kvt "Kvartal"

/* Kun terminalpassasjerer ved ankomst og avgang */
replace AvgangRute = AvgangRute - TransitRute 
replace AvgangCharter = AvgangCharter -TransitCharter 
replace AnkomstRute = AnkomstRute -TransitRute 
replace AnkomstCharter = AnkomstCharter -TransitCharter 

/* Ikke tell transfer dobbelt. Ikke tell transit */
gen TotaltRute = AvgangRute + AnkomstRute - BytteRute
gen TotaltCharter = AvgangCharter + AnkomstCharter - BytteCharter
drop TransitRute TransitCharter BytteRute BytteCharter
compress

collapse (sum) AnkomstRute AnkomstCharter AvgangRute AvgangCharter ///
	TotaltRute TotaltCharter, by(Flyplass Kvt)

reshape long Ankomst Avgang Totalt, i(Kvt Flyplass) j(Type Rute Charter) string
rename Ankomst AntallAnkomst
rename Avgang AntallAvgang
rename Totalt AntallTotalt

reshape long Antall, i(Kvt Flyplass Type) j(Utsalg Ankomst Avgang Totalt) string
reshape wide Antall, i(Kvt Flyplass Utsalg) j(Type Rute Charter) string
gen AntallTotalt = AntallRute + AntallCharter
label var Utsalg "Utsalg"

replace Flyplass = "Bergen" if Flyplass == "Bergen Flesland"
replace Flyplass = "Fagernes" if Flyplass == "Fagernes Leirin"
replace Flyplass = "Evenes" if Flyplass == "Harstad/Narvik Evenes"
replace Flyplass = "Haugesund" if Flyplass == "Haugesund Karmøy"
replace Flyplass = "Kristiansand" if Flyplass == "Kristiansand Kjevik"
replace Flyplass = "Kristiansund" if Flyplass == "Kristiansund Kvernberget"
replace Flyplass = "Lakselv" if Flyplass == "Lakselv Banak"
replace Flyplass = "Molde" if Flyplass == "Molde Årø"
replace Flyplass = "Rygge" if Flyplass == "Moss Rygge"
replace Flyplass = "Oslo" if Flyplass == "Oslo Gardermoen"
replace Flyplass = "Torp" if Flyplass == "Sandefjord Torp"
replace Flyplass = "Tromsø" if Flyplass == "Tromsø Langnes"
replace Flyplass = "Stavanger" if Flyplass == "Stavanger Sola"
replace Flyplass = "Trondheim" if Flyplass == "Trondheim Værnes"
replace Flyplass = "Ålesund" if Flyplass == "Ålesund Vigra"
tabulate Flyplass
compress

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

save "Passasjerer SSB 2021 -2023.dta", replace

/*2024 tall*/

import excel "Passasjerer SSB 2021 - 2024.xlsx", sheet("Ark1") firstrow clear
keep if År == 2024


gen Mnd = ym(År, Måned)
gen Kvt = qofd(dofm(Mnd))
drop Mnd År Måned
format %tq Kvt 
label var Kvt "Kvartal"

/* Kun terminalpassasjerer ved ankomst og avgang */
replace AvgangRute = AvgangRute - TransitRute 
replace AvgangCharter = AvgangCharter -TransitCharter 
replace AnkomstRute = AnkomstRute -TransitRute 
replace AnkomstCharter = AnkomstCharter -TransitCharter 

/* Ikke tell transfer dobbelt. Ikke tell transit */
gen TotaltRute = AvgangRute + AnkomstRute - BytteRute
gen TotaltCharter = AvgangCharter + AnkomstCharter - BytteCharter
drop TransitRute TransitCharter BytteRute BytteCharter
compress

collapse (sum) AnkomstRute AnkomstCharter AvgangRute AvgangCharter ///
	TotaltRute TotaltCharter, by(Flyplass Kvt)

reshape long Ankomst Avgang Totalt, i(Kvt Flyplass) j(Type Rute Charter) string
rename Ankomst AntallAnkomst
rename Avgang AntallAvgang
rename Totalt AntallTotalt

reshape long Antall, i(Kvt Flyplass Type) j(Utsalg Ankomst Avgang Totalt) string
reshape wide Antall, i(Kvt Flyplass Utsalg) j(Type Rute Charter) string
gen AntallTotalt = AntallRute + AntallCharter
label var Utsalg "Utsalg"

replace Flyplass = "Bergen" if Flyplass == "Bergen Flesland"
replace Flyplass = "Fagernes" if Flyplass == "Fagernes Leirin"
replace Flyplass = "Evenes" if Flyplass == "Harstad/Narvik Evenes"
replace Flyplass = "Haugesund" if Flyplass == "Haugesund Karmøy"
replace Flyplass = "Kristiansand" if Flyplass == "Kristiansand Kjevik"
replace Flyplass = "Kristiansund" if Flyplass == "Kristiansund Kvernberget"
replace Flyplass = "Lakselv" if Flyplass == "Lakselv Banak"
replace Flyplass = "Molde" if Flyplass == "Molde Årø"
replace Flyplass = "Rygge" if Flyplass == "Moss Rygge"
replace Flyplass = "Oslo" if Flyplass == "Oslo Gardermoen"
replace Flyplass = "Torp" if Flyplass == "Sandefjord Torp"
replace Flyplass = "Tromsø" if Flyplass == "Tromsø Langnes"
replace Flyplass = "Stavanger" if Flyplass == "Stavanger Sola"
replace Flyplass = "Trondheim" if Flyplass == "Trondheim Værnes"
replace Flyplass = "Ålesund" if Flyplass == "Ålesund Vigra"
tabulate Flyplass
compress

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

save "Passasjerer SSB 2024.dta", replace



/* Samle i en fil */
use "Passasjerer SSB 2010 -2022.dta", clear
drop if Kvt >= yq(2021,1)
append using "Passasjerer SSB 2021 -2023.dta"
append using "Passasjerer SSB 2024.dta"

sort Lufthavn Utsalg Kvt 

/* Ser på passasjer etter ankomst, avgang og totalt*/
twoway (line AntallTotalt Kvt) if Utsalg=="Ankomst", ///
	by(Lufthavn, yrescale)
	
	twoway (line AntallTotalt Kvt) if Utsalg=="Avgang", ///
	by(Lufthavn, yrescale)
	
	twoway (line AntallTotalt Kvt) if Utsalg=="Totalt", ///
	by(Lufthavn, yrescale)

	
/* Har det skjedd noe med Tromsø og Evenes? Plutselig dobbelt så mange på ankomst?*/
	twoway (line AntallTotalt Kvt) if Utsalg=="Ankomst" & Lufthavn=="Tromsø", ///
	by(Lufthavn, yrescale)
	
	twoway (line AntallTotalt Kvt) if Utsalg=="Ankomst" & Lufthavn=="Evenes", ///
	by(Lufthavn, yrescale)
	
	/* Søk på nett kan antyde at det har vært svært stor økning av turister sommer 2024 i Tromsø og Evenes
	https://travelnews.no/leiebil/hit-reiste-turistene-i-2024/	https://www.dn.no/reiseliv/nho-reiseliv/innovasjon-norge/knallsommer-for-reiselivet-sterk-vekst-i-nord/2-1-1682155
	*/
	
save "Passasjerer SSB 2010 -2024.dta", replace
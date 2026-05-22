********************************************************************************
	* Fila bygger videre på Daniels v/FHIs fil om passasjerer
	* Legger til for 2024, samt 2023-data for Kristiansand i Excel-fil SSB2021-2023
	


********************************************************************************


clear all

/* 	STATA do-fil som henter inn passajertall-utland fra SSB */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Passasjerer\"

import excel "Passasjerer SSB 2021 - 2025.xlsx", sheet("Ark1") firstrow clear

gen Mnd = ym(År, Måned)
gen Kvt = qofd(dofm(Mnd))
drop Mnd År Måned
format %tq Kvt 
label var Kvt "Kvartal"

drop if Kvt < yq(2023,1)

/* Kun terminalpassasjerer ved ankomst og avgang */
replace AvgangRute = AvgangRute - TransitRute 
replace AvgangCharter = AvgangCharter -TransitCharter 
replace AnkomstRute = AnkomstRute -TransitRute 
replace AnkomstCharter = AnkomstCharter -TransitCharter 

/* 	Vær oppmerksom på at transferpassasjerer blir telt enkelt i SSBs 
	statistikk. Transitpassasjerer teller ikke. */ 
	
/* Ikke tell transfer (bytte) dobbelt. Ikke tell transit */
gen TotaltRute = AvgangRute + AnkomstRute - BytteRute
gen TotaltCharter = AvgangCharter + AnkomstCharter - BytteCharter
drop TransitRute TransitCharter BytteRute BytteCharter
compress

collapse (sum) AnkomstRute AnkomstCharter AvgangRute AvgangCharter ///
	TotaltRute TotaltCharter, by(Flyplass Kvt)

/* Obs på at nå er ikke total-tall == ankomst + avgang, fordi de som 
bytter fly (transfer) er trukket fra over collapse. Dette fikses lenger ned. */

reshape long Ankomst Avgang Totalt, i(Kvt Flyplass) j(Type Rute Charter) string
rename Ankomst AntallAnkomst
rename Avgang AntallAvgang
rename Totalt AntallTotalt

reshape long Antall, i(Kvt Flyplass Type) j(Utsalg Ankomst Avgang Totalt) string
reshape wide Antall, i(Kvt Flyplass Utsalg) j(Type Rute Charter) string
gen AntallTotalt = AntallRute + AntallCharter
label var Utsalg "Utsalg"

replace Flyplass = "Bergen" if Flyplass == "Bergen Flesland"
replace Flyplass = "Evenes" if Flyplass == "Harstad/Narvik Evenes"
replace Flyplass = "Haugesund" if Flyplass == "Haugesund Karmøy"
replace Flyplass = "Kristiansand" if Flyplass == "Kristiansand Kjevik"
replace Flyplass = "Kristiansund" if Flyplass == "Kristiansund Kvernberget"
replace Flyplass = "Molde" if Flyplass == "Molde Årø"
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

sort Lufthavn Utsalg Kvt 

rename AntallTotalt AntallTotal

********************************************************************************
rename AntallTotal SSB
label var SSB "Passasjerer SSB"
drop Antall*
compress

replace Utsalg = "Total" if Utsalg == "Totalt"
reshape wide SSB, i(Kvt Lufthavn) j(Utsalg Avgang Ankomst Total) 


/* Lager variabel med ankomst-andel fra utland for hver flyplass per kvartal*/
gen K = quarter(dofq(Kvt))
bysort Lufthavn K: egen float Andel = mean(SSBAnkomst/SSBTotal)

sort Lufthavn Kvt

drop K Andel

save "Passasjerer SSB 2023-2025.dta", replace

********************************************************************************
/* Under er kode til figur*/ 
/*
twoway (line SSBTotal Kvt, sort cmissing(n)), ///
	   ylabel(#2) by(Lufthavn, yrescale note(""))
	   
	   
twoway ///
(line SSBAnkomst Kvt, lcolor(blue)) ///
(line SSBAvgang Kvt, lcolor(red)) ///
, by(Lufthavn, yrescale title("Totalt antall passasjerer per kvartal")) ///
  legend(order(1 "Ankomst" 2 "Avgang")) ///
  xtitle("Kvartal") ///
  ytitle("Antall passasjerer")

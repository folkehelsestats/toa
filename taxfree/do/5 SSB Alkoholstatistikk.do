
*******************************************************************************
*	Fil opprettet/oppdatert 2026
*	Laster inn SSB omsetningsstatistikk fra Excel-fil
* 	Tallene er hentet fra: https://www.ssb.no/statbank/table/04475
*		- Sluttfil heter SSB_Alkoholstatistikk.dta

*	Filen er opprettet av Bente Øvrebø, Hdir.
*******************************************************************************

/* 	STATA do-fil som henter inn SSBs omsetningstatistikk */ 
clear all
cd "O:\Prosjekt\Rusdata\Omsetning\SSB_originalfiler\Omsetningsstatistikk"

import excel "SSB Alkoholstatistikk.xlsx", sheet("Ark1") firstrow clear

gen Kvt = yq(År,Kvartal)
format %tq Kvt 
label var Kvt "Kvartal"
label variable Vareliter15 "Vareliter per innbygger 15 år og over"

drop År Kvartal Vareliter15
order Kvt Gruppe

/* Gjør det om til liter, så det blir likt nivå som taxfree*/
replace Vareliter = Vareliter*1000
replace Alkoholliter = Alkoholliter*1000
replace Gruppe = "Alkohol" if Gruppe == "Alkohol totalt" 
replace Vareliter = Alkoholliter if Gruppe == "Alkohol" // Obs, Alkohol i vareliter er nå ren alkohol totalt

rename Vareliter AntallSSB
rename Alkoholliter AntallRenSSB
rename Alkoholliter15 AntallRen15SSB

label variable AntallSSB "Vareliter unntatt for alkohol"
label variable AntallRenSSB "Ren alkoholliter"
label variable AntallRen15SSB "Ren alkoholliter per innbygger 15 år og over"

drop if Kvt < yq(2023,1)
compress

save "SSB_Alkoholstatistikk.dta", replace 



* Filen slutter her

* Figurer:
/*
	twoway ///
    (line AntallSSB Kvt, lpattern(solid) lcolor(blue)) ///
    (line AntallRenSSB Kvt, lpattern(solid) lcolor(red)) ///
    , by(Gruppe, yrescale) ///
      title("SSB") ///
      xlabel(, angle(45)) ///
      legend(order(1 "Vareliter" 2 "Ren alkoholliter"))
	  

	twoway ///
    (line AntallRen15SSB Kvt, lpattern(solid) lcolor(red)) ///
    , by(Gruppe, yrescale) ///
      title("SSB") ///
      xlabel(, angle(45)) ///
      legend(order(1 "Ren alkoholliter per 15+"))
	  
	 */
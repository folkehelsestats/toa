clear all
/* 	STATA do-fil som henter inn slagstall for Vinmonopolet */ 
cd "O:\Prosjekt\Rusdata\Omsetning\Vinmonopolet_originalfiler\"

import excel "Vinmonopolet 2024.xlsx", sheet("Ark1") firstrow clear

gen Mnd = ym(År, Måned)
drop År Måned 
format %tmMonth_CCYY Mnd
label var Mnd "Måned"

replace Gruppe = subinstr(Gruppe," ","",.)
drop if Gruppe == "Alkoholfritt"
drop if Gruppe == "Alkoholfritt og lettvin"
replace Gruppe = "Vin" if Gruppe == "Svakvin"
replace Gruppe = "Sterkøl" if Gruppe == "Øl"
tab Gruppe

replace Hektoliter = subinstr(Hektoliter," ","",.)
gen Liter= real(subinstr(Hektoliter," ","",.))
replace Liter = Liter*1000 if Mnd < ym(2014,1)  
format %11.0g Liter
drop Hektoliter

compress
save Vinmonopolet_Mnd_2024.dta, replace

twoway (line Liter Mnd, sort), by(Gruppe, yrescale) 
/*Mangler tall på alkoholliter både før og etter noen år*/
twoway (line Alkoholliter Mnd, sort), by(Gruppe, yrescale) 

/* Lag statistikk over kvartal */


gen Kvt = qofd(dofm(Mnd))
format %tq Kvt 
label var Kvt "Kvartal"

collapse (sum) Liter Alkoholliter, by(Kvt Gruppe)
replace Alkoholliter = . if Kvt < yq(2014,1)  
replace Alkoholliter = . if Kvt > yq(2022,4)  
label var Liter "Liter"
label var Alkoholliter "Liter ren alkohol"
format %11.0g Liter
format %11.0g Alkoholliter
replace Gruppe = "Hetvin" if Gruppe == "Sterkvin"
save Vinmonopolet_Kvt_2024.dta, replace

twoway (line Liter Kvt, sort), by(Gruppe, yrescale) 
twoway (line Alkoholliter Kvt, sort), by(Gruppe, yrescale) 

/* Lag statistikk over År */
gen År = year(dofq(Kvt))
drop if År > 2024

collapse (sum) Liter Alkoholliter, by(År Gruppe)
replace Alkoholliter = . if År < 2014 
replace Alkoholliter = . if År > 2022 
label var Liter "Liter"
format %11.0g Liter
save Vinmonopolet_Aar_2024.dta, replace

edit
twoway (line Liter År, sort), by(Gruppe, yrescale) 

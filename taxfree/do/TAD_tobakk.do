clear all

/* Hent inn innenlandsk omsetning fra TAD 2010 til 2020 */
cd "C:\Users\bovre\OneDrive - Helsedirektoratet\GitHdir\toa\taxfree\do\TAD_tobakk.do"

import excel "TAD Tobakk 2010-2024.xlsx", sheet("Ark1") firstrow clear

/* Lag noen nye variabler */ 
rename C AntallSigaretter 
rename D AntallTobakk
rename E AntallSigarer
rename F AntallSnus
rename G AntallSkråtobakk
drop H I J K L M

replace Mnd = ym(Aar, Mnd)
drop Aar
format %tmMonth_CCYY Mnd

/* Behold kun sigaretter, snus og tobakk */
drop AntallSigarer AntallSkråtobakk
destring Antall*, replace i(" ")
compress

collapse (sum) Antall*, by(Mnd) 
reshape long Antall, i(Mnd) j(Gruppe) string
label var Gruppe "Gruppe" 

gen K = quarter(dofm(Mnd))
gen A = year(dofm(Mnd))
gen Kvt = yq(A,K)
label var Kvt "Kvartal"
format %tq Kvt 

/* Sjekk om det ser riktig ut */
twoway (line Antall Mnd, sort cmissing(n)), ///
	ytitle("Antall") ylabel(,angle(forty_five)) ///
	xlabel(,format(%tmNN/YY)) xmtick(##12) ///
	by(Gruppe, yrescale xrescale note(""))

collapse (sum) Antall, by(Kvt Gruppe) 
rename Antall TobakkTAD
label var TobakkTAD "Antall"

/*
/* Kvartal 2023/1 er ufullstendig */
drop if Kvt > yq(2023,1)
*/

save "TAD_Tobakk_2024.dta", replace

gen År = year(dofq(Kvt))
label var År "År"
collapse (sum) TobakkTAD, by(År Gruppe) 
label var TobakkTAD "Antall"

/*
/* År 2022 er ufullstendig */
drop if År == 2023
*/

save "TAD_Tobakk_Aar_2024.dta", replace




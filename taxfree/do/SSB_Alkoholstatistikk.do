clear all
/* 	STATA do-fil som henter inn SSBs omsetningstatistikk */ 
cd "O:\Prosjekt\Rusdata\Omsetning\SSB_originalfiler\Omsetningsstatistikk\"

import excel "SSB Alkoholstatistikk 2024.xlsx", sheet("Sheet1") firstrow clear


gen Kvt = yq(År,Kvartal)
format %tq Kvt 
label var Kvt "Kvartal"
drop År Kvartal Vareliter15
order Kvt Gruppe

replace Vareliter = Vareliter*1000
replace Alkoholliter = Alkoholliter*1000
replace Gruppe = "Alkohol" if Gruppe == "Alkohol totalt" 
replace Gruppe = "Alkohol" if Gruppe == "Alkohol totalt" 
replace Vareliter = Alkoholliter if Gruppe == "Alkohol" 

rename Vareliter AntallSSB
rename Alkoholliter AntallRenSSB
rename Alkoholliter15 AntallRen15SSB

drop if Kvt < yq(2010,1)
compress

save SSB_Alkoholstatistikk 2024.dta, replace 

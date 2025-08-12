*******************************************************************************

** Fil opprettet for TRN-data 2024
** Filen tar utgangspunkt i do-fil fra FHI.
** Denne filen er opprettet 5/8-2025 av Bente Øvrebø, Hdir.
** Filen anses som ferdig.

*******************************************************************************

clear all

/* 	STATA do-fil som beskriver hva som blir gjort for å generere 
	kvartalsvise Tax-Free salgstall for TRN	2024			 */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Travel Retail Norway\"

import excel "TRN 2024.xlsx", sheet("Ark1") firstrow clear

gen Aar = 2024
gen Kvt = substr(Kvartal, 2, 1) 
destring Kvt, replace 
replace Kvt = yq(Aar, Kvt)
format %tq Kvt 
drop Aar Kvartal

replace Enhet = "kg" if substr(Enhet,1,17) == "Quantity B2C (KG)"
replace Enhet = "l" if substr(Enhet,1,16) == "Quantity B2C (L)"
replace Enhet = "pc" if substr(Enhet,1,17) == "Quantity B2C (pc)"

replace StrongWine = . if Enhet == "kg"
replace SparklingWine = . if Enhet == "kg"
replace TableWine = . if Enhet == "kg"
replace Beer = . if Enhet == "kg"

replace Spirits = "" if Spirits == "*"
destring Spirits, replace
replace Spirits = . if Enhet == "kg"

replace Snus = "" if Snus == "*"
destring Snus, replace
replace Snus = . if Enhet =="l"

replace Cigarettes = . if Enhet =="l"
replace Cigars = . if Enhet =="l"

replace Tobacco = "" if Tobacco =="*"
destring Tobacco, replace
replace Tobacco = . if Enhet =="l"


gen Lufthavn = substr(Sted,1,3)
replace Lufthavn = "Bergen" if Lufthavn == "BGO"
replace Lufthavn = "Kristiansand" if Lufthavn == "KRS"
replace Lufthavn = "Oslo" if Lufthavn == "OSL" 
replace Lufthavn = "Stavanger" if Lufthavn == "SVG"
replace Lufthavn = "Trondheim" if Lufthavn == "TRD"
replace Ankomst = "Y" if Sted == "OSL Oslo DFS Arrival" 
replace Ankomst = "N" if Sted == "OSL Oslo DFS Departure" 
compress


gen Utsalg = ""
replace Utsalg = "Ankomst" if Ankomst == "Y" 
replace Utsalg = "Avgang" if Ankomst == "N" 
drop Sted Ankomst
order Kvt Lufthavn Utsalg 

collapse (sum) StrongWine SparklingWine TableWine Spirits Beer Snus ///
	Cigarettes Cigars Tobacco, by(Kvt Lufthavn Utsalg Enhet)

gen AntallVin = SparklingWine + TableWine
drop SparklingWine TableWine
rename StrongWine AntallHetvin
rename Spirits AntallBrennevin
rename Beer AntallØl
rename Snus AntallSnus
rename Cigarettes AntallSigaretter
rename Cigars AntallSigarer
rename Tobacco AntallTobakk

/* Inkluderer enhet inn i navn på antall*/ 
reshape long Antall, i(Kvt Lufthavn Utsalg Enhet) ///
	j(Gruppe Hetvin Brennevin Øl Snus Sigaretter Sigarer Tobakk Vin) string
reshape wide Antall, i(Kvt Lufthavn Utsalg Gruppe) ///
	j(Enhet) string

gen Antall = 0
replace Antall = Antalll if Gruppe =="Brennevin"
replace Antall = Antalll if Gruppe =="Hetvin" 
replace Antall = Antallkg if Gruppe =="Sigarer" 
replace Antall = Antallpc*200 if Gruppe=="Sigaretter" // Spørsmålet er om denne blir riktig mtp kvoteendringene. Bør det heller 200 ved avgang og 100 ved ankomst?
replace Antall = Antallkg if Gruppe =="Snus" 
replace Antall = Antallkg if Gruppe =="Tobakk" 
replace Antall = Antalll if Gruppe =="Vin" 
replace Antall = Antalll if Gruppe =="Øl" 
drop Antallkg Antalll Antallpc
rename Antall nyAntall

save "TRN 2024.dta", replace

* Filen slutter her.
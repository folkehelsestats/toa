*******************************************************************************
	* Fil som bygger videre på fil fra FHI
	* Fil omhandler TRN-data for 2022-2023

*******************************************************************************

clear all

/* 	STATA do-fil som beskriver hva som blir gjort for å generere 
	kvartalsvise Tax-Free salgstall for TRN	2022-2023			 */ 


cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Travel Retail Norway\"

import excel "TRN 2022-2023.xlsx", sheet("Ark1") firstrow clear


gen Aar = substr(Kvartal, 3, 5)
gen Kvt = substr(Kvartal, 2, 1) 
destring Aar Kvt, replace 
replace Kvt = yq(Aar, Kvt)
format %tq Kvt 
drop Aar Kvartal

replace Enhet = "kg" if substr(Enhet,1,17) == "Quantity B2C (KG)"
replace Enhet = "l" if substr(Enhet,1,16) == "Quantity B2C (L)"
replace Enhet = "pc" if substr(Enhet,1,17) == "Quantity B2C (pc)"


destring Spirits, ignore("*") replace
replace StrongWine = . if Enhet == "kg"
replace SparklingWine = . if Enhet == "kg"
replace TableWine = . if Enhet == "kg"
replace Spirits = . if Enhet == "kg"
replace Beer = . if Enhet == "kg"

destring Snus Cigarettes Tobacco, ignore("*") replace
replace Snus = . if Enhet =="l"
replace Cigarettes = . if Enhet =="l"
replace Cigars = . if Enhet =="l"
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
* Dropper noen rader med #, fordi det ser ut til at det er feil. 
list if Ankomst == "#"
drop if Sted == "OSL Oslo T2 Departure North" & Ankomst == "#"

drop Sted Ankomst
order Kvt Lufthavn Utsalg 


collapse (sum) StrongWine SparklingWine TableWine Spirits Beer Snus ///
	Cigarettes Cigars Tobacco, by(Kvt Lufthavn Utsalg Enhet)

/*Sjekke linje, det blir 0 i 2023 i Oslo, Bergen og Stavanger*/
/*
twoway (line Tobacco Kvt if Enhet == "kg") if Utsalg == "Ankomst", by(Lufthavn, yrescale)
twoway (line Tobacco Kvt if Enhet == "kg") if Utsalg == "Avgang", by(Lufthavn, yrescale)
twoway (line Snus Kvt if Enhet == "kg") if Utsalg == "Ankomst", by(Lufthavn, yrescale)
twoway (line Cigars Kvt if Enhet == "kg") if Utsalg == "Ankomst", by(Lufthavn, yrescale)

list Snus-Tobacco Kvt Utsalg if Lufthavn == "Oslo" & Enhet == "kg"
list Snus-Tobacco Kvt Utsalg if Lufthavn == "Oslo" & Enhet == "pc"

list Snus-Tobacco Kvt Utsalg if Lufthavn == "Bergen" & Enhet == "kg"
list Snus-Tobacco Kvt Utsalg if Lufthavn == "Bergen" & Enhet == "pc"

list Snus-Tobacco Kvt Utsalg if Lufthavn == "Stavanger" & Enhet == "kg"
list Snus-Tobacco Kvt Utsalg if Lufthavn == "Stavanger" & Enhet == "pc"

*/
	
gen AntallVin = SparklingWine + TableWine
drop SparklingWine TableWine
rename StrongWine AntallHetvin
rename Spirits AntallBrennevin
rename Beer AntallØl
rename Snus AntallSnus
rename Cigarettes AntallSigaretter
rename Cigars AntallSigarer
rename Tobacco AntallTobakk

reshape long Antall, i(Kvt Lufthavn Utsalg Enhet) ///
	j(Gruppe Hetvin Brennevin Øl Snus Sigaretter Sigarer Tobakk Vin) string
reshape wide Antall, i(Kvt Lufthavn Utsalg Gruppe) ///
	j(Enhet) string

gen Antall = 0
replace Antall = Antalll if Gruppe =="Brennevin"
replace Antall = Antalll if Gruppe =="Hetvin" 
replace Antall = Antallkg if Gruppe =="Sigarer" 
replace Antall = Antallpc*200 if Gruppe=="Sigaretter" // OBS på at kvoteendring tilsier at dette er feil!
replace Antall = Antallkg if Gruppe =="Snus" 
replace Antall = Antallkg if Gruppe =="Tobakk" 
replace Antall = Antalll if Gruppe =="Vin" 
replace Antall = Antalll if Gruppe =="Øl" 
drop Antallkg Antalll Antallpc
rename Antall nyAntall

save "TRN 2022-2023.dta", replace

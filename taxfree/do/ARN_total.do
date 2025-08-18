*******************************************************************************
	* Denne fila er opprettet 5/8-2025
	* Fila bygger på FHIs fil
	* Fila legger til ARN-data for 2023 (q4) og 2024.
	* Fila er opprettet av Bente Øvrebø, Hdir.
	* Fila er under arbeid.

*******************************************************************************

clear all

/* 	STATA do-fil som beskriver hva som blir gjort for å generere 
	kvartalsvise Tax-Free salgstall for Torp og Rygge fra ARN */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"

/* Hent in data fa 2010 til 2012 */
import excel "ARN 2010 til 2012.xlsx", sheet("Ark1") firstrow clear

gen Mnd = ym(År, Måned)
drop År Måned Kvartal Kilde
format %tmMonth_CCYY Mnd
label var Mnd "Måned"

gen Kvt = qofd(dofm(Mnd))
format %tq Kvt 
label var Kvt "Kvartal"

replace Mengde = Mengde/1000 if Enhet == "ml"
replace Enhet = "l" if Enhet == "ml"
replace Mengde = Mengde/100 if Enhet == "cl"
replace Enhet = "l" if Enhet == "cl"
replace Mengde = Mengde/1000 if Enhet == "gr"
replace Enhet = "kg" if Enhet == "gr"

replace Varegruppe = "SnusTobakk" if Varegruppe == "Tobakk"

/* Torp skiller egentlig ikke mellom ankomst og avgang før 2014Q2,
   men det ligger i statistikken, og Øyvind har brukt det. */

collapse (sum) Mengde, by(Sted Utsalg Varegruppe Kvt)
rename Mengde Antall
label var Antall "Antall"
rename Varegruppe Gruppe
label var Gruppe "Gruppe"
rename Sted Lufthavn
label var Lufthavn "Lufthavn"

/*
twoway (line Antall Kvt if Utsalg == "Ankomst") ///
	   (line Antall Kvt if Utsalg == "Avgang") ///
	   if Lufthavn == "Torp", by(Gruppe, yrescale)	
twoway (line Antall Kvt if Utsalg == "Ankomst") ///
	   (line Antall Kvt if Utsalg == "Avgang") ///
	   if Lufthavn == "Rygge", by(Gruppe, yrescale)		   
*/

sort Lufthavn Utsalg Gruppe Kvt 
save "ARN2010-2012.dta", replace

/* Hent inn data fra 2013 til 2014 */ 
import excel "ARN 2013 til 2014.xlsx", sheet("Ark1") firstrow clear

gen Kvt = yq(År, Kvartal)
drop År Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe2=="Beer"
replace Gruppe="Vin" if Varegruppe=="200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="Rusbrus" if Varegruppe2=="Alco.Soda"
replace Gruppe="Sider" if Varegruppe2=="Cider"
replace Gruppe="Sigaretter" if Varegruppe2=="Cigarettes"
replace Gruppe="Sigarer" if Varegruppe2=="Cheroots"
replace Gruppe="Sigarer" if Varegruppe2=="Cigars"
replace Gruppe="Snus" if Varegruppe2=="Snuff"
replace Gruppe="Tobakk" if Varegruppe2=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

/* Mengde2 skal være korrekt: liter/kg/stk */
drop Mengde Antall
rename Mengde2 Antall
rename Sted Lufthavn
label var Lufthavn "Lufthavn"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
append using "ARN2010-2012.dta"
sort Lufthavn Utsalg Gruppe Kvt 
save "ARN2010-2014.dta", replace

/* Nye, korrigerte data for 2014*/
import excel "ARN 2014.xlsx", sheet("Ark1") firstrow clear

gen Kvt = yq(2014, Kvartal)
drop Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Vare=="Beer"
replace Gruppe="Vin" if Varegruppe=="Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="Liquor"
replace Gruppe="Rusbrus" if Vare=="Alco.Soda"
replace Gruppe="Sider" if Vare=="Cider"
replace Gruppe="Sigaretter" if Vare=="Cigarettes"
replace Gruppe="Sigarer" if Vare=="Cheroots"
replace Gruppe="Sigarer" if Vare=="Cigars"
replace Gruppe="Snus" if Vare=="Snuff"
replace Gruppe="Tobakk" if Vare=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe Vare Antallvarer
rename Literkg Antall
collapse (sum) Antall, by(Flyplass Utsalg Gruppe Kvt)
label var Antall "Antall" 
rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

save "ARN2014.dta", replace

/* Hent inn siste tall for 2015 */
import excel "ARN 2015.xlsx", sheet("Ark1") firstrow clear

gen Kvt = yq(2015, Kvartal)
drop Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe2=="Beer"
replace Gruppe="Vin" if Varegruppe=="200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="Rusbrus" if Varegruppe2=="Alco.Soda"
replace Gruppe="Sider" if Varegruppe2=="Cider"
replace Gruppe="Sigaretter" if Varegruppe2=="Cigarettes"
replace Gruppe="Sigarer" if Varegruppe2=="Cheroots"
replace Gruppe="Sigarer" if Varegruppe2=="Cigars"
replace Gruppe="Snus" if Varegruppe2=="Snuff"
replace Gruppe="Tobakk" if Varegruppe2=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

/* Mengde2 skal være korrekt: liter/kg/stk */
drop Enhet Mengde Antall
rename Mengde2 Antall
rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
save "ARN2015.dta", replace

/* Hent inn siste tall for 2016 */
import excel "ARN 2016.xlsx", sheet("Sheet1") firstrow clear

gen Kvt = yq(2016, Kvartal)
drop Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe2=="Beer"
replace Gruppe="Vin" if Varegruppe=="200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="Rusbrus" if Varegruppe2=="Alco.Soda"
replace Gruppe="Sider" if Varegruppe2=="Cider"
replace Gruppe="Sigaretter" if Varegruppe2=="Cigarettes"
replace Gruppe="Sigarer" if Varegruppe2=="Cheroots"
replace Gruppe="Sigarer" if Varegruppe2=="Cigars"
replace Gruppe="Snus" if Varegruppe2=="Snuff"
replace Gruppe="Tobakk" if Varegruppe2=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

/* Mengde2 skal være korrekt: liter/kg/stk */
drop Enhet Mengde Antall
rename Mengde2 Antall
rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
save "ARN2016.dta", replace

/* Hent inn siste tall for Torp i 2017 */
import excel "Torp 2017.xlsx", sheet("Sheet1") firstrow clear

gen Kvt = yq(2017, Kvartal)
drop Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe2=="Beer"
replace Gruppe="Vin" if Varegruppe=="200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="Rusbrus" if Varegruppe2=="Alco.Soda"
replace Gruppe="Sider" if Varegruppe2=="Cider"
replace Gruppe="Sigaretter" if Varegruppe2=="Cigarettes"
replace Gruppe="Sigarer" if Varegruppe2=="Cheroots"
replace Gruppe="Sigarer" if Varegruppe2=="Cigars"
replace Gruppe="Snus" if Varegruppe2=="Snuff"
replace Gruppe="Tobakk" if Varegruppe2=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

/* Mengde2 skal være korrekt: liter/kg/stk */
drop Antall
destring Mengde2, gen(Antall) ignore("-")
replace Antall = Mengde if Grupp == "Sigarer"
drop Mengde* 

gen Lufthavn = "Torp"
label var Lufthavn "Lufthavn"
drop Flyplass

replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "Torp2017.dta", replace

/* Hent inn tall for Torp i 2018 */
import delimited "Torp 2018.csv",  encoding(UTF-8) varnames(1) case(preserve) clear
gen Kvt = yq(2018, Kvartal)
drop Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe2=="Beer"
replace Gruppe="Vin" if Varegruppe=="200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="Rusbrus" if Varegruppe2=="Alco.Soda"
replace Gruppe="Sider" if Varegruppe2=="Cider"
replace Gruppe="Sigaretter" if Varegruppe2=="Cigarettes"
replace Gruppe="Sigarer" if Varegruppe2=="Cheroots"
replace Gruppe="Sigarer" if Varegruppe2=="Cigars"
replace Gruppe="Snus" if Varegruppe2=="Snuff"
replace Gruppe="Tobakk" if Varegruppe2=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

drop Antall
rename Mengde2 Antall
replace Antall = Mengde/100 if Grupp == "Sigarer"
drop Mengde* 

gen Lufthavn = "Torp"
label var Lufthavn "Lufthavn"
drop Flyplass

replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "Torp2018.dta", replace


/* Hent inn tall for Haugesund og Torp i 2019. 
   Haugsund driftes av ARN fra 2.kvartal 			*/
import excel "ARN 2019.xlsx", sheet("ARN") firstrow clear 

gen Kvt = yq(2019, Kvartal)
drop Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe2=="Beer"
replace Gruppe="Vin" if Varegruppe=="200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe=="210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="Rusbrus" if Varegruppe2=="Alco.Soda"
replace Gruppe="Sider" if Varegruppe2=="Cider"
replace Gruppe="Sigaretter" if Varegruppe2=="Cigarettes"
replace Gruppe="Sigarer" if Varegruppe2=="Cheroots"
replace Gruppe="Sigarer" if Varegruppe2=="Cigars"
replace Gruppe="Snus" if Varegruppe2=="Snuff"
replace Gruppe="Tobakk" if Varegruppe2=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

drop Antall
destring Mengde2, ignore("-") replace
rename Mengde2 Antall
replace Antall = Mengde/100 if Grupp == "Vin"
replace Antall = Mengde/100 if Grupp == "Sigarer"
drop Mengde* 

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

replace Lufthavn = "Torp" if Lufthavn == "Torp Ankomst"
replace Lufthavn = "Torp" if Lufthavn == "Torp Avgang"
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"
replace Utsalg = "" if Utsalg == "-"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "ARN2019.dta", replace

/* Hent inn tall for 2020-2023 */
import excel "ARN 2020-2023.xlsx", sheet("Ark1") firstrow clear 

gen Kvt = yq(År, Kvartal)
drop År Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe == "230 - Beer & softdrinks"
replace Gruppe="Vin" if Varegruppe == "200 - Tablewine"
replace Gruppe="Hetvin" if Varegruppe == "210 - Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="220 - Liquor"
replace Gruppe="AllTobakk" if Varegruppe=="300 - Tobacco"

replace Gruppe="Øl" if Varegruppe == "Beer & Softdrinks"
replace Gruppe="Vin" if Varegruppe == "Wine & Sparkling Wine"
replace Gruppe="Hetvin" if Varegruppe == "Fortified wine"
replace Gruppe="Brennevin" if Varegruppe=="Spirits"
replace Gruppe="AllTobakk" if Varegruppe=="Tobacco"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

drop Antall
destring Mengde2, ignore("-") replace
rename Mengde2 Antall
replace Antall = Mengde if Gruppe == "Vin"
replace Antall = Mengde if Gruppe == "Øl"
replace Antall = Mengde if Gruppe == "Brennevin"
replace Antall = Mengde if Gruppe == "Hetvin"

gen År = year(dofq(Kvt))
replace Antall = Antall/100 if År == 2020
replace Antall = Antall/100 if År == 2021

/*OBS OBS vurder å gjøre dette for 2023 også:
replace Antall = Antall/100 if År == 2023
*/

/* Leveranse disse årene skiller ikke på tobakk - kun oppgitt all tobakk samlet, som det er usikkert om er oppgitt i kg, stykk eller en blanding. Det inkluderer sannsynligvis cigarer, sigaretter, snus, tobakk og sigarettpapir. Daniel valgte å droppe denne variebelen. Gjør det nå, må da estimeres. Alternativt kan man muligens bruke denne variabelen til å estimere undergrupper basert på 2024-data. */

drop Mengde* 
drop if Gruppe == "AllTobakk" // Bentes kommentar: dette virker logisk siden det ser ut til at alt er oppgitt i stykk. 

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

replace Lufthavn = "Torp" if Lufthavn == "Torp Ankomst"
replace Lufthavn = "Torp" if Lufthavn == "Torp Avgang"
replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"
replace Utsalg = "" if Utsalg == "Total"
replace Utsalg = "" if Utsalg == "Toital"

collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "ARN2020-2023.dta", replace

/* Samle alle årene i en fil */
use "ARN2010-2014.dta", replace
drop if Kvt >= yq(2014,1)
append using "ARN2014.dta"
append using "ARN2015.dta"
append using "ARN2016.dta"
append using "Torp2017.dta"
append using "Torp2018.dta"
append using "ARN2019.dta"
append using "ARN2020-2023.dta"
append using "ARN2024.dta"
compress

sort Lufthavn Utsalg Gruppe Kvt

save "ARN2010-2024.dta", replace



/*

/* Sjekker figurer ved å se på totalt salg for flyplasser med både ankomst og avgangssalg*/
preserve
collapse (sum) Antall, by(Lufthavn Gruppe Kvt)
separate Antall, by(Gruppe) generate(Antall_)
twoway line Antall_1 Kvt if Lufthavn == "Torp" // Brennevin
twoway (line Antall Kvt if Lufthavn == "Torp" ), by(Gruppe, yrescale) // Alle varegrupper, kun Torp
restore


*/




/*

twoway (line Antall Kvt if Lufthavn == "Torp" ) if Utsalg == "Ankomst", by(Gruppe, yrescale)
*/



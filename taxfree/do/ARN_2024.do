
*******************************************************************************
	* Denne fila er opprettet 5/8-2025
	* Fila bygger på daniels/FHIs fil
	* Fila legger til nye ARN-data for 2022, 2023 og 2024.
	* Fila er opprettet av Bente Øvrebø, Hdir.
	* Fila er under arbeid.

*******************************************************************************

clear all

/* 	STATA do-fil som beskriver hva som blir gjort for å importere ARN-2024-data */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"

/* Hent in data fra 2022 */
import excel "ARN 2022 ny.xlsx", sheet("Ark1") firstrow clear


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

replace Gruppe="Øl" if Varegruppe=="Beer"
replace Gruppe="Vin" if Varegruppe=="Champagne"
replace Gruppe="Vin" if Varegruppe== "Sparkling Wine"
replace Gruppe="Vin" if Varegruppe== "Wine"
replace Gruppe="Hetvin" if Varegruppe=="Sherry & Port & Fruit"
replace Gruppe="Hetvin" if Varegruppe=="Vermouth"
replace Gruppe="Brennevin" if Varegruppe=="Aquavit"
replace Gruppe="Brennevin" if Varegruppe=="Brandy"
replace Gruppe="Brennevin" if Varegruppe=="Clear Spirits (with additives)"
replace Gruppe="Brennevin" if Varegruppe=="Cognac"
replace Gruppe="Brennevin" if Varegruppe=="Digestif & Aperitif"
replace Gruppe="Brennevin" if Varegruppe=="Fruitbrandy & Grappa"
replace Gruppe="Brennevin" if Varegruppe=="Fruity Spirits & Other Premix"
replace Gruppe="Brennevin" if Varegruppe=="Gin & Genever"
replace Gruppe="Brennevin" if Varegruppe=="Liqueur"
replace Gruppe="Brennevin" if Varegruppe=="miscellaneous spirit"
replace Gruppe="Brennevin" if Varegruppe=="Rum"
replace Gruppe="Brennevin" if Varegruppe=="Tequila"
replace Gruppe="Brennevin" if Varegruppe=="Vodka"
replace Gruppe="Brennevin" if Varegruppe=="Whisk(e)y"

replace Gruppe="Sigaretter" if Varegruppe=="Cigarettes Duty Free"
replace Gruppe="Sigarer" if Varegruppe=="Cigars & Cigarillo DF"
replace Gruppe="Snus" if Varegruppe=="Snus"
replace Gruppe="Tobakk" if Varegruppe=="Tobacco  DF"
replace Gruppe = "Smokers Supply" if Varegruppe == "Cigarette paper"


label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

	* Sjekker ev. missing og setter 0 der det er korrekt.
list Gruppe Flyplass Antall kg l if Antall == .
replace l = 0 if Gruppe == "Brennevin" & Flyplass == "Torp" & l == .

/* Siden Haugesund kun har tall i antall (ikke kg/l) bør det vurderes om disse skal inkluderes eller ikke*/

replace Antall = l if Gruppe == "Vin" & Flyplass == "Torp"
replace Antall = l if Gruppe == "Øl" & Flyplass == "Torp"
replace Antall = l if Gruppe == "Brennevin" & Flyplass == "Torp"
replace Antall = l if Gruppe == "Hetvin" & Flyplass == "Torp"

drop if Gruppe == "Smokers Supply"
replace Antall = kg if Gruppe == "Sigarer" & Flyplass == "Torp"
replace Antall = kg if Gruppe == "Sigaretter" & Flyplass == "Torp"
replace Antall = kg if Gruppe == "Snus" & Flyplass == "Torp"
replace Antall = kg if Gruppe == "Tobakk" & Flyplass == "Torp"

drop kg l

/* Leveranse 2022 fra Haugesund skiller ikke på tobakk - kun oppgitt all tobakk samlet, som det er usikkert om er oppgitt i kg, stykk eller en blanding. Det inkluderer sannsynligvis cigarer, sigaretter, snus, tobakk og sigarettpapir. Daniel valgte å droppe denne variebelen. Gjør det nå, må da estimeres. Alternativt kan man muligens bruke denne variabelen til å estimere undergrupper basert på 2024-data. */

drop if Gruppe == "AllTobakk" // Bentes kommentar: dette virker logisk siden det ser ut til at alt er oppgitt i stykk. 

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"
replace Utsalg = "Total" if Utsalg == ""


collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "ARN_2022.dta", replace

*******************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"


/* Hent in data fra 2023 */
import excel "ARN 2023 ny.xlsx", sheet("Ark1") firstrow clear

gen Kvt = yq(År, Kvartal)
drop År Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

/* Lager en variabel for å markere data fra Haugesund som bruker gammel inndeling på omsetning*/
	gen not = 0
	replace not = 1 if Varegruppe == "230 - Beer & softdrinks"
	replace not = 1 if Varegruppe == "200 - Tablewine" 
	replace not = 1 if Varegruppe == "210 - Fortified wine" 
	replace not = 1 if Varegruppe == "220 - Liquor" 
	replace not = 1 if Varegruppe == "300 - Tobacco"


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

replace Gruppe="Øl" if Varegruppe=="Beer"
replace Gruppe="Vin" if Varegruppe=="Champagne"
replace Gruppe="Vin" if Varegruppe== "Sparkling Wine"
replace Gruppe="Vin" if Varegruppe== "Wine"
replace Gruppe="Hetvin" if Varegruppe=="Sherry & Port & Fruit"
replace Gruppe="Hetvin" if Varegruppe=="Vermouth"
replace Gruppe="Brennevin" if Varegruppe=="Aquavit"
replace Gruppe="Brennevin" if Varegruppe=="Armagnac"
replace Gruppe="Brennevin" if Varegruppe=="Brandy"
replace Gruppe="Brennevin" if Varegruppe=="Clear Spirits (with additives)"
replace Gruppe="Brennevin" if Varegruppe=="Cognac"
replace Gruppe="Brennevin" if Varegruppe=="Digestif & Aperitif"
replace Gruppe="Brennevin" if Varegruppe=="Fruitbrandy & Grappa"
replace Gruppe="Brennevin" if Varegruppe=="Fruity Spirits & Other Premix"
replace Gruppe="Brennevin" if Varegruppe=="Gin & Genever"
replace Gruppe="Brennevin" if Varegruppe=="Liqueur"
replace Gruppe="Brennevin" if Varegruppe=="miscellaneous spirit"
replace Gruppe="Brennevin" if Varegruppe=="Rum"
replace Gruppe="Brennevin" if Varegruppe=="Tequila"
replace Gruppe="Brennevin" if Varegruppe=="Vodka"
replace Gruppe="Brennevin" if Varegruppe=="Whisk(e)y"

replace Gruppe="Sigaretter" if Varegruppe=="Cigarettes Duty Free"
replace Gruppe="Sigarer" if Varegruppe=="Cigars & Cigarillo DF"
replace Gruppe="Snus" if Varegruppe=="Snus"
replace Gruppe="Tobakk" if Varegruppe=="Tobacco  DF"
replace Gruppe = "Smokers Supply" if Varegruppe == "Cigarette paper"

label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

	* Sjekker ev. missing og setter 0 der det er korrekt.
list Gruppe Flyplass Antall kg l if Antall == .
replace l = 0 if Gruppe == "Brennevin" & l == .
replace l = 0 if Gruppe == "Hetvin" & l == .
replace l = 0 if Gruppe == "Vin" & l == .
replace l = 0 if Gruppe == "Øl" & l == .
replace kg = 0 if Gruppe == "Sigarer" & kg == .
replace kg = 0 if Gruppe == "Tobakk" & kg == .
replace kg = 0 if Gruppe == "Snus" & kg == .
replace kg = 0 if Gruppe == "Sigaretter" & kg == .

/* Siden Haugesund kun har tall i antall (ikke kg/l) bør det vurderes om disse skal inkluderes eller ikke i q1 (og q2). I fila ligger salg for q2 for Haugesund også i mer finfordelte kategorier og i kg/l. Usikker på om dette er dobbeltrapportering, eller endring i system fra en dag til en annen og derfor er totalt-salg til sammen. Det kan virke som om at det er aktuet å beholde alle q2-filene, fordi tallene som er minst detaljerte virker litt lave til å være i q2.*/

replace Antall = l if Gruppe == "Vin" & not == 0
replace Antall = l if Gruppe == "Øl" & not == 0
replace Antall = l if Gruppe == "Brennevin" & not == 0
replace Antall = l if Gruppe == "Hetvin" & not == 0

drop if Gruppe == "Smokers Supply"
replace Antall = kg if Gruppe == "Sigarer" & not == 0
replace Antall = kg if Gruppe == "Sigaretter" & not == 0
replace Antall = kg if Gruppe == "Snus" & not == 0
replace Antall = kg if Gruppe == "Tobakk" & not == 0

drop kg l

/* Leveranse 2023 q1 og q2 fra Haugesund skiller ikke på tobakk - kun oppgitt all tobakk samlet, som det er usikkert om er oppgitt i kg, stykk eller en blanding. Det inkluderer sannsynligvis cigarer, sigaretter, snus, tobakk og sigarettpapir. Daniel valgte å droppe denne variebelen. Gjør det nå, må da estimeres. Alternativt kan man muligens bruke denne variabelen til å estimere undergrupper basert på 2024-data. */
/*
drop if Gruppe == "AllTobakk" // Sletter ikke denne nå siden vi har q2 med salg både i liter/kg og i antall separat. Men dette er slettet for 2022.
*/

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"
replace Utsalg = "Total" if Utsalg == ""

/* OBS på at denne kommandoen legger sammen ulike enheter i omsetning for Haugesund i q2*/
collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "ARN_2023.dta", replace








*******************************************************************************
*******************************************************************************
*******************************************************************************
clear all


cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"

/* Hent in data fra 2024 */
import excel "ARN 2024 ny.xlsx", sheet("Ark1") firstrow clear

gen Kvt = yq(År, Kvartal)
drop År Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

/* Lage sammenliknebare varegrupper med tidligere år*/

gen Gruppe=""
replace Gruppe="Øl" if Varegruppe=="Beer"

replace Gruppe="Vin" if Varegruppe=="Champagne"
replace Gruppe="Vin" if Varegruppe== "Sparkling Wine"
replace Gruppe="Vin" if Varegruppe== "Wine"

replace Gruppe="Hetvin" if Varegruppe=="Sherry & Port & Fruit"
replace Gruppe="Hetvin" if Varegruppe=="Vermouth"

replace Gruppe="Brennevin" if Varegruppe=="Aquavit"
replace Gruppe="Brennevin" if Varegruppe=="Brandy"
replace Gruppe="Brennevin" if Varegruppe=="Clear Spirits (with additives)"
replace Gruppe="Brennevin" if Varegruppe=="Cognac"
replace Gruppe="Brennevin" if Varegruppe=="Digestif & Aperitif"
replace Gruppe="Brennevin" if Varegruppe=="Fruitbrandy & Grappa"
replace Gruppe="Brennevin" if Varegruppe=="Fruity Spirits & Other Premix"
replace Gruppe="Brennevin" if Varegruppe=="Gin & Genever"
replace Gruppe="Brennevin" if Varegruppe=="Liqueur"
replace Gruppe="Brennevin" if Varegruppe=="miscellaneous spirit"
replace Gruppe="Brennevin" if Varegruppe=="Rum"
replace Gruppe="Brennevin" if Varegruppe=="Tequila"
replace Gruppe="Brennevin" if Varegruppe=="Vodka"
replace Gruppe="Brennevin" if Varegruppe=="Whisk(e)y"

replace Gruppe="Sigaretter" if Varegruppe=="Cigarettes Duty Free"
replace Gruppe="Sigarer" if Varegruppe=="Cigars & Cigarillo DF"
replace Gruppe="Snus" if Varegruppe=="Snus"
replace Gruppe="Tobakk" if Varegruppe=="Tobacco  DF"
replace Gruppe = "Smokers Supply" if Varegruppe == "Cigarette paper"

drop if Gruppe == "Smokers Supply"
label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"


	* Sjekker ev. missing og setter 0 der det er korrekt.
list Gruppe Lufthavn Antall kg l if Antall == .
replace l = 0 if Gruppe == "Brennevin" & l == .
replace l = 0 if Gruppe == "Hetvin" & l == .
replace l = 0 if Gruppe == "Vin" & l == .
replace l = 0 if Gruppe == "Øl" & l == .
replace kg = 0 if Gruppe == "Sigarer" & kg == .
replace kg = 0 if Gruppe == "Tobakk" & kg == .
replace kg = 0 if Gruppe == "Snus" & kg == .
replace kg = 0 if Gruppe == "Sigaretter" & kg == .


replace Antall = l if Gruppe == "Vin"
replace Antall = l if Gruppe == "Øl"
replace Antall = l if Gruppe == "Brennevin"
replace Antall = l if Gruppe == "Hetvin"

replace Antall = kg if Gruppe == "Sigarer"
replace Antall = kg if Gruppe == "Sigaretter"
replace Antall = kg if Gruppe == "Snus" 
replace Antall = kg if Gruppe == "Tobakk"

drop kg l



replace Utsalg = "Ankomst" if Utsalg == "Arrival"
replace Utsalg = "Avgang" if Utsalg == "Departure"
replace Utsalg = "Total" if Utsalg == ""
replace Utsalg = "Total" if Utsalg == "Nonschengen"

/* Kollapser etter grupper*/
collapse (sum) Antall, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall
save "ARN_2024.dta", replace


**** Fila slutter her.


***

/* Samle alle årene i en fil */
clear all


cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"
use "ARN2010-2014.dta", replace
drop if Kvt >= yq(2014,1)
append using "ARN2014.dta"
append using "ARN2015.dta"
append using "ARN2016.dta"
append using "Torp2017.dta"
append using "Torp2018.dta"
append using "ARN2019.dta"
append using "ARN2020-2023.dta"
drop if Kvt >= yq(2022,1)
append using "ARN_2022.dta"
append using "ARN_2023.dta"
append using "ARN_2024.dta"
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




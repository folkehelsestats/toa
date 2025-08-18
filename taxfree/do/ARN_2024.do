
*******************************************************************************
	* Denne fila er opprettet 5/8-2025
	* Fila bygger på daniels/FHIs fil
	* Fila legger til ARN-data for 2024
	* Fila er opprettet av Bente Øvrebø, Hdir.
	* Fila er under arbeid.?

*******************************************************************************

clear all

/* 	STATA do-fil som beskriver hva som blir gjort for å importere ARN-2024-data */ 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\Airport Retail Norway\"


/* Hent in data fra 2024 */
import excel "ARN 2024.xlsx", sheet("Ark1") firstrow clear


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


label var Gruppe "Gruppe"
drop if Gruppe==""
drop Varegruppe*  

/* Justerer fila videre så den bli likt oppsettet med filene fra tidligere år*/

gen Kvt = yq(År, Kvartal)
drop År Kvartal 
format %tq Kvt 
label var Kvt "Kvartal"

rename Flyplass Lufthavn
label var Lufthavn "Lufthavn"

/* Skal ha vin, øl, brennevin og hetvin i liter som er enhet på volum*/
/* Siden antall er hoved-variabel, så erstatter jeg mengden i antall til liter for disse varegruppene*/
replace Antall = Volum if Gruppe == "Vin"
replace Antall = Volum if Gruppe == "Øl"
replace Antall = Volum if Gruppe == "Brennevin"
replace Antall = Volum if Gruppe == "Hetvin"

drop Volum

/* Sletter Sigarettpapir*/
drop if Gruppe == "Smokers Supply"

/*Må få sigretter i stykk, men Snus og Tobakk i kg(?)*/

/* Tobakk*/
replace Antall = Vekt if Gruppe == "Tobakk"

/* Sigaretter*/ 
/* I antall har vi fått oppgitt antall kartonget for sigaretter.
	I en kartong sigaretter har det tidligere vært regnet 200 sigaretter.
	I 2023 var det endring i kvotereglene som gjør at de fleste kartonger nå selges med 100 sigaretter. 
	Særlig på ankomst fra utland butikker. Utreisebutikker kan ha både og.
	Om antall kartonger skal omgjøres til antall sigaretter blir det sannsynligvis mer korrekt å gange med 100 (pga ny kvote). Men innenlandskartonger selger med 200 sigaretter. Dette gjør det kanskje enda viktigere å skille mellom arrival og departure. Men det har vi ikke i tall fra ARN i 2024.*/

	*/ Pga kvote-endrinene og at vi har fått oppgitt sigaretter i kg, beholder vekt-variabel (kg) for sigaretter. Kan være det blir mer korrekt å bruke den variabelen enn å omregne fra antall kartonger siden vi er usikre på om alle kartongene solgt er med 100 sigaretter.

/* SNUS*/
/* Snus: ser ut som antall pakker samsvarer med kg - en pakke er +/- 125g som er kvota.
Antall kg omregnet til gram og delt på 120g ser ut til å gi litt under total antall pakker. Mange snusruller veier litt mindre fordi hver boks veier mellom 16-22g*/

/* Erstatter antall for snus med vekten i kg, som samsvarer med kode i TRN*/ 
replace Antall = Vekt if Gruppe == "Snus"


replace Utsalg = "" if Utsalg == "Total"


/* Kollapser etter ny grupper*/

collapse (sum) Antall Vekt, by(Lufthavn Utsalg Gruppe Kvt)
label var Antall "Antall" 
sort Lufthavn Utsalg Gruppe Kvt 
order Lufthavn Utsalg Kvt Gruppe Antall Vekt
save "ARN2024.dta", replace

**** Fila slutter her.



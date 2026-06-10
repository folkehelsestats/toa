*******************************************************************************
*	Fil opprettet/oppdatert 2026
*	Kobler taxfree-omsetning fra ARN og TRN til én komplett fil.
*		- Sluttfil heter nå Tax-Free 2023-2025.dta
*	Filen er opprettet av Bente Øvrebø, Hdir.

* 	Benyttet CLaude og Copilot til å strukturere og utforme kode.

*******************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\"


********************************************************************************
** DEL 1: Les inn og kombiner data fra ARN og TRN
********************************************************************************

use "Airport Retail Norway\ARN_2023-2025.dta", clear
append using "Travel Retail Norway\TRN 2023-2025.dta"
compress

/* Fjern trailing blanks */
replace Utsalg = rtrim(Utsalg)


********************************************************************************
** DEL 2: Sikre at alle lufthavner og varegrupper finnes i alle kvartal
********************************************************************************

sort Lufthavn
by Lufthavn: tab Kvt
by Lufthavn: tab Kvt Gruppe

tab Utsalg, mi // sjekk missing


/* Legg til totalomsetning der den mangler */
reshape wide Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string
replace AntallTotal = AntallAnkomst + AntallAvgang ///
	if (AntallTotal == .) & (AntallAnkomst != .) & (AntallAvgang != .)

/* Sikre at alle lufthavner har samme varegrupper */
reshape wide Antall*, i(Kvt Gruppe) j(Lufthavn) string
drop if Gruppe == ""
reshape long

/* Sjekker om noen har missing i alle varegrupper - bør ikke ha det på total*/
list Lufthavn Kvt Gruppe if AntallTotal == .

/* Kristiansund har missing i Q1 i 2023 og 2024 og q4 2023. I dialog med ARN er dette 
	mulig pga fravær av utlandsreiser visse kvartal. Ikke nødvendigvis feil. 
	Omsetningen er derfor 0*/

reshape long Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string

replace Antall = 0 if Lufthavn == "Kristiansund" & Kvt == tq(2023q1) & Utsalg == "Total"
replace Antall = 0 if Lufthavn == "Kristiansund" & Kvt == tq(2023q4) & Utsalg == "Total"
replace Antall = 0 if Lufthavn == "Kristiansund" & Kvt == tq(2024q1) & Utsalg == "Total"


********************************************************************************
** Figurer for visuell sjekk av alle flyplassene sammen etter varegruppe:
********************************************************************************

/* Figurer etter varegruppe */
/*
* Brennevin
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Brennevin", ///
		by(Lufthavn, yrescale) ///
		title("Brennevin") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))
		
	* Hetvin
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Hetvin", ///
		by(Lufthavn, yrescale) ///
		title("Hetvin") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	
	
	* Vin
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Vin", ///
		by(Lufthavn, yrescale) ///
		yscale(range(0 .)) ///
		title("Vin") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	

	* Øl
	twoway ///
	 (line Antall Kvt if Utsalg=="Ankomst", lpattern(solid) lcolor(blue)) ///
		(line Antall Kvt if Utsalg=="Avgang", lpattern(solid) lcolor(red)) ///
		(line Antall Kvt if Utsalg=="Total", lpattern(solid) lcolor(green)) ///
		if Gruppe == "Øl", ///
		by(Lufthavn, yrescale) ///
		title("Øl") ///
		xlabel(, angle(45)) ///
		legend(order(1 "Ankomst - Antall" 2 "Avgang - Antall" 3 "Total - Antall"))	
*/



********************************************************************************
** DEL 3: Ved mangel på totalomsetning for noen flyplasser:
** Lag balansert panel, estimer totalomsetning etter liter per utenlandspassasjer. 
********************************************************************************
/* Sjekk missing på total*/
list Lufthavn Kvt if Utsalg == "Total" & Antall == .


reshape wide Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string
reshape wide Antall*, i(Kvt Lufthavn) j(Utsalg) string
egen id = group(Lufthavn), label lname(Lufthavn)
xtset id Kvt, quarterly
tsfill, full
drop Lufthavn
decode id, gen(Lufthavn)
label var Lufthavn "Lufthavn"
drop id

reshape long
reshape long Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string
label var Gruppe "Gruppe"


********************************************************************************
** DEL 4: Legger til utenlandspassasjerer, fil laget tidligere.
** Estimer totalomsetning etter liter per utenlandspassasjer. 
********************************************************************************
********************************************************************************
/* Legger til Passasjerdata */
reshape wide Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string

merge m:1 Kvt Lufthavn using "Passasjerer\Passasjerer SSB 2023-2025.dta"
drop if _merge != 3
drop _merge

reshape long Antall SSB, i(Kvt Lufthavn Gruppe) j(Utsalg) string

rename SSB Utland
label var Utland "Passasjerer"

/* Null utlandspassasjerer = 0 taxfreeomsetning*/
replace Antall = 0 if Utland == 0


reshape wide Antall Utland, i(Kvt Lufthavn Gruppe) j(Utsalg) string

*******************************************************************************
/* Ser på figurer for antall liter per utenlandspassasjer for å se etter feil*/
*******************************************************************************
/*

reshape long

gen AntPas = Antall/Utland // antall liter per passasjer
sort Lufthavn Utsalg Gruppe Kvt 


* Brennevin:
	 * Antall l per utlandspassasjer  
	 twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Brennevin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Brennevin -l per pas") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
	* Antall
  twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Brennevin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Brennevin - l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
	   
* Hetvin
	* Antall l per utlandspassasjer  
	 twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Hetvin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Hetvin -l per pas") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
	* Antall
  twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Hetvin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Hetvin - l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
	   
* Vin	   
	* Antall l per utlandspassasjer  
	 twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Vin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Vin -l per pas") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
	* Antall
  twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Vin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Vin - l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 

* Øl	   
	* Antall l per utlandspassasjer  
	 twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line AntPas Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Øl", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Øl -l per pas") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
	* Antall
  twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
       (line Antall Kvt if Utsalg=="Total", sort cmissing(n)) ///
       if Gruppe=="Øl", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Øl - l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
		

drop AntPas
reshape wide


*******************************************************************************
** Dersom det er noen tydelige feil i Antall / AntPas som synes fra grafene, 
** bør de vurderes videre og ev. erstattes til missing for de Kvt, flyplassene 
** og gruppene det gjelder.
*******************************************************************************
*/


********************************************************************************
** DEL 5: Estimerer ANKOMST og AVGANG for flyplasser som ikke har dette
** I do-fil 4a er det testet ut ulike metoder for å estimere anomst_avgang
** Her brukes den valgte metoden: m2b
********************************************************************************
********************************************************************************

*------- 0. Datapreparering -------*

* Numeriske variabler:
encode Lufthavn, gen(airport)
encode Gruppe,   gen(grp)
gen kvt = quarter(dofq(Kvt)) 

replace AntallAvgang = 0 if AntallTotal == 0

* Utfallsvariabel: ankomstandel av total omsetning (kun trening)
gen andel_ank = AntallAnkomst/AntallTotal 
replace andel_ank = 0 if AntallAnkomst == 0 | AntallTotal == 0

* Forklaringsvariabel: ankomstandel av passasjerene
gen pax_andel_ank = UtlandAnkomst/UtlandTotal
replace pax_andel_ank = 0 if UtlandAnkomst == 0 | UtlandTotal == 0


*=============================================================*
* Endelig prediksjon med metode m2b                           *
* fracreg logit med gruppe + kvartal + passasjerandel         *
*=============================================================*


********************************************************************************
** M2b på fullt datasett — inkludert observasjoner som mangler andel_ank
**
** Modellen estimeres på rader der andel_ank er kjent (ikke missing).
** Prediksjonen kjøres på alle rader, også de som mangler andel_ank.
********************************************************************************

/* Predikere antall ankomst-andel */
fracreg logit andel_ank i.grp i.kvt pax_andel_ank ///
    if andel_ank != ., vce(robust)
	

predict sh_pred

* Sanity check

/* Gjennomsnitt bør matche og min ikke under 0, maks ikke over 1*/
tabstat andel_ank sh_pred if andel_ank !=.,  stat(mean sd min max) by(grp)
tabstat andel_ank sh_pred, stat(mean sd min max) by(grp)


/* Korrelasjonsplot per gruppe */
	/* Se etter hvor tett den ligger på 45-graderslinja*/
twoway (scatter andel_ank sh_pred) ///
       (function y=x, range(0 1) lcolor(gs8) lpattern(dash)), ///
    by(grp, yrescale) ///
    title("Faktisk vs. predikert andel") ///
    xtitle("Predikert") ytitle("Faktisk")
	

* Lager predikerte verdier der vi mangler observasjoner
gen AntallAnkomst_final = sh_pred * AntallTotal
gen AntallAvgang_final = AntallTotal - AntallAnkomst_final

* Erstatt med faktiske verdier der vi har observasjoner
replace AntallAnkomst_final = AntallAnkomst if andel_ank !=.
replace AntallAvgang_final = AntallAvgang if andel_ank !=.

label var AntallAnkomst_final "Liter ankomst (inkl. estimert v/ M2b)"
label var AntallAvgang_final  "Liter avgang (inkl. estimert v/ M2b)"

*--- Konsistenssjekk: ankomst + avgang = total ---*
gen diff = (abs(AntallAnkomst_final + AntallAvgang_final) - AntallTotal)

di _n "=== Konsistenssjekk: differanse mellom (ank+avg) og total ==="
sum diff
list Lufthavn Kvt Gruppe AntallTotal AntallAnkomst_final AntallAvgang_final ///
    diff if diff > 0.001
	* Viser de flyplassene og kvartalene med sig avvik. 
	
*--- Sjekk for missing i prediksjonene ---*
di _n "=== Sjekk for missing i endelige tall ==="
count if missing(AntallAnkomst_final) & andel_ank ==.
count if missing(AntallAvgang_final)  & andel_ank ==.


* Treningsutvalg (flyplasser med komplett ankomst/avgang-data)
gen byte training = inlist(Lufthavn, "Oslo", "Bergen", "Stavanger", ///
    "Trondheim", "Molde", "Torp", "Ålesund")
	
	
*--- Oversikt over predikert ankomstandel per testflyplass og gruppe ---*
di _n "=== Predikert ankomstandel per testflyplass ==="
table Gruppe Lufthavn if training==0, stat(mean sh_pred) // predikert andel
di _n "=== Ankomstandel per flyplass med dette ==="
table Gruppe Lufthavn if training==1, stat(mean andel_ank) // faktisk observert andel


*--- Rimelighetssjekk: ligger andelen i et fornuftig intervall? ---*
di _n "=== Range for predikert andel (testflyplasser) ==="
sum sh_pred if training==0, detail

drop sh_pred



********************************************************************************
*---- LAGER FIGURER -------*
********************************************************************************

** Alle flyplsser i en figur:
* Brennevin
  twoway (line AntallAnkomst_final Kvt, sort cmissing(n)) ///
       (line AntallAvgang_final Kvt, sort cmissing(n)) ///
       (line AntallTotal Kvt, sort cmissing(n)) ///
       if Gruppe=="Brennevin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Brennevin - Est_l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 

* Hetvin
  twoway (line AntallAnkomst_final Kvt, sort cmissing(n)) ///
       (line AntallAvgang_final Kvt, sort cmissing(n)) ///
       (line AntallTotal Kvt, sort cmissing(n)) ///
       if Gruppe=="Hetvin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Hetvin - Est_l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 

* Vin
  twoway (line AntallAnkomst_final Kvt, sort cmissing(n)) ///
       (line AntallAvgang_final Kvt, sort cmissing(n)) ///
       (line AntallTotal Kvt, sort cmissing(n)) ///
       if Gruppe=="Vin", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Vin - Est_l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 
		
* Øl
  twoway (line AntallAnkomst_final Kvt, sort cmissing(n)) ///
       (line AntallAvgang_final Kvt, sort cmissing(n)) ///
       (line AntallTotal Kvt, sort cmissing(n)) ///
       if Gruppe=="Øl", ///
       ylabel(#2) ///
       by(Lufthavn, yrescale note("")) ///
	   title("Øl - Est_l") ///
	   legend(order(1 "Ankomst" 2 "Avgang" 3 "Total")) ///
		xlabel(, angle(45)) 

********************************************************************************
** Ferdigstiller fila for videre arbeid:

replace AntallAnkomst = AntallAnkomst_final if AntallAnkomst ==.
replace AntallAvgang = AntallAvgang_final if AntallAvgang ==.

drop airport- training


reshape long Antall Utland, i(Kvt Lufthavn Gruppe) j(Utsalg) string
sort Kvt Lufthavn 

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\"
save "Tax-Free 2023-2025.dta", replace


**** Filen slutter her.

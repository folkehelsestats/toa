*******************************************************************************
*	Fil opprettet/oppdatert 2026
*	Filer med tall som skal inn i ToA.
*******************************************************************************
*	Fila lager filer med tall relevante inn i ToA.

*	Filen er opprettet av Bente Øvrebø, Hdir.
* 	Benyttet CLaude og Copilot til å strukturere og utforme kode.
*******************************************************************************
cd "O:\Prosjekt\Rusdata\Omsetning\"

********************************************************************************
** DEL 1: Hent inn taxfree-data og kollaps per kvartal
********************************************************************************

use "Taxfree_originalfiler\Tax-Free 2023-2025.dta", clear

drop Utland 
collapse (sum) Antall, by(Kvt Gruppe Utsalg) // trenger ikke Lufthavn lenger

reshape wide Antall, i(Gruppe Kvt) j(Utsalg) string
*reshape wide Antall*, i(Gruppe) j(Kvt) // kolonner for Antall og Utland etter ankomst, avgang og total (med Kvt)

********************************************************************************
	/* Bregne mengde ren alkohol per varegruppe (alkohol % er like SSB sine) */
********************************************************************************	
	
	** Brennevin
gen AntallRenAnkomst     = AntallAnkomst    * 0.3900 if Gruppe == "Brennevin"
gen AntallRenAvgang      = AntallAvgang     * 0.3900 if Gruppe == "Brennevin"
gen AntallRenTotal      = AntallTotal     * 0.3900 if Gruppe == "Brennevin"

	** Hetvin
replace AntallRenAnkomst     = AntallAnkomst    * 0.1690 if Gruppe == "Hetvin"
replace AntallRenAvgang      = AntallAvgang     * 0.1690 if Gruppe == "Hetvin"
replace AntallRenTotal      = AntallTotal     * 0.1690 if Gruppe == "Hetvin"

	** Vin
replace AntallRenAnkomst     = AntallAnkomst    * 0.1230 if Gruppe == "Vin"
replace AntallRenAvgang      = AntallAvgang     * 0.1230 if Gruppe == "Vin"
replace AntallRenTotal      = AntallTotal     * 0.1230 if Gruppe == "Vin"

	** Øl
replace AntallRenAnkomst     = AntallAnkomst    * 0.0447 if Gruppe == "Øl"
replace AntallRenAvgang      = AntallAvgang     * 0.0447 if Gruppe == "Øl"
replace AntallRenTotal      = AntallTotal     * 0.0447 if Gruppe == "Øl"

	* Sanity check
	gen sjekk = AntallRenTotal - AntallRenAvgang
	gen sjekk2 = abs(sjekk-AntallRenAnkomst) 
	drop sjekk sjekk2


/* ANKOMST-tabell fra taxfree i 1000 vareliter og ren alkohol */


gen År = year(dofq(Kvt))
collapse (sum) AntallAnkomst AntallRenAnkomst AntallAvgang AntallRenAvgang AntallTotal AntallRenTotal, by(År Gruppe)
gen Ankomst = AntallAnkomst / 1000
gen AnkomstRen = AntallRenAnkomst / 1000

gen Avgang = AntallAvgang / 1000
gen AvgangRen = AntallRenAvgang / 1000

gen Total = AntallTotal / 1000
gen TotalRen = AntallRenTotal / 1000

* Sanity check
	gen sjekk = Total - Avgang 
	gen sjekk2 = abs(sjekk-Ankomst) 
	drop sjekk sjekk2
	
drop Antall*

reshape wide Ankomst* Avgang* Total*, i(År) j(Gruppe) string

gen RenAlkoholAnkomst = AnkomstRenBrennevin+ AnkomstRenHetvin+ AnkomstRenVin+ AnkomstRenØl
drop AnkomstRen*
gen RenAlkoholAvgang = AvgangRenBrennevin+ AvgangRenHetvin+ AvgangRenVin+ AvgangRenØl
drop AvgangRen*
gen RenAlkoholTotal = TotalRenBrennevin+ TotalRenHetvin+ TotalRenVin+ TotalRenØl
drop TotalRen*

/*
rename AnkomstBrennevin Brennevin
rename AnkomstHetvin Hetvin
rename AnkomstVin Vin
rename AnkomstØl Øl
*/
gen AnkomstVinHetvin = AnkomstVin + AnkomstHetvin 
gen AvgangVinHetvin = AvgangVin + AvgangHetvin 
gen TotalVinHetvin = TotalVin + TotalHetvin 

export excel using "O:\Prosjekt\Rusdata\Omsetning\Rapporter_mm_org\Til ToA\Taxfree ankomstomsetning 2023-2025.xlsx_tilSSB", firstrow(variables) replace
drop Avgang* Total*
*order År Øl Vin Hetvin VinHetvin Brennevin RenAlkohol

/* Ren alkohol per innbygger */
gen over15aar = 4572917 // 2023
replace over15aar = 4639075 if År == 2024  
replace over15aar = 4691770 if År == 2025
gen over15Ankomst = (RenAlkohol / over15aar)*1000 // for å få i liter per pers


/* Exporter fil */
export excel using "O:\Prosjekt\Rusdata\Omsetning\Rapporter_mm_org\Til ToA\Taxfree ankomstomsetning 2023-2025.xlsx", firstrow(variables) replace


	
	/* Ikke lenger aktuell, lagt inn over.
********************************************************************************
** DEL 4: Beregn per-passasjer lite
** 		  Befolkning over 15 år (per kalenderår) (OBS - ikke 1000 liter)
********************************************************************************
gen År = year(dofq(Kvt))
collapse (sum) AntallAnkomst AntallRenAnkomst, by(År Gruppe)

/* Må legge sammen vin og hetvin*/
reshape wide Antall*, i(År) j(Gruppe) string

gen AntallAnkomstVinHetvin = AntallAnkomstHetvin+ AntallAnkomstVin
gen AntallRenAnkomstVinHetvin = AntallRenAnkomstHetvin + AntallRenAnkomstVin


drop AntallAnkomstHetvin AntallRenAnkomstHetvin AntallAnkomstVin AntallRenAnkomstVin

reshape long


/* For å få 1000 vareliter omsatt ved ankomst*/
gen Ankomst = AntallAnkomst / 1000
gen AnkomstRen = AntallRenAnkomst / 1000

drop Antall* // Beholder kun 1000 vareliter

/*
gen over15aar = 4572917 // 2023
replace over15aar = 4639075 if År == 2024  
replace over15aar = 4691770 if År == 2025
*/

rename Ankomst Vareliter1000
rename AnkomstRen RenAlkohol1000

list År Gruppe Vareliter1000 RenAlkohol1000 

/* Collapser for å få ren alkohol per  år og liter ren alkohol totalt per innbygger*/
preserve
collapse (sum) RenAlkohol1000, by(År)
list År RenAlkohol1000
gen over15aar = 4572917 // 2023
replace over15aar = 4639075 if År == 2024  
replace over15aar = 4691770 if År == 2025
gen over15Ankomst = (RenAlkohol1000 / over15aar)*1000
list År RenAlkohol1000 over15Ankomst
restore

*/
********************************************************************************
** DEL 5: SSB-tall
** 		  Avgiftbasert omsetning i samme format
********************************************************************************

clear all
cd "O:\Prosjekt\Rusdata\Omsetning\"

use "SSB_originalfiler\Omsetningsstatistikk\SSB_Alkoholstatistikk.dta"


drop if Kvt < yq(2023,1)

gen År = year(dofq(Kvt))
collapse (sum) AntallSSB AntallRenSSB AntallRen15SSB, by(År Gruppe)

/* Ren alkoholliter per innbygger 15+ */
list År AntallRen15SSB if Gruppe == "Alkohol"


/* For å få 1000 vareliter omsatt ved ankomst*/
gen Vareliter1000 = AntallSSB / 1000 // 
gen RenAlkohol1000 = AntallRenSSB / 1000 // 

drop Antall* // Beholder kun 1000 vareliter

/* 1000 vareliter for brennevin, rusbrus, vin og øl, og ren alkohol (Alkoholgruppe) */
list År Gruppe Vareliter1000


/* Sanity check*/
gen over15aar = 4572917 // 2023
replace over15aar = 4639075 if År == 2024  
replace over15aar = 4691770 if År == 2025

gen over15Ren = (RenAlkohol1000 / over15aar)*1000 if Gruppe == "Alkohol"

/* Liste over ren alkohol i liter per innbygger over 15 år */
list År over15Ren if Gruppe == "Alkohol"



**** Filen slutter her.
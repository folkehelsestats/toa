********************************************************************************
** Test av ulike metoder for å estimere ankomst og avgang andeler for flyplasser 
** som mangler dette, basert på totalomsetning mm.
********************************************************************************

clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\"


********************************************************************************
** DEL 1: Les inn og kombiner rådata fra alle ARN og TRN
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

/* Sikrer at tidsvariabel er komplett*/
reshape wide Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string
reshape wide Antall*, i(Kvt Lufthavn) j(Utsalg) string
egen id = group(Lufthavn), label lname(Lufthavn)
xtset id Kvt, quarterly
tsfill, full // tsfill is used to fill in gaps in time-series data and gaps in panel data with new observations, which contain missing values.
drop Lufthavn
decode id, gen(Lufthavn)
label var Lufthavn "Lufthavn"
drop id

reshape long
reshape long Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string
label var Gruppe "Gruppe"


/* Legger til Passasjerdata som inkluderer andel ankomst*/
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


********************************************************************************
********************************************************************************
**
**	Estimerer ankomst/avgang-andeler for flyplasser som mangler dette.
** 	Tester først ulike metoder for å gjøre dette.
**
********************************************************************************
********************************************************************************


*=============================================================*
* Disaggregering av taxfree-omsetning på ankomst og avgang   *
* Tester tre metoder med leave-one-airport-out validering    *
*=============================================================*

*------- 0. Datapreparering -------*

* Numeriske variabler:
encode Lufthavn, gen(airport)
encode Gruppe,   gen(grp)
gen kvt = quarter(dofq(Kvt)) 

* Treningsutvalg (flyplasser med komplett ankomst/avgang-data)
gen byte training = inlist(Lufthavn, "Oslo", "Bergen", "Stavanger", ///
    "Trondheim", "Molde", "Torp", "Ålesund")

* Indikator for store flyplasser (TRN + Torp). OBS! Torp har mange utlandspassasjerer, derfor inkludert her.
gen byte stor = inlist(Lufthavn, "Bergen", "Oslo", "Stavanger", "Trondheim", "Torp")
	table Lufthavn, stat(sum UtlandTotal UtlandAnkomst UtlandAvgang)
	gen dato = dofq(Kvt)
	format dato %td
	gen aar    = year(dato)
	table Lufthavn aar, stat (sum UtlandTotal UtlandAnkomst UtlandAvgang)
	drop dato aar


* Utfallsvariabel: ankomstandel av total omsetning (kun trening)
gen andel_ank = AntallAnkomst/AntallTotal if training==1

* Tilgjengelig driver på ALLE flyplasser: ankomstandel av passasjerene
gen pax_andel_ank = UtlandAnkomst/UtlandTotal
replace pax_andel_ank = 0 if UtlandAnkomst == 0 // Noen flyplasser har 0 utlandspassasjerer noen kvarter

* Liter per passasjer (kun trening)
gen lpp_ank = AntallAnkomst/UtlandAnkomst if training==1
gen lpp_avg = AntallAvgang/UtlandAvgang if training==1

* Oversiktssjekk:
sum andel_ank pax_andel_ank lpp_ank lpp_avg if training==1
tab Lufthavn training, m



*******************************************************************************
*  LOO_estimering_alle_metoder.do
*
*  Kjører leave-one-out (LOO) estimering for alle metoder.
*  For hver flyplass i treningsdataene utelates den én gang, og alle
*  metoder predikerer andel_ank (ankomstandel av total omsetning)
*  basert på de resterende flyplassene.
*
*  Metoder:
*    M1a  — Gj.snitt andel per gruppe
*    M1b  — Gj.snitt andel per gruppe × kvartal
*    M1c  — Gj.snitt andel per gruppe × kvartal × størrelse
*    M2a  — Fracreg: gruppe + kvartal
*    M2b  — Fracreg: gruppe + kvartal + passasjerandel
*    M2c  — Fracreg: gruppe + kvartal + passasjerandel + totalomsetning
*    M3   — Liter per passasjer, skalert til totalomsetning
*    M4   — OLS per varegruppe separat: pax_andel_ank + kvartal
*
*  For M4: predikerte andeler klippes til [0, 1] med advarsel.
*  Missing i pred_m4 betyr at regresjonen ikke lot seg identifisere
*  for den aktuelle kombinasjonen av flyplass og gruppe.
*******************************************************************************


********************************************************************************
** Initialiser prediksjonsvariabler
********************************************************************************

foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
    capture drop pred_`m'
    gen pred_`m' = .
}

quietly levelsof airport if training==1, local(loo)


********************************************************************************
** Hoved-LOO-løkke
********************************************************************************

foreach a of local loo {

    *--- METODE 1: andelsmetoder ---*
    /*
      Beregner gjennomsnittsandelen blant alle treningsflyplasser UNNTATT a.
      cond(airport==`a', ., andel_ank) setter observasjoner fra a til missing
      slik at egen mean() ignorerer dem. Resultatet ganges med AntallTotal
      for flyplass a for å gi predikert liter-omsetning ved ankomst.
    */

    * 1a: andel etter gruppe alene
    capture drop sh_loo
    bysort grp: egen sh_loo = mean(cond(airport==`a', ., andel_ank))
    replace pred_m1a = sh_loo * AntallTotal if airport==`a'

    * 1b: andel etter gruppe × kvartal
    capture drop sh_loo
    bysort grp kvt: egen sh_loo = mean(cond(airport==`a', ., andel_ank))
    replace pred_m1b = sh_loo * AntallTotal if airport==`a'

    * 1c: andel etter gruppe × kvartal × størrelse
    capture drop sh_loo
    bysort grp kvt stor: egen sh_loo = mean(cond(airport==`a', ., andel_ank))
    replace pred_m1c = sh_loo * AntallTotal if airport==`a'


    *--- METODE 2: fracreg logit ---*
    /*
      Modellen estimeres på alle treningsflyplasser unntatt a, predikerer
      andelen for a, og ganger med totalen. fracreg logit er bedre egnet
      enn OLS for andeler fordi den respekterer [0, 1]-grensene i
      estimeringssteget. sum sh_pred viser min/max som kontroll.
    */

    * 2a: gruppe + kvartal
    capture drop sh_pred
    quietly fracreg logit andel_ank i.grp i.kvt ///
        if training==1 & airport!=`a'
    quietly predict sh_pred if airport==`a'
    sum sh_pred if airport==`a'
    replace pred_m2a = sh_pred * AntallTotal if airport==`a'

    * 2b: gruppe + kvartal + passasjerandel
    capture drop sh_pred
    quietly fracreg logit andel_ank i.grp i.kvt pax_andel_ank ///
        if training==1 & airport!=`a'
    quietly predict sh_pred if airport==`a'
    sum sh_pred if airport==`a'
    replace pred_m2b = sh_pred * AntallTotal if airport==`a'

    * 2c: gruppe + kvartal + passasjerandel + totalomsetning
    capture drop sh_pred
    quietly fracreg logit andel_ank i.grp i.kvt pax_andel_ank AntallTotal ///
        if training==1 & airport!=`a'
    quietly predict sh_pred if airport==`a'
    sum sh_pred if airport==`a'
    replace pred_m2c = sh_pred * AntallTotal if airport==`a'


    *--- METODE 3: liter per passasjer ---*
    /*
      Beregner gjennomsnittlig liter-per-passasjer (ankomst og avgang separat)
      fra alle treningsflyplasser unntatt a, multipliserer med a sine
      passasjertall og skalerer slik at sum(ankomst + avgang) = AntallTotal.
      Skaleringen er viktig: rå-prediksjonene treffer ikke nødvendigvis
      totalen, men siden vi kjenner totalen tvinger vi splittingen til å
      være konsistent med den.
    */

    capture drop lpp_a_loo lpp_d_loo raw_a raw_d
    bysort grp kvt: egen lpp_a_loo = mean(cond(airport==`a', ., lpp_ank))
    bysort grp kvt: egen lpp_d_loo = mean(cond(airport==`a', ., lpp_avg))
    gen raw_a = lpp_a_loo * UtlandAnkomst if airport==`a'
    gen raw_d = lpp_d_loo * UtlandAvgang  if airport==`a'
    replace pred_m3 = raw_a / (raw_a + raw_d) * AntallTotal if airport==`a'


    *--- METODE 4: OLS-regresjon per varegruppe, LOO ---*
    /*
      Viktig skilnad fra M2: M2 kjører én felles modell med gruppe-FE
      der alle grupper deler koeffisientene for pax_andel_ank og i.kvt.
      M4 kjører en separat regresjon PER gruppe — Brennevin, Vin, Øl osv.
      har dermed egne sesongprofiler og egen sensitivitet til
      passasjerandelen.

      Dobbel løkke:
        Ytre løkke (over airport): LOO — flyplass a utelates fra trening
        Indre løkke (over grp):    separat regresjon per varegruppe

      capture på regress: håndterer tilfeller der en gruppe har for
      få observasjoner etter at a er fjernet (f.eks. kun 1 flyplass
      igjen). Feiler regresjonen, forblir pred_m4 missing for den
      kombinasjonen — fanges opp i valideringssteget.

      [0,1]-klipping: OLS garanterer ikke at predikerte andeler er
      innenfor [0, 1]. Verdier utenfor er et tegn på ekstrapolering.
      Vi rapporterer og klipper. Mange advarsler for samme grp er et
      signal om at M4 bør erstattes av M1b for den gruppen.
    */

    quietly levelsof grp, local(grps)

    foreach i of local grps {

        capture drop sh_pred

        capture quietly regress andel_ank pax_andel_ank i.kvt ///
            if grp==`i' & training==1 & airport!=`a'

        if _rc == 0 {

            quietly predict sh_pred if airport==`a' & grp==`i', xb

            /* Sjekk og korriger prediksjoner under 0 */
            count if sh_pred < 0 & airport==`a' & grp==`i'
            if r(N) > 0 {
                display as error ///
                    "M4: `r(N)' pred < 0 for airport=`a', grp=`i' — klippes til 0"
                replace sh_pred = 0 ///
                    if sh_pred < 0 & airport==`a' & grp==`i'
            }

            /* Sjekk og korriger prediksjoner over 1
               (sh_pred != . fordi Stata behandler missing som +uendelig) */
            count if sh_pred > 1 & sh_pred != . & airport==`a' & grp==`i'
            if r(N) > 0 {
                display as error ///
                    "M4: `r(N)' pred > 1 for airport=`a', grp=`i' — klippes til 1"
                replace sh_pred = 1 ///
                    if sh_pred > 1 & sh_pred != . & airport==`a' & grp==`i'
            }

            replace pred_m4 = sh_pred * AntallTotal ///
                if airport==`a' & grp==`i'
        }
    }

}

**** Løkken slutter her.

******************************* Validering *************************************
/* Sjekk av metodene opp mot faktisk observerte verdier og 
% feilmargin fra observert vs predikert */


*--- Feilmål for alle metoder ---*
	/* absolutt feil */
foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
    capture drop abserr_`m' 
    gen abserr_`m' = abs(pred_`m' - AntallAnkomst) // absolutt avvik fra faktisk (fjerner - om verdien er neg)
}

*--- WAPE per metode (totalt) ---*
/* Forklaring: Total/overordnet feil i % fra faktisk liter omsatt for de ulike modellene. Lavere tall er bedre*/
di _n "=== WAPE TOTALT ==="
foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
    quietly sum abserr_`m' if training==1
    local sum_err = r(sum) // sum_err = total bom i liter
    quietly sum AntallAnkomst if training==1
    local sum_act = r(sum) // total faktisk omsetning i liter
    di "WAPE `m': " %5.1f (`sum_err'/`sum_act')*100 "%"
}



*--- WAPE per varegruppe ---*
/* Feilmargin for varegruppe - for å se om de uliek modellene estimerer mer/mindre korrekt for de ulike varegruppene */
di _n "=== WAPE PER VAREGRUPPE ==="
quietly levelsof Gruppe, local(grupper)
foreach g of local grupper {
    di _n "Gruppe: `g'"
    foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
        quietly sum abserr_`m' if training==1 & Gruppe=="`g'"
        local sum_err = r(sum)
        quietly sum AntallAnkomst if training==1 & Gruppe=="`g'"
        local sum_act = r(sum)
        di "  WAPE `m': " %5.1f (`sum_err'/`sum_act')*100 "%"
    }
}

*--- WAPE per flyplass (særlig viktig: Molde, Ålesund - likere de som mangler!?) ---*
di _n "=== WAPE PER FLYPLASS ==="
quietly levelsof Lufthavn if training==1, local(flyplasser)
foreach lh of local flyplasser {
    di _n "Flyplass: `lh'"
    foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
        quietly sum abserr_`m' if training==1 & Lufthavn=="`lh'"
        local sum_err = r(sum)
        quietly sum AntallAnkomst if training==1 & Lufthavn=="`lh'"
        local sum_act = r(sum)
        di "  WAPE `m': " %5.1f (`sum_err'/`sum_act')*100 "%"
    }
}


*===========     FIGURER    ====================*

* 1** Predikert vs observert (scatter 45-grader)

* Lag samlet figur med alle metoder
foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
    twoway (scatter pred_`m' AntallAnkomst if training==1, ///
                msize(small) mcolor(navy%50)) ///
           (function y=x, range(AntallAnkomst) lcolor(red) lpattern(dash)), ///
           title("Metode `m'") ///
           xtitle("Observert (liter)") ytitle("Predikert (liter)") ///
           legend(off) ///
           name(scat_`m', replace) nodraw
}

graph combine scat_m1a scat_m1b scat_m1c scat_m2a scat_m2b scat_m2c scat_m3 scat_m4, ///
    cols(3) title("Predikert vs observert ankomstomsetning") ///
    name(scatter_all, replace)
	
* 2** Feilfordeling - Boxplot per metode.

* Lag prosent-feil per metode (signert, ikke absolutt)
foreach m in m1a m1b m1c m2a m2b m2c m3 m4 {
    capture drop pe_`m'
    gen pe_`m' = (pred_`m' - AntallAnkomst)/AntallAnkomst * 100 ///
        if training==1 & AntallAnkomst > 0
}

graph box pe_m1a pe_m1b pe_m1c pe_m2a pe_m2b pe_m2c pe_m3 pe_m4, ///
    title("Prosentvis feil per metode") ///
    ytitle("(Predikert - Observert) / Observert (%)") ///
    yline(0, lcolor(red) lpattern(dash)) ///
    legend(label(1 "1a") label(2 "1b") label(3 "1c") ///
           label(4 "2a") label(5 "2b") label(6 "2c") label(7 "3") label(8 "4")) ///
    name(box_methods, replace)
	
	

* 4** Tidssetie per flyplass (observert + predikert) - for valgt metode

* Velg metode du vil visualisere – f.eks. den beste fra LOO-testen
local valgt_metode "m2b"

foreach lh in "Molde" "Torp" "Ålesund" "Oslo" "Bergen" "Stavanger" "Trondheim" {
    twoway (line AntallAnkomst Kvt if Lufthavn=="`lh'", sort cmissing(n) ///
                lcolor(navy) lwidth(medthick)) ///
           (line pred_`valgt_metode' Kvt if Lufthavn=="`lh'", sort cmissing(n) ///
                lcolor(red) lpattern(dash)), ///
           by(Gruppe, title("`lh' – metode `valgt_metode'") ///
                yrescale note("")) ///
           xtitle("Kvartal") ytitle("Liter") ///
           legend(label(1 "Observert") label(2 "Predikert") rows(1)) ///
           name(ts_`lh', replace)
}

* Velg metode du vil visualisere – f.eks. den beste fra LOO-testen
local valgt_metode "m4" // Daniels metode

foreach lh in "Molde" "Torp" "Ålesund" "Oslo" "Bergen" "Stavanger" "Trondheim" {
    twoway (line AntallAnkomst Kvt if Lufthavn=="`lh'", sort cmissing(n) ///
                lcolor(navy) lwidth(medthick)) ///
           (line pred_`valgt_metode' Kvt if Lufthavn=="`lh'", sort cmissing(n) ///
                lcolor(red) lpattern(dash)), ///
           by(Gruppe, title("`lh' – metode `valgt_metode'") ///
                yrescale note("")) ///
           xtitle("Kvartal") ytitle("Liter") ///
           legend(label(1 "Observert") label(2 "Predikert") rows(1)) ///
           name(ts_`lh', replace)
}




********************************************************************************
/* FIGURER SOM HAR MED DE ULIKE MODELLENE for hver varegruppe*/
********************************************************************************



** ØL
twoway ///
(line AntallAnkomst     Kvt, sort cmissing(n) lcolor(black) lwidth(medthick)) ///
(line pred_m1a  		Kvt, sort cmissing(n) lcolor(pink)) ///
(line pred_m1b    		Kvt, sort cmissing(n) lcolor(brown)) ///
(line pred_m1c 			Kvt, sort cmissing(n) lcolor(purple)) ///
(line pred_m2a 			Kvt, sort cmissing(n) lcolor(gray)) ///
(line pred_m2b    		Kvt, sort cmissing(n) lcolor(blue)) ///
(line pred_m2c    		Kvt, sort cmissing(n) lcolor(red)) ///
(line pred_m3    		Kvt, sort cmissing(n) lcolor(green)) ///
(line pred_m4    		Kvt, sort cmissing(n) lcolor(orange)) ///
if Gruppe == "Øl" & training == 1, ///
by(Lufthavn, yrescale note("") ///
   title("Øl – liter ved ankomst")) ///
legend(order(1 "Observert andel" ///
             2 "Estimert (modell 1a)" ///
             3 "Estimert (modell 1b)" ///
			 4 "Estimert (modell 1c)" ///
             5 "Estimert (modell 2a)" ///
             6 "Estimert (modell 2b)" ///
             7 "Estimert (modell 2c)" ///			 
             8 "Estimert (modell 3)" ///
             9 "Estimert (modell 4)")) ///
xtitle("Kvartal") ///
ytitle("Liter") ///
xlabel(, angle(45))



** VIN
twoway ///
(line AntallAnkomst     Kvt, sort cmissing(n) lcolor(black) lwidth(medthick)) ///
(line pred_m1a  		Kvt, sort cmissing(n) lcolor(pink)) ///
(line pred_m1b    		Kvt, sort cmissing(n) lcolor(brown)) ///
(line pred_m1c 			Kvt, sort cmissing(n) lcolor(purple)) ///
(line pred_m2a 			Kvt, sort cmissing(n) lcolor(gray)) ///
(line pred_m2b    		Kvt, sort cmissing(n) lcolor(blue)) ///
(line pred_m2c    		Kvt, sort cmissing(n) lcolor(red)) ///
(line pred_m3    		Kvt, sort cmissing(n) lcolor(green)) ///
(line pred_m4    		Kvt, sort cmissing(n) lcolor(orange)) ///
if Gruppe == "Vin" & training == 1, ///
by(Lufthavn, yrescale note("") ///
   title("Vin – liter ved ankomst")) ///
legend(order(1 "Observert andel" ///
             2 "Estimert (modell 1a)" ///
             3 "Estimert (modell 1b)" ///
			 4 "Estimert (modell 1c)" ///
             5 "Estimert (modell 2a)" ///
             6 "Estimert (modell 2b)" ///
             7 "Estimert (modell 2c)" ///			 
             8 "Estimert (modell 3)" ///
             9 "Estimert (modell 4)")) ///
xtitle("Kvartal") ///
ytitle("Liter") ///
xlabel(, angle(45))

** Hetvin
twoway ///
(line AntallAnkomst     Kvt, sort cmissing(n) lcolor(black) lwidth(medthick)) ///
(line pred_m1a  		Kvt, sort cmissing(n) lcolor(pink)) ///
(line pred_m1b    		Kvt, sort cmissing(n) lcolor(brown)) ///
(line pred_m1c 			Kvt, sort cmissing(n) lcolor(purple)) ///
(line pred_m2a 			Kvt, sort cmissing(n) lcolor(gray)) ///
(line pred_m2b    		Kvt, sort cmissing(n) lcolor(blue)) ///
(line pred_m2c    		Kvt, sort cmissing(n) lcolor(red)) ///
(line pred_m3    		Kvt, sort cmissing(n) lcolor(green)) ///
(line pred_m4    		Kvt, sort cmissing(n) lcolor(orange)) ///
if Gruppe == "Hetvin" & training == 1, ///
by(Lufthavn, yrescale note("") ///
   title("Hetvin – liter ved ankomst")) ///
legend(order(1 "Observert andel" ///
             2 "Estimert (modell 1a)" ///
             3 "Estimert (modell 1b)" ///
			 4 "Estimert (modell 1c)" ///
             5 "Estimert (modell 2a)" ///
             6 "Estimert (modell 2b)" ///
             7 "Estimert (modell 2c)" ///			 
             8 "Estimert (modell 3)" ///
             9 "Estimert (modell 4)")) ///
xtitle("Kvartal") ///
ytitle("Liter") ///
xlabel(, angle(45))

** Brennevin
twoway ///
(line AntallAnkomst     Kvt, sort cmissing(n) lcolor(black) lwidth(medthick)) ///
(line pred_m1a  		Kvt, sort cmissing(n) lcolor(pink)) ///
(line pred_m1b    		Kvt, sort cmissing(n) lcolor(brown)) ///
(line pred_m1c 			Kvt, sort cmissing(n) lcolor(purple)) ///
(line pred_m2a 			Kvt, sort cmissing(n) lcolor(gray)) ///
(line pred_m2b    		Kvt, sort cmissing(n) lcolor(blue)) ///
(line pred_m2c    		Kvt, sort cmissing(n) lcolor(red)) ///
(line pred_m3    		Kvt, sort cmissing(n) lcolor(green)) ///
(line pred_m4    		Kvt, sort cmissing(n) lcolor(orange)) ///
if Gruppe == "Brennevin" & training == 1, ///
by(Lufthavn, yrescale note("") ///
   title("Brennevin – liter ved ankomst")) ///
legend(order(1 "Observert andel" ///
             2 "Estimert (modell 1a)" ///
             3 "Estimert (modell 1b)" ///
			 4 "Estimert (modell 1c)" ///
             5 "Estimert (modell 2a)" ///
             6 "Estimert (modell 2b)" ///
             7 "Estimert (modell 2c)" ///			 
             8 "Estimert (modell 3)" ///
             9 "Estimert (modell 4)")) ///
xtitle("Kvartal") ///
ytitle("Liter") ///
xlabel(, angle(45))



** Velg metode og benytt den i 4 Taxfree_total.do

** Filen slutter her. 
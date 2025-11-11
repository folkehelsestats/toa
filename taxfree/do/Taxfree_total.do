*******************************************************************************

	** Fil opprettet for å koble sammen taxfreomsetning fra ulike kilder.
	** Filen tar utgangspunkt i do-fil fra FHI.
	** Denne filen er opprettet 5/8-2025 av Bente Øvrebø, Hdir.
	** Filen er ikke ferdig.

*******************************************************************************


clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\"
	
/* Hent inn taxfree omsetningen ved norske luftahvner.
   Noen ganger er ankomst avgang slått sammen, beregn ved hjelp av estimerte 
   andeler. Også snus og tobakk er slått sammen i TRN i 2010, og etter 2Q2019,
   og Brennevin og Hetvin. Beregn ved hjelp av estimerte andeler. */
   
use "Avinor\Avinor 2010-2020.dta", clear
append using "Airport Retail Norway\ARN2010-2024.dta"
append using "Travel Retail Norway\TRN2010-2024.dta"
compress


/* Fjern "trailing blanks" */
replace Utsalg = rtrim(Utsalg)

/* Rusbrus og sider fjernes, kun ARN selger noen av dette. Få sigarer, 
   det er dessuten urklart hvordan dette rapporteres, i kg eller stk? */
drop if Gruppe == "Rusbrus"
drop if Gruppe == "Sider"
drop if Gruppe == "Sigarer"

/* Tre Flyplasser mangler, kun årsdata. Legg de til med missing records for å
   estimere omsetningen per kvartal. */ 
local new = _N + 3
set obs `new'

replace Kvt = yq(2010,1) in -3/-1
replace Lufthavn = "Fagernes" in -1
replace Lufthavn = "Kristiansund" in -2
replace Lufthavn = "Lakselv" in -3
replace Utsalg = "Totalt" if Utsalg=="" 

/* Legg til Total omsetning, der den ikke finnes */ 
reshape wide Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string
replace AntallTotalt = AntallAnkomst + AntallAvgang /// 
	if (AntallTotalt==.) & (AntallAnkomst!=.) & (AntallAvgang!=.)    

/* Sørg for at alle lufthavnen har samme varegrupper */
reshape wide Antall*, i(Kvt Gruppe) j(Lufthavn) string  
drop if Gruppe==""
reshape long

reshape long Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string
reshape wide Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string

/* Legg på "Merke" */
gen Merke = "Avinor"
replace Merke = "TRN" if Lufthavn=="Oslo"
replace Merke = "TRN" if Lufthavn=="Bergen" 
replace Merke = "TRN" if Lufthavn=="Stavanger" 
replace Merke = "TRN" if Lufthavn=="Trondheim" 
replace Merke = "TRN" if Lufthavn=="Kristiansand" // til Q22022
replace Merke = "ARN" if Lufthavn=="Rygge" 
replace Merke = "ARN" if Lufthavn=="Torp" 

/* Merke er ikke fullstendig satt siste årene. Usikkert på om dette er viktig?*/

*Fra Q12023 får vi data fra ARN for: Torp, Bodø, Evenes, Krstiansand, Molde, Tromsø, Ålesund, Haugesund, Kristiansund
replace Merke = "ARN" if Lufthavn=="Bodø"& Kvt >= yq(2023,1)
replace Merke = "ARN" if Lufthavn=="Evenes" & Kvt >= yq(2023,1)
replace Merke = "ARN" if Lufthavn=="Molde" & Kvt >= yq(2023,1)
replace Merke = "ARN" if Lufthavn=="Haugesund" & Kvt >= yq(2019,2)
replace Merke = "ARN" if Lufthavn == "Kristiansand" & Kvt >= yq(2023,1)
replace Merke = "ARN" if Lufthavn=="Tromsø"& Kvt >= yq(2023,1)
replace Merke = "ARN" if Lufthavn=="Ålesund"& Kvt >= yq(2023,1)
replace Merke = "ARN" if Lufthavn=="Kristiansund"& Kvt >= yq(2023,1)


label var Merke "Merke"

order Merke Lufthavn Utsalg Kvt
sort Merke Lufthavn Utsalg Kvt

/* Ser hvordan det går med Rygge og Torp. Noen år med altfor høyt salg */
/*
reshape long
twoway (line Antall Kvt if Lufthavn == "Torp", sort) ///
	   (line Antall Kvt if Lufthavn == "Rygge", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)

twoway (line Antall Kvt if Lufthavn == "Oslo", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)
		
twoway (line Antall Kvt if Lufthavn == "Bergen", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)
		
twoway (line Antall Kvt if Lufthavn == "Bergen", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)

twoway (line Antall Kvt if Lufthavn == "Trondheim", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)
		
reshape wide
*/


/* Sjekker noen av de større flyplassene. Kategori-utfordringer siste år.
reshape long
twoway (line Antall Kvt if Lufthavn == "Oslo", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)
		
twoway (line Antall Kvt if Lufthavn == "Bergen", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)
		
twoway (line Antall Kvt if Lufthavn == "Stavanger", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)

twoway (line Antall Kvt if Lufthavn == "Trondheim", sort) ///
	    if Utsalg == "Totalt", ///
	    by(Gruppe, yrescale) ylabel(#2)
		
reshape wide
*/
		
/* her er det noen grunnlegende feilrapportering for Rygge. Slett alt */
drop if Kvt == yq(2013,2) & Lufthavn == "Rygge"
drop if Kvt == yq(2013,3) & Lufthavn == "Rygge"
drop if Kvt == yq(2013,4) & Lufthavn == "Rygge"

/* Torp rapporterer feil for ankomst/avgang 2014Q1. Slå sammen totalt */
drop if Utsalg != "Totalt" & Lufthavn == "Torp" & Kvt == yq(2014,1)

reshape long 
drop if Kvt>=yq(2013,2) & Kvt<=yq(2013,4) & Gruppe=="Brennevin" & Lufthavn=="Torp"  
drop if Kvt>=yq(2013,2) & Kvt<=yq(2013,4) & Gruppe=="Tobakk" & Lufthavn=="Torp"  
drop if Kvt>=yq(2013,2) & Kvt<=yq(2013,4) & Gruppe=="Vin" & Lufthavn=="Torp"  
reshape wide

/* Del opp snus og annen tobakk ved hjelp av andeler fra andre år. Selv om TRN 
   rapporterer snus og tobakk i 2011, men ikke får det, er andeler feil. I 
   2013 Q3-Q4 ser snusandeler også til å være feil i TRN. Tobakk 
   for høyt, snus for lavt. Slå sammen er beregn på nytt. Etter 
   beregning ser 2010 Q2 helt feil ut i TRN. Slett denne oppføringen. 
   
   ARN rapporterer heller ikke snus i 2010 og 2011. I 2013 Q1 er snusandelen
   også feil. Slett oppføringen.
   
   Bruk lineær kvadratisk tidstrend sammen med flyplass dummy. 
	
 */
 
reshape wide Antall*, i(Kvt Lufthavn) j(Utsalg) string
egen id = group(Lufthavn), label lname(Lufthavn)
xtset id Kvt
tsfill, full
drop Lufthavn
decode id, gen(Lufthavn)
label var Lufthavn "Lufthavn"
drop id 
reshape long

replace AntallSnusTobakk = AntallSnus + AntallTobakk ///
	if AntallSnus !=. & AntallTobakk !=.   
replace AntallBrennevinHetvin = AntallBrennevin + AntallHetvin ///
	if AntallBrennevin !=. & AntallHetvin !=.   

/*
twoway (line AntallSnus Kvt, sort cmissing(n)) ///
	   (line AntallTobakk Kvt, sort cmissing(n)) ///
	   (line AntallSnusTobakk Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt", xline(201) xline(208) xline(212) ///
	   xline(214) xline(215) ///
	   ylabel(#2) by(Lufthavn, yrescale note(""))
* AntallSnusTobakk ser ukunstig lav ut for Bergen, Oslo, Stavanger, ila 2023. Her må det være noe feil. For 2023 og 2024 skal vi få oppdaterte filer fra TRN. 
* Mangler tall i noen år (i perioden 2020-2023) for noen flyplasser: Bodø, Evenes, Kristiansund, Kristiansand, Haugesund, Molde, Torp, Tromsø, Ålesund.

twoway (line AntallSnus Kvt, sort cmissing(n)) ///
	   (line AntallTobakk Kvt, sort cmissing(n)) ///
	   (line AntallSnusTobakk Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt" & Lufthavn=="Oslo", xline(201) xline(208) xline(212) ///
	   xline(214) xline(215) ///
	   ylabel(#2) by(Lufthavn, yrescale note(""))
	  

twoway (line AntallSnus Kvt, sort cmissing(n)) ///
	   (line AntallTobakk Kvt, sort cmissing(n)) ///
	   (line AntallSnusTobakk Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt" & Lufthavn == "Haugesund", xline(201) xline(208) xline(212) ///
	   xline(214) xline(215) ///
	   ylabel(#2) by(Lufthavn, yrescale note(""))
*Noe er feil i data 2025 fra Haugesund. Er det en annen enhet disse årene som avviker?
	
twoway (line AntallBrennevin Kvt, sort cmissing(n)) ///
	   (line AntallHetvin Kvt, sort cmissing(n)) ///
	   (line AntallBrennevinHetvin Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt", ylabel(#2) by(Lufthavn, yrescale note(""))

twoway (line AntallBrennevin Kvt, sort cmissing(n)) ///
	   (line AntallHetvin Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt" & Lufthavn == "Oslo", ylabel(#2) by(Lufthavn, yrescale note(""))
	   */

/* TRN */
replace AntallSnusTobakk = . if Merke=="TRN" & Kvt == yq(2010,2)
replace AntallTobakk = . if Merke=="TRN" & Kvt < yq(2012,1)   	   
replace AntallSnus = . if Merke=="TRN" & Kvt < yq(2012,1)   	   
replace AntallTobakk = . if Merke=="TRN" & Kvt >= yq(2013,3) & Kvt <= yq(2013,4)
replace AntallSnus = . if Merke=="TRN" & Kvt >= yq(2013,3) & Kvt <= yq(2013,4) 

/* ARN */
replace AntallTobakk = . if Merke=="ARN" & Kvt == yq(2013,1) 
replace AntallSnus = . if Merke=="ARN" & Kvt == yq(2013,1) 

/* Åpenbar feil i rapporteringen av tobakk i Haugesund */
replace AntallTobakk = AntallTobakk/10 if Lufthavn=="Haugesund" & Kvt >= yq(2015,3) & Kvt <= yq(2016,4)
replace AntallSnusTobakk = . if Lufthavn=="Haugesund" & Kvt >= yq(2015,3) & Kvt <= yq(2016,4)

gen AndelSnus = AntallSnus/(AntallTobakk+AntallSnus) 
gen AndelBrennevin = AntallBrennevin/AntallBrennevinHetvin

gen k = quarter(dofq(Kvt))   
sort Lufthavn Utsalg Kvt 
by Lufthavn Utsalg: gen t = _n 
gen t2 = t^2
*sort Lufthavn Utsalg Kvt
egen Lufthavn2 = group(Lufthavn)

regress AndelSnus t t2 i.k i.Lufthavn2 if Utsalg == "Totalt"
predict EstAndel, xb

/* 
*observert versus predikert andel snus
twoway (scatter AndelSnus Kvt, sort cmissing(n)) ///
	   (line EstAndel Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt", xline(208) xline(215) ///
	   ylabel(#2) by(Lufthavn, yrescale note(""))
*/

replace AntallSnus = AntallSnusTobakk*EstAndel ///
	if AntallSnus ==. & Utsalg == "Totalt" 
replace AntallTobakk = AntallSnusTobakk-AntallSnus ///
	if AntallTobakk ==. & AntallSnus!=. & Utsalg == "Totalt"
drop EstAndel   

/* TRN har feilregistrert Hetvin/Brennevin og Snus/Tobakk fra 2019 Q3 */
/* Fordelingen ankomst/avgang stemmer imidlertid */

regress AndelSnus t t2 i.k i.Lufthavn2 if Utsalg == "Ankomst"
predict EstAndel, xb

replace AntallSnus = AntallSnusTobakk*EstAndel ///
	if AntallSnus ==. & Utsalg == "Ankomst" & Merke == "TRN" & Kvt >= yq(2019,3)
replace AntallTobakk = AntallSnusTobakk-AntallSnus ///
	if AntallTobakk ==. & Utsalg == "Ankomst" & Merke == "TRN" & Kvt >= yq(2019,3)
drop EstAndel

regress AndelSnus t t2 i.k i.Lufthavn2 if Utsalg == "Avgang"
predict EstAndel, xb

replace AntallSnus = AntallSnusTobakk*EstAndel ///
	if AntallSnus ==. & Utsalg == "Avgang" & Merke == "TRN" & Kvt >= yq(2019,3)
replace AntallTobakk = AntallSnusTobakk-AntallSnus ///
	if AntallTobakk ==. & Utsalg == "Avgang" & Merke == "TRN" & Kvt >= yq(2019,3)
drop EstAndel AndelSnus AntallSnusTobakk

	/*Denne koden for å estimere andel og predikere brennevin og hetvin skiller seg fra den fra tobakk. */
	
regress AndelBrennevin i.k i.Lufthavn2 if Utsalg == "Ankomst"
predict EstAndelBrennevin, xb
replace AntallBrennevin = AntallBrennevinHetvin*EstAndelBrennevin ///
	if AntallBrennevin ==. & Utsalg == "Ankomst"   
drop EstAndelBrennevin

regress AndelBrennevin i.k i.Lufthavn2 if Utsalg == "Avgang"
predict EstAndelBrennevin, xb
replace AntallBrennevin = AntallBrennevinHetvin*EstAndelBrennevin ///
	if AntallBrennevin ==. & Utsalg == "Avgang" 
drop EstAndelBrennevin

replace AntallHetvin = AntallBrennevinHetvin - AntallBrennevin ///
	if AntallHetvin == . & AntallBrennevinHetvin != .
drop AndelBrennevin AntallBrennevinHetvin  k t t2 Lufthavn2



/*

twoway (line AntallSnus Kvt, sort cmissing(n)) ///
	   (line AntallTobakk Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt", ylabel(#2) by(Lufthavn, yrescale note(""))

	   display display tq(2023q1) // for å sette inn strek for siste halvering av tobakkskvote
	   
	   twoway (line AntallSnus Kvt, sort cmissing(n)) ///
	   (line AntallTobakk Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt", ylabel(#2) by(Lufthavn, yrescale note("")) ///
	   xline(252 , lpattern(dash) lcolor(gs10))
	   
	   /* Fra oslo ser vi at det er noe rart med snus i q3 og q4 i 2023*/
	   twoway (line AntallSnus Kvt, sort cmissing(n)) ///
	   (line AntallTobakk Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt" & Lufthavn == "Oslo", ylabel(#2) ///
	   xline(252 , lpattern(dash) lcolor(gs10))
	
twoway (line AntallBrennevin Kvt, sort cmissing(n)) ///
	   (line AntallHetvin Kvt, sort cmissing(n)) ///
	   if Utsalg=="Totalt", ylabel(#2) by(Lufthavn, yrescale note(""))
	   
twoway (line AntallBrennevin Kvt if Utsalg=="Ankomst", sort cmissing(n) lpattern(solid) lcolor(blue)) ///
	   (line AntallHetvin Kvt if Utsalg=="Ankomst",  sort cmissing(n) lpattern(solid) lcolor(green)) ///
	   (line AntallBrennevin Kvt if Utsalg=="Avgang", sort cmissing(n) lpattern(solid) lcolor(red)) ///
	   (line AntallHetvin Kvt if Utsalg=="Avgang", sort cmissing(n) lpattern(solid) lcolor(orange)) /// 
	   if Lufthavn == "Oslo", ylabel(#2) by(Lufthavn, yrescale note(""))	   ///
	   legend(order(1 "Ankomst - Brennevin" 2 "Ankomst - hetvin" 3 "Avgang - Brennevin" 4 "Avgang - hetvin")) 
	   */	   

reshape long Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string
reshape wide Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string
replace AntallTotalt = AntallAnkomst + AntallAvgang  ///
	if AntallAnkomst != . & AntallAvgang != . 
reshape long 
label var Utsalg "Utsalg" 

/*
twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Snus",  ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note("")) ///
	   xline(252 , lpattern(dash) lcolor(gs10))
	   
	   *Oslo:
	   twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Snus" & Lufthavn == "Oslo",  ///
	   ylabel(#2) ///
	   xline(252 , lpattern(dash) lcolor(gs10))
	   
twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Tobakk", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note("")) ///
	   xline(252 , lpattern(dash) lcolor(gs10))
	   
	   *Oslo - tar bort omsetning i 2023 for illustere: 
	   preserve
	   replace Antall = . if Kvt == yq(2023,1)
	   replace Antall = . if Kvt == yq(2023,2)
	   replace Antall = . if Kvt == yq(2023,3)
	   replace Antall = . if Kvt == yq(2023,4)
	   
	   twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Tobakk" & Lufthavn == "Oslo", ///
	   ylabel(#2) ///
	   xline(252 , lpattern(dash) lcolor(gs10))
	   
	   restore
*/

/* Slik at alt er i antall kg eller antall liter. */
replace Antall = Antall/1000 if Gruppe=="Sigaretter"
reshape wide Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string 

/* Lag et balansert panel med missing records */
reshape wide Antall*, i(Kvt Lufthavn) j(Utsalg) string
egen id = group(Lufthavn), label lname(Lufthavn)
xtset id Kvt, quarterly
tsfill, full
drop Lufthavn
decode id, gen(Lufthavn)
label var Lufthavn "Lufthavn"
drop id Merke
/*
gen Merke = "Avinor" 
replace Merke = "TRN" if Lufthavn=="Oslo"
replace Merke = "TRN" if Lufthavn=="Bergen" 
replace Merke = "TRN" if Lufthavn=="Stavanger" 
replace Merke = "TRN" if Lufthavn=="Trondheim" 
replace Merke = "TRN" if Lufthavn=="Kristiansand" 
replace Merke = "ARN" if Lufthavn=="Rygge" 
replace Merke = "ARN" if Lufthavn=="Torp" 
label var Merke "Merke"
*/

reshape long
reshape long Antall, i(Kvt Lufthavn Utsalg) j(Gruppe) string
label var Gruppe "Gruppe"

/* Legg på Antall passasjerer */
reshape wide Antall, i(Kvt Lufthavn Gruppe) j(Utsalg) string
merge m:1 Kvt Lufthavn using "Passasjerer.dta"
drop if _merge!=3 
reshape long Antall SSB AvinorTorp, i(Kvt Lufthavn Gruppe) j(Utsalg) string
drop _merge


/* Tromsø 2012 Q1 har vor lave passasjerer i SSBs statistikk */
gen Utland = SSB 
replace Utland = AvinorTorp if SSB ==.
replace Utland = AvinorTorp if Kvt == yq(2012,1) & Lufthavn == "Tromsø"
label var Utland "Passasjerer"
drop SSB AvinorTorp

/* Sett Antall til 0 hvis ingen passasjerer */
replace Antall = 0 if Utland == 0

/* Se om det er noen åpenbare feil i dataene */

/*
gen AntPas = Antall/Utland
sort Lufthavn Utsalg Gruppe Kvt 

twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Brennevin", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))
   
twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Hetvin", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note("")) 

twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Øl", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))

twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Vin",  ///
	   ylabel(#2) xline(228) by(Lufthavn, yrescale legend(off) note("")) 

twoway (line AntPas Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line AntPas Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Sigaretter",  ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note("")) 
	    
twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Snus",  ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))

twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Tobakk",  ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))
 drop AntPas
 
*/
   	   
/* Fjern åpenbare feil før estimering.
   Oslo: 4Q2010 Ankomst. Øl.
   Molde: 4Q3014 og 3Q2015: Vin, totalen ser riktig ut.
   Haugesund: 2017Q1 rapport kun for de første 2 mnd
   Torp & Haugesund: 2020 gir ingen mening
*/
replace Antall =. if Lufthavn=="Haugesund" & Kvt==yq(2017,1) 
replace Antall =. if Lufthavn=="Oslo"  & Kvt==yq(2010,4) & (Gruppe=="Øl")
*replace Antall =. if Lufthavn=="Haugesund" & Kvt>=yq(2020,1)
*replace Antall =. if Lufthavn=="Torp" & Kvt>=yq(2020,1)

reshape wide Antall Utland, i(Kvt Lufthavn Gruppe) j(Utsalg) string
label var Gruppe "Gruppe"

/* Estimer totalomsetningen, hvis det mangler. Tidstrend og kvartal */ 
gen NyKvote1 = 0
gen NyKvote2 = 0

replace NyKvote1 = 1 if (Kvt>=yq(2014,3) & Kvt < yq(2022,1)) // innføring byttevote mer vin og øl i stedet for tobakk, fjernes jan 2022.
replace NyKvote2 = 1 if (Kvt>=yq(2023,1)) // halverring av tobakkskvote
label var NyKvote1 "Endring kvoteregler1 byttekvote"
label var NyKvote2 "Endring kvoteregler2 halvvering tobakkskvote"


gen AntPas = AntallTotalt/UtlandTotalt
sort Lufthavn Gruppe Kvt
by Lufthavn Gruppe: gen t = _n 
gen t2 = Kvt > yq(2013,1)
replace t2 = 2 if  Kvt>=yq(2016,1)

gen k = quarter(dofq(Kvt))

egen Lufthavn2 = group(Lufthavn)
egen Gruppe2 = group(Gruppe)
gen EstTotalt = .

levelsof Gruppe2, local(I)
foreach i of local I {
	reg AntPas c.t#t2 i.k i.NyKvote1 i.NyKvote2 i.Lufthavn2 if Gruppe2 == `i' & Kvt<=yq(2019,4)
	predict temp, xb
	replace EstTotalt = temp if Gruppe2 == `i'
    drop temp
}

/* Sammenlign totalomsetning med estimerte verdier */
/*
twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Brennevin", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))

twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Vin", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))

twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Øl", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))

twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Sigaretter", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))

twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Snus", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))

twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Tobakk", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))
		
*/

/* Tobakk får negative verdier i Oslo, Rygge og Torp */
reg AntPas c.t#t2 i.k i.NyKvote1 i.NyKvote2 ///
	if Gruppe == "Tobakk" & Kvt<=yq(2019,4) & Lufthavn == "Oslo"
	predict temp, xb
	replace EstTotalt = temp if Gruppe == "Tobakk"  & Lufthavn == "Oslo"
    drop temp

reg AntPas c.t#t2 i.k i.NyKvote1 i.NyKvote2  ///
	if Gruppe == "Tobakk" & Kvt<=yq(2019,4) & Lufthavn == "Rygge"
	predict temp, xb
	replace EstTotalt = temp if Gruppe == "Tobakk"  & Lufthavn == "Rygge"
    drop temp
	
reg AntPas c.t#t2 i.k i.NyKvote1 i.NyKvote2  ///
	if Gruppe == "Tobakk" & Kvt<=yq(2019,4) & Lufthavn == "Torp"
	predict temp, xb
	replace EstTotalt = temp if Gruppe == "Tobakk"  & Lufthavn == "Torp"
    drop temp

	
/*
twoway (line AntPas Kvt, sort cmissing(n)) ///
	   (line EstTotalt Kvt, sort cmissing(n)) ///
	    if Gruppe=="Tobakk", ///
	    ylabel(#2) by(Lufthavn, yrescale note(""))
*/

replace AntallTotalt = EstTotalt*UtlandTotalt if AntallTotalt ==. 
drop AntPas EstTotalt Lufthavn2 		

/* Del opp total omsetning i ankomst og avgang, ved hjelp av passasjerer */
gen UtlandAndel = UtlandAnkomst/(UtlandAnkomst+UtlandAvgang)  
gen AntallAndel = AntallAnkomst/AntallTotalt
gen EstAndel = .

levelsof Gruppe2, local(I)
foreach i of local I {
    regress AntallAndel UtlandAndel i.k i.NyKvote1 i.NyKvote2  if Gruppe2 == `i' 
	predict temp, xb
	replace EstAndel = temp if Gruppe2 == `i'
    drop temp
}

replace AntallAnkomst = EstAndel*AntallTotalt if AntallAnkomst ==. 
replace AntallAvgang = (1-EstAndel)*AntallTotalt if AntallAvgang ==. 
drop t t2 k Gruppe2 EstAndel UtlandAndel AntallAndel NyKvote1 NyKvote2 

reshape long Antall Utland, i(Kvt Lufthavn Gruppe) ///
	j(Utsalg Ankomst Avgang Totalt)
compress

/*
twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Brennevin", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))
  
twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Vin", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))

twoway (line Antall Kvt if Utsalg=="Ankomst", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Avgang", sort cmissing(n)) ///
	   (line Antall Kvt if Utsalg=="Totalt", sort cmissing(n)) ///
	   if Gruppe=="Snus", ///
	   ylabel(#2) by(Lufthavn, yrescale legend(off) note(""))
	   
*/

/* Taxfree-utsalget ved Fagernes oppgørte i 2016. Rygge ble nedlagt i 11/2016 */
drop if Lufthavn=="Fagernes" & Kvt >= yq(2016,1)
drop if Lufthavn=="Lakselv" & Kvt >= yq(2014,1)
drop if Kvt >= yq(2024,1)

save "Tax-Free 2024.dta", replace


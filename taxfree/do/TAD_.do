clear all

/* Hent inn avgiftsbelagt aloholomsetning fra Toll/Skatteetaten 2010 til 2020 */

cd  "O:\Prosjekt\Rusdata\Omsetning\Særavgiftsrapporter_originalfiler\

import excel "TAD Alkohol 2010-2024.xlsx", sheet("Ark1") firstrow
keep År Måned Avggrp Liter Beløp Sats

/* Lag noen nye variabler */ 
gen Mnd = ym(År, Måned)
format %tmMonth_CCYY Mnd
label var Mnd "Måned"
drop År Måned

destring Liter Beløp, replace i(" ")
compress

replace Avggrp = "OL101" if Avggrp == "101"
replace Avggrp = "OL201" if Avggrp == "201"
replace Avggrp = "OL301" if Avggrp == "301"
replace Avggrp = "OL401" if Avggrp == "401"
replace Avggrp = "OL720" if Avggrp == "720"
replace Avggrp = "OL730" if Avggrp == "730"
replace Avggrp = "BV511" if Avggrp == "511"
replace Avggrp = "BV512" if Avggrp == "512"
replace Avggrp = "BV513" if Avggrp == "513"
replace Avggrp = "BV514" if Avggrp == "514"
replace Avggrp = "BV515" if Avggrp == "515"
replace Avggrp = "BV516" if Avggrp == "516"
replace Avggrp = "BV517" if Avggrp == "517"
replace Avggrp = "BV610" if Avggrp == "610"
replace Avggrp = "BV620" if Avggrp == "620"
replace Avggrp = "BV630" if Avggrp == "630"
replace Avggrp = "BV640" if Avggrp == "640"
replace Avggrp = "BV650" if Avggrp == "650"

/* Bemerk at collapse setter NA til 0 */
drop if Liter==. & Beløp==.
collapse (sum) Liter Beløp (last) Sats, by(Avggrp Mnd)
replace Beløp = . if Beløp==0 & Liter>0

/* Sett som tidsserie og fyll hull med NA */
egen id = group(Avggrp), label lname(Avgiftsgruppe)
tsset id Mnd
tsfill
drop Avggrp
decode id, gen(Avggrp)

/* Ordne og pynt med labels */
order Mnd Avggrp Liter Beløp Sats 
label var Avggrp "Avgiftsgruppe"
label var Liter "Liter"
label var Beløp "Beløp"
label var Sats "Sats"

gen AvgKode = real(substr(Avggrp,3,3))

/* Estimert sats - for å avdekke feil */
gen estSats = round(Beløp/Liter,0.01)
replace estSats = Sats if AvgKode > 514 & AvgKode < 801

/* Beregn gjennomsnittlig alkoholprosent og estimert liter */
gen gjAlk = .
label var gjAlk "Alk.prosent"
replace gjAlk = 0.5 if Avggrp == "OL101"
replace gjAlk = 2.5 if Avggrp == "OL201"
replace gjAlk = 3.5 if Avggrp == "OL301" 
replace gjAlk = 4.5 if Avggrp == "OL401" 
replace gjAlk = 4.5 if Avggrp == "OL801"
replace gjAlk = 4.5 if Avggrp == "OL802"
replace gjAlk = 4.5 if Avggrp == "OL803"
replace gjAlk = 4.5 if Avggrp == "OL804"
replace gjAlk = 0.5 if Avggrp == "BV511" 
replace gjAlk = 2.5 if Avggrp == "BV512" 
replace gjAlk = 3.5 if Avggrp == "BV513" 
replace gjAlk = 4.5 if Avggrp == "BV514" 
replace gjAlk = 4.5 if Avggrp == "BV801"
replace gjAlk = 4.5 if Avggrp == "BV802"
replace gjAlk = 4.5 if Avggrp == "BV803"
replace gjAlk = 4.5 if Avggrp == "BV804"

replace gjAlk = Beløp/(Liter*Sats) ///
	if AvgKode > 514 & AvgKode < 801 & Liter > 0  
	
/* Når estimert sats er lavere enn riktig sats er enten liter for høy eller innbetalt 
   beløp for lav. Det er mer sannsynlig at liter er for høy */

gen estLiter = round(Beløp/Sats) if AvgKode < 515 
replace estLiter = round(Beløp/Sats) if AvgKode >= 801 
label var estLiter "Est. ant. liter"

/* OL101 - til og med 0,7 vol % - Alkoholfri øl. Est. sats fom 2018 for høy */    
/* men dette slettes uansett 												*/
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL101", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) /// 
	xline(642 643 647 684 693) 
	
replace Liter = . if Mnd == ym(2013,07) & Avggrp == "OL101"
replace Liter = . if Mnd == ym(2013,08) & Avggrp == "OL101"
replace Liter = . if Mnd == ym(2013,12) & Avggrp == "OL101"
replace Liter = . if Mnd == ym(2017,10) & Avggrp == "OL101"

*replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "OL101"
*replace Liter = . if Mnd == ym(2017,01) & Avggrp == "OL101"
replace Beløp =. if Mnd == ym(2017,10) & Avggrp == "OL101"


/* OL201 - over 0,7 tom 2,7 vol % - Lettøl */ 
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL201", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	xline(647 684 692 693 694) 
	
replace Liter = . if Mnd == ym(2013,12) & Avggrp == "OL201"
replace Liter = . if Mnd == ym(2017,09) & Avggrp == "OL201"
replace Liter = . if Mnd == ym(2017,10) & Avggrp == "OL201"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "OL201"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "OL201"

/* OL301 - over 2,7 tom 3,7 vol % - Mellomøl */ 
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL301", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	xline(636 642 643 647 684 692 693) 

replace Liter = . if Mnd == ym(2013,01) & Avggrp == "OL301"
replace Liter = . if Mnd == ym(2013,07) & Avggrp == "OL301"
replace Liter = . if Mnd == ym(2013,08) & Avggrp == "OL301"
replace Liter = . if Mnd == ym(2013,12) & Avggrp == "OL301"
replace Liter = . if Mnd == ym(2017,09) & Avggrp == "OL301"
replace Liter = . if Mnd == ym(2017,10) & Avggrp == "OL301"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "OL301"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "OL301"


/* OL401 - over 3,7 tom 4,7 vol % - Vanlig butikkøl */ 
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL401", ylabel(#3, angle(forty_five)) ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	xline(636 642 643 647 684 692 693 694) 
	
replace Liter = . if Mnd == ym(2013,01) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2013,07) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2013,08) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2013,12) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2017,09) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2017,10) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2017,11) & Avggrp == "OL401"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "OL401"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "OL401"

/* BV511 - til og med 0,7 vol % - Alkoholfri fruktdrikk. */ 
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV511", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	xline(627 636 642 643 647 694) 

replace Liter = . if Mnd == ym(2012,04) & Avggrp == "BV511"
replace Liter = . if Mnd == ym(2013,01) & Avggrp == "BV511"
replace Liter = . if Mnd == ym(2013,07) & Avggrp == "BV511"
replace Liter = . if Mnd == ym(2013,08) & Avggrp == "BV511"
replace Liter = . if Mnd == ym(2013,12) & Avggrp == "BV511"
replace Liter = . if Mnd == ym(2017,11) & Avggrp == "BV511"

/* BV512 - over 0,7 tom 2,7 vol % - Sider/rusbrus */ 
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV512", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) 	

	
/* BV513 - over 2,7 tom 3,7 vol % - Sider/rusbrus */ 
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV513", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12)
	
replace Liter = 0 if Liter == . & Avggrp == "BV513"

/* BV514 - over 3,7 tom 4,7 vol % - Sider/rusbrus */
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV514", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	xline(642 643 647 684 692 694) 

replace Liter = . if Mnd == ym(2013,07) & Avggrp == "BV514"
replace Liter = . if Mnd == ym(2013,08) & Avggrp == "BV514"
replace Liter = . if Mnd == ym(2013,12) & Avggrp == "BV514"
replace Liter = . if Mnd == ym(2017,09) & Avggrp == "BV514"
replace Liter = . if Mnd == ym(2017,11) & Avggrp == "BV514"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "BV514"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "BV514"


/* BV801 - Sider/mjød mikrobryggeri */

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV801", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12)


/* OL801 - ØL mikrobryggeri */

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL801", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12)

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL802", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12)
	
twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL803", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12)	

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line estLiter Mnd, sort cmissing(n) lpattern(longdash)) ///
	(line estSats Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL804", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12)	


/* Etter å ha sjekket om liter gir mening for lavprosent alkohol, erstatt med estimert verdi 
   kun hvis liter er missing, ellers bruk est */
replace estLiter = Liter if Liter != . & AvgKode < 515
replace estLiter = Liter if Liter != . & AvgKode >= 801
replace estLiter = . if Liter == . & Beløp == .
drop estSats

/* Se om gj. alkoholprosent endrer seg kraftig. Hvis den dropper plutselig,
   er trolig liter for høy, hvis den stiger plutselig er trolig beløpet for høy */

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV515", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(613 636 642 643 647) 
	
replace gjAlk = . if Mnd == ym(2011,02) & Avggrp == "BV515"
replace Beløp = . if Mnd == ym(2011,02) & Avggrp == "BV515"
replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV515"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV515"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV515"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV515"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV516", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 647 684 692 694) 
	
replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV516"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV516"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV516"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV516"
replace gjAlk = . if Mnd == ym(2017,09) & Avggrp == "BV516"
replace gjAlk = . if Mnd == ym(2017,11) & Avggrp == "BV516"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV517", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 647)

replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV517"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV517"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV517"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV517"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV610", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 647 692 684 694) 

replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV610"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV610"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV610"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV610"
replace gjAlk = . if Mnd == ym(2017,09) & Avggrp == "BV610"
replace gjAlk = . if Mnd == ym(2017,11) & Avggrp == "BV610"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "BV610"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "BV610"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV620", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(625 636 642 643 647 684 688)

replace gjAlk = . if Mnd == ym(2012,02) & Avggrp == "BV620"
replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV620"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV620"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV620"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV620"
replace gjAlk = . if Mnd == ym(2017,05) & Avggrp == "BV620"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "BV620"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "BV620"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV630", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 647 686 692) 

replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV630"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV630"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV630"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV630"
replace gjAlk = . if Mnd == ym(2017,03) & Avggrp == "BV630"
replace gjAlk = . if Mnd == ym(2017,06) & Avggrp == "BV630"
replace gjAlk = . if Mnd == ym(2017,09) & Avggrp == "BV630"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV640", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 684 647) 
	
replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV640"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV640"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV640"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV640"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "BV640"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "BV640"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "BV650", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 647 684) 

replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "BV650"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "BV650"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "BV650"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "BV650"

replace Beløp = . if Mnd == ym(2017,01) & Avggrp == "BV650"
replace Liter = . if Mnd == ym(2017,01) & Avggrp == "BV650"

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL720", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(642 643 647 688 693 695 698 700) 

replace gjAlk = . if gjAlk < 15  & Avggrp == "OL720"

/*
replace gjAlk = . if Mnd == ym(2010,02) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == 720

replace gjAlk = . if Mnd == ym(2017,05) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2017,06) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2017,07) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2017,08) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2017,09) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2017,10) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2017,12) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2018,03) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2018,04) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2018,05) & Avggrp == 720
replace gjAlk = . if Mnd == ym(2018,05) & Avggrp == 720
*/

twoway (line Liter Mnd, sort cmissing(n)) ///
	(line gjAlk Mnd, sort cmissing(n) yaxis(2)) ///
	if Avggrp == "OL730", ///
	ytitle("Liter") xlabel(#9, format(%tmNN/YY)) xmtick(##12) ///
	by(Avggrp, yrescale xrescale note("")) ///
	xline(636 642 643 647 693)

replace gjAlk = . if Mnd == ym(2013,01) & Avggrp == "OL730"
replace gjAlk = . if Mnd == ym(2013,07) & Avggrp == "OL730"
replace gjAlk = . if Mnd == ym(2013,08) & Avggrp == "OL730"
replace gjAlk = . if Mnd == ym(2013,12) & Avggrp == "OL730"
replace gjAlk = . if Mnd == ym(2017,10) & Avggrp == "OL730"	


/* Lag en estimert alkoholprosent for hver kategori */	
sort id Mnd
gen estAlkL12 = L12.gjAlk
gen estAlkF12 = F12.gjAlk
egen estAlk = rmean(estAlkL12 estAlkF12)
replace estAlk = gjAlk if gjAlk !=.
tssmooth ma estAlk2 = estAlk, weights(1 <2> 1)
replace estAlk = estAlk2 if estAlk == .
drop estAlkL12 estAlkF12 estAlk2
label var estAlk "Est. alk.prosent"

twoway (line estAlk Mnd, cmissing(n)) /// 
	(line gjAlk Mnd, cmissing(n)) ///
	if AvgKode > 514 & AvgKode < 801, ///
	ytitle(" Est. Alkoholprosent") ///
	xtitle("Jan 2010 til Des 2024") ///
	by(Avggrp, yrescale xrescale noixlabel note(""))
	
/* Estimert antall liter etter beløp er mer nøyaktig */
replace estLiter = round(Beløp/(estAlk*Sats)) if AvgKode > 514 & AvgKode < 801
misstable summarize estLiter

/* Estimer antall liter når både liter og beløp mangler */
gen estLiterL12 = L12.estLiter
gen estLiterF12 = F12.estLiter
egen estLiter2 = rmean(estLiterL12 estLiterF12)
replace estLiter2 = estLiter if estLiter !=.
replace estLiter = estLiter2 if Liter == . & estLiter ==.
replace estLiter = Liter if Liter != . & estLiter ==.
drop estLiter2 estLiterL12 estLiterF12
misstable summarize estLiter

/* Lav omsetning i starten når mikrobryggeri-kodene ble innført */
replace estLiter  = 0 if Avggrp == "BV802" & estLiter == .  
replace estLiter  = 0 if Avggrp == "BV803" & estLiter == .  
replace estLiter  = 0 if Avggrp == "BV804" & estLiter == .  
replace estLiter  = 0 if Avggrp == "OL802" & estLiter == .  
replace estLiter  = 0 if Avggrp == "OL803" & estLiter == .  
replace estLiter  = 0 if Avggrp == "OL804" & estLiter == .  

/* Estimer gj. alkoholprosent */
tssmooth ma estAlk2 = estAlk, window(4 1 3)
misstable summarize estAlk2
replace estAlk = estAlk2 if estAlk ==.
drop estAlk2

/* Antall liter - estimert etter beløp og */
twoway (line estLiter Mnd, sort cmissing(n)) ///
	if AvgKode > 514 & AvgKode < 801, ///
	ytitle("Antall liter") ylabel(#3, angle(forty_five)) ///
	xtitle("Januar 2010 til Des 2020") ///
	by(Avggrp, yrescale xrescale noixlabel note("")) 
	
twoway (line estLiter Mnd, sort cmissing(n)) ///
	if AvgKode <= 514 , ///
	ytitle("Antall liter") ylabel(#3, angle(forty_five)) ///
	xtitle("Januar 2010 til Mai 2018") ///
	by(Avggrp, yrescale xrescale noixlabel note("")) 


/* Lag Grupper */
gen Gruppe = ""
*gen Undergruppe = ""
label var Gruppe "Gruppe"
*label var Undergruppe "Undergruppe"

drop if Avggrp == "OL101"
replace Gruppe = "Øl" if Avggrp == "OL201" 
*replace Undergruppe = "Lettøl" if Avggrp == 201 
replace Gruppe = "Øl" if Avggrp == "OL301" 
*replace Undergruppe = "Lettøl" if Avggrp == 301 
replace Gruppe = "Øl" if Avggrp == "OL401" 
*replace Undergruppe = "Øl" if Avggrp == 401 
replace Gruppe = "Øl" if Avggrp == "OL801" 
replace Gruppe = "Øl" if Avggrp == "OL802" 
replace Gruppe = "Øl" if Avggrp == "OL803" 
replace Gruppe = "Øl" if Avggrp == "OL804" 

replace Gruppe = "Sterkøl" if Avggrp == "OL720" 
replace Gruppe = "Sterkøl" if Avggrp == "OL730"

drop if Avggrp == "BV511"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV512"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV513"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV514"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV801"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV802"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV803"
replace Gruppe = "Fruktdrikk" if Avggrp == "BV804"

/* Vin over 4,7 - 10 vol% og 10-15 vol% */
replace Gruppe = "Vin" if Avggrp == "BV515"
replace Gruppe = "Vin" if Avggrp == "BV516"

replace Gruppe = "Sterkvin" if Avggrp == "BV517"
replace Gruppe = "Rusbrus" if Avggrp == "BV610"

replace Gruppe = "Brennevin" if Avggrp == "BV620"
*replace Undergruppe = "<22%" if Avggrp == 620
replace Gruppe = "Brennevin" if Avggrp == "BV630"
*replace Undergruppe = "<22%" if Avggrp == 630
replace Gruppe = "Brennevin" if Avggrp == "BV640"
*replace Undergruppe = "<22%" if Avggrp == 640
replace Gruppe = "Brennevin" if Avggrp == "BV650"
*replace Undergruppe = ">22%" if Avggrp == 650

gen estAlkLiter = estLiter*estAlk/100
*save TAD_mnd.dta, replace

/* Lag et datasett over hvert kvartal */
gen K = quarter(dofm(Mnd))
gen A = year(dofm(Mnd))
gen Kvt = yq(A,K)
format %tq Kvt 
label var Kvt "Kvartal"
drop K A

/* Tar dette ut, da jeg har satt inn tall. 
/* Kvartal 2022/1 er ufullstendig */
drop if Kvt >= yq(2023,1)
*/

collapse (sum) estLiter estAlkLiter Liter, by(Kvt Gruppe)
gen LiterTAD = estLiter
gen LiterAlkTAD = estAlkLiter
drop estLiter estAlkLiter Liter

label var LiterTAD "TAD, vareliter" 
label var LiterAlkTAD "Ren alkohol TAD" 
format %11.0g LiterTAD
format %11.0g LiterAlkTAD

replace Gruppe = "Hetvin" if Gruppe == "Sterkvin"

save TAD_Alkohol_2024.dta, replace
use TAD_Alkohol_2024.dta, replace

twoway (line LiterTAD Kvt, cmissing(n)), ///
	ytitle("Antall liter") ylabel(#3, angle(forty_five)) ///
	xtitle("Januar 2010 til Desember 2024") ///
	by(Gruppe, yrescale xrescale note("")) 
	
/* Må gjennomføre det under også*/

/* Lag et datasett per år */
*gen År = year(dofq(Kvt))
*label var År "År"

/* År 2021 er ufullstendig */
*drop if År >= 2021
	   
*collapse (sum) Liter*, by(År Gruppe)

*label var LiterTAD "TAD, vareliter" 
*label var LiterAlkTAD "TAD, ren alkohol"

*save TAD_Aar.dta, replace


clear all

cd "O:\Prosjekt\Rusdata\Omsetning\Taxfree_originalfiler\"


/* Hent inn terminalpassasjerer fra Avinor, passasjertallene er inkl. 
   barn. Totalt for både ankomst og avgang, inkl. transfer. Deretter koble med 
   ankomst og avgang fra SSB, inkl. transfer, for å beregne andeler som brukes 
   for å fremskrive dette.
   
   Enkle passasjertall kan være misvisende. Behold begge seriene for å
   dobbeltsjekke dette Opplysninger om rute og charter brukes ikke lenger.
 */

use "Passasjerer\Passasjerer Avinor.dta", clear
rename AntallTotalt AvinorTorp
label var Avinor "Passasjerer Avinor" 

egen id = group(Lufthavn)
xtset id Kvt, quarterly
tsfill, full
drop id
drop if Lufthavn == ""

merge 1:m Kvt Lufthavn using "Passasjerer\Passasjerer Torp.dta", nogenerate
replace AvinorTorp = AntallTotalt if Lufthavn == "Torp" & Kvt >= yq(2019,2)
drop AntallTotalt 

gen UAvgang = .
gen UAnkomst = .
gen UTotalt = .
reshape long U, i(Kvt Lufthavn) j(Utsalg Avgang Ankomst Totalt) string
drop U 
label var Utsalg "Utsalg"

merge 1:m Kvt Lufthavn Utsalg  ///
	using "Passasjerer\Passasjerer SSB 2010 -2024.dta", nogenerate 
rename AntallTotalt SSB
label var SSB "Passasjerer SSB"

/* Dette er lagt inn i fila over. Slett kode?
merge 1:m Kvt Lufthavn Utsalg  ///
	using "Passasjerer\Passasjerer SSB 2024.dta", nogenerate 
*/

drop Antall*
compress

reshape wide SSB, i(Kvt Lufthavn) j(Utsalg Avgang Ankomst Totalt) 


/* 	Vær oppmerksom på at transferpassasjerer blir telt enkelt i SSBs 
	statistikk. Transitpassasjerer teller ikke. */ 

twoway (line SSBTotal Kvt, sort cmissing(n)) ///
	   (line AvinorTorp Kvt, sort cmissing(n)), ///
	   ylabel(#2) by(Lufthavn, yrescale note(""))

gen K = quarter(dofq(Kvt))
bysort Lufthavn K: egen float Andel = mean(SSBAnkomst/SSBTotalt)

gen AvinorTorpAnkomst = round(AvinorTorp*Andel)
gen AvinorTorpAvgang = round(AvinorTorp*(1-Andel))
rename AvinorTorp AvinorTorpTotalt 
drop K Andel 

sort Lufthavn Kvt

/* Taxfree-utsalget ved Fagernes oppgørte i 2016, Rygge i oktober 2010*/
drop if Lufthavn=="Lakselv" & Kvt >= yq(2014,1)
drop if Lufthavn=="Fagernes" & Kvt >= yq(2016,1)
drop if Lufthavn=="Rygge" & Kvt >= yq(2017,1)

save Passasjerer.dta, replace 

/* Per år til statistikk */
gen Aar = year(dofq(Kvt))




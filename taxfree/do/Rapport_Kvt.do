*******************************************************************************

	** Fil opprettet for å få tall i rapport om omsetning taxfree.
	** Filen tar utgangspunkt i do-fil fra FHI.
	** Denne filen er opprettet 21/8-2025 av Bente Øvrebø, Hdir.
	** Filen er ikke ferdig.

*******************************************************************************


clear all

cd "O:\Prosjekt\Rusdata\Omsetning\"


/* Per kvt til tabell */  
/* Per nå har fila under data til og med 2023 - må fikse*/
use "Taxfree_originalfiler\Tax-Free 2024.dta", replace 

collapse (sum) Antall Utland, by(Kvt Gruppe Utsalg)
reshape wide Antall Utland, i(Gruppe Kvt) j(Utsalg) string
reshape wide Antall* Utland*, i(Gruppe) j(Kvt)
set obs `= _N+3'
replace Gruppe = "Sterkøl" in -3
replace Gruppe = "Fruktdrikk" in -2
replace Gruppe = "Rusbrus" in -1

reshape long
format %tq Kvt 
reshape long Antall Utland, i(Gruppe Kvt) j(Utsalg) string
reshape wide Antall Utland, i(Utsalg Kvt) j(Gruppe) string
replace UtlandSterkøl = UtlandVin
reshape long

reshape wide Antall Utland, i(Gruppe Kvt) j(Utsalg) string
merge m:1 Kvt Gruppe using "Særavgiftsrapporter\TAD_Alkohol.dta", nogenerate
merge m:1 Kvt Gruppe using "Særavgiftsrapporter\TAD_Tobakk.dta", nogenerate 
merge m:1 Kvt Gruppe using "Vinmonopolet\Vinmonopolet_Kvt.dta", nogenerate 
merge m:1 Kvt Gruppe using "SSB\Omsetningsstatistikk\SSB_Alkoholstatistikk.dta", nogenerate 
drop if Kvt <  yq(2010,1)
drop if Kvt >= yq(2024,1)
rename Liter AntallVinmonopolet 
rename LiterAlkTAD AntallRenTAD
rename Gruppe Varegruppe

drop Alkoholliter

replace LiterTAD = TobakkTAD if LiterTAD==. & TobakkTAD !=.
rename LiterTAD AntallTAD
drop TobakkTAD

reshape long Antall Utland, i(Varegruppe Kvt) j(Gruppe) string
reshape wide Antall Utland, i(Kvt Gruppe) j(Varegruppe) string

gen AntallAllØl = 0
gen UtlandAllØl = UtlandVin
replace AntallAllØl = AntallØl if Gruppe == "Ankomst" 
replace AntallAllØl = AntallØl if Gruppe == "Avgang" 
replace AntallAllØl = AntallØl if Gruppe == "Totalt" 
replace AntallAllØl = AntallSterkøl + AntallØl if Gruppe == "TAD"
replace AntallAllØl = AntallSterkøl + AntallØl if Gruppe == "RenTAD"
replace AntallAllØl = AntallSterkøl if Gruppe == "Vinmonopolet"
replace AntallAllØl = AntallØl if Gruppe == "SSB"
replace AntallAllØl = AntallØl if Gruppe == "RenSSB"
replace AntallAllØl = AntallØl if Gruppe == "Ren15SSB"

replace AntallØl = . if Gruppe == "Ankomst" 
replace AntallØl = . if Gruppe == "Avgang" 
replace AntallØl = . if Gruppe == "Totalt" 
replace AntallØl = . if Gruppe == "SSB"
replace AntallØl = . if Gruppe == "RenSSB"
replace AntallØl = . if Gruppe == "Ren15SSB"

gen AntallSiderRusbrus = AntallFruktdrikk + AntallRusbrus
gen UtlandSiderRusbrus = UtlandVin
replace AntallSiderRusbrus = AntallRusbrus if Gruppe == "SSB" 
replace AntallSiderRusbrus = AntallRusbrus if Gruppe == "RenSSB" 
replace AntallSiderRusbrus = AntallRusbrus if Gruppe == "Ren15SSB" 
drop AntallFruktdrikk AntallRusbrus UtlandFruktdrikk UtlandRusbrus  

gen AntallAllVin = 0
gen UtlandAllVin = UtlandVin
replace AntallAllVin = AntallVin + AntallHetvin
replace AntallAllVin = AntallVin if Gruppe == "SSB"
replace AntallAllVin = AntallVin if Gruppe == "RenSSB"
replace AntallAllVin = AntallVin if Gruppe == "Ren15SSB"
replace AntallVin = . if Gruppe == "SSB"
replace AntallVin = . if Gruppe == "RenSSB"
replace AntallVin = . if Gruppe == "Ren15SSB"

reshape long
drop if Antall ==.
reshape wide Antall Utland, i(Varegruppe Kvt) j(Gruppe) string
gen gjAlk = AntallRenTAD/AntallTAD
gen AntallRenAnkomst = AntallAnkomst*gjAlk
gen AntallRenAvgang = AntallAvgang*gjAlk
gen AntallRenTotalt = AntallTotalt*gjAlk
gen AntallRenVinmonopolet = AntallVinmonopolet*gjAlk
 
reshape long Antall AntallRen AntallRen15 Utland, i(Kvt Varegruppe) j(Gruppe) string
replace gjAlk = AntallRen/Antall if Gruppe =="SSB"
drop if Gruppe == "RenTAD"
drop if Gruppe == "RenSSB"
drop if Gruppe == "Ren15SSB"
reshape wide Antall AntallRen AntallRen15 Utland gjAlk, i(Kvt Gruppe) j(Varegruppe) string

replace UtlandAlkohol = UtlandVin
replace gjAlkAllØl = gjAlkSterkøl if Gruppe =="Vinmonopolet"
replace AntallRenAllØl = AntallRenSterkøl if Gruppe =="Vinmonopolet"

replace AntallRenAlkohol = AntallRenAllØl + AntallRenVin + ///
	AntallRenHetvin + AntallRenBrennevin if Gruppe != "SSB"
replace AntallRenAlkohol = AntallRenAlkohol + ///
	AntallRenSiderRusbrus if Gruppe == "TAD"  	
gen AntallAllTobakk = AntallSigaretter + AntallSnus + AntallTobakk

reshape long Antall AntallRen AntallRen15 Utland gjAlk, i(Kvt Gruppe) j(Varegruppe) string
rename Antall AntallVare
rename AntallRen15 SSB15
reshape long Antall, i(Kvt Gruppe Varegruppe) j(Omregnet) string
drop if Antall == .

reshape wide Antall Utland gjAlk SSB15, i(Kvt Gruppe Omregnet) j(Varegruppe) string
replace UtlandAlkohol = UtlandVin
replace UtlandAllTobakk = UtlandVin
reshape long
drop if Antall ==.
replace gjAlk = 1 if Varegruppe == "Alkohol"

gen År = year(dofq(Kvt))
gen over15aar = 3940474
replace over15aar = 3998596 if År==2011
replace over15aar = 4062295 if År==2012
replace over15aar = 4123891 if År==2013
replace over15aar = 4178211 if År==2014
replace over15aar = 4233409 if År==2015
replace over15aar = 4280030 if År==2016 
replace over15aar = 4320607 if År==2017 
replace over15aar = 4356685 if År==2018 
replace over15aar = 4393254 if År==2019 
replace over15aar = 4437453 if År==2020 
replace over15aar = 4469778 if År==2021 
replace over15aar = 4509283 if År==2022 
replace over15aar = 4572917 if År==2023  

reshape wide Antall Utland gjAlk SSB15, i(Kvt Omregnet Varegruppe) j(Gruppe) string
gen A = gjAlkTAD
gen B = gjAlkSSB
gen C = SSB15SSB
drop gjAlk* SSB15* UtlandTAD UtlandVinmonopolet UtlandSSB
rename A gjAlkFHI
rename B gjAlkSSB
rename C over15SSB
replace gjAlkFHI = 1 if Varegruppe == "Alkohol"

gen AntPasAnkomst = AntallAnkomst/UtlandAnkomst  
gen AntPasAvgang = AntallAvgang/UtlandAvgang
gen AntPasTotalt = AntallTotalt/UtlandTotalt  

gen over15Ankomst = AntallAnkomst/over15aar
gen over15Avgang = AntallAvgang/over15aar
gen over15Totalt = AntallTotalt/over15aar
gen over15TAD = AntallTAD/over15aar
gen over15Vinmonopolet = AntallVinmonopolet/over15aar
drop over15aar
drop if Omregnet == "Vare" & Varegruppe == "Alkohol"

reshape wide Antall* over* AntPas*, i(Kvt Varegruppe) j(Omregnet) string 

/* Generer tabell slik som i rapporten */
gen Avgiftsbelagt = AntallTADVare/1000
replace Avgiftsbelagt = AntallTADRen/1000 if Varegruppe =="Alkohol"
gen Avgiftsbelagt15 = over15TADRen
replace Avgiftsbelagt15 = over15TADVare if over15TADRen ==.
gen Vinmonopolet = AntallVinmonopoletVare/1000
replace Vinmonopolet = AntallVinmonopoletRen/1000 if Varegruppe =="Alkohol"
gen Vinmonopolet15 = over15VinmonopoletRen
drop AntallTAD* over15TAD* AntallVinmonopolet* over15Vinmonopolet*

gen Ankomst = AntallAnkomstVare/1000  
replace Ankomst = AntallAnkomstRen/1000 if Varegruppe =="Alkohol"
gen Avgang = AntallAvgangVare /1000 
replace Avgang = AntallAvgangRen/1000 if Varegruppe =="Alkohol"
gen Totalt = AntallTotaltVare/1000 
replace Totalt = AntallTotaltRen/1000 if Varegruppe =="Alkohol"
drop AntallAnkomst* AntallAvgang* AntallTotalt*

gen AnkomstPas = AntPasAnkomstVare  
replace AnkomstPas = AntPasAnkomstRen if Varegruppe =="Alkohol"
gen AvgangPas = AntPasAvgangVare  
replace AvgangPas = AntPasAvgangRen if Varegruppe =="Alkohol"
gen TotaltPas = AntPasTotaltVare  
replace TotaltPas = AntPasTotaltRen if Varegruppe =="Alkohol"
drop AntPas*

gen Ankomst15 = over15AnkomstRen
replace Ankomst15 = over15AnkomstVare if over15AnkomstRen ==.
gen Avgang15 = over15AvgangRen
replace Avgang15 = over15AvgangVare if over15AvgangRen ==.
gen Totalt15 = over15TotaltRen
replace Totalt15 = over15TotaltVare if over15TotaltRen ==.

gen AvgiftsbelagtSSB = AntallSSBVare/1000
replace AvgiftsbelagtSSB = AntallSSBRen/1000 if Varegruppe =="Alkohol"
gen AvgiftsbelagtSSB15 = over15SSBRen
replace AvgiftsbelagtSSB15 = over15SSBVare if over15SSBRen ==.
drop AntallSSB* over15SSB* over15*

order År Kvt Varegruppe Ankomst Avgang Totalt AnkomstPas AvgangPas TotaltPas ///
	Ankomst15 Avgang15 Totalt15 Avgiftsbelagt Vinmonopolet Avgiftsbelagt15 ///
	Vinmonopolet15 gjAlkFHI AvgiftsbelagtSSB AvgiftsbelagtSSB15 gjAlkSSB 

drop UtlandAnkomst UtlandAvgang UtlandTotalt
gen No = 1 
replace No = 1  if Varegruppe =="Alkohol"
replace No = 2  if Varegruppe =="AllVin"
replace No = 3  if Varegruppe =="Vin"
replace No = 4  if Varegruppe =="Hetvin"
replace No = 5  if Varegruppe =="Brennevin"
replace No = 6  if Varegruppe =="AllØl"
replace No = 7  if Varegruppe =="Øl"
replace No = 8  if Varegruppe =="Sterkøl"
replace No = 9  if Varegruppe =="SiderRusbrus"
replace No = 10  if Varegruppe =="AllTobakk"
replace No = 11 if Varegruppe =="Sigaretter"
replace No = 12 if Varegruppe =="Snus"
replace No = 13 if Varegruppe =="Tobakk"
sort No Kvt
drop No

edit

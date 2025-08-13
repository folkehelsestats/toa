use "O:\Prosjekt\Rusdata\Rusundersøkelsen\Rusus 2024\nytt forsøk februar 25 rus24.dta", clear


* lage variabel for antall dager drukket alkohol siste år (blant siste års drikkere)
gen alkodager=0
replace alkodager=365 if Drukket2==1
replace alkodager=234 if Drukket2==2 & Drukk2a==1
replace alkodager =130 if Drukket2==2 & Drukk2a==2
replace alkodager =52 if Drukket2==2 & Drukk2a==3
replace alkodager =42 if Drukket2==3 & Drukk2b==1
replace alkodager =30 if Drukket2==3 & Drukk2b==2
replace alkodager =12 if Drukket2==3 & Drukk2b==3
replace alkodager =7.5 if Drukket2==4 & Drukk2c==1
replace alkodager =2.5 if Drukket2==4 & Drukk2c==2
replace alkodager =1 if Drukket2==4 & Drukk2c==3
replace alkodager=. if Drukket2==9
replace alkodager=. if Drukk2a==8
replace alkodager=. if Drukk2b==9
replace alkodager=. if Drukk2c==8
replace alkodager=. if Drukk2c==9
replace alkodager=. if Drukket1==8
replace alkodager=. if Drukket1==.

*alkohofrekvens totalt og siste år
recode Drukket1 (1=2)(2=1)(8=.), gen(alkofrekvens)
replace alkofrekvens=0 if Drukk1b==2
replace alkofrekvens=3 if Drukket2==3
replace alkofrekvens=4 if Drukket2==2
replace alkofrekvens=5 if Drukket2==1
replace alkofrekvens=. if Drukket2==9
replace alkofrekvens=. if Drukk1b==8
replace alkofrekvens=. if Drukk1b==9
label define alkofrekvens 0 "aldri drukket" 1 "ikke drukket siste år" 2 "drukket sjeldnere enn månedlig siste 12 mnd" 3 "drukket månedlig siste 12 mnd" 4 "drukket ukentlig siste 12 mnd" 5 "drukket daglig siste 12 mnd", modify
label val alkofrekvens alkofrekvens


recode alkofrekvens (0=.)(1=.), gen (alkofreksisteår)
label define alkofreksisteår  2 "drukket sjeldnere enn månedlig siste 12 mnd" 3 "drukket månedlig siste 12 mnd" 4 "drukket ukentlig siste 12 mnd" 5 "drukket daglig siste 12 mnd", modify
label val alkofreksisteår alkofreksisteår

*andel som drikker siste år og siste 4 uker

recode Drukket1 (1=1)(2=2)(8=.), gen (alksisteår)
label define alksisteår  1 "drukket alkohol siste 12 mnd" 2 "ikke drukket alkohol siste 12 mnd", modify
label val alksisteår alksisteår

recode Drukket3 (1=1) (2=2) (9=.), gen (alkfiruker)
label define alkfiruker  1 "drukket alkohol siste 4 uker" 2 "ikke drukket alkohol siste 4 uker", modify
label val alkfiruker alkfiruker

gen alkfirukeravalle=0
replace alkfirukeravalle=1 if alkfiruker==1 
label define alkfirukeravalle 0 "ikke drukket alkohol siste 4 uker" 1 "drukket alkohol siste 4 uker",  modify
label val alkfirukeravalle alkfirukeravalle

gen totalfrekvens=2
replace totalfrekvens=0 if alkofrekvens==0
replace totalfrekvens=1 if alkofrekvens==1
replace totalfrekvens=3 if alkfiruker==1
label define totalfrekvens 0 "aldri drukket" 1" ikke drukket siste år" 2 "drukket siste år men ikke siste 4 uker" 3 "drukket siste fire uker" 
label val totalfrekvens totalfrekvens

*siste 4 ukers konsum

*antall dager drukket øl, hele utvalget
gen øldager=0
replace øldager=28 if Type1a==1
replace øldager=18 if Type1a==2 & Typ1a_uk==1
replace øldager =10 if Type1a==2 & Typ1a_uk==2
replace øldager =4 if Type1a==2 & Typ1a_uk==3
replace øldager =3.5 if Type1a==3 & Typ1a_mn==1
replace øldager =2.5 if Type1a==3 & Typ1a_mn==2
replace øldager =1 if Type1a==3 & Typ1a_mn==3
replace øldager=. if Type1a==9
replace øldager=. if Typ1a_uk==8
replace øldager=. if Typ1a_mn==9

*antall dager drukket øl, kun folk som har drukket alkohol siste 4 uker
gen øldageraktive=øldager
replace øldageraktive=. if Drukket3>=2

*antall dager drukket øl, kun folk som har drukket alkohol siste år.
gen øldagersisteår=øldager
replace øldagersisteår=. if Drukket1>=2


*antall dager drukket vin, hele utvalget
gen vindager=0
replace vindager=28 if Type2a==1
replace vindager=18 if Type2a==2 & Typ2a_uk==1
replace vindager =10 if Type2a==2 & Typ2a_uk==2
replace vindager =4 if Type2a==2 & Typ2a_uk==3
replace vindager =3.5 if Type2a==3 & Typ2a_mn==1
replace vindager =2.5 if Type2a==3 & Typ2a_mn==2
replace vindager =1 if Type2a==3 & Typ2a_mn==3
replace vindager=. if Type2a==9
replace vindager=. if Typ2a_uk==8
replace vindager=. if Typ2a_mn==8
replace vindager=. if Typ2a_mn==9


*antall dager drukket vin, kun folk som har drukket alkohol siste 4 uker
gen vindageraktive=vindager
replace vindageraktive=. if Drukket3>=2

*antall dager drukket vin, kun folk som har drukket alkohol siste år.
gen vindagersisteår=vindager
replace vindagersisteår=. if Drukket1>=2


*antall dager drukket brennevin, hele utvalget
gen spritdager=0
replace spritdager=28 if Type3a==1
replace spritdager=18 if Type3a==2 & Typ3a_uk==1
replace spritdager =10 if Type3a==2 & Typ3a_uk==2
replace spritdager =4 if Type3a==2 & Typ3a_uk==3
replace spritdager =3.5 if Type3a==3 & Typ3a_mn==1
replace spritdager =2.5 if Type3a==3 & Typ3a_mn==2
replace spritdager =1 if Type3a==3 & Typ3a_mn==3
replace spritdager=. if Type3a==8
replace spritdager=. if Type3a==9
replace spritdager=. if Typ3a_uk==8
replace spritdager=. if Typ3a_uk==9
replace spritdager=. if Typ3a_mn==8
replace spritdager=. if Typ3a_mn==9


*antall dager drukket brennevin, kun folk som har drukket alkohol siste 4 uker
gen spritdageraktive=spritdager
replace spritdageraktive=. if Drukket3>=2

*antall dager drukket brennevin, kun folk som har drukket alkohol siste år.
gen spritdagersisteår=spritdager
replace spritdagersisteår=. if Drukket1>=2


*antall dager drukket rusbrus, hele utvalget
gen brusdager=0
replace brusdager=28 if Type4a==1
replace brusdager=18 if Type4a==2 & Typ4a_uk==1
replace brusdager =10 if Type4a==2 & Typ4a_uk==2
replace brusdager =4 if Type4a==2 & Typ4a_uk==3
replace brusdager =3.5 if Type4a==3 & Typ4a_mn==1
replace brusdager =2.5 if Type4a==3 & Typ4a_mn==2
replace brusdager =1 if Type4a==3 & Typ4a_mn==3
replace brusdager=. if Type4a==8
replace brusdager=. if Type4a==9
replace brusdager=. if Typ4a_uk==8
replace brusdager=. if Typ4a_uk==9
replace brusdager=. if Typ4a_mn==8
replace brusdager=. if Typ4a_mn==9


*antall dager drukket rusbrus, kun folk som har drukket alkohol siste 4 uker
gen brusdageraktive=brusdager
replace brusdageraktive=. if Drukket3>=2

*antall dager drukket rusbrus, kun folk som har drukket alkohol siste år.
gen brusdagersisteår=brusdager
replace brusdagersisteår=. if Drukket1>=2



*ølfrekvens siste 4 uker
recode Type1a (8=.)(9=.), gen (ølfrekvens)
label define ølfrekvens 1 "daglig" 2 "ukentlig" 3 "sjeldnere enn ukentlig", modify
label val ølfrekvens ølfrekvens

*vinfrekvens siste 4 ukers
recode Type2a (8=.)(9=.), gen (vinfrekvens)
label define vinfrekvens 1 "daglig" 2 "ukentlig" 3 "sjeldnere enn ukentlig", modify
label val vinfrekvens vinfrekvens

*brennevinsfrekvens siste 4 ukers
recode Type3a (8=.)(9=.), gen (brennevinfrekvens)
label define brennevinfrekvens 1 "daglig" 2 "ukentlig" 3 "sjeldnere enn ukentlig", modify
label val brennevinfrekvens brennevinfrekvens

*rusbrusfrekvens siste 4 ukers 
recode Type4a (8=.)(9=.), gen (rusbrusfrekvens)
label define rusbrusfrekvens 1 "daglig" 2 "ukentlig" 3 "sjeldnere enn ukentlig", modify
label val rusbrusfrekvens rusbrusfrekvens

*total drikkefrekvens siste 4 uker
gen dagligdrikk=0
replace dagligdrikk=1 if ølfrekvens==1
replace dagligdrikk=1 if vinfrekvens==1
replace dagligdrikk=1 if brennevinfrekvens==1
replace dagligdrikk=1 if rusbrusfrekvens==1

gen ukedrikk=0
replace ukedrikk = 2 if  ølfrekvens==2 & dagligdrikk==0
replace ukedrikk = 2 if  vinfrekvens==2 & dagligdrikk==0
replace ukedrikk = 2 if brennevinfrekvens==2 & dagligdrikk==0
replace ukedrikk = 2 if rusbrusfrekvens==2 & dagligdrikk==0

gen måneddrikk = 0
replace måneddrikk=3 if ølfrekvens==3 & dagligdrikk==0 & ukedrikk==0
replace måneddrikk=3 if vinfrekvens==3  & dagligdrikk==0 & ukedrikk==0
replace måneddrikk=3 if brennevinfrekvens==3  & dagligdrikk==0 & ukedrikk==0
replace måneddrikk=3 if rusbrusfrekvens==3  & dagligdrikk==0 & ukedrikk==0


gen drikkefrekvens = dagligdrikk + ukedrikk + måneddrikk
label define drikkefrekvens 0 "ikke drukket siste 4 uker" 1 "drukket daglig siste 4 uker" 2 "drukket ukentlig siste 4 uker" 3 "drukket sjeldnere enn ukentlig siste 4 uker", modify
label val drikkefrekvens drikkefrekvens


*antall enheter siste 4 uker -> ETTER MASSE OM OG MEN ER NÅVÆRENDE LØSNING Å IKKE STRYKE NOE: FHI VIL ANTAKELIG GJØRE DET SAMME[ Kan muligens legge inn en cut-off på 70 enheter slik at alt over 70 er 70, slik det gjøres i NCD. Uskker på om det er per drikkesort eller totalt - rettelse: må være per drikkesort - ny rettelse: Elin sier det er totalt. Avventer dette, men retter opp enhetsberegningene så de blir lik FHIs - siste nytt: winsorizing per enhet, dvs endrer alle over 95% percentilen til lik 95% percentilen]
*øl

gen flaskerøluke=0
replace flaskerøluke=Type1b_1 if Type1b_1<.
recode flaskerøluke (99998=0)(99999=0)

gen halvliterøluke=0
replace halvliterøluke=Type1b_2 if Type1b_2<.
recode halvliterøluke (99998=0)(99999=0)

gen flaskerøltot=0
replace flaskerøltot= Type1c_1 if Type1c_1<.
recode flaskerøltot (99998=0) (99999=0)


gen halvlitertot=0
replace halvlitertot=Type1c_2 if Type1c_2<.
recode halvlitertot (99998=0)(99999=0)

*regner 1,5 enheter per halvliter øl
gen ølenheter= (flaskerøluke + 1.5*halvliterøluke)*4 + flaskerøltot + 1.5*halvlitertot


*winsorising: endrer alle over 95%-percentilen til =95% percentilen
winsor2 ølenheter, suffix(_win) cuts(0 95) 


*antall halvlitere øl per 4 uker
gen ølhalvlitere =(flaskerøluke/1.5 +halvliterøluke)*4 + flaskerøltot/1.5 + halvlitertot

winsor2 ølhalvlitere, suffix(_win) cuts(0 95)

*vin
gen vinglassuke=0
replace vinglassuke=Type2b_1 if Type2b_1<.
recode vinglassuke (99998=0)(99999=0)

gen vinflaskeruke=0
replace vinflaskeruke=Type2b_2 if Type2b_2<.
recode vinflaskeruke (99998=0)(99999=0)

gen vinglasstot=0
replace vinglasstot= Type2c_1 if Type2c_1<.
recode vinglasstot (99999=0)(99998=0)


gen vinflaskertot=0
replace vinflaskertot=Type2c_2 if Type2c_2<.
recode vinflaskertot (99998=0)(99999=0)

*regner 6 enheter per flaske vin
gen vinenheter= (1.2*vinglassuke + 6*vinflaskeruke)*4 + 1.2*vinglasstot + 6*vinflaskertot

*winsorising: endrer alle over 95%-percentilen til =95% percentilen
winsor2 vinenheter, suffix(_win) cuts(0 95) 

gen allevinflasker =(vinflaskeruke + vinglassuke/5)*4 + vinglasstot/5 + vinflaskertot

winsor2 allevinflasker, suffix(_win) cuts(0 95)

*brennevinfrekvens
gen brennevinglassuke=0
replace brennevinglassuke=Type3b_1 if Type3b_1<.
recode brennevinglassuke (99998=0)(99999=0)

gen brennevinflaskeruke=0
replace brennevinflaskeruke=Type3b_2 if Type3b_2<.
*recode brennevinflaskeruke (99998=0)(99999=0)

gen brennevinglasstot=0
replace brennevinglasstot= Type3c_1 if Type3c_1<.
recode brennevinglasstot (99998=0)(99999=0)


gen brennevinflaskertot=0
replace brennevinflaskertot=Type3c_2 if Type3c_2<.
recode brennevinflaskertot (99998=0)(99999=0)

*regner 17,5 enheter per flaske sprit
gen brennevinenheter = (brennevinglassuke + 17.5*brennevinflaskeruke)*4 + brennevinglasstot + 17.5*brennevinflaskertot

*winsorising: endrer alle over 95%-percentilen til =95% percentilen
*ssc install winsor2

winsor2 brennevinenheter, suffix(_win) cuts(0 95) 

*rusbrus
gen rusbrussmåflaskeruke=0
replace rusbrussmåflaskeruke=Type4b_1 if Type4b_1<.
recode rusbrussmåflaskeruke (99998=0)(99999=0)

gen rusbrushalvliteruke=0
replace rusbrushalvliteruke=Type4b_2 if Type4b_2<.
recode rusbrushalvliteruke (99998=0)(99999=0)

gen rusbrussmåflasketot=0
replace rusbrussmåflasketot=Type4c_1 if Type4c_1<.
recode rusbrussmåflasketot (99998=0) (99999=0)


gen rusbrushalvlitertot=0
replace rusbrushalvlitertot=Type4c_2 if Type4c_2<.
recode rusbrushalvlitertot (99998=0)(99999=0)

*regner 1,5 enheter per halvliter rusbrus
gen rusbrusenheter = (rusbrussmåflaskeruke + 1.5*rusbrushalvliteruke)*4 + rusbrussmåflasketot + 1.5*rusbrushalvlitertot

*winsorising: endrer alle over 95%-percentilen til =95% percentilen
winsor2 rusbrusenheter, suffix(_win) cuts(0 95) 

*halvlitere rusbrus/cider

gen rusbrushalvlitere =(rusbrussmåflaskeruke/1.5 + rusbrushalvliteruke)*4 + rusbrussmåflasketot/1.5 + rusbrushalvlitertot

winsor2 rusbrushalvlitere, suffix(_win) cuts(0 95)




gen totalenheter= ølenheter + vinenheter + brennevinenheter + rusbrusenheter


*Beregne enheter kun for de som har drukket siste 4 uker:

gen totalenheternetto =totalenheter
replace totalenheternetto=. if alkfiruker==2

gen ølenheternetto =ølenheter
replace ølenheternetto=. if alkfiruker==2

gen vinenheternetto =vinenheter
replace vinenheternetto=. if alkfiruker==2

gen brennevinenheternetto =brennevinenheter
replace brennevinenheternetto=. if alkfiruker==2

gen rusbrusenheternetto =rusbrusenheter
replace rusbrusenheternetto=. if alkfiruker==2


gen totalenheter_win = ølenheter_win + vinenheter_win + brennevinenheter_win + rusbrusenheter_win


*Beregne mengde ren alkohol (her må det avklares hvordan cl skal samordnes med enheter. Nåværende løsning: alle enheter telles med. Mulig annen løsning: basere seg på winsorized enheter)
*øl

gen alkocløl= ølhalvlitere*2.25

gen alkocløl_win= ølhalvlitere_win*2.25

*vin

gen alkoclvin=allevinflasker*9

gen alkoclvin_win=allevinflasker_win*9

*brennevinenheter

gen alkoclbrennevin=brennevinenheter*1.6
gen alkoclbrennevin_win=brennevinenheter_win*1.6

*rusbrus/cider

gen alkoclrusbrus=rusbrushalvlitere*2.25
gen alkoclrusbrus_win=rusbrushalvlitere_win*2.25

*total mengde alkohol siste fire uker

gen totalkcl= alkocløl + alkoclvin + alkoclbrennevin + alkoclrusbrus

*beregne cl kun for de som har drukket siste 4 uker (dvs kun for de som har svart på disse spørsmålene)
gen totalkclnetto =totalkcl
replace totalkclnetto=. if alkfiruker==2

gen totalkcl_win= alkocløl_win + alkoclvin_win + alkoclbrennevin_win + alkoclrusbrus_win


*Drikker ukedag og helg: fjerne missing

recode AL2 (8/9=.)
recode AL3 (8/9=.)
recode AL4 (8/9=.)
recode AL5 (8/9=.)

*gruppering av ukedag og helgedag (NB: Ingen svarte "mer enn 16 enheter" på ukedag i 2024. Dermed starter AL3 på 2. Dette kan endre seg til neste år)
recode AL2 (1/3=1)(4=2)(5=3), gen (ukedager)
label define ukedager 1 "drukket 2-4 ukedager" 2 "drukket 1 ukedag" 3 "ikke drukket på ukedager", modify
label val ukedager ukedager

recode AL3 (2/3=1)(4/5=2)(6/7=3), gen (ukedagenheter)
label define ukedagenheter 1 "drikker 6-15 enheter" 2 "drikker 3-5 enheter" 3 "drikker 1-2 enheter", modify
label val ukedagenheter ukedagenheter

recode AL4 (1/2=1)(3=2)(4=3), gen (helgedager)
label define helgedager 1 "drukket 2-3 helgedager" 2 "drukket 1 helgedag" 3 "ikke drukket på helgedager", modify
label val helgedager helgedager

recode AL5 (1/3=1)(4/5=2)(6/7=3), gen (helgeenheter)
label define helgeenheter 1 "drikker 6 eller flere enheter" 2 "drikker 3-5 enheter" 3 "drikker 1-2 enheter", modify
label val helgeenheter helgeenheter



*Berengne AUDIT (har ikke endret labels som derfor er forvirrende etter omregning av Audit 2, 4, 5, 6, 7 og 8. Står 0, aldri, sjeldnere enn mnd, mnd, ukentlig, men er egentlig: aldri, sjeldnere enn mnd, mnd, ukentlig, daglig. For Audit 2 : mengdeangivelser som bør regnes om. Sjekk i originalfil)
*AUDIT1
gen Audit1=0
replace Audit1=1 if Drukket2==4 
replace Audit1=1 if Drukk2b==3
replace Audit1=2 if Drukk2a==3
replace Audit1=2 if Drukk2b==1
replace Audit1=2 if Drukk2b==2
replace Audit1=3 if Drukk2a==2
replace Audit1=4 if Drukk2a==1
replace Audit1=4 if Drukket2==1

*AUDIT2
recode Audit2 (1=0)(2=1)(3=2)(4=3)(5=4)(8/9=.)
gen Audit2new=Audit2
replace Audit2new=0 if Drukket1==2
replace Audit2new=0 if Drukket1==8

*AUDIT3 (sjekke skillet mellom 3 og 4 poeng. Bare daglig gir 4, eller 4-5 ggr i uka gir også 4? (dvs Audit3_1==1-->Audit3new=4) - gnerelt sjekke ettersom kategoriene ikke overensstemmer helt med audit)
gen Audit3new=0
replace Audit3new=1 if Audit3==4
replace Audit3new=1 if Audit3_2==3
replace Audit3new=2 if Audit3_2==1
replace Audit3new=2 if Audit3_2==2
replace Audit3new=2 if Audit3_1==3
replace Audit3new=3 if Audit3_1==1
replace Audit3new=3 if Audit3_1==2
replace Audit3new=4 if Audit3==1

gen Audit3new1=Audit3new
replace Audit3new1=0 if Drukket1==2
replace Audit3new1=0 if Drukket1==8

*Audit4
recode Audit4 (1=0)(2=1)(3=2)(4=3)(5=4)(8/9=.)
gen Audit4new=Audit4
replace Audit4new=0 if Drukket1==2
replace Audit4new=0 if Drukket1==8

*Audit5
recode Audit5 (1=0)(2=1)(3=2)(4=3)(5=4)(8/9=.)
gen Audit5new=Audit5
replace Audit5new=0 if Drukket1==2
replace Audit5new=0 if Drukket1==8


*Audit6
recode Audit6 (1=0)(2=1)(3=2)(4=3)(5=4)(8/9=.)
gen Audit6new=Audit6
replace Audit6new=0 if Drukket1==2
replace Audit6new=0 if Drukket1==8


*Audit7
recode Audit7 (1=0)(2=1)(3=2)(4=3)(5=4)(8/9=.)
gen Audit7new=Audit7
replace Audit7new=0 if Drukket1==2
replace Audit7new=0 if Drukket1==8

*Audit8
recode Audit8 (1=0)(2=1)(3=2)(4=3)(5=4)(8/9=.)
gen Audit8new=Audit8
replace Audit8new=0 if Drukket1==2
replace Audit8new=0 if Drukket1==8

*Audit9 (fant Audit9 i spørreskjemaet(audit9_a_b_c)- men audit9_a er mystisk og stemmer ikke overense med _b og _c?
gen Audit9new=0
replace Audit9new=2 if audit9_b==1
replace Audit9new=2 if audit9_c==1
replace Audit9new=4 if Audit9a==1
replace Audit9new=4 if Audit9b==1

* Audit 9 og 10: Alle er med så trenger ikke å beregne new1??
*gen Audit9new1=Audit9new
*replace Audit9new1=0 if Audit1==0

*Audit10
gen Audit10new=0
replace Audit10new=2 if Audit10==1
replace Audit10new=4 if Audit10a==1

*gen Audit10new1=Audit10new
*replace Audit10new1=0 if Audit1==0

gen Auditscore =Audit1 + Audit2 + Audit3new + Audit4 + Audit5 + Audit6 + Audit7 + Audit8 + Audit9new + Audit10new


*Auditscorenew og risikogruppernew = basert på hele befolkningen og ikke bare de som har drukket siste år.
gen Auditscorenew = Audit1 + Audit2new + Audit3new1 + Audit4new + Audit5new + Audit6new + Audit7new + Audit8new + Audit9new + Audit10new

*Risikogrupper
recode Auditscore (0/7=0)(8/15=1)(16/19=2)(20/40=3), gen (risikogruppe)
recode Auditscorenew (0/7=0)(8/15=1)(16/19=2)(20/40=3), gen (risikogruppenew)


*OBS finne ut hva som skjer med missing i Auditscorenew - bare de som ikke har noe mising skal telles med

*fant ut av det - bare nonmissing er telt med:

egen float kontr = rowmiss(Audit1 Audit2new Audit3new Audit3new1 Audit4new Audit5new Audit6new Audit7new Audit8new Audit9new Audit10new)

tab kontr



*konstruere aldersgrupper
recode Alder (15/24=1)(25/34=2)(35/44=3)(45/54=4)(55/64=5)(55/79=6), gen (Alder6)
label define Alder6 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-79", modify
label val Alder6 Alder6

recode Alder (15/24=1)(25/54=2)(55/79=3), gen (Alder3)
label define Alder3 1 "15-24" 2 "25-54" 3 "55-79", modify
label val Alder3 Alder3

recode Alder (15/44=1)(45/79=2), gen (Alder2)
label define Alder2 1 "15-44" 2 "45-79", modify
label val Alder2 Alder2

*konstruere utdanningsgrupper
recode Utdann_4gr (1=1)(2=2)(3/4=3), gen(Utdann_3gr)
label define  Utdann_3gr 1 "grunnskole og uoppgitt" 2"Videregående skole" 3 "høyere utdanning"
label val Utdann_3gr Utdann_3gr


*tabeller etc
* alkoholforbuk i cl:
summarize totalkcl 
by Kjonn, sort: summarize totalkcl 
by Alder6, sort: summarize totalkcl 
by Utdann_3gr, sort: summarize totalkcl if Alder>24

summarize alkocløl 
by Kjonn, sort: summarize alkocløl 
by Alder6, sort: summarize alkocløl 
by Utdann_3gr, sort: summarize alkocløl if Alder>24

summarize alkoclvin
by Kjonn, sort: summarize alkoclvin 
by Alder6, sort: summarize alkoclvin 
by Utdann_3gr, sort: summarize alkoclvin if Alder>24

summarize alkoclbrennevin
by Kjonn, sort: summarize alkoclbrennevin 
by Alder6, sort: summarize alkoclbrennevin 
by Utdann_3gr, sort: summarize alkoclbrennevin if Alder>24

summarize alkoclrusbrus
by Kjonn, sort: summarize alkoclrusbrus
by Alder6, sort: summarize alkoclrusbrus 
by Utdann_3gr, sort: summarize alkoclrusbrus if Alder>24

*total cl basert på bare de som har drukket siste 4 uker
summarize totalkclnetto

* winsorized alkoholforbuk i cl:
summarize totalkcl_win
by Kjonn, sort: summarize totalkcl_win
by Alder6, sort: summarize totalkcl_win
by Utdann_3gr, sort: summarize totalkcl_win if Alder>24

summarize alkocløl_win
by Kjonn, sort: summarize alkocløl_win 
by Alder6, sort: summarize alkocløl_win
by Utdann_3gr, sort: summarize alkocløl_win if Alder>24

summarize alkoclvin_win
by Kjonn, sort: summarize alkoclvin_win 
by Alder6, sort: summarize alkoclvin_win 
by Utdann_3gr, sort: summarize alkoclvin_win if Alder>24

summarize alkoclbrennevin_win
by Kjonn, sort: summarize alkoclbrennevin_win 
by Alder6, sort: summarize alkoclbrennevin_win
by Utdann_3gr, sort: summarize alkoclbrennevin_win if Alder>24

summarize alkoclrusbrus_win
by Kjonn, sort: summarize alkoclrusbrus_win
by Alder6, sort: summarize alkoclrusbrus_win
by Utdann_3gr, sort: summarize alkoclrusbrus_win if Alder>24

*drikkefrekvens
tab alkofrekvens
tab alkofreksisteår
tab alkfiruker
tab alkfirukeravalle
tab totalfrekvens

tab  totalfrekvens Kjonn, col chi2
tab  totalfrekvens Alder6, col chi2
tab  totalfrekvens Utdann_3gr if Alder>24, col chi2 

*drikking på hverdag og helg
tab ukedager Kjonn, col chi2
tab ukedager Alder6, col chi2
tab ukedager Utdann_3gr if Alder>24, col chi2 

tab ukedagenheter Kjonn, col chi2
tab ukedagenheter Alder6, col chi2
tab ukedagenheter Utdann_3gr if Alder>24, col chi2 

tab helgedager Kjonn, col chi2
tab helgedager Alder6, col chi2
tab helgedager Utdann_3gr if Alder>24, col chi2 

tab helgeenheter Kjonn, col chi2
tab helgeenheter Alder6, col chi2
tab helgeenheter Utdann_3gr if Alder>24, col chi2 

tab ukedager helgedager, col chi2
tab ukedagenheter helgeenheter, col chi2
tab ukedagenheter ukedager , col chi2
tab helgeenheter helgedager , col chi2

*antall enheter (blant alle, uavhengig om de har svart på dette soørsmålet eller ei)
tab totalenheter Kjonn, col chi2
tab totalenheter Alder6, col chi2
tab totalenheter Utdann_3gr if Alder>24, col chi2 

by Kjonn, sort: summarize ølenheter 
by Kjonn, sort: summarize vinenheter 
by Kjonn, sort: summarize brennevinenheter 
by Kjonn, sort: summarize rusbrusenheter 



*antall enheter kun de som har fått disse spørsmålene

by Kjonn, sort: summarize ølenheternetto
by Kjonn, sort: summarize vinenheternetto 
by Kjonn, sort: summarize brennevinenheternetto
by Kjonn, sort: summarize rusbrusenheternetto

by Alder6, sort: summarize ølenheternetto
by Alder6, sort: summarize vinenheternetto 
by Alder6, sort: summarize brennevinenheternetto
by Alder6, sort: summarize rusbrusenheternetto


*AUDIT risikogrupper

tab risikogruppenew Kjonn, col chi2
tab risikogruppenew Alder6, col chi2
tab risikogruppenew Utdann_3gr if Alder>24, col chi2 

*AUDIT ENKELT-ITEMS

tab Audit1 Kjonn, col chi2
tab Audit1 Alder6 , col chi2
tab Audit1 Utdann_3gr if Alder>24, col chi2

tab Audit2new Kjonn, col chi2
tab Audit2new Alder6 , col chi2
tab Audit2new Utdann_3gr if Alder>24, col chi2


tab Audit3new1 Kjonn, col chi2
tab Audit3new1 Alder6 , col chi2
tab Audit3new1 Utdann_3gr if Alder>24 , col chi2


tab Audit4new Kjonn, col chi2
tab Audit4new Alder6 , col chi2
tab Audit4new Utdann_3gr , col chi2


tab Audit5new Kjonn, col chi2
tab Audit5new Alder6 , col chi2
tab Audit5new Utdann_3gr if Alder>24 , col chi2

tab Audit6new Kjonn, col chi2
tab Audit6new Alder6 , col chi2
tab Audit6new Utdann_3gr if Alder>24 , col chi2

tab Audit7new Kjonn, col chi2
tab Audit7new Alder6 , col chi2
tab Audit7new Utdann_3gr , col chi2

tab Audit8new Kjonn, col chi2
tab Audit8new Alder6 , col chi2
tab Audit8new Utdann_3gr if Alder>24 , col chi2

tab Audit9new Kjonn, col chi2
tab Audit9new Alder6 , col chi2
tab Audit9new Utdann_3gr if Alder>24 , col chi2
 
tab Audit10new Kjonn, col chi2
tab Audit10new Alder6 , col chi2
tab Audit10new Utdann_3gr if Alder>24, col chi2 
 
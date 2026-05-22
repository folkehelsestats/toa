* Befolkningsundersøkelse-fil fra Opinion 2025

import spss using "O:\Prosjekt\Rusdata\Befolkningsundersøkelser alkohol og cannabis\Leveranse 2025\Helsedirektoratet_Alkohol_2015–2025.sav"

tabulate År
tabulate År, nolabel

* Lager ny årsvariabel siden Verion ikke har lagt til År i deres data
gen yr = .
replace yr = 2015 if År == 1
replace yr = 2017 if År == 2
replace yr = 2018 if År == 3 
replace yr = 2019 if År == 4
replace yr = 2021 if År == 5
replace yr = 2022 if År == 6
replace yr = 2023 if År == 7
replace yr = 2024 if År == 8
replace yr = 2025 if År == 9

tabulate År yr



* Det er to vektingsvariabler: Weight og new_wegiht, begge er standardiserte
sum weight

	* Etter å ha testet vektene med svy-design i Stata, og sammenliknet tallene med presentasjonen fra Verian 2024, så ser det ut til at det er weight som er brukt.
	* Har fått bekreftet fra Verian at det er Weight som er brukt, setter det som vekt.

	svyset _n [pweight= weight]
	

	* Variabler over tid til rapport:
*******************************************************************************
/* Hvor drikker man oftest alkohol*/

	* OBS på at Verian (2024-tall) ikke har registrert not selected slik som Opinion har. Dette er viktig dersom man skal bruke 2024 tall. Nå benyttes 2025.
	
	* Hjemme sammen med venner
	svy: tab Q12_01 if yr == 2025, percent
	svy: tab Q12_01 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_01 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_01 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* Hjemme sammen med familie
	svy: tab Q12_02 if yr == 2025, percent
	svy: tab Q12_02 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_02 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_02 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* Hjemme alene
	svy: tab Q12_03 if yr == 2025, percent
	svy: tab Q12_03 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_03 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_03 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* På besøk hos venner/kjente
	svy: tab Q12_04 if yr == 2025, percent
	svy: tab Q12_04 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_04 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_04 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* På besøk hos familie
	svy: tab Q12_05 if yr == 2025, percent
	svy: tab Q12_05 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_05 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_05 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* Ute på byen/serveringssted
	svy: tab Q12_06 if yr == 2025, percent
	svy: tab Q12_06 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_06 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_06 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* I jobbsammenheng/med kollegaer
	svy: tab Q12_08 if yr == 2025, percent
	svy: tab Q12_08 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_08 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_08 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet
	
	* Annet
	svy: tab Q12_98 if yr == 2025, percent
	svy: tab Q12_98 if yr == 2025 & gender_new == 1, percent // mann
	svy: tab Q12_98 if yr == 2025 & gender_new == 2, percent // kvinne
	svy: tab Q12_98 if yr == 2025 & gender_new == 3, percent // annen kjønnsidentitet

*******************************************************************************
	***Holdninger til alkoholpolitikk
*******************************************************************************
/* Andel som er helt eller delvis enig i følgende påstander om alkoholpolitikk*/
	tabulate Q1r1
	tabulate Q1r1, nolabel
	gen alkodyr = Q1r1 // alkohol er for dyrt i Norge
	label values alkodyr labels15
	replace alkodyr = 1 if alkodyr ==2
	tabulate alkodyr
	*svy: tab alkodyr if yr == 2024, percent	
	svy: tab alkodyr if yr == 2025, percent	

	
	tabulate Q1r3
	tabulate Q1r3, nolabel // Vin bør selges i dagligvarehandel
	gen vindvh = Q1r3
	label values vindvh labels17
	replace vindvh = 1 if vindvh ==2
	tabulate vindvh
	*svy: tab vindvh if yr == 2024, percent	
	svy: tab vindvh if yr == 2025, percent	

	tabulate Q1r5
	tabulate Q1r5, nolabel // Det bør være lov å reklamere for alkohol
	gen lovreklame = Q1r5
	label values lovreklame labels19
	replace lovreklame = 1 if lovreklame ==2
	tabulate lovreklame
	*svy: tab lovreklame if yr == 2024, percent	
	svy: tab lovreklame if yr == 2025, percent	

	tabulate Q1r7
	tabulate Q1r7, nolabel // Det går greit å smugle litt alkohol
	gen smugle = Q1r7
	label values smugle labels21
	replace smugle = 1 if smugle ==2
	tabulate smugle
	*svy: tab smugle if yr == 2024, percent	
	svy: tab smugle if yr == 2025, percent	
	
	tabulate Q1r9
	tabulate Q1r9, nolabel // Dagens taxfree-ordning bør bestå
	gen tfbesta = Q1r9
	label values tfbesta labels23
	replace tfbesta = 1 if tfbesta ==2
	tabulate tfbesta
	*svy: tab tfbesta if yr == 2024, percent
	svy: tab tfbesta if yr == 2025, percent

	tabulate Q1r11
	tabulate Q1r11, nolabel // Alkohol bør merkes med innholdsdeklarasjon
	gen innhold = Q1r11
	label values innhold labels25
	replace innhold = 1 if innhold ==2
	tabulate innhold
	*svy: tab innhold if yr == 2024, percent
	svy: tab innhold if yr == 2025, percent

	tabulate Q1r12
	tabulate Q1r12, nolabel // Alkohol bør merkes med helseinformasjon
	gen helseinfo = Q1r12
	label values helseinfo labels26
	replace helseinfo = 1 if helseinfo ==2
	tabulate helseinfo
	*svy: tab helseinfo if yr == 2024, percent
	svy: tab helseinfo if yr == 2025, percent

	tabulate Q1r15
	tabulate Q1r15, nolabel // Vinmonoolet bør overta taxfree-butikkene
	gen vinmontf = Q1r15
	label values vinmontf labels28
	replace vinmontf = 1 if vinmontf ==2
	tabulate vinmontf
	*svy: tab vinmontf if yr == 2024, percent
	svy: tab vinmontf if yr == 2025, percent

	tabulate Q1r2
	tabulate Q1r2, nolabel // For vanskelig å få kjøpt alkohol
	gen vanskelig = Q1r2
	label values vanskelig labels16
	replace vanskelig = 1 if vanskelig ==2
	tabulate vanskelig
	*svy: tab vanskelig if yr == 2024, percent
	svy: tab vanskelig if yr == 2025, percent

	tabulate Q1r4
	tabulate Q1r4, nolabel // Brennevin bør selges i dagligvarehandelen
	gen brennevindvh = Q1r4
	label values brennevindvh labels18
	replace brennevindvh = 1 if brennevindvh ==2
	tabulate brennevindvh
	*svy: tab brennevindvh if yr == 2024, percent
	svy: tab brennevindvh if yr == 2025, percent

	tabulate Q1r6
	tabulate Q1r6, nolabel // Promillegrensen for bilkjøring er for strenge
	gen promillestreng = Q1r6
	label values promillestreng labels20
	replace promillestreng = 1 if promillestreng ==2
	tabulate promillestreng
	*svy: tab promillestreng if yr == 2024, percent
	svy: tab promillestreng if yr == 2025, percent

	tabulate Q1r8
	tabulate Q1r8, nolabel // Aldergrense for øl/vin bør heves til 20 år
	gen hevealder = Q1r8
	label values hevealder labels22
	replace hevealder = 1 if hevealder ==2
	tabulate hevealder
	*svy: tab hevealder if yr == 2024, percent
	svy: tab hevealder if yr == 2025, percent
	
	tabulate Q1r10
	tabulate Q1r10, nolabel // Man bør ikke kunne ta med seg noe alkohol på taxfreekvota inn i landet
	gen inniland = Q1r10
	label values inniland labels24
	replace inniland = 1 if inniland ==2
	tabulate inniland
	*svy: tab inniland if yr == 2024, percent
	svy: tab inniland if yr == 2025, percent
/*
	tabulate Q1r13
	tabulate Q1r13, nolabel // Det bør ikke være lov å selge vin i større enn 2-liters kartonger
	gen toliters = Q1r13
	label values toliters labels
	replace toliters = 1 if toliters ==2
	tabulate toliters
	svy: tab toliters if yr == 2024, percent
*/

	tabulate Q1r14
	tabulate Q1r14, nolabel // Aldersgrensen for å kjøpe alkohol bør senkes
	gen senkealder = Q1r14
	label values senkealder labels27
	replace senkealder = 1 if senkealder ==2
	tabulate senkealder
	*svy: tab senkealder if yr == 2024, percent
	svy: tab senkealder if yr == 2025, percent

	tabulate Q1r16
	tabulate Q1r16, nolabel // Vinkartongen bør bli mindre
	gen mindrevink = Q1r16
	label values mindrevink labels29
	replace mindrevink = 1 if mindrevink ==2
	tabulate mindrevink
	*svy: tab mindrevink if yr == 2024, percent
	svy: tab mindrevink if yr == 2025, percent

	tabulate Q1r17
	tabulate Q1r17, nolabel // Fastleger bør som rutine spørre pasienter om alkoholbruk
	gen fastleger = Q1r17
	label values fastleger labels29
	replace fastleger = 1 if fastleger ==2
	tabulate fastleger
	svy: tab fastleger if yr == 2025, percent

	tabulate Q1r18
	tabulate Q1r18, nolabel // Fastleger bør som rutine spørre pasienter om alkoholbruk
	gen promillebaat = Q1r18
	label values promillebaat labels29
	replace promillebaat = 1 if promillebaat ==2
	tabulate promillebaat
	svy: tab promillebaat if yr == 2025, percent

*******************************************************************************
	*** Holdninger til tiltak som begrenser skadevirkningene av alkoholkonsum
*******************************************************************************	
/*Andel som i svært stor eller ganske stor grad tror følgende tiltak begrenser skadevirkningene av alkoholkonsum*/

	tabulate Q2r1
	tabulate Q2r1, nolabel // aldersgrense for kjøp av alkohol 
	gen alderhøy = Q2r1
	label value alderhøy labels33
	replace alderhøy = 1 if alderhøy ==2
	tabulate alderhøy
	*svy: tab alderhøy if yr == 2024, percent
	svy: tab alderhøy if yr == 2025, percent

	tabulate Q2r2
	tabulate Q2r2, nolabel // Promilleregler for bilkjøpring i alkholpåvirket stand
	gen promillekj = Q2r2
	label value promillekj labels34
	replace promillekj = 1 if promillekj ==2
	tabulate promillekj
	*svy: tab promillekj if yr == 2024, percent
	svy: tab promillekj if yr == 2025, percent

	tabulate Q2r3
	tabulate Q2r3, nolabel // Skjenkeregler som lukningstid er på utesteder 
	gen skjenkeregler = Q2r3
	label value skjenkeregler labels35
	replace skjenkeregler = 1 if skjenkeregler ==2
	tabulate skjenkeregler
	*svy: tab skjenkeregler if yr == 2024, percent
	svy: tab skjenkeregler if yr == 2025, percent
	
	tabulate Q2r6
	tabulate Q2r6, nolabel // Informasjon og holdsningsskapende arbeid
	gen infooghold = Q2r6
	label value infooghold labels38
	replace infooghold = 1 if infooghold ==2
	tabulate infooghold
	*svy: tab infooghold if yr == 2024, percent
	svy: tab infooghold if yr == 2025, percent

	
	tabulate Q2r7
	tabulate Q2r7, nolabel // Hyppige kontroller av salg og skjenking
	gen kontroller = Q2r7
	label value kontroller labels39
	replace kontroller = 1 if kontroller ==2
	tabulate kontroller
	*svy: tab kontroller if yr == 2024, percent
	svy: tab kontroller if yr == 2025, percent

	tabulate Q2r8
	tabulate Q2r8, nolabel // Foreldre setter grenser for barna sine
	gen foreldre = Q2r8
	label value foreldre labels40
	replace foreldre = 1 if foreldre ==2
	tabulate foreldre
	*svy: tab foreldre if yr == 2024, percent
	svy: tab foreldre if yr == 2025, percent

	tabulate Q2r4
	tabulate Q2r4, nolabel // Salg av vin og sprit begrenses til vinmonopolet
	gen vinmono = Q2r4
	label value vinmono labels36
	replace vinmono = 1 if vinmono ==2
	tabulate vinmono
	*svy: tab vinmono if yr == 2024, percent
	svy: tab vinmono if yr == 2025, percent

	tabulate Q2r5
	tabulate Q2r5, nolabel // Høye priser/avgifter på alkohol
	gen priser = Q2r5
	label value priser labels37
	replace priser = 1 if priser ==2
	tabulate priser
	*svy: tab priser if yr == 2024, percent
	svy: tab priser if yr == 2025, percent
	
	tabulate Q2r9
	tabulate Q2r9, nolabel // Taxfree-salget avvikles
	gen tfavvikles = Q2r9
	label value tfavvikles labels41
	replace tfavvikles = 1 if tfavvikles ==2
	tabulate tfavvikles
	*svy: tab tfavvikles if yr == 2024, percent
	svy: tab tfavvikles if yr == 2025, percent
	
	tabulate Q2r12
	tabulate Q2r12, nolabel // Strengere promillegrense for fritidsbåter
	gen prom_baat = Q2r12
	label value prom_baat labels41
	replace prom_baat = 1 if prom_baat ==2
	tabulate prom_baat
	svy: tab prom_baat if yr == 2025, percent
	
	tabulate Q2r10
	tabulate Q2r10, nolabel // At alkoholholdige varer har innholdsdeklarasjon som andre varer 
	gen til_innhold = Q2r10
	label value til_innhold labels41
	replace til_innhold = 1 if til_innhold ==2
	tabulate til_innhold
	svy: tab til_innhold if yr == 2025, percent
	
	tabulate Q2r11
	tabulate Q2r11, nolabel // At alkoholholdige varer har informasjon om helserisiko ved bruk
	gen til_helserisk = Q2r11
	label value til_helserisk labels41
	replace til_helserisk = 1 if til_helserisk ==2
	tabulate til_helserisk
	svy: tab til_helserisk if yr == 2025, percent
	
*******************************************************************************
	*** Påstander om alkoholvirkning
*******************************************************************************	

	* Alkoholinntak i svangerskapet øker risikoen for fosterskader
	tabulate Q10r2
	tabulate Q10r2, nolabel
	gen alkohosvanger = Q10r2
	label value alkohosvanger labels58
	replace alkohosvanger = 1 if alkohosvanger ==2
	tabulate alkohosvanger
	svy: tab alkohosvanger if yr == 2015, percent
	svy: tab alkohosvanger if yr == 2017, percent
	svy: tab alkohosvanger if yr == 2018, percent
	svy: tab alkohosvanger if yr == 2019, percent
	svy: tab alkohosvanger if yr == 2021, percent
	svy: tab alkohosvanger if yr == 2022, percent
	svy: tab alkohosvanger if yr == 2023, percent
	svy: tab alkohosvanger if yr == 2024, percent
	svy: tab alkohosvanger if yr == 2025, percent

	* Det er sunt å drikke ett glass vin om dagen
	tabulate Q10r3
	tabulate Q10r3, nolabel
	gen glasssunt = Q10r3 
	label value glasssunt labels59
	replace glasssunt = 1 if glasssunt ==2
	tabulate glasssunt
	svy: tab glasssunt if yr == 2015, percent
	svy: tab glasssunt if yr == 2017, percent
	svy: tab glasssunt if yr == 2018, percent
	svy: tab glasssunt if yr == 2019, percent
	svy: tab glasssunt if yr == 2021, percent
	svy: tab glasssunt if yr == 2022, percent
	svy: tab glasssunt if yr == 2023, percent
	svy: tab glasssunt if yr == 2024, percent
	svy: tab glasssunt if yr == 2025, percent
	

	* Det er liten sammenheng mellom alkoholbruk og vold
	tabulate Q10r5
	tabulate Q10r5, nolabel
	gen litenvold = Q10r5
	label value litenvold labels61
	replace litenvold = 1 if litenvold ==2
	tabulate litenvold
	svy: tab litenvold if yr == 2015, percent
	svy: tab litenvold if yr == 2017, percent
	svy: tab litenvold if yr == 2018, percent
	svy: tab litenvold if yr == 2019, percent
	svy: tab litenvold if yr == 2021, percent
	svy: tab litenvold if yr == 2022, percent
	svy: tab litenvold if yr == 2023, percent
	svy: tab litenvold if yr == 2024, percent
	svy: tab litenvold if yr == 2025, percent
	
	
	* Rødvin er sunnere enn andre former for alkohol
	tabulate Q10r6
	tabulate Q10r6, nolabel
	gen rødsunnere = Q10r6
	label value rødsunnere labels62
	replace rødsunnere = 1 if rødsunnere ==2
	tabulate rødsunnere
	svy: tab rødsunnere if yr == 2015, percent
	svy: tab rødsunnere if yr == 2017, percent
	svy: tab rødsunnere if yr == 2018, percent
	svy: tab rødsunnere if yr == 2019, percent
	svy: tab rødsunnere if yr == 2021, percent
	svy: tab rødsunnere if yr == 2022, percent
	svy: tab rødsunnere if yr == 2023, percent
	svy: tab rødsunnere if yr == 2024, percent
	svy: tab rødsunnere if yr == 2025, percent

	* Alkohol er en risikofaktor for ulike former for kreft
	tabulate Q10r13
	tabulate Q10r13, nolabel
	gen kreft = Q10r13
	label value kreft labels69
	replace kreft = 1 if kreft ==2
	tabulate kreft
	svy: tab kreft if yr == 2021, percent
	svy: tab kreft if yr == 2022, percent
	svy: tab kreft if yr == 2023, percent
	svy: tab kreft if yr == 2024, percent	
	svy: tab kreft if yr == 2025, percent	
	


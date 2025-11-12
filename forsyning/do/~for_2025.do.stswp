*******************************************************************************

	* Filen importerer og ser på data fra forsyningsundersøkelsen
	* Filen er opprettet av Hdir
	* Opprettet 12/11-2025

********************************************************************************

*** Importerer fil
import spss using "O:\Prosjekt\Rusdata\Forsyningsundersøkelsen\Data_Forsyn_2015_2024\FU_veid_2015_2025_sep.sav"

*** Lager tidsvariabler, i tråd med filer fra FHI:

	tostring Astartdato1, generate(datostring)

	gen double dato=date(datostring, "YMD")

	format dato %tdDD-MM-YYYY
	format dato %td

	gen dag = day(dato)
	gen maned = month(dato)
	gen aar = year(dato)


numlabel, add force // tvinger stata til å bruke labels og nummer.


*** Lager variabler i tråd med FHI, kjønn og alder:

	rename Aalder1 alder
	rename Akjonn kjonn

	drop if kjonn==.
	drop if alder>74
	drop if alder<16

	gen alder_4=alder if alder>15 & alder<75
	recode alder_4 (16/24=1)(25/49=2)(50/64=3)(65/74=4)
	lab define alder_4 1 "16-24" 2 "25-49" 3 "50-64" 4 "65-74", replace
	lab val alder_4 alder_4

	gen alder_10=alder if alder>15 & alder<=75
	recode alder_10 (16/25=1)(26/35=2)(36/45=3)(46/55=4)(56/65=5)(66/75=6)
	lab define alder_10 1 "16-25" 2 "26-35" 3 "36-45" 4 "46-55" 5 "56-65" 6 "66-75", replace
	lab val alder_10 alder_10


*** Lager variabler for røyk, snus og damp i tråd med FHIs koder:

	gen royk=Aq1
	gen snus=Aq2
	gen damp=Aq3
	
	* Ulike røykevaner variabler:
	recode Aq1 (1=1)(2/3=2)(4/6=3), 		gen(royk_3) // Daglig; av og til; tidligere/aldri
	recode Aq1 (1=1)(2/3=2)(4/5=3)(6=4), 	gen(royk_4) // Daglig; av og til; tidligere; aldri
	recode Aq1 (1=1)(2/3=2)(4=3)(5=4)(6=5), gen(royk_5) // Daglig; av og til; daglig-tidligere; avogtil-tidligere; aldri
	
	* Ulike snusvaner variabler:
	recode Aq2 (1=1)(2/3=2)(4/6=3), 		gen(snus_3) // Daglig; av og til; tidligere/aldri
	recode Aq2 (1=1)(2/3=2)(4/5=3)(6=4), 	gen(snus_4) // Daglig; av og til; tidligere; aldri
	
	* Ulike dampvaner variabler:
	recode Aq3 (1=1)(2/3=2)(4/5=3)(6=4), 	gen(damp_4) // Daglig; av og til; tidligere; aldri
	recode Aq3 (1=1)(2/3=2)(4/6=3), 		gen(damp_3) // Daglig; av og til; tidligere/aldri
	
	recode Aq3 (1/3=1)(4/6=0), 				gen(damp_regelmessig)	// daglig/avogtil; tidligere/aldri
	recode Aq3 (1=1)(2/6=0), 				gen(damp_daglig)		// daglig; avogtil/tidligere/aldri
	recode Aq3 (2/3=1)(1 4/6=0), 			gen(damp_avogtil)		// avogtil; daglig/tidligere/aldri
	recode Aq3 (4/5=1)(1/3 6=0), 			gen(damp_tidligere)		// tidligere; daglig/avogtil/aldri

	recode Ae1 (2=1)(3=2), 					gen(e_type)				// 
	recode Ae2 (3/4=3)(5=4)(6=5), 			gen(damp_innhold)		//
	
	
	*** Lager variabler som omkoder individer som ikke har svart på kjøpskilde om hvor man har kjøpt røyk og snus siste 24t for personer som røyker/snuser daglig eller av og til, til 0 for å få total N i hver variabl til å refletere alle som er daglig/avogtil røykere/snusere. 

		/* ~=1 tilsvarer !=1*/
		
	gen temp_s=0 if royk<=3 								//MERK! Gir 0 for individer som røyker daglig/avogtil
	
	/* Setter daglig og avogtil røykere til at de ikke har svart på kjøpskilden (0) for alle variabler As11-As19 for å for tot N daglig/avogtil røykere inn når man skal rapportere kjøpskilden for denne gruppen og få fordeling/andel. */
	
		forvalues n=1/9 {									// For variablene om hvor man har kjøpt røyk siste 24t
			replace As1`n'=0 if temp_s==0 & As1`n'~=1 		// endrer til kjøpsvar til 0 hvis man røyker daglig/avogtil og kjøpsvar ikke == 1.
		}

	/* Tilsvarende for snus*/
	gen temp_n=0 if snus<=3 								//MERK!
		forvalues n=1/9 {
			replace An1`n'=0 if temp_n==0 & An1`n'~=1 
		}
		

	elabel variable (As11-As19) ("") // fjerner variabellabel

	elabel variable (An11-An19) ("") // fjerner variabellabel

	numlabel, add force

	
********************************************************************************
** Beregner med kode fra FHI:

	********************************					
	******* Forsyningskilder *******
	********************************				

*** OBS. Koden fra FHI under er gir ikke tabellene som den sier, gir ikke prosent. Må sjekkes nærmere.


	**************************************************
	*Dagligrøykere, andel kjøp ulike steder
	**************************************************

	preserve
	keep if royk==1


		*Vedleggstabell 3.X: Andel som svarte hvor sigaretter røykt siste 24 timer var kjøpt, 2015-2020, dagligrøykere i alderen 16-74

			table aar if As19==0 & (alder>15 & alder<75), statistic(mean As11 As12 As13 As14 As15 As16 As17 As18) //statistic(count As19)

			*Med vekt

			table aar if As19==0 & (alder>15 & alder<75) [pweight=W1], statistic(mean As11 As12 As13 As14 As15 As16 As17 As18) //statistic(count As19)
			
	restore
	
**************************************************
	*Dagligrøykere, andel antall DENNE!
	**************************************************
preserve
keep if royk==1
	** Regner ut totalt antall sigaretter kjøpt fra de ulike kildene per år:
		bysort aar: egen roykkjopt_nor=sum(As21) if alder>15 & alder<75
		bysort aar: egen roykkjopt_tax=sum(As22) if alder>15 & alder<75
		bysort aar: egen roykkjopt_smu=sum(As23) if alder>15 & alder<75
		bysort aar: egen roykkjopt_sve=sum(As24) if alder>15 & alder<75
		bysort aar: egen roykkjopt_dan=sum(As25) if alder>15 & alder<75
		bysort aar: egen roykkjopt_utl=sum(As26) if alder>15 & alder<75
		bysort aar: egen roykkjopt_inn=sum(As27) if alder>15 & alder<75
		bysort aar: egen roykkjopt_inu=sum(As28) if alder>15 & alder<75

		gen n_royk_nor =As21
		replace n_royk_nor=1 if As21>0&As21<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_tax =As22
		replace n_royk_tax=1 if As22>0&As22<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_smu =As23
		replace n_royk_smu=1 if As23>0&As23<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_sve =As24
		replace n_royk_sve=1 if As24>0&As24<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_dan =As25
		replace n_royk_dan=1 if As25>0&As25<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_utl =As26
		replace n_royk_utl=1 if As26>0&As26<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_inn =As27
		replace n_royk_inn=1 if As27>0&As27<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk_inu =As28
		replace n_royk_inu=1 if As28>0&As28<. // Variabel som markerer indiver som har kjøpt minst 1 røyk.

		gen n_royk=1 if n_royk_nor==1 | n_royk_tax==1 | n_royk_smu==1 | n_royk_sve==1 | n_royk_dan==1 | n_royk_utl==1 | n_royk_inn==1 | n_royk_inu==1 	// Varibel som markerer individer som har kjøpt minst 1 røyk fra en av de ulike kildene (As21-As28).

		*Prosentandel av siste døgns sigarettforbruk blant dagligrøykere som ble kjøpt i Norge og i utlandet, 2015-2023, personer i alderen 16-74

			table aar if alder>15 & alder<75, statistic(mean roykkjopt_nor roykkjopt_tax roykkjopt_smu roykkjopt_sve roykkjopt_dan roykkjopt_utl roykkjopt_inn roykkjopt_inu)
			table aar if alder>15 & alder<75 , statistic(sum n_royk)

			*Med vekt
		
			table aar if alder>15 & alder<75 [pweight=W1], statistic(mean roykkjopt_nor roykkjopt_tax roykkjopt_smu roykkjopt_sve roykkjopt_dan roykkjopt_utl roykkjopt_inn roykkjopt_inu)
			table aar if alder>15 & alder<75 [pweight=W1], statistic(sum n_royk)

restore		



			
			
	
	






* Importere SSB tall.
* 2025

import delimited "https://data.ssb.no/api/pxwebapi/v2/tables/04188/data?lang=no&outputFormat=csv&valuecodes[Tid]=2025&valuecodes[Alkohol]=*&valuecodes[ContentsCode]=*&heading=Alkohol,Tid&stub=ContentsCode"


label variable v2 "Alkohol totalt"
label variable v3 "Brennevin"
label variable v4 "Vin"
label variable v5 "Øl"
label variable v6 "Rusbrus"

rename v2 Totalt
rename v3 Brennevin
rename v4 Vin
rename v5 Øl
rename v6 Rusbrus


replace contentscode = "Alkoliter1000" if contentscode == "ForbrukAlkoliter"
replace contentscode = "Vareliter1000" if contentscode == "ForbrukVareliter"
replace contentscode = "VarelInnbygg15" if contentscode == "ForbrukInbygger"
replace contentscode = "AlkolInnbygg15" if contentscode == "ForbrukInbAlkLit"

* 2024
clear all
import delimited "https://data.ssb.no/api/pxwebapi/v2/tables/04188/data?lang=no&outputFormat=csv&valuecodes[Tid]=2024&valuecodes[Alkohol]=*&valuecodes[ContentsCode]=*&heading=Alkohol,Tid&stub=ContentsCode"

* 2023
clear all
import delimited "https://data.ssb.no/api/pxwebapi/v2/tables/04188/data?lang=no&outputFormat=csv&valuecodes[Tid]=2023&valuecodes[Alkohol]=*&valuecodes[ContentsCode]=*&heading=Alkohol,Tid&stub=ContentsCode"
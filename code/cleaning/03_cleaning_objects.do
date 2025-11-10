/// PROJECT: Housing Policy
/// GOAL: Data Cleaning
/// AUTHOR: Laura Arnemann
/// CREATION: 11.12.2023
/// LAST UPDATE: 
/// SOURCE: *

********************************************************************************
* Reading in the data 
********************************************************************************

use "${IN}/Sonderaufbereitung_RED_v9_WM.dta", clear 

 
 rename ajahr jahr 
 tabstat obid, by(jahr) stats(count)
 
* Only keep observations in Berlin 
 keep if kid2019 == 11000
 
 replace mietekalt=. if mietekalt<0 
 replace mietewarm=. if mietewarm<0
 replace wohnflaeche = . if wohnflaeche<0 
 gen qm_miete_kalt=mietekalt/wohnflaeche 
 gen qm_miete_warm=mietewarm/wohnflaeche 
 
* Drop implausible high values 
 drop if qm_miete_kalt>40 
 drop if qm_miete_kalt<3
 replace qm_miete_warm = . if qm_miete_warm>40
* drop if qm_miete_warm >50
 
foreach var of varlist qm_miete_kalt qm_miete_warm mietekalt mietewarm {
 bysort obid jahr: egen mean_`var'=mean(`var')
 replace `var' = mean_`var'
 drop mean_`var'
}
 duplicates drop obid jahr, force
 
keep qm_miete_kalt qm_miete_warm obid plz mietekalt mietewarm nebenkosten wohnflaeche laufzeittage letzte_modernisierung jahr foerderung hits PLR_ID 
 

* Labeling the variables 
label var mietewarm "Warmmiete"
label var mietekalt "Kaltmiete"
label var qm_miete_kalt "QM Miete, Kalt"
label var qm_miete_warm "QM Miete, Warm"
label var plz "PLZ"
label var nebenkosten "Nebekosten"
label var PLR_ID "PLR ID"
label var foerderung "WBS ja/nein"

 save "$TEMP/berlin_data_object.dta", replace
 

 
 
 
 
 
 
 
 
 

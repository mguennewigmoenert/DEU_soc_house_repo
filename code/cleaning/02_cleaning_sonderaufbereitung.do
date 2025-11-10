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
 
* preserve
 preserve
 
* Alle geförderten Wohnungen rausnehmen 
drop if foerderung==1 


* modernization/renovation
g modern = 1
replace modern = 0 if letzte_modernisierung == -9

g modern_year = 0
replace modern_year = 1 if letzte_modernisierung == jahr

g modern_year_1 = 0
replace modern_year_1 = (letzte_modernisierung == jahr + 1)

 collapse (mean) mietewarm mietekalt qm_miete_kalt qm_miete_warm (median) medmietewarm=mietewarm medmietekalt=mietekalt med_qm_kalt=qm_miete_kalt med_qm_warm=qm_miete_warm (sd) sd_miete = mietewarm sd_qm_kalt = qm_miete_kalt (count) n = mietekalt (sum) objects_moden = modern objects_modern_year=modern_year objects_modern_year_1=modern_year_1, by(PLR_ID jahr)

rename n objects 

* Labeling the variables 
label var mietewarm "Warmmiete"
label var mietekalt "Kaltmiete"
label var qm_miete_kalt "QM Miete, Kalt"
label var qm_miete_warm "QM Miete, Warm"
label var medmietewarm "Warmmiete, Median"
label var medmietekalt "Kaltmiete, Median"
label var med_qm_kalt "QM Miete, Kalt (Median)"
label var med_qm_warm "Qm Miete, Warm (Median)"
label var objects "Anzahl Objekte"
label var PLR_ID "PLR ID"

 save "$TEMP/berlin_data.dta", replace
 
* restore with public housing
restore, preserve

g wbs = 0
replace wbs = 1 if foerderung==1

* collapse by funding type
 collapse (mean) mietewarm mietekalt qm_miete_kalt qm_miete_warm (median) medmietewarm=mietewarm medmietekalt=mietekalt med_qm_kalt=qm_miete_kalt med_qm_warm=qm_miete_warm (sd) sd_miete = mietewarm sd_qm_kalt = qm_miete_kalt (count) n=mietekalt , by(PLR_ID wbs jahr)


rename n objects 

* Labeling the variables 
label var mietewarm "Warmmiete"
label var mietekalt "Kaltmiete"
label var qm_miete_kalt "QM Miete, Kalt"
label var qm_miete_warm "QM Miete, Warm"
label var medmietewarm "Warmmiete, Median"
label var medmietekalt "Kaltmiete, Median"
label var med_qm_kalt "QM Miete, Kalt (Median)"
label var med_qm_warm "Qm Miete, Warm (Median)"
label var objects "Anzahl Objekte"
label var PLR_ID "PLR ID"

 save "$TEMP/berlin_data_ph.dta", replace
 
 
* restore with public housing
restore
* collapse by funding type
 collapse (mean) mietewarm_wbs=mietewarm mietekalt_wbs= mietekalt qm_miete_kalt_wbs = qm_miete_kalt qm_miete_warm_wbs = qm_miete_warm (median) medmietewarm_wbs=mietewarm medmietekalt_wbs=mietekalt med_qm_kalt_wbs=qm_miete_kalt med_qm_warm_wbs=qm_miete_warm (sd) sd_miete_wbs = mietewarm sd_qm_kalt_wbs = qm_miete_kalt (count) n_wbs=mietekalt , by(PLR_ID jahr)


rename n_wbs objects_wbs 

* Labeling the variables 
label var mietewarm_wbs "Warmmiete incl. WBS properties"
label var mietekalt_wbs "Kaltmiete incl. WBS properties"
label var qm_miete_kalt_wbs "QM Miete, Kalt incl. WBS properties"
label var qm_miete_warm_wbs "QM Miete, Warm incl. WBS properties"
label var medmietewarm_wbs "Warmmiete, Median incl. WBS properties"
label var medmietekalt_wbs "Kaltmiete, Median incl. WBS properties"
label var med_qm_kalt_wbs "QM Miete, Kalt (Median) incl. WBS properties"
label var med_qm_warm_wbs "Qm Miete, Warm (Median) incl. WBS properties"
label var objects_wbs "Anzahl Objekte incl. WBS properties"
label var PLR_ID "PLR ID"

 save "$TEMP/berlin_data_incl_wbs.dta", replace
 
 
 
 
 
 
 
 
 
 

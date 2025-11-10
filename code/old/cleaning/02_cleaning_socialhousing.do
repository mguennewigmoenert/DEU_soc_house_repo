/// PROJECT: Housing Policy
/// GOAL: Data Cleaning
/// AUTHOR: Laura Arnemann
/// CREATION: 11.12.2023
/// LAST UPDATE: 
/// SOURCE: *

********************************************************************************
* Reading in the data 
********************************************************************************

clear 
forvalues i=1/13 {
append using "$IN/immoscout/WM_SUF_ohneText`i'.dta", force
*Information from Wikipedia
*https://de.wikipedia.org/wiki/Liste_der_kreisfreien_St%C3%A4dte_in_Deutschland
*keep if kid2019==05334 | kid2019==09361 | kid2019==09561 | kid2019==09661 | kid2019==09761 | kid2019==08211 | kid2019==09461 | kid2019==09462 | kid2019==11000 | kid2019==05711  | kid2019==05911 | kid2019==05314 | kid2019==05512 | kid2019==12051 | kid2019==03101 | kid2019==04011 | kid2019==04012 | kid2019==14511 | kid2019==09463 | kid2019==12052 | kid2019==06411 | kid2019==03401 | kid2019==15001 | kid2019==05913 | kid2019==14612 | kid2019==05112 | kid2019==05111 | kid2019==03402 | kid2019==16051 | kid2019==09562 | kid2019==05113 | kid2019==01001 | kid2019==07311 | kid2019==12053 | kid2019==06412 | kid2019==08311 | kid2019==09563 | kid2019==05513 | kid2019==16052 | kid2019==03159 | kid2019==05914 | kid2019==15002 | kid2019==02000 | kid2019==05915 | kid2019==03241 | kid2019==08221 | kid2019==08121 | kid2019==05916 | kid2019==09464 | kid2019==09161 | kid2019==16053 | kid2019==07312 | kid2019==08212 | kid2019==06611 | kid2019==09762 | kid2019==09763 | kid2019==01002 | kid2019==07111 | kid2019==05315 | kid2019==05114 | kid2019==07313 | kid2019==09261 | kid2019==14713 | kid2019==05316 | kid2019==01003 | kid2019==07314 | kid2019==15003 | kid2019==07315 | kid2019==08222 | kid2019==09764 | kid2019==05116 | kid2019==05117 | kid2019==09162 | kid2019==05515 | kid2019==01004 | kid2019==07316 | kid2019==09564 | kid2019==05119 | kid2019==06413 | kid2019==03403 | kid2019==03404 | kid2019==09262 | kid2019==08231 | kid2019==07317 | kid2019==12054 | kid2019==09362 | kid2019==05120 | kid2019==09163 | kid2019==13003 | kid2019==03102 | kid2019==09565 | kid2019==09662 | kid2019==13004 | kid2019==05122 | kid2019==07318 | kid2019==09263 | kid2019==08111 | kid2019==16054 | kid2019==07211 | kid2019==08421 | kid2019==09363 | kid2019==16055 | kid2019==06414 | kid2019==03405 | kid2019==03103 | kid2019==07319 | kid2019==05124 | kid2019==09663 | kid2019==07320
* only keep the information for observations in the largest cities 
 gen file`i'=1
 
 } 

 
  gen file=1 if file1!=. 
 replace file=2 if missing(file1) & file2!=. 
 replace file=3 if missing(file2) & file3!=. 
 replace file=4 if missing(file3) & file4!=. 
 replace file=5 if missing(file4) & file5!=. 
 replace file=6 if missing(file5) & file6!=. 
 replace file=7 if missing(file6) & file7!=. 
 replace file=8 if missing(file7) & file8!=. 
 drop file1-file13
 
 rename ajahr jahr 
 
 * Only keep observations in Berlin 
 
 *keep if kid2019 == 11000

 replace mietekalt=. if mietekalt<0 
 replace mietewarm=. if mietewarm<0
 replace wohnflaeche = . if wohnflaeche<0 
 gen qm_miete_kalt=mietekalt/wohnflaeche 
 gen qm_miete_warm=mietewarm/wohnflaeche 
 
 tabstat obid, by(jahr) stats(count)
 *tabstat obid if kid2019==02000, by(jahr) stats(count)
 tabstat obid, by(ejahr) stats(count)
 tabstat qm_miete_kalt, by(jahr) stats(count)
 
 
 * Drop implausible high values 
 drop if qm_miete_kalt>40 
 drop if qm_miete_kalt<3
 replace qm_miete_warm = . if qm_miete_warm>40
 *drop if qm_miete_warm >50
 
foreach var of varlist qm_miete_kalt qm_miete_warm mietekalt mietewarm {
 bysort obid jahr: egen mean_`var'=mean(`var')
 replace `var' = mean_`var'
 drop mean_`var'
}
 duplicates drop obid jahr, force 
 * Alle geförderten Wohnungen rausnehmen 
 drop if foerderung==1 
   save "$TEMP/berlin_data_alt.dta", replace
 
 collapse (mean) mietewarm mietekalt qm_miete_kalt qm_miete_warm (median) medmietewarm=mietewarm medmietekalt=mietekalt med_qm_kalt=qm_miete_kalt med_qm_warm=qm_miete_warm (count) n=mietekalt , by(plz jahr)
 
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

 save "$TEMP/berlin_data_alt.dta", replace
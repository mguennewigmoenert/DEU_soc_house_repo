// Project: Social Housing
// Creation Date: 05-09-2023
// Last Update: 22-11-2023
// Author: Laura Arnemann 
// Goal: Preparing data for synthetic control command

/*
use "${TEMP}/socialhousing_1_since2008.dta", clear 
keep qm_miete_kalt mietekalt jahr PLR_ID wohnungen socialh share change_share1 change_share2

reshape wide qm_miete_kalt mietekalt wohnungen socialh share , i(PLR_ID) j(jahr)

tempfile socialhousing1 
save `socialhousing1'


use "${TEMP}/plrs_neighbors_stacked.dta", clear 

merge m:1 PLR_ID using `socialhousing1'
keep if _merge==3 
drop _merge 

tostring treat, replace 

gen id=PLR_ID + treat 

reshape long qm_miete_kalt mietekalt wohnungen socialh share, i(id) j(jahr)

gen district_plr = substr(PLR_ID, 1, 2)
gen district_treat =substr(treat,1,2)
destring district_treat, replace 
destring district_plr, replace 

keep if district_plr==district_treat+1 | district_plr==district_treat | district_plr==district_treat - 1

destring treat, replace 
destring PLR_ID, gen(plr_code)
save "${TEMP}/synthetic_control_prepped.dta", replace 
*/

********************************************************************************
* Clean observations and other characteristics of the LORs
********************************************************************************
/*
import delimited "${TEMP}/distance_matrix.csv", clear 
rename v1 PLR_ID
expand 542
bysort PLR_ID: gen count = _n 

gen target = "" 
gen gen_dist = . 

local a = 1

foreach var of varlist dist_* {
	local c `var'
	replace gen_dist = `var' if count == `a'
	replace target = "`c'" if count == `a'
	local `a' `++a'
	di "`a'"
}

replace target = substr(target,5,.) 
replace target = substr(target,2,.) 

drop dist_* count  

save "${TEMP}/distance_lors.dta", replace 
*/



local c = 15
* Adjust to keep for example only the 30 nearest LORS 
use "${TEMP}/distance_lors.dta", clear 
*tostring PLR_ID, replace 
*replace PLR_ID = "0" + PLR_ID if strlen(PLR_ID)==7 


bysort PLR_ID gen_dist: gen count = _n 
keep if count <= `c' 
rename PLR_ID treat
rename target PLR_ID
tempfile thirtylargest 
save `thirtylargest'


forvalues i =2014/2023 {
import delimited "${IN}/other/WHNDAUER_L21_`i'_Matrix.csv", clear 
tempfile wohndauer`i'
save `wohndauer`i''
}

clear
forvalues i =2014/2023 {
	append using `wohndauer`i''
}
rename raumid PLR_ID 
tostring PLR_ID, replace 
replace PLR_ID = "0" + PLR_ID if strlen(PLR_ID)==7
label var pdau10 "Percent, longer 10 years"
label var pdau5 "Percent, longer 5 years"
rename zeit year
save "${TEMP}/duration.dta", replace 



foreach num of numlist 2014 2015 2017 2018 2019 2020 2021 2022 2023 {
	
import delimited "${IN}/other/EWR_L21_`num'12E_Matrix.csv", clear 

tempfile einwohner`i'
save `einwohner`i''
}
clear
foreach num of numlist 2014 2015 2017 2018 2019 2020 2021 2022 2023 {
	append using `einwohner`i''
}

rename raumid PLR_ID
gen year = int(zeit/100)
gen inhabitants = e_e 
label var inhabitants "Inhabitants in district"

save "${TEMP}/inhabitants.dta", replace 

use "${TEMP}/inhabitants.dta", clear 
bysort PLR_ID: egen mean_inhabitants = mean(inhabitants)
collapse (mean) mean_inhabitants, by(PLR_ID)
label var mean_inhabitants "Mean Population Size"
tempfile inhabitants_invariant 
save `inhabitants_invariant'



********************************************************************************
* Only keep donor observations as control units 
********************************************************************************

use "${TEMP}/socialhousing_1_since2008.dta", clear 
keep qm_miete_kalt mietekalt jahr PLR_ID wohnungen socialh share change_share1 change_share2 sd_qm_kalt

reshape wide qm_miete_kalt mietekalt wohnungen socialh share sd_qm_kalt, i(PLR_ID) j(jahr)
tempfile socialhousing1 
save `socialhousing1'

use "${TEMP}/socialhousing_onlytreated.dta", clear 
keep PLR_ID min_treatment 
gen treated = 1 
gen donor = 0 
tempfile treated 
save `treated'

use "${TEMP}/socialhousing_onlydonors.dta"
keep PLR_ID min_treatment 
gen treated = 0 
gen donor = 1 
append using `treated'
tempfile donorstreated 
save `donorstreated'


use "${TEMP}/plrs_neighbors_stacked.dta", clear 

merge m:1 PLR_ID using `socialhousing1'
keep if _merge==3 
drop _merge 

* Reshaping the variables 
tostring treat, replace 
gen id=PLR_ID + treat 
reshape long qm_miete_kalt mietekalt wohnungen socialh share sd_qm_kalt, i(id) j(jahr)

merge m:1 PLR_ID using `donorstreated', keepusing(treated donor min_treatment)
drop if _merge ==2 
drop _merge 

rename jahr year 

* Merging in additional outcome variables
merge m:1 PLR_ID year using "${TEMP}/hedonic_regressions_a.dta"
drop if _merge ==2 
drop _merge 


merge m:1 PLR_ID year using "${TEMP}/duration.dta", keepusing(pdau5 pdau10)
drop if _merge ==2 
drop _merge 

rename year jahr

gen district_plr = substr(PLR_ID, 1, 2)
gen district_treat =substr(treat,1,2)
destring district_treat, replace 
destring district_plr, replace 

destring treat, replace 
destring PLR_ID, gen(plr_code)
rename treated gen_treated 

drop tag change* neighbors 
save "${TEMP}/synthetic_control_prepped.dta", replace 

********************************************************************************
* Creating different data sets based on the restrictions for the control group 
********************************************************************************

* Only districts in the treated district or adjacent district 
keep if district_plr==district_treat+1 | district_plr==district_treat | district_plr==district_treat - 1
save "${TEMP}/synthetic_control_prepped_district.dta", replace 


* Only keep LORS within a certain distance 
use "${TEMP}/synthetic_control_prepped.dta"
merge m:1 treat PLR_ID using `thirtylargest'
keep if _merge ==3 
drop _merge 
save "${TEMP}/synthetic_control_prepped_distance.dta", replace


use "${TEMP}/inhabitants.dta", clear 
bysort PLR_ID: egen mean_inhabitants = mean(inhabitants)
collapse (mean) mean_inhabitants, by(PLR_ID)
label var mean_inhabitants "Mean Population Size"
tempfile inhabitants_invariant1 
save `inhabitants_invariant1'

tostring PLR_ID, replace 
replace PLR_ID = "0" + PLR_ID if strlen(PLR_ID) == 7
tempfile inhabitants_invariant2 
save `inhabitants_invariant2'


* Only districts with similar characteristics with regards to foreigners and demographic structure 
use "${TEMP}/synthetic_control_prepped.dta"
rename PLR_ID helper_PLR 
rename treat PLR_ID 
merge m:1 PLR_ID using `inhabitants_invariant1', keepusing(mean_inhabitants)
keep if _merge ==3 
drop _merge 

rename mean_inhabitants treat_inhabitants 
rename PLR_ID treat 
rename helper_PLR PLR_ID 

merge m:1 PLR_ID using `inhabitants_invariant2', keepusing(mean_inhabitants)
keep if _merge ==3 
drop _merge 

gen diff = treat_inhabitants - mean_inhabitants 
replace diff = -1* diff if diff <0 

*drop count
* Only keep units with a similar population size 
bysort treat jahr (diff): gen count = _n 
keep if count <=`c' 
drop count 

destring PLR_ID, replace 

keep if donor==1 | PLR_ID ==treat
bysort treat jahr donor (diff) : gen count =_n 
keep if count<=2 | PLR_ID ==treat

save "${TEMP}/synthetic_control_prepped_population.dta", replace




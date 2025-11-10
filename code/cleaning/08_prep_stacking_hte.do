// Project: Social Housing
// Creation Date: 05-09-2023
// Last Update: 22-11-2023
// Author: Laura Arnemann 
// Goal: Stacking to account for HTE 




use "${TEMP}/socialhousing_analysis.dta", clear 

* Create treatment groups which did not have an event in the three years before and three years after

* Create leads and lags of the event
local fmax 3
local lmax 3

drop treat*

local treatment treat1 

levelsof jahr if jahr>2010, local(time)
di "`time'"

foreach v in `time' {
	
	use "${TEMP}/socialhousing_analysis.dta", clear 
	drop treated max_treatment min_treatment 
	
	* keep only if within around year
	keep if jahr>=`v'-`fmax' & jahr<= `v'+ `lmax'
	
	* indicator if change in year v occured
	gen helper_treated = 0 
	replace helper_treated = 1 if jahr ==`v' & `treatment'==1 
	
	* expand treatment indicator for treated
	bysort PLR_ID (jahr): egen treated = max(helper_treated)
	drop helper_treated 
	
	* Drop treated LORs if they experience a social housing change in the four years prior to the reform 
	gen helper =0 
	replace helper = 1 if jahr<`v' & `treatment'!=0 

	
	bysort PLR_ID: egen max_helper = max(helper)
	drop if max_helper==1 
	drop helper max_helper
	
	* Drop all Control LORs that had a treatment at some time before or during the treatment
	bysort PLR_ID: egen max_treatment = max(`treatment')
	bysort PLR_ID: egen min_treatment = min(`treatment')
	
	drop if max_treatment!=0 & treated==0 
	drop if min_treatment!=0 & treated==0 

	* Drop all units with a positive change (incraese in SH)
	gen indic = 1 if missing(`treatment') & jahr!=2007 
	bysort PLR_ID: egen max_indic = max(indic)
	drop if max_indic==1 
	drop max_indic indic

	
	* Generate indicator if treated LOR has multiple treatments
	gen multiple_treatments = 0 
	replace multiple_treatments = 1 if jahr>`v' & `treatment'==1 
	bysort PLR_ID: egen max_multiple_treatments = max(multiple_treatments)
	drop if max_multiple_treatments == 1 

	gen ry_change= jahr -`v' if treated==1
	
	* Generate the dummies based on the variable ry_change 
	
    forvalues i=1/`fmax' {
	gen f`i'_binary = ry_change==-`i'
	label var f`i'_binary "- `i'"
}

    forvalues i=0/`lmax' {
	gen l`i'_binary = ry_change==`i'
	label var l`i'_binary "`i'"
     }
	
	
	* For now drop multiple treatments
	gen event = `v'
	
	tempfile stacked_`v'
	save `stacked_`v''
}


clear 
foreach v in `time' {
	append using `stacked_`v''
}

* Some sanity checks 

sum d_socialh if ry_change ==0 
* Should be bigger than 4 
sum d_socialh if ry_change ==. 
* Should be equal to 0 or smaller equal 3  
	
save "${TEMP}/stacked_`treatment'.dta", replace 	
	
	
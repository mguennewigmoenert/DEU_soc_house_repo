// Project: Social Housing
// Creation Date: 05-09-2023
// Last Update: 22-11-2023
// Author: Laura Arnemann 
// Goal: Merging Social Housing Data and creating binscatter plots 



*******************************************************************************
* Merge 1
*****************************************************************************

* Data on rents 
use "${TEMP}/berlin_data.dta", clear 
tempfile berlin 
save `berlin', replace 

* Data on social housing 
import delimited "${TEMP}/socialhousing.csv", clear 
rename plr PLR_ID
tempfile socialhousing 
save `socialhousing', replace 


use "${TEMP}/areas_merged1.dta", clear 
merge 1:m PLR_ID using `socialhousing'
keep if _merge==3 
drop _merge 

reshape long wohnungen socialh share, i(PLR_ID) j(jahr)
destring plz, replace 


merge m:1 plz jahr using `berlin'
keep if _merge==3 
drop _merge 

* Drop all areas where the number of flats listed is below 30 
drop if objects<=30
* This deletes 52 observations 

gen pct_intersect=area_intersect/area_PLRID
label var pct_intersect "Pct Intersecting"

save "${TEMP}/socialhousing_1.dta", replace 


*****************************************************************************
* Alternative Merge 
*****************************************************************************


use "${TEMP}/berlin_data.dta", clear 
tempfile berlin 
save `berlin', replace 

import delimited "${TEMP}/socialhousing.csv", clear 
rename plr PLR_ID
drop if missing(PLR_ID)
tempfile socialhousing 
save `socialhousing', replace 


use "${TEMP}/areas_merged2.dta", clear 
drop index
duplicates drop 
* Where do these duplicates come from all of them were PLZ 14193 
replace pct=pct/100

gsort plz -pct 
by plz: gen count=_n 
by plz: gen num=_N 

forvalues i=0/14 {
	
bysort plz: egen min_pct=min(pct_plz)
replace pct_plz=pct_plz + min_pct if min_pct<=0.05 & count==1 
drop if count==(num-`i') & min_pct<=0.05 

drop min_pct 
}

* Generate this to check that the overall sums to one 
bysort plz: egen total_pct=total(pct)
drop total_pct 

merge m:1 PLR_ID using `socialhousing'
keep if _merge==3 
drop _merge 

tostring count, replace
gen id = plz + count 

drop change* 
reshape long wohnungen socialh share, i(id) j(jahr)
drop id 
replace share=pct_plz*share 
collapse (sum) share, by(plz jahr)
destring plz, replace 

merge 1:1 plz jahr using `berlin'
keep if _merge==3
drop _merge 

drop if objects<=30 

save "${TEMP}/socialhousing_2.dta", replace 
 
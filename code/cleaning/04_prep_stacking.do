// Project: Social Housing
// Creation Date: 05-09-2023
// Last Update: 22-11-2023
// Author: Laura Arnemann 
// Goal: Preparing data for stacke regression


* Included all the neighbors 
use "${TEMP}/plrs_neighbors.dta", clear 
drop index 
split neighbors, parse(,) gen(dir_neighbor)
save "${TEMP}/plrs_neighbors_cleaned.dta", replace

* Add ajdacent neighbors by merging: 
forvalues i =1 /14 {
use "${TEMP}/plrs_neighbors.dta", clear 
drop index 
rename PLR_ID dir_neighbor`i'
rename neighbors adj_neighbors`i'
save "${TEMP}/plrs_cleaned_`i'.dta", replace 
}

use "${TEMP}/plrs_neighbors.dta", clear 
drop index 
split neighbors, parse(,) gen(dir_neighbor)

forvalues i =1 /14 {
replace dir_neighbor`i' = subinstr(dir_neighbor`i'," ","",.)
merge m:1 dir_neighbor`i' using "${TEMP}/plrs_cleaned_`i'.dta", keepusing(adj_neighbors`i')
drop if _merge==2 
drop _merge 
}

save "${TEMP}/plrs_neighbors_cleaned.dta", replace
xxx
********************************************************************************
* For each LOR create the respective control group
******************************************************************************** 

levelsof PLR_ID, local(lors)

* Dropping direct and adjacent neighbors 
foreach l in `lors'  {
	use "${TEMP}/plrs_neighbors_cleaned.dta", clear 
	gen tag=1 if PLR_ID=="`l'"
forvalues i=1/14 {
	
	drop if dir_neighbor`i'=="`l'" & missing(tag)
	*drop if strpos(adj_neighbors`i',"`l'") & missing(tag)
	
	}
	gen treat="`l'"
	tempfile PLR`l'
	save `PLR`l''

}

clear 

foreach l in `lors'  {
append using `PLR`l''
} 

drop dir_neighbor* adj_neighbor* 
 
save "${TEMP}/plrs_neighbors_stacked.dta", replace 






// Project: Social Housing
// Creation Date: 05-02-2024
// Last Update: 05-02-2024
// Author: Laura Arnemann 
// Goal: Descriptive Statistics

********************************************************************
* Descriptives for merge on PLZ Level 
********************************************************************

forvalues i=1/2 {

use "${TEMP}/socialhousing_`i'.dta", clear

drop share 
gen share = socialh/wohnungen 
destring PLR_ID, replace 
	
	foreach var of varlist mietekalt qm_miete_kalt {
	
* Some Binscatter Plots 
binscatter `var' share, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'.png", replace 

binscatter `var' share if share<=20, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'_share20.png", replace

binscatter `var' share if share<=10, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'_share10.png", replace 

binscatter `var' share if share<=10 & share>0, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_0.png", replace 


* Some Binscatter Plots 
binscatter `var' share, nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_c.png", replace 

binscatter `var' share if share<=20, nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_c_share20.png", replace

binscatter `var' share if share<=10, nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_c_share10.png", replace 

binscatter `var' share if share<=10 & share>0, nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_c_share10_0.png", replace 


* Same graph but now with controls for year and plz 
binscatter `var' share if inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_c_2010_2014.png", replace 

binscatter `var' share if share<=20 & inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_share20_c_2010_2014.png", replace 

binscatter `var' share if share<=10 & inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_c_2010_2014.png", replace  

binscatter `var' share if share<=10 & share>0 & inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.PLR_ID)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_0_c_2010_2014.png", replace 

	}
}

********************************************************************* 
*Descriptives for merge on LOR Level 
********************************************************************


forvalues i=3/4 {

use "${TEMP}/socialhousing_`i'.dta", clear

gen share = sum_socialh/sum_wohnungen 
	
	foreach var of varlist mietekalt qm_miete_kalt {
	
* Some Binscatter Plots 
binscatter `var' share, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'.png", replace 

binscatter `var' share if share<=20, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'_share20.png", replace

binscatter `var' share if share<=10, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'_share10.png", replace 

binscatter `var' share if share<=10 & share>0, nq(50)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_0.png", replace 


* Same graph but now with controls for year and plz 
binscatter `var' share, nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_c.png", replace 

binscatter `var' share if share<=20, nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_share20_c.png", replace 

binscatter `var' share if share<=10, nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_c.png", replace  

binscatter `var' share if share<=10 & share>0, nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_0_c.png", replace 


* Same graph but now for years 2010 until 2014  
binscatter `var' share if inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_c_2010_2014.png", replace 

binscatter `var' share if share<=20 & inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_share20_c_2010_2014.png", replace 

binscatter `var' share if share<=10 & inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_c_2010_2014.png", replace  

binscatter `var' share if share<=10 & share>0 & inrange(jahr, 2010, 2014), nq(50) controls(i.jahr i.plz)
graph export "${output}/descriptives/binscatter/`var'`i'_share10_0_c_2010_2014.png", replace 

	}
}



// Project: Social Housing
// Creation Date: 14-04-2024
// Last Update: 14-04-2024
// Author: Laura Arnemann 
// Goal: Merging Social Housing Data and creating binscatter plots 

*******************************************************************************
* Merge 1
*****************************************************************************

* Data on social housing 
import delimited "${TEMP}/socialhousing.csv", clear 
rename plr PLR_ID
drop if missing(PLR_ID)

forvalues i =2007/2009 {
	gen share`i'= share2010
	gen wohnungen`i'= wohnungen2010
	gen socialh`i'= socialh2010
}
reshape long wohnungen socialh share, i(PLR_ID) j(jahr)
tempfile socialhousing 
save `socialhousing', replace 


use "${TEMP}/berlin_data.dta" , clear 
merge 1:m PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")

/* 
   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        Master only (1) |      2,146       23.35       23.35
         Using only (2) |        116        1.26       24.61
            Matched (3) |      6,930       75.39      100.00
------------------------+-----------------------------------
                  Total |      9,192      100.00

* Not matched from Master: 2146 mostly years which are not in the Social Housing data set; 116 weird PLRs where we also would not expect too many housing units (e.g. Tempelhofer Feld) 
*/
* keep if _merge==3 
drop _merge 

tempfile socialhousing 
save `socialhousing', replace 

**# Add SGB12 Empfänger
* add sgb12 receivers to main dataframe
import delimited "${TEMP}/sgb12_final.csv",  stringcols(2) clear

* add zero to string
replace target_id = "0" + target_id if length(target_id) == 7

* rename for merging
rename target_id PLR_ID
rename year jahr 

merge 1:1 PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")
* check merge outcome
sort PLR_ID jahr
br 

* drop merge column from previous merge
drop _merge 

tempfile socialhousing 
save `socialhousing', replace 

**# Add RWI data
* add sgb12 receivers to main dataframe
import delimited "${TEMP}/lor_microm_panelSUF_w.csv",  stringcols(2) clear

* add zero to string
replace target_id = "0" + target_id if length(target_id) == 7

* rename for merging
rename target_id PLR_ID
rename year jahr 

merge 1:1 PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")
* check merge outcome
sort PLR_ID jahr
br 

* drop merge column from previous merge
drop _merge 

tempfile socialhousing 
save `socialhousing', replace 


**# Add Wohndauer
* add sgb12 receivers to main dataframe
import delimited "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/temp/whndauer_final.csv",  stringcols(1) clear

* add zero to string
replace plr_id = "0" + plr_id if length(plr_id) == 7

* rename for merging
rename plr_id PLR_ID
rename year jahr 

merge 1:1 PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")
* check merge outcome
sort PLR_ID jahr
br 

* drop merge column from previous merge
drop _merge 

tempfile socialhousing 
save `socialhousing', replace 

**# Add Einwohner
* add sgb12 receivers to main dataframe
import delimited "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/temp/ewr_final.csv",  stringcols(1) clear

* add zero to string
replace plr_id = "0" + plr_id if length(plr_id) == 7

* rename for merging
rename plr_id PLR_ID
rename year jahr 

merge 1:1 PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")
* check merge outcome
sort PLR_ID jahr
br 

* drop merge column from previous merge
drop _merge 

tempfile socialhousing 
save `socialhousing', replace 

**# Add Wohnlage
* add sgb12 receivers to main dataframe
import delimited "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/temp/whnlage_final.csv",  stringcols(1) clear

* set key variable type 
tostring plr_id, replace
destring year, replace

* add zero to string
replace plr_id = "0" + plr_id if length(plr_id) == 7

* rename for merging
rename plr_id PLR_ID
rename year jahr 

merge 1:1 PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")
* check merge outcome
sort PLR_ID jahr
br 

* drop merge column from previous merge
drop _merge 

tempfile socialhousing 
save `socialhousing', replace 

**# Add Hedonic rents
* add sgb12 receivers to main dataframe
use "${TEMP}/hedonic_regressions_a.dta",  clear

* rename for merging
rename year jahr

* The back-tick + macro name + double quotes expands to the path.
merge 1:1 PLR_ID jahr using `"`socialhousing'"'

drop _merge 

tempfile socialhousing 
save `socialhousing', replace 

**# Add Gutachter data
* add sgb12 receivers to main dataframe
use "${TEMP}/df_final_agg.dta",  clear

* rename for merging
rename Jahr jahr

* unnecessary observations
drop if jahr < 2007

* The back-tick + macro name + double quotes expands to the path.
merge 1:1 PLR_ID jahr using `"`socialhousing'"'

drop _merge 

*263 observations less than 30 object; 99 observations have less than 10 objects 

save "${TEMP}/socialhousing_1_since2008.dta", replace 


use "${TEMP}/socialhousing_1_since2008.dta" , clear 
merge 1:m PLR_ID jahr using "${TEMP}/berlin_data_incl_wbs.dta"
* keep if _merge==3 
drop _merge 

save "${TEMP}/socialhousing_1_since2008.dta", replace 

use "${TEMP}/berlin_data_ph.dta" , clear 
merge m:m PLR_ID jahr using `socialhousing'
drop if strpos(PLR_ID, "insgesamt")

/* 
   Matching result from |
                  merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        Master only (1) |      2,146       23.35       23.35
         Using only (2) |        116        1.26       24.61
            Matched (3) |      6,930       75.39      100.00
------------------------+-----------------------------------
                  Total |      9,192      100.00

* Not matched from Master: 2146 mostly years which are not in the Social Housing data set; 116 weird PLRs where we also would not expect too many housing units (e.g. Tempelhofer Feld) 
*/ 
keep if _merge==3 
drop _merge 

*263 observations less than 30 object; 99 observations have less than 10 objects 


save "${TEMP}/socialhousing_2_since2008.dta", replace 

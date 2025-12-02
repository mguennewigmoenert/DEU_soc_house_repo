// Project: Social Housing
// Creation Date: 05-02-2024 
// Last Update: 18-04-2024 
// Author: Laura Arnemann 
// Goal: Running the stacked regression

clear all
set more off
set mem 400m
set matsize 1200
estimates clear


* ========================= *
**# === Upload data set === *
* ========================= *

use "$TEMP/socialhousing_analysis.dta", clear 
drop *miete*
drop med_qm_kalt med_qm_warm sd_qm_kalt 
tempfile socialhousing 
save `socialhousing'

use "${TEMP}/berlin_data_object.dta", clear 
merge m:1 PLR_ID jahr using `socialhousing'
* Not merged PLR ID: 08401138 ; 09300922; 10200630 and year 2023
keep if _merge==3 
drop _merge 

* ============================================ *
**# === Comparing LORs with similar trajectory ===
* ============================================ *
gen ln_qm_miete_kalt = log(qm_miete_kalt)

* Only small ``treatments''

forval y = 1/6 {

di "`y'"
* Set locals indicating the frequency of treatment 

foreach var of varlist ln_qm_miete_kalt qm_miete_kalt {
	
	foreach treat_group of varlist treated {
	
	forval i = 1(1)3 {
			* all together
			if `i' == 1{
				local ring ""
				local ring_type "no"
			}
			* priphery
			else if `i' == 2{
				local ring "& a100_r == 0"
				local ring_type "out"
			}
			* core
			else if `i' == 3{
				local ring "& a100_r == 1"
				local ring_type "in"
		}

	
	reghdfe `var' ///
	11.ty_treat0_p#1.`treat_group' 12.ty_treat0_p#1.`treat_group' ///
	13.ty_treat0_p#1.`treat_group' 15.ty_treat0_p#1.`treat_group' ///
	16.ty_treat0_p#1.`treat_group' 17.ty_treat0_p#1.`treat_group' ///
	18.ty_treat0_p#1.`treat_group' 19.ty_treat0_p#1.`treat_group' ///
	if inrange(jahr, 2010, 2019) `ring' & (tot_dd_socialh == 0 | tot_dd_socialh == `y') & foerderung!=1, ///
	absorb(obid jahr) cl(PLR_ID)
	
	
	* manipulate estimate matrix
	nlcom ///
	(_b[11.ty_treat0_p#1.`treat_group']) ///
	(_b[12.ty_treat0_p#1.`treat_group']) ///
	(_b[13.ty_treat0_p#1.`treat_group']) ///
	(0) ///
	(_b[15.ty_treat0_p#1.`treat_group']) ///
	(_b[16.ty_treat0_p#1.`treat_group']) ///
	(_b[17.ty_treat0_p#1.`treat_group']) ///
	(_b[18.ty_treat0_p#1.`treat_group']) ///
	(_b[19.ty_treat0_p#1.`treat_group']) ///
	, post level(95) 

	* store baseline estimates
	eststo est_t0
	
	* plot coefficients
	coefplot ///
	(est_t0, level(95 90)), omitted vertical drop( _cons) ///
	coeflabel(_nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 ///
	_nl_5 = 0 _nl_6 = 1 _nl_7 = 2 _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
	yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) ///
	xtitle("Years until large Change in Social Housing") 
	
	* set local for name of outcome variable
	if "`var'"== "ln_qm_miete_kalt"{
		local outcome "ln_rent"
	}
	else if "`var'"== "qm_miete_kalt"{
		local outcome "rent"
	}
		
graph export "${output}/max/graphs/single_treatment/diff_comparisons/t2_`outcome'_r_`ring_type'_`y'.png", replace 
			}
		}	
	}
}

* Only large treatments 

forval y = 1/5 {

di "`y'"
* Set locals indicating the frequency of treatment 

foreach var of varlist ln_qm_miete_kalt qm_miete_kalt {
	
	foreach treat_group of varlist treated_2 {
	
	forval i = 1(1)3 {
			* all together
			if `i' == 1{
				local ring ""
				local ring_type "no"
			}
			* priphery
			else if `i' == 2{
				local ring "& a100_r == 0"
				local ring_type "out"
			}
			* core
			else if `i' == 3{
				local ring "& a100_r == 1"
				local ring_type "in"
		}

	
	reghdfe `var' ///
	11.ty_treat2_p#1.`treat_group' 12.ty_treat2_p#1.`treat_group' ///
	13.ty_treat2_p#1.`treat_group' 15.ty_treat2_p#1.`treat_group' ///
	16.ty_treat2_p#1.`treat_group' 17.ty_treat2_p#1.`treat_group' ///
	18.ty_treat2_p#1.`treat_group' 19.ty_treat2_p#1.`treat_group' ///
	if inrange(jahr, 2010, 2019) `ring' & (total_large_socialh == 0 | total_large_socialh == `y') & foerderung!=1, ///
	absorb(obid jahr) cl(PLR_ID)
	
	
	* manipulate estimate matrix
	nlcom ///
	(_b[11.ty_treat2_p#1.`treat_group']) ///
	(_b[12.ty_treat2_p#1.`treat_group']) ///
	(_b[13.ty_treat2_p#1.`treat_group']) ///
	(0) ///
	(_b[15.ty_treat2_p#1.`treat_group']) ///
	(_b[16.ty_treat2_p#1.`treat_group']) ///
	(_b[17.ty_treat2_p#1.`treat_group']) ///
	(_b[18.ty_treat2_p#1.`treat_group']) ///
	(_b[19.ty_treat2_p#1.`treat_group']) ///
	, post level(95) 

	* store baseline estimates
	eststo est_t0
	
	* plot coefficients
	coefplot ///
	(est_t0, level(95 90)), omitted vertical drop( _cons) ///
	coeflabel(_nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 ///
	_nl_5 = 0 _nl_6 = 1 _nl_7 = 2 _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
	yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) ///
	xtitle("Years until large Change in Social Housing") 
		
graph export "${output}/max/graphs/object_level/single_treatment/diff_comparisons/large_t2_`outcome'_r_`ring_type'_`y'.png", replace 
			}
		}
	}
}

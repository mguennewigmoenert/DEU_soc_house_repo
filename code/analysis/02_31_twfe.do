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

********************************************************************************
* Regression Analyses without stacking
********************************************************************************
* upload treated file
use "${TEMP}/socialhousing_analysis.dta", clear 

* sum dummies by LOR and keep only maximum of sum: total changes within lor
* egen tot_dd_socialh = total(c_dd_socialh), by(PLR_ID)
/*
* test regressions
reghdfe qm_miete_kalt 1.dynamic_treat0#1.a100_r 1.dynamic_treat0#0.a100_r if inrange(jahr, 2010, 2019) & tot_dd_socialh < 2, absorb(i.PLR_ID_num#i.a100_r i.jahr#i.a100_r) cl(PLR_ID)
reghdfe qm_miete_kalt 1.dynamic_treat1_0#1.a100_r 1.dynamic_treat1_0#0.a100_r if inrange(jahr, 2010, 2019) & tot_dd_socialh < 2, absorb(PLR_ID jahr) cl(PLR_ID)
reghdfe qm_miete_kalt 1.dynamic_treat2#1.a100_r 1.dynamic_treat2#0.a100_r if inrange(jahr, 2010, 2019) & treated_2 != . & tot_dd_socialh < 2, absorb(PLR_ID jahr) cl(PLR_ID)

reghdfe qm_miete_kalt ///
11.ty_treat0_p#1.treated#1.sbahn_r 12.ty_treat0_p#1.treated#1.sbahn_r ///
14.ty_treat0_p#1.treated#1.sbahn_r 15.ty_treat0_p#1.treated#1.sbahn_r ///
16.ty_treat0_p#1.treated#1.sbahn_r 17.ty_treat0_p#1.treated#1.sbahn_r ///
18.ty_treat0_p#1.treated#1.sbahn_r 19.ty_treat0_p#1.treated#1.sbahn_r ///
11.ty_treat0_p#1.treated#0.sbahn_r 12.ty_treat0_p#1.treated#0.sbahn_r ///
13.ty_treat0_p#1.treated#0.sbahn_r 15.ty_treat0_p#1.treated#0.sbahn_r ///
16.ty_treat0_p#1.treated#0.sbahn_r 17.ty_treat0_p#1.treated#0.sbahn_r ///
18.ty_treat0_p#1.treated#0.sbahn_r 19.ty_treat0_p#1.treated#0.sbahn_r ///
if inrange(jahr, 2010, 2019) & tot_dd_socialh < 2, absorb(i.sbahn_r#i.PLR_ID_num i.sbahn_r#i.jahr) cl(PLR_ID)

reghdfe ln_qm_miete_kalt 9.ty_treat2_p#1.treated#1.sbahn_r 10.ty_treat2_p#1.treated#1.sbahn_r 11.ty_treat2_p#1.treated#1.sbahn_r 12.ty_treat2_p#1.treated#1.sbahn_r 13.ty_treat2_p#1.treated#1.sbahn_r 15.ty_treat2_p#1.treated#1.sbahn_r 16.ty_treat2_p#1.treated#1.sbahn_r 17.ty_treat2_p#1.treated#1.sbahn_r 18.ty_treat2_p#1.treated#1.sbahn_r 19.ty_treat2_p#1.treated#1.sbahn_r 20.ty_treat2_p#1.treated#1.sbahn_r 9.ty_treat2_p#1.treated#0.sbahn_r 10.ty_treat2_p#1.treated#0.sbahn_r 11.ty_treat2_p#1.treated#0.sbahn_r 12.ty_treat2_p#1.treated#0.sbahn_r 13.ty_treat2_p#1.treated#0.sbahn_r 15.ty_treat2_p#1.treated#0.sbahn_r 16.ty_treat2_p#1.treated#0.sbahn_r 17.ty_treat2_p#1.treated#0.sbahn_r 18.ty_treat2_p#1.treated#0.sbahn_r 19.ty_treat2_p#1.treated#0.sbahn_r 20.ty_treat2_p#1.treated#0.sbahn_r if inrange(jahr, 2007, 2016) , absorb(PLR_ID jahr) cl(PLR_ID)


* ====================================== *
**# === Binary Treatment: 1st change ===
* ====================================== *
foreach var of varlist ln_qm_miete_kalt qm_miete_kalt {
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

	* manual regression
	local var ln_qm_miete_kalt
	local ring "& a100_r == 1"
	
	* baseline treatment: time to first change
	reghdfe `var' ///
	11.ty_treat0_p#1.treated 12.ty_treat0_p#1.treated ///
	13.ty_treat0_p#1.treated 15.ty_treat0_p#1.treated ///
	16.ty_treat0_p#1.treated 17.ty_treat0_p#1.treated ///
	18.ty_treat0_p#1.treated 19.ty_treat0_p#1.treated ///
	if inrange(jahr, 2010, 2019) `ring' & (tot_dd_socialh == 0 | tot_dd_socialh == 1), ///
	absorb(PLR_ID jahr) cl(PLR_ID)

	* manipulate estimate matrix
	nlcom ///
	(_b[11.ty_treat0_p#1.treated]) ///
	(_b[12.ty_treat0_p#1.treated]) ///
	(_b[13.ty_treat0_p#1.treated]) ///
	(0) ///
	(_b[15.ty_treat0_p#1.treated]) ///
	(_b[16.ty_treat0_p#1.treated]) ///
	(_b[17.ty_treat0_p#1.treated]) ///
	(_b[18.ty_treat0_p#1.treated]) ///
	(_b[19.ty_treat0_p#1.treated]) ///
	, post level(95) 

	* store baseline estimates
	eststo est_t0
	
	* set local for name of outcome variable
	if "`var'"== "ln_qm_miete_kalt"{
		local outcome "ln_rent"
	}
	else if "`var'"== "qm_miete_kalt"{
		local outcome "rent"
	}

	coefplot ///
	(est_t0, level(95 90)), omitted vertical drop( _cons) coeflabel(_nl_1 = -4 ///
	_nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2 _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) ///
	yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) ///
	xtitle("Years until Change in Social Housing") 

	* save graph
	graph export ${output}/max/graphs/single_treatment/1st_change/t0_`outcome'_r_`ring_type'.png, replace 
	}
}

* ==================================================== *
**# === Binary Treatment: 1st change - Joint plots ===
* ==================================================== *

foreach var of varlist ln_qm_miete_kalt qm_miete_kalt {
	foreach ring of varlist a100_r sbahn_r {
	* regression to store within ring results
	reghdfe `var' ///
	11.ty_treat0_p#1.treated#1.`ring' 12.ty_treat0_p#1.treated#1.`ring' ///
	13.ty_treat0_p#1.treated#1.`ring' 15.ty_treat0_p#1.treated#1.`ring' ///
	16.ty_treat0_p#1.treated#1.`ring' 17.ty_treat0_p#1.treated#1.`ring' ///
	18.ty_treat0_p#1.treated#1.`ring' 19.ty_treat0_p#1.treated#1.`ring' ///
	11.ty_treat0_p#1.treated#0.`ring' 12.ty_treat0_p#1.treated#0.`ring' ///
	13.ty_treat0_p#1.treated#0.`ring' 15.ty_treat0_p#1.treated#0.`ring' ///
	16.ty_treat0_p#1.treated#0.`ring' 17.ty_treat0_p#1.treated#0.`ring' ///
	18.ty_treat0_p#1.treated#0.`ring' 19.ty_treat0_p#1.treated#0.`ring' ///
	if inrange(jahr, 2010, 2019) & (tot_dd_socialh == 0 | tot_dd_socialh == 1), ///
	absorb(i.`ring'#PLR_ID_num i.`ring'#jahr) cl(PLR_ID_num)
	
	* manipulate estimate matrix
	nlcom ///
	(_b[11.ty_treat0_p#1.treated#1.`ring']) ///
	(_b[12.ty_treat0_p#1.treated#1.`ring']) ///
	(_b[13.ty_treat0_p#1.treated#1.`ring']) ///
	(0) ///
	(_b[15.ty_treat0_p#1.treated#1.`ring']) ///
	(_b[16.ty_treat0_p#1.treated#1.`ring']) ///
	(_b[17.ty_treat0_p#1.treated#1.`ring']) ///
	(_b[18.ty_treat0_p#1.treated#1.`ring']) ///
	(_b[19.ty_treat0_p#1.treated#1.`ring']) ///
	, post level(95) 

	* store estimate matrix
	eststo est_t01_`ring'
	
	* regression to store outside ring results
	reghdfe `var' ///
	11.ty_treat0_p#1.treated#1.`ring' 12.ty_treat0_p#1.treated#1.`ring' ///
	13.ty_treat0_p#1.treated#1.`ring' 15.ty_treat0_p#1.treated#1.`ring' ///
	16.ty_treat0_p#1.treated#1.`ring' 17.ty_treat0_p#1.treated#1.`ring' ///
	18.ty_treat0_p#1.treated#1.`ring' 19.ty_treat0_p#1.treated#1.`ring' ///
	11.ty_treat0_p#1.treated#0.`ring' 12.ty_treat0_p#1.treated#0.`ring' ///
	13.ty_treat0_p#1.treated#0.`ring' 15.ty_treat0_p#1.treated#0.`ring' ///
	16.ty_treat0_p#1.treated#0.`ring' 17.ty_treat0_p#1.treated#0.`ring' ///
	18.ty_treat0_p#1.treated#0.`ring' 19.ty_treat0_p#1.treated#0.`ring' ///
	if inrange(jahr, 2010, 2019) & (tot_dd_socialh == 0 | tot_dd_socialh == 1), ///
	absorb(i.`ring'#PLR_ID_num i.`ring'#jahr) cl(PLR_ID_num)
	
	* manipulate estimate matrix
	nlcom ///
	(_b[11.ty_treat0_p#1.treated#0.`ring']) ///
	(_b[12.ty_treat0_p#1.treated#0.`ring']) ///
	(_b[13.ty_treat0_p#1.treated#0.`ring']) ///
	(0) ///
	(_b[15.ty_treat0_p#1.treated#0.`ring']) ///
	(_b[16.ty_treat0_p#1.treated#0.`ring']) ///
	(_b[17.ty_treat0_p#1.treated#0.`ring']) ///
	(_b[18.ty_treat0_p#1.treated#0.`ring']) ///
	(_b[19.ty_treat0_p#1.treated#0.`ring']) ///
	, post level(95) 

	* store estimate matrix
	eststo est_t02_`ring'

	* set local for name of outcome variable
	if "`var'"== "ln_qm_miete_kalt"{
		local outcome "ln_rent"
	}
	else if "`var'"== "qm_miete_kalt"{
		local outcome "rent"
	}
	
	coefplot ///
	(est_t01_`ring', label(Within `ring') level(95 90)) ///
	(est_t02_`ring', label(Outside `ring') level(95 90)) ///
	, omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4 , angle(45)) ///
	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing") 

	* save output
	graph export ${output}/max/graphs/single_treatment/1st_change/t0_`outcome'_`ring'.png, replace 
	}
}


* ====================================== *
**# === Binary Treatment: Max change ===
* ====================================== *
foreach var of varlist ln_qm_miete_kalt qm_miete_kalt {
	foreach treat of varlist  ty_treat1_1_p ty_treat1_0_p {
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
	* manual regression
	* local var ln_qm_miete_kalt
	* local treat ty_treat1_0_p
	* local ring "& a100_r == 1"
	
	* regression equation
	reghdfe `var' ///
	11.`treat'#1.treated 12.`treat'#1.treated ///
	13.`treat'#1.treated 15.`treat'#1.treated ///
	16.`treat'#1.treated 17.`treat'#1.treated ///
	18.`treat'#1.treated 19.`treat'#1.treated ///
	if inrange(jahr, 2010, 2019) `ring' & (tot_dd_socialh == 0 | tot_dd_socialh == 1), ///
	absorb(PLR_ID jahr) cl(PLR_ID)

	* manipulate estimate matrix
	nlcom ///
	(_b[11.`treat'#1.treated]) ///
	(_b[12.`treat'#1.treated]) ///
	(_b[13.`treat'#1.treated]) ///
	(0) ///
	(_b[15.`treat'#1.treated]) ///
	(_b[16.`treat'#1.treated]) ///
	(_b[17.`treat'#1.treated]) ///
	(_b[18.`treat'#1.treated]) ///
	(_b[19.`treat'#1.treated]) ///
	, post level(95) 

	* save estimates
	eststo est_t2

	* set local for name of outcome variable
	if "`var'"== "ln_qm_miete_kalt"{
		local outcome "ln_rent"
	}
	else if "`var'"== "qm_miete_kalt"{
		local outcome "rent"
	}
	
	* treatment name for saving
	if "`treat'" == "ty_treat1_0_p"{
		local treatment "0"
	}
	else if "`treat'"== "ty_treat1_1_p"{
		local treatment "1"
	}

	* generate graph
	coefplot ///
	(est_t2, level(95 90)), omitted vertical drop( _cons) ///
	coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 ///
	_nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(4.5, lpattern(dash) lwidth(thin) lcolor(black)) ///
	xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ///
	ylabel(,labsize(medlarge)) graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) ///
	xtitle("Years until Max. Change in Social Housing") 


	* save output
	graph export ${output}/max/graphs/single_treatment/max_change/t1_`treatment'_`outcome'_`ring_type'.png, replace 
		}
	}
}

* ============================================ *
**# === Binary Treatment: 1st large change ===
* ============================================ *
* loop over outcomes
foreach var of varlist ln_qm_miete_kalt qm_miete_kalt {
	* loop over treatment groups
	foreach treat_group of varlist treated treated_2 {
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

	* = manual regression
	*local var ln_qm_miete_kalt
	*local treat_group treated_2
	*local ring "& a100_r == 0"
	*local ring_type "in"

	* baseline treatment: time to first change
	reghdfe `var' ///
	11.ty_treat2_p#1.`treat_group' 12.ty_treat2_p#1.`treat_group' ///
	13.ty_treat2_p#1.`treat_group' 15.ty_treat2_p#1.`treat_group' ///
	16.ty_treat2_p#1.`treat_group' 17.ty_treat2_p#1.`treat_group' ///
	18.ty_treat2_p#1.`treat_group' 19.ty_treat2_p#1.`treat_group' ///
	if inrange(jahr, 2010, 2019) `ring', ///
	absorb(PLR_ID jahr) cl(PLR_ID)

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

	* set local for name of outcome variable
	if "`var'"== "ln_qm_miete_kalt"{
		local outcome "ln_rent"
	}
	else if "`var'"== "qm_miete_kalt"{
		local outcome "rent"
	}
	* set local for name of treatment group
	if "`treat_group'"== "treated"{
		local group "1"
	}
	else if "`treat_group'"== "treated_2"{
		local group "2"
	}

	* save output
	graph export ${output}/max/graphs/single_treatment/1st_large_change/t2_`outcome'_gr`group'_r_`ring_type'.png, replace 
		}
	}
}

*/
* ============================================ *
**# === Comparing LORs with similar trajectory ===
* ============================================ *

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
	if inrange(jahr, 2010, 2019) `ring' & (tot_dd_socialh == 0 | tot_dd_socialh == `y'), ///
	absorb(PLR_ID jahr) cl(PLR_ID)
	
	
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
	if inrange(jahr, 2010, 2019) `ring' & (total_large_socialh == 0 | total_large_socialh == `y'), ///
	absorb(PLR_ID jahr) cl(PLR_ID)
	
	
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
		
graph export "${output}/max/graphs/single_treatment/diff_comparisons/large_t2_`outcome'_r_`ring_type'_`y'.png", replace 
	
}
}
}
}

/*
* ============================================ *
**# === Comparing LORs with similar trajectory ===
* ============================================ *

forval y = 1/6 {

local a = `y'-1
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
	if inrange(jahr, 2010, 2019) `ring' & (tot_dd_socialh == `a' | tot_dd_socialh == `y'), ///
	absorb(PLR_ID jahr) cl(PLR_ID)
	
	
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
	xtitle("Years until first change in Social Housing") 
	
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
	if inrange(jahr, 2010, 2019) `ring' & (total_large_socialh == `a' | total_large_socialh == `y'), ///
	absorb(PLR_ID jahr) cl(PLR_ID)
	
	
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
	xtitle("Years until first large change in Social Housing") 
		
graph export "${output}/max/graphs/single_treatment/diff_comparisons/large_t2_`outcome'_r_`ring_type'_`y'.png", replace 
	
}
}
}
}
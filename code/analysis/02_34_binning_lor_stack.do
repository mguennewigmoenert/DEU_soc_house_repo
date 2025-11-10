/// PROJECT: Housing Policy
/// GOAL: Regressions on object level 
/// AUTHOR: MGM
/// CREATION: 29.10.2024
/// LAST UPDATE: 
/// SOURCE: *

* upload prepared abalysis data
use "${TEMP}/socialhousing_analysis.dta", clear 

* keep variables of interest
keep qm_miete_kalt mietekalt jahr PLR_ID wohnungen a100_r ///
socialh share shchange d_socialh ln_d_socialh c_dd_socialh s_d_socialh ///
T_scaled_t1_L* T_scaled_t1_F* /// pp change in social housing share 
T_scaled_t2_L* T_scaled_t2_F* /// Change in social housing units
T_scaled_t3_L* T_scaled_t3_F* /// Change in Log(social housing units)
T_scaled_t4_L* T_scaled_t4_F* /// SD Change in social housing units
T_scaled_t5_L* T_scaled_t5_F* /// Multiple Dummies for Changes in social housing units

reshape wide qm_miete_kalt mietekalt wohnungen a100_r ///
socialh share shchange d_socialh ln_d_socialh c_dd_socialh s_d_socialh ///
T_scaled_t1_L* T_scaled_t1_F* /// pp change in social housing share 
T_scaled_t2_L* T_scaled_t2_F* /// 
T_scaled_t3_L* T_scaled_t3_F* /// 
T_scaled_t4_L* T_scaled_t4_F* /// 
T_scaled_t5_L* T_scaled_t5_F* /// 
, i(PLR_ID) j(jahr)

tempfile socialhousing_analysis
save `socialhousing_analysis'

use "${TEMP}/plrs_neighbors_stacked.dta", clear 

merge m:1 PLR_ID using `socialhousing_analysis'
keep if _merge==3 
drop _merge

tostring treat, replace 

gen id=PLR_ID + treat 

reshape long qm_miete_kalt mietekalt wohnungen a100_r ///
socialh share shchange d_socialh ln_d_socialh c_dd_socialh s_d_socialh ///
T_scaled_t1_L0 T_scaled_t1_L1 T_scaled_t1_L2 T_scaled_t1_L3 T_scaled_t1_L4 ///
T_scaled_t1_F1 T_scaled_t1_F2 T_scaled_t1_F3 T_scaled_t1_F4 ///
T_scaled_t2_L0 T_scaled_t2_L1 T_scaled_t2_L2 T_scaled_t2_L3 T_scaled_t2_L4 ///
T_scaled_t2_F1 T_scaled_t2_F2 T_scaled_t2_F3 T_scaled_t2_F4 ///
T_scaled_t3_L0 T_scaled_t3_L1 T_scaled_t3_L2 T_scaled_t3_L3 T_scaled_t3_L4 ///
T_scaled_t3_F1 T_scaled_t3_F2 T_scaled_t3_F3 T_scaled_t3_F4 ///
T_scaled_t4_L0 T_scaled_t4_L1 T_scaled_t4_L2 T_scaled_t4_L3 T_scaled_t4_L4 ///
T_scaled_t4_F1 T_scaled_t4_F2 T_scaled_t4_F3 T_scaled_t4_F4 ///
T_scaled_t5_L0 T_scaled_t5_L1 T_scaled_t5_L2 T_scaled_t5_L3 T_scaled_t5_L4 ///
T_scaled_t5_F1 T_scaled_t5_F2 T_scaled_t5_F3 T_scaled_t5_F4, ///
i(id) j(jahr)

rename treat event 
encode event, gen(event_code)
encode PLR_ID, gen(PLR_code)

* generate log rent
g ln_qm_miete_kalt = ln(qm_miete_kalt + 1)

* make PLR numeric for example for fixed effects estimation
g PLR_ID_num = PLR_ID
destring PLR_ID_num, replace

br T_scaled_t1_F* T_scaled_t1_L*  ///
///T_scaled_F4 T_scaled_F3 T_scaled_F2 T_scaled_F1 T_scaled_L0 T_scaled_L1 T_scaled_L2 T_scaled_L3 T_scaled_L4 ///
jahr s_d_socialh d_socialh ln_d_socialh if PLR_ID_num == 1100104

local i 5
reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 if a100 ==1 & inrange(jahr, 2009, 2019), absorb(i.PLR_ID_num#i.event_code i.jahr#i.event_code) cl(event_code) noomitted noempty noconst level(95)

* adjust coeffcients
nlcom ///
	(_b[T_scaled_t`i'_F4]) ///
	(_b[T_scaled_t`i'_F3]) ///
	(_b[T_scaled_t`i'_F2]) ///
	(0) ///
	(_b[T_scaled_t`i'_L0]) ///
	(_b[T_scaled_t`i'_L1]) ///
	(_b[T_scaled_t`i'_L2]) ///
	(_b[T_scaled_t`i'_L3]) ///
	(_b[T_scaled_t`i'_L4]) ///
	, post level(95) 
	
eststo _test

coefplot ///
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(90 95)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")



* set global for potential treatments
global treat_c shchange d_socialh ln_d_socialh s_d_socialh c_dd_socialh

* global set to the number of words in treatment global
global treat_count : list sizeof global(treat_c)

* loop over rings
forvalues i = 1/$treat_count {
	* run regression without trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num#i.event_code i.jahr#i.event_code) noomitted noempty cluster(PLR_ID_num) noconst level(95)

	* adjust coeffcients
	nlcom ///
	(_b[T_scaled_t`i'_F4]) ///
	(_b[T_scaled_t`i'_F3]) ///
	(_b[T_scaled_t`i'_F2]) ///
	(0) ///
	(_b[T_scaled_t`i'_L0]) ///
	(_b[T_scaled_t`i'_L1]) ///
	(_b[T_scaled_t`i'_L2]) ///
	(_b[T_scaled_t`i'_L3]) ///
	(_b[T_scaled_t`i'_L4]) ///
	, post level(95) 
	
	* store baseline estimates
	eststo est_outside

	* run regression with trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num#i.event_code i.jahr#i.event_code i.PLR_ID_num#c.jahr#event_code) noomitted noempty cl(PLR_ID_num) noconst level(95)

	* adjust coeffcients
	nlcom ///
	(_b[T_scaled_t`i'_F4]) ///
	(_b[T_scaled_t`i'_F3]) ///
	(_b[T_scaled_t`i'_F2]) ///
	(0) ///
	(_b[T_scaled_t`i'_L0]) ///
	(_b[T_scaled_t`i'_L1]) ///
	(_b[T_scaled_t`i'_L2]) ///
	(_b[T_scaled_t`i'_L3]) ///
	(_b[T_scaled_t`i'_L4]) ///
	, post level(95) 
	
	* store baseline estimates
	eststo est_outside_trend
	* call variables from list by index value

	* call variables from list by index value
	local x: word `i' of $treat_c
	di "`x'"
	if "`x'"== "shchange"{
		local treatment "SH share"
	}
	else if "`x'"== "ln_socialh"{
		local treatment "log(SH units)"
	}
	else if "`x'"== "d_socialh"{
		local treatment "Change in SH"
	}
		else if "`x'"== "ln_d_socialh"{
		local treatment "Log(Change in SH)"
	}
		else if "`x'"== "s_d_socialh"{
		local treatment "SD change in SH"
	}
		else if "`x'"== "c_dd_socialh"{
		local treatment "Multiple Dummies for Change in SH"
	}

	
	di `x'
	coefplot ///
	(est_outside, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)) ///
	(est_outside_trend, label(Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)), ///
	omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = -0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/continous_treatment_stack/treat_`x'_all_stack.png, replace 
}



* loop over rings
forvalues r = 0/1{
	* loop over treatments
	forvalues i = 1/$treat_count{
	* run regression without trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r ==`r' & jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num#i.event_code i.jahr#i.event_code) cl(PLR_ID_num) noomitted noempty noconst level(90)

	* adjust coeffcients
	nlcom ///
	(_b[T_scaled_t`i'_F4]) ///
	(_b[T_scaled_t`i'_F3]) ///
	(_b[T_scaled_t`i'_F2]) ///
	(0) ///
	(_b[T_scaled_t`i'_L0]) ///
	(_b[T_scaled_t`i'_L1]) ///
	(_b[T_scaled_t`i'_L2]) ///
	(_b[T_scaled_t`i'_L3]) ///
	(_b[T_scaled_t`i'_L4]) ///
	, post level(95) 
	
	* store baseline estimates
	eststo est_outside

	* run regression with trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r==`r' & jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num#i.event_code i.jahr#i.event_code i.PLR_ID_num#c.jahr#event_code) noomitted noempty cl(PLR_ID_num) noconst level(90)

	* adjust coeffcients
	nlcom ///
	(_b[T_scaled_t`i'_F4]) ///
	(_b[T_scaled_t`i'_F3]) ///
	(_b[T_scaled_t`i'_F2]) ///
	(0) ///
	(_b[T_scaled_t`i'_L0]) ///
	(_b[T_scaled_t`i'_L1]) ///
	(_b[T_scaled_t`i'_L2]) ///
	(_b[T_scaled_t`i'_L3]) ///
	(_b[T_scaled_t`i'_L4]) ///
	, post level(95) 
	
	* store baseline estimates
	eststo est_outside_trend
	* call variables from list by index value

	* call variables from list by index value
	local x: word `i' of $treat_c
	di "`x'"
	if "`x'"== "shchange"{
		local treatment "SH share"
	}
	else if "`x'"== "ln_socialh"{
		local treatment "log(SH units)"
	}
	else if "`x'"== "d_socialh"{
		local treatment "Change in SH"
	}
		else if "`x'"== "ln_d_socialh"{
		local treatment "Log(Change in SH)"
	}
		else if "`x'"== "s_d_socialh"{
		local treatment "SD change in SH"
	}
		else if "`x'"== "c_dd_socialh"{
		local treatment "Multiple Dummies for Change in SH"
	}

	
	di `x'
	coefplot ///
	(est_outside, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)) ///
	(est_outside_trend, label(Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)), ///
	omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = -0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/continous_treatment_stack/treat_`x'_A100_`r'_stack.png, replace 

	}
}









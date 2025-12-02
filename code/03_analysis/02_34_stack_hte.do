clear all
set more off
set mem 400m
set matsize 1200
estimates clear

* Set Globals 

* set global for potential treatments
global treat_c shchange d_socialh ln_d_socialh s_d_socialh c_dd_socialh ln_socialh

* global set to the number of words in treatment global
global treat_count : list sizeof global(treat_c)

********************************************************************************
* Regression Analyses without stacking
********************************************************************************
* upload treated file
use "${TEMP}/stacked_treat1.dta", clear


reghdfe qm_miete_kalt T_dummy_F3 T_dummy_F2 ///
T_dummy_L0 T_dummy_L1 T_dummy_L2 T_dummy_L3, ///
absorb(i.event#i.jahr i.event#i.PLR_ID_num) noomitted noempty cluster(i.event#i.PLR_ID_num) noconst level(95)

	* adjust coeffcients
	nlcom ///
	(_b[T_dummy_F3]) ///
	(_b[T_dummy_F2]) ///
	(0) ///
	(_b[T_dummy_L0]) ///
	(_b[T_dummy_L1]) ///
	(_b[T_dummy_L2]) ///
	(_b[T_dummy_L3]) ///
	, post level(95)
	
eststo _test
coefplot ///
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -3 _nl_2 = -2 _nl_3 = -1 _nl_4 = 0 _nl_5 = 1 _nl_6 = 2 _nl_7 = 3  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")

local i 5
reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 ///
T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
if a100_r==0 & inrange(jahr, 2010, 2019), ///
absorb(i.event#i.jahr i.event#i.PLR_ID_num#c.objects i.event#i.PLR_ID_num) noomitted noempty cluster(event) noconst level(95)

	* adjust coeffcients
	nlcom ///
	(_b[T_scaled_t`i'_F3]) ///
	(_b[T_scaled_t`i'_F2]) ///
	(0) ///
	(_b[T_scaled_t`i'_L0]) ///
	(_b[T_scaled_t`i'_L1]) ///
	(_b[T_scaled_t`i'_L2]) ///
	(_b[T_scaled_t`i'_L3]) ///
	, post level(95)
	
eststo _test

coefplot ///
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -3 _nl_2 = -2 _nl_3 = -1 _nl_4 = 0 _nl_5 = 1 _nl_6 = 2 _nl_7 = 3  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")


local i 5
reghdfe qm_miete_kalt f3_binary f2_binary l0_binary ///
l1_binary l2_binary l3_binary ///
if a100_r==1 & inrange(jahr, 2010, 2019), ///
absorb(i.event#i.jahr i.event#i.PLR_ID_num#c.jahr i.event#i.PLR_ID_num) noomitted noempty cluster(event) noconst level(95)

	* adjust coeffcients
	nlcom ///
	(_b[f3_binary]) ///
	(_b[f2_binary]) ///
	(0) ///
	(_b[l0_binary]) ///
	(_b[l1_binary]) ///
	(_b[l2_binary]) ///
	(_b[l3_binary]) ///
	, post level(95)
	
eststo _test

coefplot ///
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(95)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -3 _nl_2 = -2 _nl_3 = -1 _nl_4 = 0 _nl_5 = 1 _nl_6 = 2 _nl_7 = 3  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")

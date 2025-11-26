/// PROJECT: Housing Policy
/// GOAL: Regressions on object level 
/// AUTHOR: Laura Arnemann
/// CREATION: 17.10.2024
/// LAST UPDATE: 
/// SOURCE: *


* set global for potential treatments
global treat_c shchange d_socialh ln_d_socialh s_d_socialh c_dd_socialh ln_socialh

* global set to the number of words in treatment global
global treat_count : list sizeof global(treat_c)


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

* log outcome 
gen ln_qm_miete_kalt = log(qm_miete_kalt)

* modernization/renovation
g modern = 1
replace modern = 0 if letzte_modernisierung == -9

g modern_year = 0
replace modern_year = 1 if letzte_modernisierung == jahr

g modern_year_1 = 0
replace modern_year_1 = (letzte_modernisierung == jahr + 1)

* scale treatment variables
g d_socialh_scale = d_socialh *10
g sh_d_socialh_scale = sh_d_socialh *1000

bysort obid: gen d_sh = (foerderung == 1)

xxx
* ============================= *
**# === Regression Results === *
* ============================= *
g ln_pop = ln(e_e)

did_multiplegt_dyn objects PLR_ID_num jahr c_dd_socialh if d_socialh >= 0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung == 1, effects(5) placebo(3) cluster(PLR_ID_num)
did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )
did_multiplegt_dyn modern_year PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr sh_d_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) continous(1)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh ///
if a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung != 1, ///
effects(5) placebo(3) controls( ln_wohnungen ) cluster(PLR_ID_num)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh ///
if d_socialh >= 0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung != 1, ///
effects(5) placebo(3) controls( ln_wohnungen ) cluster(PLR_ID_num)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr d_socialh_scale ///
if a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung != 1, ///
effects(5) placebo(3) controls(ln_wohnungen) continuous(1) cluster(PLR_ID_num) ///
ci_level(90)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr sh_d_socialh_scale ///
if d_socialh >= 0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung != 1, ///
effects(5) placebo(3) controls(ln_wohnungen) continuous(1) cluster(PLR_ID_num) ///
ci_level(90)

did_multiplegt_dyn modern_year PLR_ID_num jahr c_dd_socialh ///
if a100_r == 1 & inrange(jahr, 2010, 2019) & d_sh == 1, ///
effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num) ///
ci_level(90)

* ============================= *
**# === Regression Results === *
* ============================= *
g ln_pop = ln(e_e)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung == 1, effects(5) placebo(3) cluster(PLR_ID_num)
did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num)

*reghdfe qm_miete_kalt T_scaled_t4_F4 T_scaled_t4_F3 T_scaled_t4_F2 T_scaled_t4_L0 T_scaled_t4_L1 T_scaled_t4_L2 T_scaled_t4_L3 T_scaled_t4_L4 ///
*	if jahr > 2009 & jahr <= 2019, absorb(i.obid i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num)
graph export $output/max/graphs/dsdh/dcdh_prop_ln_rent.png, as(png) replace

did_multiplegt_dyn modern PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num) same_switchers
graph export $output/max/graphs/dsdh/dcdh_prop_modern.png, as(png) replace

did_multiplegt_dyn modern_year PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num)

did_multiplegt_dyn modern_year PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num)
graph export $output/max/graphs/dsdh/dcdh_prop_modern_year.png, as(png) replace

* d_socialh
did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr d_socialh    if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) continuous(1)
graph export $output/max/graphs/dsdh/dcdh_prop_d_socialh_ln_rent.png, as(png) replace

did_multiplegt_dyn modern PLR_ID_num jahr d_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num) continuous(1)
graph export $output/max/graphs/dsdh/dcdh_prop_d_socialh_modern.png, as(png) replace

did_multiplegt_dyn modern_year PLR_ID_num jahr d_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num) continuous(1)
graph export $output/max/graphs/dsdh/dcdh_prop_d_socialh_modern_year.png, as(png) replace

* sh_d_socialh
did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr sh_d_socialh    if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) continuous(1)
graph export $output/max/graphs/dsdh/dcdh_prop_sh_d_socialh_ln_rent.png, as(png) replace

did_multiplegt_dyn modern PLR_ID_num jahr sh_d_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num) continuous(1)
graph export $output/max/graphs/dsdh/dcdh_prop_sh_d_socialh_modern.png, as(png) replace

did_multiplegt_dyn modern_year PLR_ID_num jahr sh_d_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019) & foerderung!=1, effects(5) placebo(3) cluster(PLR_ID_num) continuous(1)
graph export $output/max/graphs/dsdh/dcdh_prop_sh_d_socialh_modern_year.png, as(png) replace



*-------------------------------------------------------------------*
* 1.  Loop over each outcome and generate a post-file (in the loop) *
*-------------------------------------------------------------------*
foreach ooi in ln_qm_miete_kalt {
	
	postutil clear
	tempname P9_`ooi'
	postfile `P9_`ooi'' str15(treat) ///
	double(d_ph_p0 d_ph_p0_se d_ph_p1 d_ph_p1_se d_ph_p2 d_ph_p2_se d_ph_p3 d_ph_p3_se d_ph_p4 d_ph_p4_se ///
	d_ph_m1 d_ph_m1_se d_ph_m2 d_ph_m2_se d_ph_m3 d_ph_m3_se d_ph_m4 d_ph_m4_se ) ///
	using "$output/postfiles/dcdh_cont_obj_`ooi'", replace

	* absorbing treatment: when becoming one your are staying one forever
	did_multiplegt_dyn `ooi' PLR_ID_num jahr ///
        c_dd_socialh                         			///
        if a100_r==1 & d_socialh>=0 & inrange(jahr, 2010, 2019) & foerderung!=1, ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) graph_off

	post `P9_`ooi'' ("c_dd_socialh") ///
	( e(estimates)[1, 1] ) ( sqrt(e(variances)[1, 1]) ) ///
	( e(estimates)[2, 1] ) ( sqrt(e(variances)[2, 1]) ) ///
	( e(estimates)[3, 1] ) ( sqrt(e(variances)[3, 1]) ) ///
	( e(estimates)[4, 1] ) ( sqrt(e(variances)[4, 1]) ) ///
	( e(estimates)[5, 1] ) ( sqrt(e(variances)[5, 1]) ) ///
	(0) (0) ///
	( e(estimates)[7, 1] ) ( sqrt(e(variances)[7, 1]) ) ///
	( e(estimates)[8, 1] ) ( sqrt(e(variances)[8, 1]) ) ///
	( e(estimates)[9, 1] ) ( sqrt(e(variances)[9, 1]) )

	did_multiplegt_dyn `ooi' PLR_ID_num jahr 		///
        d_socialh_scale                         	/// change in social housing
        if a100_r==1 & d_socialh>=0 & inrange(jahr, 2010, 2019) & foerderung!=1, ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        continuous(1) cluster(PLR_ID_num) graph_off
	
	post `P9_`ooi'' ("d_socialh_scale") ///
	( e(estimates)[1, 1] ) ( sqrt(e(variances)[1, 1]) ) ///
	( e(estimates)[2, 1] ) ( sqrt(e(variances)[2, 1]) ) ///
	( e(estimates)[3, 1] ) ( sqrt(e(variances)[3, 1]) ) ///
	( e(estimates)[4, 1] ) ( sqrt(e(variances)[4, 1]) ) ///
	( e(estimates)[5, 1] ) ( sqrt(e(variances)[5, 1]) ) ///
	(0) (0) ///
	( e(estimates)[7, 1] ) ( sqrt(e(variances)[7, 1]) ) ///
	( e(estimates)[8, 1] ) ( sqrt(e(variances)[8, 1]) ) ///
	( e(estimates)[9, 1] ) ( sqrt(e(variances)[9, 1]) )

	did_multiplegt_dyn `ooi' PLR_ID_num jahr 		///
        sh_d_socialh_scale                         		///
        if a100_r==1 & d_socialh>=0 & inrange(jahr, 2010, 2019) & foerderung!=1, ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        continuous(1) cluster(PLR_ID_num) graph_off

	post `P9_`ooi'' ("sh_d_socialh_scale") ///
	( e(estimates)[1, 1] ) ( sqrt(e(variances)[1, 1]) ) ///
	( e(estimates)[2, 1] ) ( sqrt(e(variances)[2, 1]) ) ///
	( e(estimates)[3, 1] ) ( sqrt(e(variances)[3, 1]) ) ///
	( e(estimates)[4, 1] ) ( sqrt(e(variances)[4, 1]) ) ///
	( e(estimates)[5, 1] ) ( sqrt(e(variances)[5, 1]) ) ///
	(0) (0) ///
	( e(estimates)[7, 1] ) ( sqrt(e(variances)[7, 1]) ) ///
	( e(estimates)[8, 1] ) ( sqrt(e(variances)[8, 1]) ) ///
	( e(estimates)[9, 1] ) ( sqrt(e(variances)[9, 1]) )

	postclose `P9_`ooi''
}


use "$output/postfiles/dcdh_cont_obj_ln_qm_miete_kalt", clear

*--- 1. Give SE variables a clean, parallel stub --------------------------------
local times m4 m3 m2 m1 p0 p1 p2 p3 p4
foreach t of local times {
    rename d_ph_`t'_se   se_`t'     // d_ph_m1_se  ->  se_m1
}

*--- 2. Reshape both stubs at once ----------------------------------------------
reshape long d_ph_ se_, i(treat) j(time) string


*--- 3. Tidy variable names ------------------------------------------------------
rename d_ph_  estimate
rename se_    se

*--- 5. Confidence intervals -----------------------------------------------------
gen max90 = estimate + 1.78*se
gen min90 = estimate - 1.78*se
gen max95 = estimate + 1.96*se
gen min95 = estimate - 1.96*se

* Generate period indicators
gen period =substr(time,-1,1)
destring period, replace

* Distinguish pre and post
replace period = period*(-1) if substr(time,-2,1)=="m"

* obtain treat variable
egen byte reg = group(treat), label

gen period_shift=period
replace period_shift = period - .2 if reg == 1
replace period_shift = period + .2 if reg == 3


* set global for size
global ylab_size .5cm
global xlab_size .5cm
global ytitle_size .5cm
global xtitle_size .5cm
global x_titel "Years since treatment"
global x_size 14cm
global y_size 11cm
global rspike_lwidth95 .04cm
global rspike_lwidth90 .07cm
global legend_size .5cm
global legend_title_size .3cm
global subtitle_size .4cm
global xline_width .04cm
global msize_size .28cm

colorpalette s2, locals

twoway ///
(scatter estimate period_shift 	 if reg==1, msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==1, lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg==1, lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg==2, msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==2, lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg==2, lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period_shift 	 if reg==3, msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==3, lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if reg==3, lwidth($rspike_lwidth90) lcolor("`forest_green'%60")), ///
yline(0, lpattern(dash) lcolor(gs8) ) xlabel(-4(1)4, labsize($xlab_size ) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order(1 "Dummy" 4 "One unit Change" 7 "Change in SH share") pos(6) rows(1)) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)


colorpalette s2, locals

twoway ///
(scatter estimate period_shift 	 if reg==1, msymbol(o) mcolor("`navy'%60") msize($msize_size ) ) ///
(rspike min95 max95 period_shift if reg==1, lwidth( $rspike_lwidth95 ) lcolor("`navy'%60" ) ) ///
(rspike min90 max90 period_shift if reg==1, lwidth( $rspike_lwidth90 ) lcolor("`navy'%60" ) ), ///
yline(0, lpattern(dash) lcolor(gs8) ) xlabel(-4(1)4, labsize($xlab_size ) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1) ) scale(0.9) ///
legend( off ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/max/graphs/dsdh/dcdh_cont_objt_ln_rent.png", replace


foreach treat in c_dd_socialh d_socialh sh_d_socialh {
	foreach ooi in ln_qm_miete_kalt modern modern_year {

	* absorbing treatment: when becoming one your are staying one forever
	did_multiplegt_dyn `ooi' PLR_ID_num jahr `treat' if `treat' >=0 & a100_r==1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num)

local i 1
reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 ///
T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r == 1 & jahr > 2009 & jahr <= 2019 & foerderung!=1, ///
	absorb(i.jahr i.PLR_ID_num) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(90)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")


*reghdfe qm_miete_kalt T_dummy_F4 T_dummy_F3 T_dummy_F2 T_dummy_L0 T_dummy_L1 T_dummy_L2 T_dummy_L3 T_dummy_L4 if a100_r==0 &  jahr>2009 & jahr <= 2019, absorb(i.obid i.jahr) noomitted noempty cluster(PLR_ID_num) noconst

* loop over rings
* loop over treatments
forvalues i = 1/$treat_count {
	* run regression without trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if jahr > 2009 & jahr <= 2019 & foerderung!=1, absorb(i.obid i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	
	* stire baseline estimates
	eststo est_outside

	* run regression with trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if jahr > 2009 & jahr <= 2019  & foerderung!=1, absorb(i.obid i.jahr i.PLR_ID_num#c.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)


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
	
	* stire baseline estimates
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
	graphregion(color(white)) ytitle("log(Rents per sqm)", size(medsmall)) xtitle("Years until Large Change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/object_level/treat_`x'_all_indi.png, replace 
}
	
* loop over rings
forvalues r = 0/1{
	* loop over treatments
	forvalues i = 1/$treat_count{
	* run regression without trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r ==`r' & jahr > 2009 & jahr <= 2019  & foerderung!=1, absorb(i.obid i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	
	* stire baseline estimates
	eststo est_outside

	* run regression with trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r==`r' & jahr > 2009 & jahr <= 2019  & foerderung!=1, absorb(i.obid i.jahr i.PLR_ID_num#c.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	
	* stire baseline estimates
	eststo est_outside_trend
	* call variables from list by index value

	* call variables from list by index value
	local x: word `i' of $treat_c
	di "`x'"
	* set graph names by treatment
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
	graphregion(color(white)) ytitle("log(Rents per sqm)", size(medsmall)) xtitle("Years until Large Change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/object_level/treat_`x'_A100_`r'_indi.png, replace 

	}
}
/*
* manual checks
reghdfe qm_miete_kalt T_scaled_t4_F4 T_scaled_t4_F3 T_scaled_t4_F2 T_scaled_t4_L0 T_scaled_t4_L1 T_scaled_t4_L2 T_scaled_t4_L3 T_scaled_t4_L4 ///
if jahr > 2009 & jahr <=2019 & foerderung!=1, absorb(i.obid i.jahr i.PLR_ID_num) noomitted noempty cluster(PLR_ID_num) noconst level(90)


reghdfe qm_miete_kalt T_scaled_t5_F4 T_scaled_t5_F3 T_scaled_t5_F2 T_scaled_t5_L0 T_scaled_t5_L1 T_scaled_t5_L2 T_scaled_t5_L3 T_scaled_t5_L4 ///
if a100_r==1 & jahr > 2009 & jahr <=2019, absorb(i.obid i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)


	* run regression without trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
if jahr > 2009 & jahr <=2019  & foerderung!=1, absorb(i.obid i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)
*/





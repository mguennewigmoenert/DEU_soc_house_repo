
/**
 * PICTUREIT - PLOT ESTIMATED COEFFICIENTS
 *
 * @project proptax-rents
 * (c) M. Löffler, S. Siegloch
 */


* ========================= *
**# === Upload data set === *
* ========================= *
* uplouad dataframe
use "$TEMP/socialhousing_analysis.dta", clear

* set global for potential treatments
global treat_c sh_d_socialh d_socialh ln_d_socialh s_d_socialh c_dd_socialh ln_socialh

* global set to the number of words in treatment global
global treat_count : list sizeof global(treat_c)

* ============================= *
**# === Regressuion Results === *
* ============================= *

* did_multiplegt_dyn qm_miete_kalt PLR_ID_num jahr T_scaled_t4 if a100 ==1 & inrange(jahr, 2007, 2019), effects(5) placebo(3) cluster(PLR_ID_num)

sum tot_d_socialh if tot_d_socialh>0, d
sum tot_dd_socialh if tot_dd_socialh>0, d

* (tot_d_socialh>=230 | tot_d_socialh==0)
* (tot_dd_socialh>=5 | tot_dd_socialh==0)

* average social housing drop of all treated
sum d_socialh if inrange(jahr, 2010, 2019) & d_socialh>0
sum socialh if inrange(jahr, 2010, 2019)

* fy_treat0: first year a change of any magnitude happening

* local i 2
* reghdfe s.ln_qm_miete_kalt s.T_scaled_t`i'_F4 s.T_scaled_t`i'_F3 s.T_scaled_t`i'_F2 ///
* s.T_scaled_t`i'_L0 s.T_scaled_t`i'_L1 s.T_scaled_t`i'_L2 s.T_scaled_t`i'_L3 s.T_scaled_t`i'_L4 ///
* if a100_r == 1 & inrange(jahr, 2010, 2019), ///
* absorb(i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(95)

xxx

reghdfe ln_qm_miete_kalt T_dummy_F4 T_dummy_F3 T_dummy_F2 ///
T_dummy_L0 T_dummy_L1 T_dummy_L2 T_dummy_L3 T_dummy_L4 ///
ln_wohnungen ///
if a100_r == 1 & d_socialh >= 0 & inrange(jahr, 2010, 2019), ///
absorb(jahr PLR_ID_num) noomitted noempty cluster(PLR_ID_num) noconst level(95)

	* adjust coeffcients
	nlcom ///
	(_b[T_dummy_F4]) ///
	(_b[T_dummy_F3]) ///
	(_b[T_dummy_F2]) ///
	(0) ///
	(_b[T_dummy_L0]) ///
	(_b[T_dummy_L1]) ///
	(_b[T_dummy_L2]) ///
	(_b[T_dummy_L3]) ///
	(_b[T_dummy_L4]) ///
	, post level(95)
	
eststo _test

coefplot ///
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(90)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")


local i 5

reghdfe ln_qm_miete_kalt ///
T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 ///
T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
 ///
if a100_r == 1 & inrange(jahr, 2010, 2019), ///
absorb( i.PLR_ID_num i.jahr ) noomitted noempty cluster( PLR_ID_num ) noconst level(95)

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
	
eststo base_10_19

coefplot ///
(base_10_19, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(90)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")

xxx

* use not yet treated as control

local i 1
reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 ///
T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ln_wohnungen ///
if a100_r == 1 & inrange(jahr, 2010, 2018) & fy_treat0 >=2014 & fy_treat0 <=2016 , ///
absorb(PLR_ID_num jahr i.PLR_ID_num#c.wohnungen) noomitted noempty cluster(PLR_ID_num) noconst level(95)

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
	
eststo base_13_16

coefplot ///
(base_13_16, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(90)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")

* use not yet treated as control
local i 5
reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 ///
T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ln_wohnungen ///
if a100_r == 1 & inrange(jahr, 2010, 2018) & fy_treat0 >=2014 & fy_treat0 != ., ///
absorb(PLR_ID_num jahr) noomitted noempty cluster(PLR_ID_num) noconst level(95)

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
	
eststo base_13_19_notyet

coefplot ///
(_test, label(No Trend) ciopts(recast(rarea) fintensity(inten10) color(%50)) recast(connected) level(90)), ///
omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = 0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing")

coefplot ///
	(base_10_19, label("All") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)) ///
	(base_13_16, label("Only treated 2014 to 1016") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)) ///
	(base_13_19_notyet, label("Only treated in 2014 and after + not yet treated") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)), ///
	omitted vertical drop( _cons) legend(pos(6)) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = -0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("log(Rents per sqm)", size(medsmall)) xtitle("Years until change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/continous_treatment/treat_base_A100_1.png, replace 

	
* check LORs
br qm_miete_kalt jahr PLR_ID_num d_socialh tot_d_socialh tot_dd_socialh T_scaled_t5_F* T_scaled_t5_L* T_scaled_t2_F* T_scaled_t2_L* if a100_r == 1 & inrange(jahr, 2009, 2019) & tot_d_socialh>=202

reghdfe qm_miete_kalt T_scaled_t4_F4 T_scaled_t4_F3 T_scaled_t4_F2 T_scaled_t4_L0 T_scaled_t4_L1 T_scaled_t4_L2 T_scaled_t4_L3 T_scaled_t4_L4 if a100==1 & inrange(jahr, 2009, 2019) & (tot_d_socialh > 71 | tot_d_socialh==0), absorb(i.PLR_ID_num i.jahr i.PLR_ID_num#c.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

g ln_objects = ln(objects+1)
reghdfe ln_objects T_dummy_F4 T_dummy_F3 T_dummy_F2 T_dummy_L0 T_dummy_L1 T_dummy_L2 T_dummy_L3 T_dummy_L4 if jahr>2009 & jahr <= 2019, absorb(PLR_ID_num jahr i.PLR_ID_num#c.jahr) noomitted noempty cluster(PLR_ID_num) noconst

**# Total Berlin
* loop over rings
forvalues i = 1/$treat_count {
	* run regression without trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	if jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num i.jahr i.PLR_ID_num#c.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	graph export ${output}/max/graphs/continous_treatment/treat_`x'_all.png, replace 
}

**# Within and outside A100
* loop over rings
forvalues r = 0/1{
	* loop over treatments
	forvalues i = 1/$treat_count{
	* run regression without trend
	reghdfe qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r ==`r' & jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	if a100_r==`r' & jahr > 2009 & jahr <= 2019, absorb(i.PLR_ID_num i.jahr i.PLR_ID_num#c.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	graph export ${output}/max/graphs/continous_treatment/treat_`x'_A100_`r'.png, replace 

	}
}

**# Quartiles of cumulative number dropped units in LOR 
* check distribution of accumuluated change
sum tot_d_socialh if tot_d_socialh>0, d

* loop over rings
* loop over treatments
forvalues i = 1/$treat_count{
	* run regression without trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r ==1 & jahr > 2009 & jahr <= 2019 & (tot_d_socialh==0 | tot_d_socialh >= 22), absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	eststo est_q2

	* run regression with trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r==1 & jahr > 2009 & jahr <= 2019 & (tot_d_socialh==0 | tot_d_socialh >= 71), absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	eststo est_q3
	
	* run regression with trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r==1 & jahr > 2009 & jahr <= 2019 & (tot_d_socialh==0 | tot_d_socialh >= 230), absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	eststo est_q4

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
	(est_q2, label("22 units") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)) ///
	(est_q3, label("71 units") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)) ///
	(est_q4, label("230 units") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)), ///
	omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = -0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("log(Rents per sqm)", size(medsmall)) xtitle("Years until Large Change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/continous_treatment/treat_`x'_A100_Q_cum.png, replace 
}

**# Quartiles of total events in LOR 
* check distribution of accumuluated change
sum tot_dd_socialh if tot_dd_socialh>0, d
_pctile tot_dd_socialh if tot_dd_socialh>0, p(30)
return list
* loop over rings
* loop over treatments
forvalues i = 1/$treat_count{
	* run regression without trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r ==1 & jahr > 2009 & jahr <= 2019 & (tot_dd_socialh==0 | tot_dd_socialh >= 2), absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	eststo est_q2

	* run regression with trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r==1 & jahr > 2009 & jahr <= 2019 & (tot_dd_socialh==0 | tot_dd_socialh >= 3), absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	eststo est_q3
	
	* run regression with trend
	reghdfe ln_qm_miete_kalt T_scaled_t`i'_F4 T_scaled_t`i'_F3 T_scaled_t`i'_F2 T_scaled_t`i'_L0 T_scaled_t`i'_L1 T_scaled_t`i'_L2 T_scaled_t`i'_L3 T_scaled_t`i'_L4 ///
	if a100_r==1 & jahr > 2009 & jahr <= 2019 & (tot_dd_socialh==0 | tot_dd_socialh >= 5), absorb(i.PLR_ID_num i.jahr) noomitted noempty cluster(PLR_ID_num) noconst level(90)

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
	eststo est_q4

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
	(est_q2, label("2 Changes") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)) ///
	(est_q3, label("3 Changes") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)) ///
	(est_q4, label("5 Changes") ciopts(recast(rcap) fintensity(inten10) color(%50)) level(90 95)), ///
	omitted vertical drop( _cons) coeflabel( _nl_1 = -4 _nl_2 = -3 _nl_3 = -2 _nl_4 = -1 _nl_5 = -0 _nl_6 = 1 _nl_7 = 2  _nl_8 = 3 _nl_9 = 4, angle(45)) ///
	xline(5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) ///
	graphregion(color(white)) ytitle("log(Rents per sqm)", size(medsmall)) xtitle("Years until Large Change in Social Housing") title("`treatment'")
	graph export ${output}/max/graphs/continous_treatment/treat_`x'_A100_Q_dd.png, replace 
}



*reghdfe ln_qm_miete_kalt c.T_scaled_F4#1.a100_r c.T_scaled_F3#1.a100_r c.T_scaled_F2#1.a100_r c.T_scaled_L0#1.a100_r c.T_scaled_L1#1.a100_r c.T_scaled_L2#1.a100_r c.T_scaled_L3#1.a100_r c.T_scaled_L4#1.a100_r  c.T_scaled_F4#0.a100_r c.T_scaled_F3#0.a100_r c.T_scaled_F2#0.a100_r c.T_scaled_L0#0.a100_r c.T_scaled_L1#0.a100_r c.T_scaled_L2#0.a100_r c.T_scaled_L3#0.a100_r c.T_scaled_L4#0.a100_r if jahr <=2019, absorb(i.a100_r#i.PLR_ID_num i.a100_r#i.jahr) noomitted noempty cluster(PLR_ID_num) noconst


reghdfe ln_qm_miete_kalt 1.T_dummy_F4#1.a100_r 1.T_dummy_F3#1.a100_r 1.T_dummy_F2#1.a100_r 1.T_dummy_L0#1.a100_r 1.T_dummy_L1#1.a100_r 1.T_dummy_L2#1.a100_r 1.T_dummy_L3#1.a100_r 1.T_dummy_L4#1.a100_r  1.T_dummy_F4#0.a100_r 1.T_dummy_F3#0.a100_r 1.T_dummy_F2#0.a100_r 1.T_dummy_F1#0.a100_r 1.T_dummy_L0#0.a100_r 1.T_dummy_L1#0.a100_r 1.T_dummy_L2#0.a100_r 1.T_dummy_L3#0.a100_r 1.T_dummy_L4#0.a100_r if jahr <=2019, absorb(i.a100_r#i.PLR_ID_num i.a100_r#i.jahr) noomitted noempty cluster(PLR_ID_num) noconst

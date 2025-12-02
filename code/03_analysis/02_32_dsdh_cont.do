// Project: Social Housing
// Creation Date: 05-02-2024 
// Last Update: 18-04-2024 
// Author: Laura Arnemann 
// Goal: Running the stacked regression

*************************************************************************
* Regression Analyses without stacking
*************************************************************************
* upload treated file
use "${TEMP}/socialhousing_analysis.dta", clear 

* set panel dataset
xtset PLR_ID_num jahr, yearly

* test regressions
* calendar period
gen t = 1
replace t = 2 if jahr == 2008
replace t = 3 if jahr == 2009
replace t = 4 if jahr == 2010
replace t = 5 if jahr == 2011
replace t = 6 if jahr == 2012
replace t = 7 if jahr == 2013
replace t = 8 if jahr == 2014
replace t = 9 if jahr == 2015
replace t = 10 if jahr == 2016
replace t = 11 if jahr == 2017
replace t = 12 if jahr == 2018
replace t = 13 if jahr == 2019

* generate group variable
gen Ei_t1 = .
replace Ei_t1 = 2 if fy_treat0 == 2008 & treated !=.
replace Ei_t1 = 3 if fy_treat0 == 2009 & treated !=.
replace Ei_t1 = 4 if fy_treat0 == 2010 & treated !=.
replace Ei_t1 = 5 if fy_treat0 == 2011 & treated !=.
replace Ei_t1 = 6 if fy_treat0 == 2012 & treated !=.
replace Ei_t1 = 7 if fy_treat0 == 2013 & treated !=.
replace Ei_t1 = 8 if fy_treat0 == 2014 & treated !=.
replace Ei_t1 = 9 if fy_treat0 == 2015 & treated !=.
replace Ei_t1 = 10 if fy_treat0 == 2016 & treated !=.
replace Ei_t1 = 11 if fy_treat0 == 2017 & treated !=.

* group variable as required for the csdid command
gen gvar_t1 = cond(Ei_t1==., 0, Ei_t1)
replace gvar_t1=. if treated == .
replace gvar_t1=0 if treated == 0

/*
* generate group variable
gen Ei2_t1 = .
replace Ei2_t1 = 2 if fy_treat0_2 == 2008 & treated_2 !=.
replace Ei2_t1 = 3 if fy_treat0_2 == 2009 & treated_2 !=.
replace Ei2_t1 = 4 if fy_treat0_2 == 2010 & treated_2 !=.
replace Ei2_t1 = 5 if fy_treat0_2 == 2011 & treated_2 !=.
replace Ei2_t1 = 6 if fy_treat0_2 == 2012 & treated_2 !=.
replace Ei2_t1 = 7 if fy_treat0_2 == 2013 & treated_2 !=.
replace Ei2_t1 = 8 if fy_treat0_2 == 2014 & treated_2 !=.
replace Ei2_t1 = 9 if fy_treat0_2 == 2015 & treated_2 !=.
replace Ei2_t1 = 10 if fy_treat0_2 == 2016 & treated_2 !=.
replace Ei2_t1 = 11 if fy_treat0_2 == 2017 & treated_2 !=.

* group variable as required for the csdid command
gen gvar2_t1 = cond(Ei2_t1==., 0, Ei2_t1)
replace gvar2_t1=. if treated_2 == .
replace gvar2_t1=0 if treated_2 == 0

* generate group variable
gen Ei_t2 = .
replace Ei_t2 = 2 if fy_treat2 == 2008 & treated !=.
replace Ei_t2 = 3 if fy_treat2 == 2009 & treated !=.
replace Ei_t2 = 4 if fy_treat2 == 2010 & treated !=.
replace Ei_t2 = 5 if fy_treat2 == 2011 & treated !=.
replace Ei_t2 = 6 if fy_treat2 == 2012 & treated !=.
replace Ei_t2 = 7 if fy_treat2 == 2013 & treated !=.
replace Ei_t2 = 8 if fy_treat2 == 2014 & treated !=.
replace Ei_t2 = 9 if fy_treat2 == 2015 & treated !=.
replace Ei_t2 = 10 if fy_treat2 == 2016 & treated !=.
replace Ei_t2 = 11 if fy_treat2 == 2017 & treated !=.

* group variable as required for the csdid command
gen gvar_t2 = cond(Ei_t2==., 0, Ei_t2)
replace gvar_t2=. if treated == .
replace gvar_t2=0 if treated == 0

* generate group variable
gen Ei2_t2 = .
replace Ei2_t2 = 2 if fy_treat2_2 == 2008 & treated_2 !=.
replace Ei2_t2 = 3 if fy_treat2_2 == 2009 & treated_2 !=.
replace Ei2_t2 = 4 if fy_treat2_2 == 2010 & treated_2 !=.
replace Ei2_t2 = 5 if fy_treat2_2 == 2011 & treated_2 !=.
replace Ei2_t2 = 6 if fy_treat2_2 == 2012 & treated_2 !=.
replace Ei2_t2 = 7 if fy_treat2_2 == 2013 & treated_2 !=.
replace Ei2_t2 = 8 if fy_treat2_2 == 2014 & treated_2 !=.
replace Ei2_t2 = 9 if fy_treat2_2 == 2015 & treated_2 !=.
replace Ei2_t2 = 10 if fy_treat2_2 == 2016 & treated_2 !=.
replace Ei2_t2 = 11 if fy_treat2_2 == 2017 & treated_2 !=.

* group variable as required for the csdid command
gen gvar2_t2 = cond(Ei2_t2==., 0, Ei2_t2)
replace gvar2_t2=. if treated_2 == .
replace gvar2_t2=0 if treated_2 == 0
*/
* set fy_ph_census to missing if zero for estimators
gen first_treat=.
replace first_treat = fy_treat0 if treated !=.
replace first_treat = . if treated ==. | treated ==0

* set fy_ph_census to missing if zero for estimators
gen first_treat_t2 =.
replace first_treat_t2 = fy_treat2 if treated !=.
replace first_treat_t2 = . if treated ==. | treated ==0
/*
* set fy_ph_census to missing if zero for estimators
gen first_treat2=.
replace first_treat2 = fy_treat0_2 if treated_2 !=.
replace first_treat2 = . if treated_2 ==. | treated_2 ==0

* set fy_ph_census to missing if zero for estimators
gen first_treat2_t2 =.
replace first_treat2_t2 = fy_treat2_2 if treated_2 !=.
replace first_treat2_t2 = . if treated_2 ==. | treated_2 ==0
*/
* set census year to missing for cs estimaor
* gen gvar_t2 = fy_treat2
* recode gvar_t2 (. = 0)

* set census year to missing for cs estimaor
* gen gvar_t1 = fy_treat0
* recode gvar_t1 (. = 0)

// generate leads and lags (used in some commands)
summ ty_treat2
local relmin = abs(r(min))
local relmax = abs(r(max))

// leads
cap drop F_t2_*
forval x = 0/`relmin' {  // drop the first lead
		gen F_t2_`x' = ty_treat2 == `x'
}

	
//lags
	cap drop L_t2_*
	forval x = 1/`relmax' {
		gen L_t2_`x' = ty_treat2 ==  -`x'
}

sum first_treat
gen last_cohort = first_treat==r(max) // dummy for the latest- or never-treated cohort

// generate leads and lags (used in some commands)
summ ty_treat0
local relmin = abs(r(min))
local relmax = abs(r(max))

// leads
* cap drop F_*
forval x = 0/`relmin' {  // drop the first lead
		gen F_`x' = ty_treat0 == `x'
}

	
//lags
	*cap drop L_*
	forval x = 1/`relmax' {
		gen L_`x' = ty_treat0 ==  -`x'
}
	
// generate the control_cohort variables  (used in some commands)
gen never_treat = treated==0

// generate the control_cohort variables  (used in some commands)
gen never_treat2 = treated_2==0

* make sure jahr is numeric
g jahr_num = jahr
recast int jahr_num, force


reghdfe ln_qm_miete_kalt L_2-L_5 F_0-F_5 if a100_r==1 & inrange(jahr, 2013, 2019) , absorb(PLR_ID jahr) cl(PLR_ID)

* adjust coeffcients
	nlcom ///
	(_b[L_4]) ///
	(_b[L_3]) ///
	(_b[L_2]) ///
	(0) ///
	(_b[F_0]) ///
	(_b[F_1]) ///
	(_b[F_2]) ///
	(_b[F_3]) ///
	(_b[F_4]) ///
	, post level(95)
	
eststo _test

* coefplot _test, vertical level(95 90)

* what is the sample
tab jahr if e(sample)

reghdfe ln_qm_miete_kalt L_t2_2-L_t2_5 F_t2_0-F_t2_5 if inrange(jahr, 2007, 2016) , absorb(PLR_ID jahr) cl(PLR_ID)

* percentage neighborhood composition
local nb_comp total_unemployed r1_mso_paare r1_mso_singles ///
              r1_mso_familien r1_mso_ausland

foreach var of local nb_comp {

    /* define the name of the new variable */
    local new = "`var'_p"

    /* choose the divisor and generate the percentage */
    if "`var'" == "total_unemployed" {
        gen double `new' = `var' / working_age_pop * 100
    }
    else {
        gen double `new' = `var' / r1_mba_a_haushalt * 100
    }
}

* composition
g ln_total_unemployed = ln(total_unemployed +1)

* rent prices
g ln_sqm_rent_hed_avg = ln(sqm_rent_hed_avg + 1)
g ln_sqm_rent_hed_med = ln(sqm_rent_hed_med + 1)
g ln_sqm_rent_avg = ln(sqm_rent_avg + 1)
g ln_sqm_rent_med = ln(sqm_rent_med + 1)
g ln_sqm_rent_p25 = ln(sqm_rent_p25 + 1)
g ln_sqm_rent_p75 = ln(sqm_rent_p75 + 1)

* percentage cars (rwi)
local cars r1_mps_cabrio r1_mps_gelaende r1_mps_kleinwag r1_mps_kombi ///
r1_mps_mittel r1_mps_obmittel r1_mps_miniwag r1_mps_ober r1_mps_unmittel ///
r1_mpa_elektro ///

foreach var of local cars {
    di "`var'"
	g ln_`var' = ln(`var' + 1)
	g `var'_p = (`var' / r1_mpi_w_dichte_hh * 100) 
}

* population
g ln_r1_ewa_a_gesamt = ln(r1_ewa_a_gesamt + 1) // total population (rwi)
g ln_r1_mba_a_haushalt = ln(r1_mba_a_haushalt + 1) // # households (rwi)

* generate population per household
g r1_pop_hh = ln_r1_ewa_a_gesamt / ln_r1_mba_a_haushalt

* generate purchasing power per person
g r1_kkr_pop = r1_kkr_w_total / ln_r1_ewa_a_gesamt

g ln_r1_kkr_pop = ln(r1_kkr_pop + 1)

* pool households by risk type
g risk_low      = r1_mri_risiko_1 + r1_mri_risiko_2 + r1_mri_risiko_3 + r1_mri_risiko_4 + r1_mri_risiko_5
g risk_high     = r1_mri_risiko_6 + r1_mri_risiko_7 + r1_mri_risiko_8 + r1_mri_risiko_9

g risk_low_high = risk_low/risk_high
g risk_p_high   = (risk_high / r1_mba_a_haushalt *100)
g risk_p_low    = (risk_low / r1_mba_a_haushalt *100)
g ln_risk_low   = ln(risk_low + 1)
g ln_risk_high  = ln(risk_high + 1)

* adjust race
* pool race
g non_german = r1_met_italien + r1_met_tuerkei + r1_met_griechen + r1_met_spanport + r1_met_balkan + r1_met_osteurop + r1_met_afrika + r1_met_islam + r1_met_asien + r1_met_uebrige
g east_europe = r1_met_balkan + r1_met_osteurop
g south_europe = r1_met_italien + r1_met_griechen + r1_met_spanport
g guest_worker = r1_met_italien + r1_met_tuerkei + r1_met_griechen

* percentage race
local race r1_met_deutschl r1_met_italien r1_met_tuerkei r1_met_griechen ///
r1_met_spanport r1_met_balkan r1_met_osteurop r1_met_afrika r1_met_islam ///
r1_met_asien r1_met_uebrige non_german east_europe south_europe guest_worker

* percentage of total
foreach var of local race {
    di "`var'"
	g `var'_p = (`var' / r1_mba_a_haushalt * 100)
}

* movers
g mobile_high = r1_mmo_fluktu_5 + r1_mmo_fluktu_6 + r1_mmo_fluktu_7
g mobile_low = r1_mmo_fluktu_1 + r1_mmo_fluktu_2 + r1_mmo_fluktu_3 + r1_mmo_fluktu_4

g ln_r1_mba_a_gewerbe = ln(r1_mba_a_gewerbe)
g ln_tot_sgb12_w  = ln(tot_sgb12_w + 1)
g psgb12_w  = (tot_sgb12_w / e_e ) *100 
g pdau5  	= (dau5 / e_e ) *100
g pdau10 	= (dau10  / e_e ) *100
g ln_dau5 	= ln(dau5 + 1)
g ln_dau10 	= ln(dau10 + 1)
g ln_pop 	= ln(e_e)

g e_e18u30 = e_e18_21 + e_e21_25 + e_e25_27 + e_e27_30
g e_e18u35 = e_e18_21 + e_e21_25 + e_e25_27 + e_e27_30 + e_e30_35
g ln_e_e18u30 = ln(e_e18u30)
g ln_e_e18u35 = ln(e_e18u35)

g e_e30u50 = e_e30_35 + e_e35_40 + e_e40_45 + e_e45_50
g ln_e_e30u50 = ln(e_e30u50)

g ln_e_e18_21 = ln(e_e18_21)
g ln_e_e21_25 = ln(e_e21_25)
g ln_e_e25_27 = ln(e_e25_27)
g ln_e_e27_30 = ln(e_e27_30)
g ln_e_e30_35 = ln(e_e30_35)
g ln_e_e35_40 = ln(e_e35_40)
g ln_e_e40_45 = ln(e_e40_45)

* ratio of 
g ratio_5to10 = dau5/dau10

g ln_objects_modern = ln(objects_moden + 1)
g ln_objects_modern_year = ln(objects_modern_year + 1)
g ln_objects_modern_year_1  = ln(objects_modern_year_1 + 1)

g asin_objects_modern = asinh(objects_moden)
g asin_objects_modern_year = asinh(objects_modern_year)
g asin_objects_modern_year_1 = asinh(objects_modern_year_1)
g p_objects_modern_year = (objects_modern_year/objects * 100)

* scale treatment variables
g d_socialh_scale = d_socialh * 10
gen d_socialh_per100 = d_socialh/100
gen sh_d_socialh_10pp = 10 * sh_d_socialh
gen sh_d_social_priv_10pp = (d_socialh / l.wohnungen)*10  // Share of social housing relative to preexisting housing stock

rename e_e pop
br objects_modern_year PLR_ID_num jahr c_dd_socialh

sum d_socialh if d_socialh>0 & a100_r == 1 & inrange(jahr, 2010, 2019)

drop F_*

xxx

* ================================================================================== *
**# = Estimation with did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020) = *
* ================================================================================== *

* Panel and sample
tsset PLR_ID_num jahr
keep if a100_r==1 & inrange(jahr,2010,2019)

* Ex-ante exposure: baseline stock in 2010
by PLR_ID_num (jahr): gen base2010 = socialh if jahr==2010
by PLR_ID_num: egen base2010_i = max(base2010)

* Intensity bins (median split; change nq() to 3 or 4 for terciles/quartiles)
xtile expo_bin = base2010_i, nq(2)

* 1) Name the bins and show the cutoff
quietly summarize base2010_i if !missing(base2010_i), detail
local med = r(p50)
label define expo 1 "Low exposure (<= `med' in 2010)" 2 "High exposure (> `med' in 2010)"
label values expo_bin expo

* 2) One row per unit to count units and summarize baseline stock
egen tag_i = tag(PLR_ID_num)

di as txt "Median baseline (2010) stock: " %9.0f `med'
tab expo_bin if tag_i                           // number of PLR_ID_num by bin
tabstat base2010_i if tag_i, by(expo_bin)      ///
    stats(N mean p25 p50 p75 min max)

* 3) Realized intensity (descriptive only): max cumulative loss per unit
by PLR_ID_num (jahr): gen loss_flow = max(L.socialh - socialh, 0)
by PLR_ID_num (jahr): gen loss_flow10 = max(L.socialh - socialh, 0)/10
by PLR_ID_num (jahr): gen loss_flow100 = max(L.socialh - socialh, 0)/100
by PLR_ID_num (jahr): gen cumloss100 = sum(loss_flow)/100
by PLR_ID_num: egen max_cumloss100_i = max(cumloss100)

* cumulative number of changes from c_dd_socialh
bysort PLR_ID_num (jahr): gen cum_changes = sum(c_dd_socialh)

tabstat max_cumloss100_i if tag_i, by(expo_bin) stats(N mean p50 p90 max)

br PLR_ID_num jahr c_dd_socialh cum_changes cumloss100 loss_flow100

* 4) How many actual switchers per bin (uses cumloss100 increments)
by PLR_ID_num (jahr): gen switched = (D.cumloss100 != 0)
by PLR_ID_num: egen ever_switch = max(switched)
tab expo_bin ever_switch if tag_i, row

* 5) Optional balance on pre-treatment covariates (2010)
tabstat ln_sqm_rent_avg ln_wohnungen if jahr==2010, by(expo_bin) stats(N mean sd)

* Run normalized event-study per bin (per 100 units)
forvalues b = 1/2 {
    di "=== Bin `b' (ex-ante exposure) ==="
    did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
        if expo_bin==`b', ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        cluster(PLR_ID_num)
}


xtile med_drop = d_socialh if d_socialh>0, nq(2)
replace med_drop = 0 if d_socialh == 0

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
    if a100_r==1 & inrange(jahr,2010,2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num)


did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
        if med_drop== 1 | med_drop== 0, ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        cluster(PLR_ID_num)


did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr sh_d_social_priv_10pp ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        cluster(PLR_ID_num)


did_multiplegt_dyn p_objects_modern_year PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

	
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr sh_d_social_priv_10pp ///
    if a100_r==1 & inrange( jahr, 2010, 2019 ), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr 		///
        sh_d_social_priv_10pp                         		///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3)   ///
        normalized continuous(1) cluster(PLR_ID_num)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr ///
        d_socialh_per100                         			///
        if a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) same_switchers

	
*========================================================*
**# == Continous Treatment - Rents ==#
*========================================================*
restore, preserve

postutil clear
	tempname P3
	postfile `P3' str15(treat) str15(ooi) ///
	double(	av_tot_eff  av_tot_eff_se ///
			N_obs 		joint_plac )  ///
	using "$output/postfiles/dcdh_con_beta_rents.dta", replace
	
*-------------------------------------------------------------------*
* 1.  Loop over each outcome and generate a post-file (in the loop) *
*-------------------------------------------------------------------*
foreach ooi in ln_qm_miete_kalt qm_miete_kalt {
	
	* absorbing treatment: when becoming one your are staying one forever
	did_multiplegt_dyn `ooi' PLR_ID_num jahr ///
        d_socialh_per100                         			///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) graph_off

	post `P3' ("`ooi'") ("d_socialh_per100") ///
	( e(Av_tot_effect) ) ( e(se_avg_total_effect) ) ///
	( e(N_avg_total_effect) ) ( e(p_jointplacebo) )

	did_multiplegt_dyn `ooi' PLR_ID_num jahr 		///
        sh_d_socialh_10pp                         		///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) graph_off
	
	post `P3' ("`ooi'") ("sh_d_socialh_10pp") ///
	( e(Av_tot_effect) ) ( e(se_avg_total_effect) ) ///
	( e(N_avg_total_effect) ) ( e(p_jointplacebo) )

	did_multiplegt_dyn `ooi' PLR_ID_num jahr 		///
        sh_d_social_priv_10pp                         		///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        normalized continuous(1) cluster(PLR_ID_num) graph_off

	post `P3' ("`ooi'") ("sh_d_social_priv_10pp") ///
	( e(Av_tot_effect) ) ( e(se_avg_total_effect) ) ///
	( e(N_avg_total_effect) ) ( e(p_jointplacebo) )

}

postclose `P3'

* load saved output

* Keep one specification (CHANGE this if you want the other)
keep if treat == "ln_qm_miete_kal"

* Keep only the three target OOIs that become columns
keep if inlist(ooi,"d_socialh_per10","sh_d_socialh_10","sh_d_social_pri")

* Map OOIs to final column names
gen str14 col = cond(ooi=="d_socialh_per10","d_socialh", ///
                 cond(ooi=="sh_d_socialh_10","sh_d_soc","sh_d_soc_priv"))

*----------------------------
* 2) P-values, stars, rounding
*----------------------------
gen double p_val = 2*(1 - normal(abs(av_tot_eff/av_tot_eff_se)))

gen byte sig_num = .
replace sig_num = 1 if p_val>0.05 & p_val<=0.10
replace sig_num = 2 if p_val>0.01 & p_val<=0.05
replace sig_num = 3 if p_val<=0.01

gen str3 stars = cond(sig_num==1,"*",cond(sig_num==2,"**",cond(sig_num==3,"***","")))

* Rounded display strings
gen str12 beta_r   = string(round(av_tot_eff,.01),     "%9.2f")
gen str12 se_r     = string(round(av_tot_eff_se,.001), "%9.3f")
gen str12 N_r      = string(N_obs,                     "%9.0f")
gen str12 joint_r  = string(round(joint_plac,.01),     "%9.2f")
gen str12 beta_fin = beta_r + stars

*----------------------------
* 3) Build rows and reshape
*----------------------------
tempfile beta star se n joint final

preserve
    keep col beta_r
    rename beta_r value
    gen str8 var = "beta"
    save `beta'
restore

preserve
    keep col sig_num
    tostring sig_num, replace
    rename sig_num value
    gen str8 var = "star"
    save `star'
restore

preserve
    keep col se_r
    rename se_r value
    gen str8 var = "se"
    save `se'
restore

preserve
    keep col N_r
    rename N_r value
    gen str8 var = "N"
    save `n'
restore

preserve
    keep col joint_r
    rename joint_r value
    gen str8 var = "joint_p"
    save `joint'
restore

preserve
    keep col beta_fin
    rename beta_fin value
    gen str8 var = "final"
    save `final'
restore

clear
use `beta'
append using `star' `se' `n' `joint' `final'

reshape wide value, i(var) j(col) string
rename (valued_socialh valuesh_d_soc valuesh_d_soc_priv) ///
       (d_socialh       sh_d_soc       sh_d_soc_priv)

order d_socialh sh_d_soc sh_d_soc_priv var
list, noobs sepby(var)

* drop rows 2 and 6 (star and final)
drop if inlist(var, "star", "beta")

* move N to the bottom
gen order = cond(var == "N", 99, _n)
sort order
drop order

list, noobs sepby(var)

order var d_socialh sh_d_soc sh_d_soc_priv


texsave * using "$output/max/tables/tab_dsdh_cont_ln_rent.tex", replace


*--------------------------------------------------------*
* 1.  Open ONE master post-file (before the loop)        *
*--------------------------------------------------------*
postutil clear
tempname P6
postfile `P6' str15(outcome)                            /// which Y
              str20(treat)                             /// which treatment
              double(                                  ///
                  av_tot_eff  av_tot_eff_se ///
				  N_obs joint_plac )  ///
    using "${output}/postfiles/dcdh_cont_all_beta.dta", replace

*-------------------------------
* Global with all outcomes
*-------------------------------
global ooi_list ///
    ln_pop ///
    ln_r1_ewa_a_gesamt ///
    ln_risk_high ///
    ln_risk_low ///
    ln_tot_sgb12_w ///
    ln_dau10 ///
    ln_dau5 ///
    pdau10 ///
    pdau5 ///
    psgb12_w ///
    total_unemployed_p ///
    asin_objects_modern_year ///
    p_objects_modern_year ///
    r1_met_deutschl_p ///
    r1_met_italien_p ///
    r1_met_tuerkei_p ///
    r1_met_griechen_p ///
    r1_met_spanport_p ///
    r1_met_balkan_p ///
    r1_met_osteurop_p ///
    r1_met_afrika_p ///
    r1_met_islam_p ///
    r1_met_asien_p ///
    r1_met_uebrige_p ///
    non_german_p ///
    east_europe_p ///
    south_europe_p ///
    guest_worker_p ///
    r1_mps_cabrio_p ///
    r1_mps_gelaende_p ///
    r1_mps_kleinwag_p ///
    r1_mps_miniwag_p ///
    r1_mps_kombi_p ///
    r1_mpa_elektro_p ///
    r1_mps_unmittel_p ///
    r1_mps_mittel_p ///
    r1_mps_obmittel_p ///
    r1_mps_ober_p

* (optional) count how many outcomes
local var_count : word count $ooi_list
display "Outcomes in list: `var_count'"

*--------------------------------------------------------*
* 2.  Loop over outcomes (and treatment, if you add more)*
*--------------------------------------------------------*
foreach ooi of global ooi_list {

	* absorbing treatment: when becoming one your are staying one forever
	did_multiplegt_dyn `ooi' PLR_ID_num jahr ///
        d_socialh_per100                         			///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) graph_off
	post `P6' ("`ooi'") ("d_socialh_per100") ///
	( e(Av_tot_effect) ) ( sqrt( e(se_avg_total_effect) ) ) ///
	( e(N_avg_total_effect) ) ( e(p_jointplacebo) )


	did_multiplegt_dyn `ooi' PLR_ID_num jahr 		///
        sh_d_socialh_10pp                         		///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        normalized continuous(1) cluster(PLR_ID_num) graph_off
	
	post `P6' ("`ooi'") ("sh_d_socialh_10pp") ///
	( e(Av_tot_effect) ) ( sqrt( e(se_avg_total_effect) ) ) ///
	( e(N_avg_total_effect) ) ( e(p_jointplacebo) )

	did_multiplegt_dyn `ooi' PLR_ID_num jahr 		///
        sh_d_social_priv_10pp                         		///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        normalized continuous(1) cluster(PLR_ID_num) graph_off

	post `P6' ("`ooi'") ("sh_d_social_priv_10pp") ///
	( e(Av_tot_effect) ) ( sqrt( e(se_avg_total_effect) ) ) ///
	( e(N_avg_total_effect) ) ( e(p_jointplacebo) )

}

postclose `P6'

use "${output}/postfiles/dcdh_cont_all_beta.dta", clear



*--------------------------------------------------------*
* 1.  Open ONE master post-file (before the loop)        *
*--------------------------------------------------------*
postutil clear
tempname P7
postfile `P7' str15(outcome)                            /// which Y
              str20(treat)                             /// which treatment
              double(                                  ///
                  d_ph_p0  d_ph_p0_se  d_ph_p1  d_ph_p1_se ///
                  d_ph_p2  d_ph_p2_se  d_ph_p3  d_ph_p3_se ///
                  d_ph_p4  d_ph_p4_se  d_ph_m1  d_ph_m1_se ///
                  d_ph_m2  d_ph_m2_se  d_ph_m3  d_ph_m3_se ///
                  d_ph_m4  d_ph_m4_se)                 ///
    using "${output}/postfiles/dcdh_cont_all_event.dta", replace

*-------------------------------
* Global with all outcomes
*-------------------------------
global ooi_list ///
    ln_pop ///
    ln_r1_ewa_a_gesamt ///
    ln_risk_high ///
    ln_risk_low ///
    ln_tot_sgb12_w ///
    ln_dau10 ///
    ln_dau5 ///
    pdau10 ///
    pdau5 ///
    psgb12_w ///
    total_unemployed_p ///
    asin_objects_modern_year ///
    p_objects_modern_year ///
    r1_met_deutschl_p ///
    r1_met_italien_p ///
    r1_met_tuerkei_p ///
    r1_met_griechen_p ///
    r1_met_spanport_p ///
    r1_met_balkan_p ///
    r1_met_osteurop_p ///
    r1_met_afrika_p ///
    r1_met_islam_p ///
    r1_met_asien_p ///
    r1_met_uebrige_p ///
    non_german_p ///
    east_europe_p ///
    south_europe_p ///
    guest_worker_p ///
    r1_mps_cabrio_p ///
    r1_mps_gelaende_p ///
    r1_mps_kleinwag_p ///
    r1_mps_miniwag_p ///
    r1_mps_kombi_p ///
    r1_mpa_elektro_p ///
    r1_mps_unmittel_p ///
    r1_mps_mittel_p ///
    r1_mps_obmittel_p ///
    r1_mps_ober_p

* (optional) count how many outcomes
local var_count : word count $ooi_list
display "Outcomes in list: `var_count'"

*--------------------------------------------------------*
* 2.  Loop over outcomes (and treatment, if you add more)*
*--------------------------------------------------------*
foreach ooi of global ooi_list {

	* absorbing treatment: when becoming one your are staying one forever
	did_multiplegt_dyn `ooi' PLR_ID_num jahr ///
        c_dd_socialh                         			///
        if a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) graph_off

	post `P7' ("`ooi'") ("c_dd_socialh") ///
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
        loss_flow100                         		///
        if a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        normalized continuous(1) cluster(PLR_ID_num) graph_off
	
	post `P7' ("`ooi'") ("loss_flow100") ///
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
        cumloss100                         		///
        if a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        normalized continuous(1) cluster(PLR_ID_num) graph_off

	post `P7' ("`ooi'") ("cumloss100") ///
	( e(estimates)[1, 1] ) ( sqrt(e(variances)[1, 1]) ) ///
	( e(estimates)[2, 1] ) ( sqrt(e(variances)[2, 1]) ) ///
	( e(estimates)[3, 1] ) ( sqrt(e(variances)[3, 1]) ) ///
	( e(estimates)[4, 1] ) ( sqrt(e(variances)[4, 1]) ) ///
	( e(estimates)[5, 1] ) ( sqrt(e(variances)[5, 1]) ) ///
	(0) (0) ///
	( e(estimates)[7, 1] ) ( sqrt(e(variances)[7, 1]) ) ///
	( e(estimates)[8, 1] ) ( sqrt(e(variances)[8, 1]) ) ///
	( e(estimates)[9, 1] ) ( sqrt(e(variances)[9, 1]) )
}

postclose `P7'

use "${output}/postfiles/dcdh_cont_all_event.dta", clear


*--------------------------------------------------------------------
* 1.  Give SE variables a parallel stub   ->  d_ph_m1_se → se_m1
*--------------------------------------------------------------------
quietly ds d_ph_*_se
foreach v of varlist `r(varlist)' {
    local base = subinstr("`v'", "_se", "", .)
    local stub = substr("`base'", 1, strlen("`base'") - 1)  // drop last char (m1,p0,…)
    local suf  = substr("`base'", -2, .)                    //   -> "m1","p0",…
    rename `v' se_`suf'
}

*--------------------------------------------------------------------
* 2.  Reshape to long
*--------------------------------------------------------------------
reshape long d_ph_ se_, i(outcome treat) j(time) string


*--------------------------------------------------------------------
* 3.  Clean names + confidence intervals
*--------------------------------------------------------------------
rename d_ph_  estimate
rename se_    se
generate double max90 = estimate + 1.78*se
generate double min90 = estimate - 1.78*se
generate double max95 = estimate + 1.96*se
generate double min95 = estimate - 1.96*se


* ------------------------------------------------------------------
* 4.  Create the numeric event-time index  (-4 … +4)
* ------------------------------------------------------------------
gen byte period = real(substr(time, -1, 1))      // 0,1,2,3,4
replace period = -period if substr(time, 1, 1)=="m"



* obtain outcome variable
gen reg = 1
replace reg = 2 if regexm(treat, "loss_flow100")
replace reg = 3 if regexm(treat, "cumloss100")

gen period_shift=period
replace period_shift = period - .2 if reg == 1
replace period_shift = period + .2 if reg == 3

* numeric id: 1,2,3,… for each distinct outcome
egen outcome_id = group(outcome), label
label var outcome_id "ID of outcome (from egen group)"

* numeric id: 1,2,3,… for each distinct outcome
egen treat_id = group(treat), label
label var treat_id "ID of treatment (from egen group)"

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

local var_count : word count $ooi_list


forvalues i = 1/`var_count' {
    local x : word `i' of $ooi_list
    di as txt "`x'"

twoway ///
(scatter estimate period_shift 	 if outcome_id == `i' & treat_id == 1, msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if outcome_id == `i' & treat_id == 1, lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if outcome_id == `i' & treat_id == 1, lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if outcome_id == `i' & treat_id == 3, msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if outcome_id == `i' & treat_id == 3, lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if outcome_id == `i' & treat_id == 3, lwidth($rspike_lwidth90) lcolor("`forest_green'%60")) ///
(scatter estimate period_shift 	 if outcome_id == `i' & treat_id == 2, msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if outcome_id == `i' & treat_id == 2, lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if outcome_id == `i' & treat_id == 2, lwidth($rspike_lwidth90) lcolor("`maroon'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order(1 "Dummy" 4 "Unit Change" 7 "Cumulative Change") pos(6) rows(1)) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/max/graphs/continous_treatment/dsdh/dcdh_cont_`x'.png", replace

}



























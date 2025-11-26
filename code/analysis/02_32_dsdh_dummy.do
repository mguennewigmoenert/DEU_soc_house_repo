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

/*
reghdfe ln_qm_miete_kalt L_2-L_5 F_0-F_5 if a100_r==1 & inrange(jahr, 2013, 2019) , absorb(PLR_ID jahr) cl(PLR_ID) nocons
coefplot, vertical
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
*/

* what is the sample
tab jahr if e(sample)

reghdfe ln_qm_miete_kalt L_t2_2-L_t2_5 F_t2_0-F_t2_5 if inrange(jahr, 2007, 2016) , absorb(PLR_ID jahr) cl(PLR_ID) nocons
coefplot, vertical
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
g risk_low      = r1_mri_risiko_1 + r1_mri_risiko_2 + r1_mri_risiko_3
g risk_med      = r1_mri_risiko_4 + r1_mri_risiko_5 + r1_mri_risiko_6
g risk_high     = r1_mri_risiko_7 + r1_mri_risiko_8 + r1_mri_risiko_9

g risk_low_high = risk_low/risk_high
g risk_p_high   = ( risk_high / r1_mba_a_haushalt * 100 )
g risk_p_med    = ( risk_med / r1_mba_a_haushalt * 100 )
g risk_p_low    = ( risk_low / r1_mba_a_haushalt * 100 )
g ln_risk_low   = ln( risk_low )
g ln_risk_high  = ln( risk_high )
g ln_risk_med   = ln( risk_high )

/*

did_multiplegt_dyn p_objects_modern_year	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen ) same_switchers


did_multiplegt_dyn risk_p_med	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen ) same_switchers

did_multiplegt_dyn risk_p_med	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen ) same_switchers weight( r1_ewa_a_gesamt )

did_multiplegt_dyn risk_p_high	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen ) ci_level(90) same_switchers

g risk_low_med = risk_low + risk_med

did_multiplegt_dyn risk_low_med	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen ) ci_level(90)
*/

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

* br d_socialh socialh sh_d_socialh

* 3) Realized intensity (descriptive only): max cumulative loss per unit
* annual flow of losses (only when stock falls)
by PLR_ID_num (jahr): gen loss_flow = max(L.socialh - socialh, 0)
by PLR_ID_num (jahr): gen loss_flow100 = max(L.socialh - socialh, 0)/100
* cumulative dose (absorbing); scale to "per 100 units"
by PLR_ID_num (jahr): gen cumloss100 = sum(loss_flow)/100
by PLR_ID_num: egen max_cumloss100_i = max(cumloss100)

rename e_e pop
* br objects_modern_year PLR_ID_num jahr c_dd_socialh

sum d_socialh if d_socialh>0 & a100_r == 1 & inrange(jahr, 2010, 2019)

preserve
xxx

* ================================================================================== *
**# = Estimation with did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020) = *
* ================================================================================== *

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) save_sample 
rename _effect _effect_1
rename _did_sample _did_sample_1

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) weight(objects) same_switchers save_sample

did_multiplegt_dyn ln_pop PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) same_switchers trends_lin


rename _effect _effect_2
rename _did_sample _did_sample_2

br ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh _effect_1 _effect_2 _did_sample_2


gen used_w_sw = e(sample)
by PLR_ID_num: egen group_used = max(used)

bysort PLR_ID_num: gen first = _n==1
count if group_used==1 & first

gen used_both = used==used_w_sw

keep if used == 1
br PLR_ID jahr c_dd_socialh ln_sqm_rent_avg used_both

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) design(1, console) weight(objects)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr d_socialh_per100 ///
    if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) same_switchers

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) same_switchers normalized
	

* Compares only units that start treatment in the same year to each other — not to earlier or later switchers.
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    same_switchers cluster(PLR_ID_num)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    normalized cluster(PLR_ID_num)


* run goodman bacon decomposition in case there are negative weights
* switcher option: give more weight to one 

g inve_share = 1-share
g share10 = share/10
g share_drop10 = -(share/10)          // +1 = 10 pp *fall*
g share_drop = -(share)          // +1 = 10 pp *fall*

g socialh10 = socialh/10
g socialh_drop10 = -(socialh/10)          // 10 unit *fall*
g socialh_drop100 = -(socialh/100)          // 100 unit *fall*
g socialh_drop = -(socialh)          // 100 unit *fall*

* Level of share used for up-jumps only
gen share10_up  = share10
gen share10_down = share10

* identify direction of the first difference
gen d_share10 = share10 - L.share10

br share_drop10 sh_d_socialh p_objects_modern_year PLR_ID_num jahr

* drop out the opposite cases
replace share10_up  = L.share10 if d_share10 <= 0      // stays flat over down periods
replace share10_down = L.share10 if d_share10 >= 0     // stays flat over up periods

tsset PLR_ID_num jahr


br cumloss100 tot_d_socialh sum_d_socialh jahr PLR_ID_num

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr cumloss100 ///
    if a100_r==1 & inrange(jahr,2010,2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    normalized continuous(1) same_switchers cluster(PLR_ID_num)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr cumloss100 ///
    if a100_r==1 & inrange(jahr,2010,2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    continuous(1) cluster(PLR_ID_num)


sum(c_dd_socialh)
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    cluster(PLR_ID_num) design(0.6, console)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if a100_r==1 & inrange(jahr, 2010, 2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) ///
    same_switchers cluster(PLR_ID_num) by_path(10)

	
	
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr ///
        tot_d_socialh                         		   ///
        if a100_r==1 & inrange(jahr, 2010, 2019),  ///
        effects(5) placebo(3)                      ///
        cluster(PLR_ID_num)
		
/* After spec-2 ran */
scalar b_cont = e(estimates)[1,1]          // slope per 1 unit
display "Dummy-implied effect: " 43*b_cont
/* Should match e(estimates)[1,1] from spec-3 */

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr 		///
        c_dd_socialh                      		///
        if a100_r==1 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num) weight(objects) normalized normalized_weights effects_equal("all")


did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr 		///
        d_socialh                      		///
        if a100_r==1 & d_socialh >=0 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr 		///
        d_socialh_per100                      		///
        if a100_r==1 & d_socialh >=0 & inrange(jahr, 2010, 2019),         ///
        effects(5) placebo(3) controls(ln_wohnungen)    ///
        cluster(PLR_ID_num)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr ///
        sh_d_socialh_scale           				///
        if a100_r==1 & d_socialh >=0 & inrange(jahr, 2010, 2019),   ///
        effects(5) placebo(3) 						///
        cluster(PLR_ID_num) 

* Example with did_multiplegt(_dyn)
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr ///
        c_dd_socialh           				///
        if a100_r==1 & d_socialh >=0 & inrange(jahr, 2010, 2019),   ///
        effects(5) ///
        cluster(PLR_ID_num)
		
did_multiplegt_dyn y id t treat, effects(5) over(groupvar) cluster(id)
* Then joint tests on leads/lags across groups (postestimation `test`/`lincom`)

* 
summ d_socialh if a100_r==1 & d_socialh>0 & inrange(jahr,2010,2019), detail
local med = r(p50)
display "Median of d_socialh_per100 = `med'"

gen high_treat = (d_socialh_per100 > `med') if !missing(d_socialh_per100)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr d_socialh_per100 ///
    if a100_r==1 & d_socialh>=0 & high_treat==0 & inrange(jahr,2010,2019), ///
    effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)
	
gen private_units = wohnungen - socialh          // if you have total stock
gen d_private     = private_units - L.private_units   // Δ private
gen d_social      = socialh      - L.socialh          // Δ social

* Recode so that a "drop" is positive
gen social_drop   = - (d_social) //  + when units exit
gen private_exp   =   d_private  //  + when new private built

did_multiplegt_dyn psgb12_w PLR_ID_num jahr 	 ///
        social_drop 								 /// 
		if a100_r==1 & inrange(jahr, 2010, 2019),    ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        continuous(1) cluster(PLR_ID_num)


did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr 	 ///
        private_exp     							 /// 
		if a100_r==1 & inrange(jahr, 2010, 2019),	 ///
        effects(5) placebo(3) ///
        continuous(1) cluster(PLR_ID_num)


did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr inve_share ///
if a100_r == 1 & inrange(jahr, 2010, 2015), ///
effects(5) placebo(3) controls(ln_wohnungen) continuous(1)

* aerage drop by tract
egen avg_d_socialh = mean(d_socialh), by(PLR_ID_num)

egen byte tag = tag(PLR_ID_num)
summ avg_d_socialh if a100_r==1 & avg_d_socialh != 0 & avg_d_socialh> 0 &  tag, detail

did_multiplegt_dyn r1_pop_hh PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

did_multiplegt_dyn sqm_rent_avg PLR_ID_num jahr c_dd_socialh if ( avg_d_socialh == 0 | avg_d_socialh < 19.25 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num) ci_level(90)

did_multiplegt_dyn sqm_rent_avg PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) design(1, "console")  controls(ln_wohnungen) cluster(PLR_ID_num) only_never_switchers

did_multiplegt_dyn sqm_rent_avg PLR_ID_num jahr c_dd_socialh, effects(5) placebo(3) ///
    design(1, "console")            // or design(0.5,"/path/paths.xlsx")

	* 0) panel order
sort PLR_ID_num jahr

* 1) First switch date F_g (year when D first equals 1)
bys PLR_ID_num (jahr): gen byte switched = c_dd_socialh==1
bys PLR_ID_num (jahr): egen F = min(cond(switched, jahr, .))

* 2) Status at horizons ℓ = 1..5 (status at year F-1+ℓ)
forvalues l = 1/5 {
    gen byte D_l`l' = .
    by PLR_ID_num (jahr): replace D_l`l' = c_dd_socialh if jahr == F - 1 + `l'
}

* 3) Encode the 5-period treatment path (e.g. 10000, 11111, 10101, …)
egen path5 = group(D_l1 D_l2 D_l3 D_l4 D_l5), label
label list path5   // see the mapping

* Keep one row per group just to inspect counts (optional)
bys PLR_ID_num: gen byte tag = _n==1
tab path5 if tag

* 4) Re-estimate effects separately by path
levelsof path5 if tag, local(paths)
foreach p of local paths {
    di as txt "=== Path " as res `p' as txt " (" `"`: label (path5) `p''"' ") ==="
    did_multiplegt_dyn sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
        if path5==`p', effects(5) placebo(3) cluster(PLR_ID_num)
    * store/export as needed
}

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh, effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num) design(0.5, console)

did_multiplegt_dyn sqm_rent_avg PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

did_multiplegt_dyn r1_mpi_w_dichte_hh PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

* cars
did_multiplegt_dyn p_objects_modern_year PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num) weight(objects) same_switchers

did_multiplegt_dyn ln_r1_mps_mittel PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster( PLR_ID_num )

did_multiplegt_dyn ln_r1_mps_obmittel PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

did_multiplegt_dyn ln_r1_mps_ober PLR_ID_num jahr c_dd_socialh if d_socialh>=0 & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

did_multiplegt_dyn ln_r1_mpa_elektro PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )

did_multiplegt_dyn ln_r1_mba_a_gewerbe	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) ci_level(90) 

d_socialh sh_d_socialh

* rents
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )
did_multiplegt_dyn ln_sqm_rent_med PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )
did_multiplegt_dyn ln_sqm_rent_p25 PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )
did_multiplegt_dyn ln_sqm_rent_p75 PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )


* absorbing treatment: when becoming one your are staying one forever
did_multiplegt_dyn r1_mso_p_paare    PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( wohnungen )
did_multiplegt_dyn r1_mso_p_familien PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( wohnungen )
did_multiplegt_dyn r1_mso_singles  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( wohnungen )
did_multiplegt_dyn r1_mso_p_ausland  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( wohnungen )

* absorbing treatment: when becoming one your are staying one forever
did_multiplegt_dyn ln_r1_mpa_elektro PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )
did_multiplegt_dyn r1_mpa_elektro_p PLR_ID_num  jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls( ln_wohnungen )

did_multiplegt_dyn r1_kkr_w_summe PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2023), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn total_unemployed_p PLR_ID_num jahr c_dd_socialh if d_socialh >= 0 & a100_r == 1 & inrange(jahr, 2010, 2023), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) weight(r1_ewa_a_gesamt)

did_multiplegt_dyn ln_sqm_rent_hed_med	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2023), effects(5) placebo(3) cluster(PLR_ID_num) controls( wohnungen )

did_multiplegt_dyn r1_pop_hh PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2023), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn r1_alq_p_quote	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2023), effects(5) placebo(3) cluster(PLR_ID_num) controls( wohnungen )

did_multiplegt_dyn r1_met_p_deutschl PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn r1_met_p_islam 	 PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn r1_met_p_italien  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn r1_met_p_tuerkei  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn working_age_pop	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) ci_level(90)
did_multiplegt_dyn working_age_pop	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) ci_level(90)

did_multiplegt_dyn ln_pop	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) ci_level(90)
did_multiplegt_dyn ln_r1_ewa_a_gesamt	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) ci_level(90)

summarize pop r1_ewa_a_gesamt if a100_r == 1 & inrange(jahr, 2010, 2019)

corr pop r1_ewa_a_gesamt

gen diff = pop - r1_ewa_a_gesamt
summ diff if a100_r == 1 & inrange(jahr, 2010, 2019)

count if pop==0 | pop==.
count if r1_ewa_a_gesamt==0 | r1_ewa_a_gesamt==.

br PLR_ID_num jahr pop r1_ewa_a_gesamt if a100_r == 1 & inrange(jahr, 2010, 2019)

br r1_ewa_a_gesamt if r1_id =="4549_3272" | r1_id =="4549_3271"

4549_3272 4549_3271

non_german east_europe south_europe guest_worker ln_risk_low ln_risk_high

did_multiplegt_dyn risk_p_high PLR_ID_num jahr c_dd_socialh ///
        if d_socialh >= 0 & a100_r==1 & inrange(jahr,2010,2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        trends_nonparam(jahr) cluster(PLR_ID_num)


did_multiplegt_dyn mobile_high PLR_ID_num jahr c_dd_socialh ///
        if a100_r==1 & inrange(jahr, 2010, 2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        cluster(PLR_ID_num)


did_multiplegt_dyn r1_alq_p_quote	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) ci(90)

did_multiplegt_dyn ln_r1_kkr_pop	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn r1_ewa_a_gesamt PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn r1_mba_a_haushalt PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

r1_mba_a_haushalt

* credit risk per household
did_multiplegt_dyn risk_low_high	  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn risk_p_low	  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

g s_risk_high = risk_high /r1_ewa_a_gesamt
g s_risk_low = risk_low /r1_ewa_a_gesamt


did_multiplegt_dyn s_risk_high	  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn s_risk_low	  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn s_risk_low	  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn ln_risk_high	  PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) 



did_multiplegt_dyn psgb12_w	PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn total_unemployed_p	PLR_ID_num jahr sh_d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)


did_multiplegt_dyn ln_tot_sgb12_w PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn ln_total_unemployed PLR_ID_num jahr sh_d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) same_switchers

did_multiplegt_dyn r1_mba_a_gewerbe PLR_ID_num jahr sh_d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn ln_dau5 PLR_ID_num jahr d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn ln_dau5	PLR_ID_num jahr sh_d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn pdau10 PLR_ID_num jahr d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn pdau5 PLR_ID_num jahr sh_d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn ln_dau10 PLR_ID_num jahr d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn ln_dau10 PLR_ID_num jahr sh_d_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

g risk_low_high = risk_low/risk_high

g ln_risk_low = ln(risk_low + 1)
g ln_risk_high = ln(risk_high + 1)

did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn ln_risk_low PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)
did_multiplegt_dyn ln_risk_high PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen)

did_multiplegt_dyn ratio_5to10 PLR_ID_num jahr d_socialh    if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) trends_nonparam(jahr)
did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), normalized effects(5) placebo(3) cluster(PLR_ID_num) trends_nonparam(jahr) controls(ln_wohnungen)

did_multiplegt_dyn ln_qm_miete_kalt PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) by_path(5)


g pdau5 = dau5/e_e
g pdau10 = dau10/e_e


g sgb12_tot =(sgb12_w / 100) * e_e

*========================================================*
**# == Section: Rent Outcomes + Robustness ==#
*========================================================*

*--------------------------------------------------------*
* 1.  Open ONE master post-file (before the loop)        *
*--------------------------------------------------------*
postutil clear
tempname P1
postfile `P1' str15(outcome)                            	/// which Y
              str20(treat)                             		/// which treatment
			  double(a100)									/// A100 Dummy
              double(                                  		///
                  d_ph_p0  d_ph_p0_se d_avg_p0 d_ph_p1  d_ph_p1_se d_avg_p1 ///
                  d_ph_p2  d_ph_p2_se d_avg_p2 d_ph_p3  d_ph_p3_se d_avg_p3 ///
                  d_ph_p4  d_ph_p4_se d_avg_p4 d_ph_m1  d_ph_m1_se d_avg_m1 ///
                  d_ph_m2  d_ph_m2_se d_avg_m2 d_ph_m3  d_ph_m3_se d_avg_m3 ///
                  d_ph_m4  d_ph_m4_se d_avg_m4 ) ///
    using "${output}/postfiles/dcdh_rent.dta", replace


*--------------------------------------------------------*
* 2.  Loop over outcomes (and treatment, if you add more)*
*--------------------------------------------------------*
foreach ooi in ln_sqm_rent_avg ln_sqm_rent_med 		///
				ln_sqm_rent_p25 ln_sqm_rent_p75{ 	///

    *— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh 	///
        if a100_r == 1 & inrange(jahr, 2010, 2019), 			///
        effects(5) placebo(3) controls(ln_wohnungen) 		///
        trends_nonparam(jahr) cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("base") (1)					///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0)	///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0)	///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0)	///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)

	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange(jahr, 2010, 2019),           ///
        effects(5) placebo(3) controls(ln_wohnungen)      ///
        same_switchers cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("same_switchers") 	(1)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange(jahr, 2010, 2019),           ///
        effects(5) placebo(3) controls(ln_wohnungen)      ///
        same_switchers weight( objects ) cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("same_switchers_w") 	(1)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange(jahr, 2010, 2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        same_switchers normalized cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("normalized") 	(1)			  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange(jahr, 2010, 2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        only_never_switchers cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("only_never_switchers")	(1)	  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		
		*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange(jahr, 2010, 2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        weight( objects ) cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("weighted") 	(1)			  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
	
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh 	///
        if a100_r == 0 & inrange(jahr, 2010, 2019), 			///
        effects(5) placebo(3) controls(ln_wohnungen) 		///
        trends_nonparam(jahr) cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("base") (0)					///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
			*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 0 & inrange(jahr, 2010, 2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        weight( objects ) cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("weighted") 	(0)			  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 0 & inrange(jahr, 2010, 2019),       ///
        effects(5) placebo(3) controls(ln_wohnungen)      ///
        same_switchers cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("same_switchers") 	(0)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh 	///
        if a100_r == 0 & inrange(jahr, 2010, 2019), 		///
        effects(5) placebo(3) controls(ln_wohnungen) 		///
        same_switchers normalized cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("normalized") 	(0)			  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
	
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 0 & inrange(jahr, 2010, 2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        only_never_switchers cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P1' ("`ooi'") ("only_never_switchers")	(0)	  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) (e(Av_tot_effect)) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) (e(Av_tot_effect)) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) (e(Av_tot_effect)) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) (e(Av_tot_effect)) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) (e(Av_tot_effect)) ///
        (0) (0)                                       (0) ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) (0) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) (0) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1])) (0)
		
}

*--------------------------------------------------------*
* 3.  Close the post-file (after the loop)               *
**# Bookmark #1
*--------------------------------------------------------*
postclose `P1'

preserve

use "$output/postfiles/dcdh_rent", clear

*--- 1. Give SE variables a clean, parallel stub --------------------------------
local times m4 m3 m2 m1 p0 p1 p2 p3 p4
foreach t of local times {
    rename d_ph_`t'_se   se_`t'     // d_ph_m1_se  ->  se_m1
}

*--- 2. Reshape both stubs at once ----------------------------------------------
reshape long d_ph_ se_ d_avg_, i(outcome treat a100) j(time) string


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

* Compute mean d_avg_ for post period by outcome
bys outcome treat a100: egen d_post_avg = mean(cond(period>=0, estimate, .))

* obtain outcome variable
gen reg = 1
replace reg = 2 if regexm(outcome, "ln_sqm_rent_med")
replace reg = 3 if regexm(outcome, "ln_sqm_rent_p25")
replace reg = 4 if regexm(outcome, "ln_sqm_rent_p75")

gen period_shift = period
replace period_shift = period - .3 if reg == 1
replace period_shift = period - .1 if reg == 2
replace period_shift = period + .1 if reg == 3
replace period_shift = period + .3 if reg == 4

gen period_shift2 = period
replace period_shift2 = period - .1 if treat == "same_switch"
replace period_shift2 = period + .1 if treat == "normalized"


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
(scatter estimate period_shift 	 if reg == 1 & a100 == 1 & treat == "base", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 1 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg == 1 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg == 2 & a100 == 1 & treat == "base", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 2 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg == 2 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period_shift 	 if reg == 3 & a100 == 1 & treat == "base", msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 3 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if reg == 3 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`forest_green'%60")) ///
(scatter estimate period_shift 	 if reg == 4 & a100 == 1 & treat == "base", msymbol(o) mcolor("`dkorange'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 4 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`dkorange'%60")) ///
(rspike min90 max90 period_shift if reg == 4 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`dkorange'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "log(Ø rent)" 4 "log(med rent)" 7 "log(25p rent)" 10 "log(75p rent)" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_base_inA100.png", replace


colorpalette s2, locals

twoway ///
(scatter estimate period_shift 	 if reg == 2 & a100 == 1 & treat == "base", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 2 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg == 2 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg == 3 & a100 == 1 & treat == "base", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 3 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg == 3 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period_shift 	 if reg == 4 & a100 == 1 & treat == "base", msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 4 & a100 == 1 & treat == "base", lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if reg == 4 & a100 == 1 & treat == "base", lwidth($rspike_lwidth90) lcolor("`forest_green'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "log(med rent)" 4 "log(25p rent)" 7 "log(75p rent)" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_alt_switch_inA100.png", replace

colorpalette s2, locals

twoway ///
(scatter estimate period_shift 	 if reg == 1 & a100 == 0 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 1 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg == 1 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg == 2 & a100 == 0 & treat == "same_switchers", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 2 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg == 2 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period_shift 	 if reg == 3 & a100 == 0 & treat == "same_switchers", msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 3 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if reg == 3 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`forest_green'%60")) ///
(scatter estimate period_shift 	 if reg == 4 & a100 == 0 & treat == "same_switchers", msymbol(o) mcolor("`dkorange'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 4 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`dkorange'%60")) ///
(rspike min90 max90 period_shift if reg == 4 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`dkorange'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "log(Ø rent)" 4 "log(med rent)" 7 "log(25p rent)" 10 "log(75p rent)" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_base_outA100.png", replace


colorpalette s2, locals

twoway ///
(scatter estimate period_shift2   if reg == 1 & a100 == 1 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift2 if reg == 1 & a100 == 1 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift2 if reg == 1 & a100 == 1 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend( off ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(-0.04(0.02)0.07, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_switch_inA100.png", replace

colorpalette s2, locals

twoway ///
(scatter estimate period_shift2   if reg == 1 & a100 == 0 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift2 if reg == 1 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift2 if reg == 1 & a100 == 0 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend( off ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_switch_outA100.png", replace

colorpalette s2, locals

twoway ///
(scatter estimate period_shift2   if reg == 1 & a100 == 1 & treat == "only_never_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift2 if reg == 1 & a100 == 1 & treat == "only_never_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift2 if reg == 1 & a100 == 1 & treat == "only_never_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(line d_avg_ period_shift2        if reg == 1 & a100 == 1 & treat == "only_never_switchers", sort lpattern(dot) lcolor(gs8)), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "Only Never Treated" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_never_treat_inA100.png", replace

colorpalette s2, locals

twoway ///
(scatter estimate period_shift2   if reg == 1 & a100 == 0 & treat == "only_never_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift2 if reg == 1 & a100 == 0 & treat == "only_never_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift2 if reg == 1 & a100 == 0 & treat == "only_never_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "Only Never Treated" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_never_treat_outA100.png", replace


colorpalette s2, locals

twoway ///
(scatter estimate period_shift2 	if reg == 1 & a100 == 1 & treat == "weighted", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift2 	if reg == 1 & a100 == 1 & treat == "weighted", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift2 	if reg == 1 & a100 == 1 & treat == "weighted", lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "Weighted" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_weight_inA100.png", replace

colorpalette s2, locals

twoway ///
(scatter estimate period_shift2 	if reg == 1 & a100 == 0 & treat == "weighted", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift2 	if reg == 1 & a100 == 0 & treat == "weighted", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift2 	if reg == 1 & a100 == 0 & treat == "weighted", lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "Weighted" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/rent/dcdh_rent_weight_outA100.png", replace

*========================================================*
**# == Section: Rent Outcomes + By Treatment Path ==#
*========================================================*

*--------------------------------------------------------*
* 1.  Open ONE master post-file (before the loop)        *
*--------------------------------------------------------*
* 1. Sort & keep core sample
sort PLR_ID_num jahr
keep if inrange(jahr, 2010, 2019)

* First treatment year F
gen switched = (c_dd_socialh==1)
bys PLR_ID_num: egen F = min(cond(switched==1, jahr, .))

* Event time
gen event_time = jahr - F

* Compute unit-level 5-year treatment path
forvalues l = 1/5 {
    by PLR_ID_num: egen D_l`l' = max(cond(event_time==`= `l'-1', c_dd_socialh, .))
    replace D_l`l' = 0 if missing(D_l`l')
}

* Encode 5-year path (constant within unit)
egen path5 = group(D_l1 D_l2 D_l3 D_l4 D_l5), label
label list path5

* Keep one row per group just to inspect counts (optional)
bys PLR_ID_num: gen byte tag = _n==1
tab path5 if tag

* 4) Re-estimate effects separately by path
levelsof path5 if tag, local(paths)

* view most common treatment path
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) design(1, console)
did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh if a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) by_path(4)

*--------------------------------------------------------*
* 2.  Loop over outcomes (and treatment, if you add more)*
*--------------------------------------------------------*
postutil clear
tempname P2

postfile `P2' str15(outcome) str10(path) double(groups)	///
				double(				///
						d_p0  se_p0 ///
						d_p1  se_p1 ///
						d_p2  se_p2 ///
						d_p3  se_p3 ///
						d_p4  se_p4 ///
						d_m1  se_m1 ///
						d_m2  se_m2 ///
						d_m3  se_m3 ///
						d_m4  se_m4) ///
using "${output}/postfiles/dyn_paths_ln_rent.dta", replace

	did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if ( path5 == 2  | path5 == 1 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) graph_off
	
    post `P2' ("ln_sqm_rent_avg") ("10000") (19)	  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))

	did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if ( path5 == 17  | path5 == 1 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) graph_off
	
	post `P2' ("ln_sqm_rent_avg") ("11111") (15)	  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))

	did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if ( path5 == 6  | path5 == 1 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) graph_off
	
	post `P2' ("ln_sqm_rent_avg") ("10100") (7)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))
	
	did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if ( path5 == 12  | path5 == 1 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) graph_off
	
	post `P2' ("ln_sqm_rent_avg") ("11010") (6)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))

	did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if ( path5 == 3  | path5 == 1 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) graph_off
	
	post `P2' ("ln_sqm_rent_avg") ("10001") (6)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))

	did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh ///
	if ( path5 == 11  | path5 == 1 ) & a100_r == 1 & inrange(jahr, 2010, 2019), effects(5) placebo(3) cluster(PLR_ID_num) controls(ln_wohnungen) graph_off
	
	post `P2' ("ln_sqm_rent_avg") ("11001") (5)		  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))

*--------------------------------------------------------*
* 3.  Close the post-file (after the loop)               *
*--------------------------------------------------------*
postclose `P2'

preserve

*--------------------------------------------------------*
* 4.  Close the post-file (after the loop)               *
*--------------------------------------------------------*
use "$output/postfiles/dyn_paths_ln_rent", clear

*--- 1. Reshape both stubs at once ----------------------------------------------
reshape long d_ se_, i(outcome path groups) j(time) string

*--- 3. Tidy variable names ------------------------------------------------------
rename d_  estimate
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

* obtain outcome variable
gen reg = 1
replace reg = 2 if regexm(outcome, "ln_sqm_rent_med")
replace reg = 3 if regexm(outcome, "ln_sqm_rent_p25")
replace reg = 4 if regexm(outcome, "ln_sqm_rent_p75")

gen period_shift = period
replace period_shift = period - .3 if reg == 1
replace period_shift = period - .1 if reg == 2
replace period_shift = period + .1 if reg == 3
replace period_shift = period + .3 if reg == 4

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

* generate order variable
g graph_order = .
replace graph_order = 1 if strpos(path, "10000")
replace graph_order = 2 if strpos(path, "11111")
replace graph_order = 3 if strpos(path, "10100")
replace graph_order = 4 if strpos(path, "11010")
replace graph_order = 5 if strpos(path, "10001")
replace graph_order = 6 if strpos(path, "11001")

* change labels
label define graphlbl 1 "10000" 2 "11111" 3 "10100" 4 "11010" 5 "10001" 6 "11001"
label values graph_order graphlbl

colorpalette s2, locals

twoway ///
(scatter estimate period_shift 	 if reg == 1, msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg == 1, lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg == 1, lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
by( graph_order, cols(3) title( "" , size( medsmall ) ) yrescale graphregion( color( white ) ) legend( off ) note("") ) ///
xtitle("Years since Treatment")
 
graph export "$output/max/graphs/dsdh/dcdh_rent_path.png", replace

*========================================================*
**# == SECTION: Non Rent Outcomes ==#
*========================================================*
restore, preserve

*--------------------------------------------------------*
* 1.  Open ONE master post-file (before the loop)        *
*--------------------------------------------------------*
postutil clear
tempname P3
postfile `P3' str15(outcome)                            /// which Y
              str20(treat)                             /// which treatment
              double(                                  ///
                  d_ph_p0  d_ph_p0_se  d_ph_p1  d_ph_p1_se ///
                  d_ph_p2  d_ph_p2_se  d_ph_p3  d_ph_p3_se ///
                  d_ph_p4  d_ph_p4_se  d_ph_m1  d_ph_m1_se ///
                  d_ph_m2  d_ph_m2_se  d_ph_m3  d_ph_m3_se ///
                  d_ph_m4  d_ph_m4_se)                 ///
    using "${output}/postfiles/dcdh_non_rent.dta", replace

*--------------------------------------------------------*
* 2.  Loop over outcomes (and treatment, if you add more)*
*--------------------------------------------------------*
foreach ooi in ln_pop ///
				ln_r1_ewa_a_gesamt ///
				risk_p_high ///
				risk_p_med ///
				risk_p_low ///
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
				r1_mps_ober_p { ///
	
	local ooi risk_p_med
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r==1 & inrange(jahr,2010,2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        cluster(PLR_ID_num) same_switchers

    *— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r==1 & inrange(jahr,2010,2019), ///
        effects(5) placebo(3) controls(ln_wohnungen) ///
        cluster(PLR_ID_num) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P3' ("`ooi'") ("base") 			  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1]))       ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))

	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange( jahr, 2010, 2019 ), ///
        effects( 5 ) placebo( 3 ) controls( ln_wohnungen ) ///
        same_switchers cluster( PLR_ID_num ) graph_off

	*— build list of coeff & se to post —----------------------------*
    post `P3' ("`ooi'") ("same_switchers") 			  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))
		
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange( jahr, 2010, 2019 ), ///
        effects( 5 ) placebo( 3 ) controls( ln_wohnungen ) ///
        same_switchers normalized cluster( PLR_ID_num ) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P3' ("`ooi'") ("normalized") 				  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))
		
	*— estimation —--------------------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange( jahr, 2010, 2019 ), ///
        effects( 5 ) placebo( 3 ) controls( ln_wohnungen ) ///
        only_never_switchers cluster( PLR_ID_num ) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P3' ("`ooi'") ("only_never_switchers") 				  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))
	

	*----------- choose weight variable ------------------------------*
    local wvar r1_ewa_a_gesamt
    if inlist("`ooi'","asin_objects_modern_year","p_objects_modern_year") {
        local wvar objects
    }

	*— estimation with weights —-------------------------------------*
    did_multiplegt_dyn `ooi' PLR_ID_num jahr c_dd_socialh ///
        if a100_r == 1 & inrange( jahr, 2010, 2019 ), ///
        effects( 5 ) placebo( 3 ) controls( ln_wohnungen ) ///
        weight(`wvar') cluster( PLR_ID_num ) graph_off

    *— build list of coeff & se to post —----------------------------*
    post `P3' ("`ooi'") ("weighted")  ///
        (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
        (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
        (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
        (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
        (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
        (0) (0)                                       ///
        (e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
        (e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
        (e(estimates)[9,1]) (sqrt(e(variances)[9,1]))
    *— append one row —---------------------------------------------*
    * post `P3' ("`ooi'") ("c_dd_socialh") `postlist'
}

*--------------------------------------------------------*
* 3.  Close the post-file (after the loop)               *
*--------------------------------------------------------*
postclose `P3'

*--------------------------------------------------------------------
* 0.  Load the combined post-file
*--------------------------------------------------------------------
use "$output/postfiles/dcdh_non_rent", clear

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

*--------------------------------------------------------------------
* 5.  Map `outcome` names to numeric reg codes with one lookup table
*--------------------------------------------------------------------
egen byte reg = group(outcome), label      // 1,2,3,…
gen double period_shift = period * 10           // start with raw event time

/*
note regressions labels
1 asin_objects_modern_year
10 p_objects_modern_year
35 risk_p_high
36 risk_p_low
37 risk_p_med
38 
*/

* TEST
local reg 7


colorpalette s2, locals
twoway ///
(scatter estimate period 	 if reg==`reg' & treat == "same_switchers", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period if reg==`reg' & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period if reg==`reg' & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`maroon'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend( off ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xlabel(`xl', labsize($xlab_size)) ///
xsize($x_size) ysize($y_size)

local reg 7

colorpalette s2, locals
twoway ///
(scatter estimate period 	 if reg==`reg' & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period if reg==`reg' & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period if reg==`reg' & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period 	 if reg==`reg' & treat == "weighted", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period if reg==`reg' & treat == "weighted", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period if reg==`reg' & treat == "weighted", lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period 	 if reg==`reg' & treat == "base", msymbol(o) mcolor("`dkorange'%60") msize($msize_size)) ///
(rspike min95 max95 period if reg==`reg' & treat == "base", lwidth($rspike_lwidth95) lcolor("`dkorange'%60")) ///
(rspike min90 max90 period if reg==`reg' & treat == "base", lwidth($rspike_lwidth90) lcolor("`dkorange'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend( off ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xlabel(`xl', labsize($xlab_size)) ///
xsize($x_size) ysize($y_size)


* adjust for high and low risk
replace period_shift = period_shift - 1  if reg == 6 // pop berlin
replace period_shift = period_shift + 1  if reg == 7 // pop RWI

* population
replace period_shift = period_shift - 1  if reg == 35 // low risk
replace period_shift = period_shift + 1  if reg == 36 // high risk

* unemployed
replace period_shift = period_shift - 1  if reg == 13 // SGB12
replace period_shift = period_shift + 1  if reg == 39 // Unemployed

* (1) East Europe= Balkan+East Europe;  (2) Southern Europe = Griechen, SpanPort, Italy, (3) Afrika; (4) Asia, (5) Turkey, (6) Arabic, (7) German;  (drop other) 
* replace period_shift = period_shift - 1.5  	if reg == 37 // South Europe
replace period_shift = period_shift - 1  	if reg == 19 // German
replace period_shift = period_shift -  .5	if reg == 2 // East Europe
replace period_shift = period_shift +  .5  	if reg == 19 // German
replace period_shift = period_shift + 0. 	if reg == 16 // Afrika
replace period_shift = period_shift +  .5   if reg == 25 // Turkey
replace period_shift = period_shift + 1    	if reg == 21 // Arabic
replace period_shift = period_shift + 1.5  	if reg == 17 // Asia

replace period_shift = period_shift - 1  	if reg == 11 // non-German

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

local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10  "1"  20  "2"  30  "3"  40 "4"
* Population
twoway ///
(scatter estimate period_shift 	 if reg==10 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==10 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg==10 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-40(10)40, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend( off ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xlabel(`xl', labsize($xlab_size)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/renovation/dcdh_p_renov.png", replace

colorpalette s2, locals

global x_size 14cm
global y_size 11cm

local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10  "1"  20  "2"  30  "3"  40 "4"
* Population
twoway ///
(scatter estimate period_shift 	 if reg==6 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==6 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg==6 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg==7 & treat == "same_switchers", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==7 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg==7 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`maroon'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-40(10)40, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "ODB" 4 "RWI" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xlabel(`xl', labsize($xlab_size)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/pop/dcdh_ln_pop.png", replace

colorpalette s2, locals

*  x-axis ticks at data –40 –30 … 40 but labelled –4 … 4
local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10  "1"  20  "2"  30  "3"  40 "4"

global x_size 14cm
global y_size 11cm

twoway ///
(scatter estimate period_shift 	 if reg==35 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==35 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg==35 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg==37 & treat == "same_switchers", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==37 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg==37 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period_shift 	 if reg==36 & treat == "same_switchers", msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==36 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if reg==36 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`forest_green'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1  "% High Risk" 4 "% Med Risk" 7 "% Low Risk") row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(zero)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
xlabel(`xl', labsize($xlab_size)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/risk/dcdh_risk_rwi.png", replace


colorpalette s2, locals

local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10  "1"  20  "2"  30  "3"  40 "4"
* Population
twoway ///
(scatter estimate period_shift 	 if reg==13 & treat == "same_switchers", msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==13 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg==13 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg==39 & treat == "same_switchers", msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==39 & treat == "same_switchers", lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg==39 & treat == "same_switchers", lwidth($rspike_lwidth90) lcolor("`maroon'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-40(10)40, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "SGB12" 4 "Unemployed" ) row(1) pos(6) ) ///
ytitle("percentage points", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(-.45(.1).35, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xlabel(`xl', labsize($xlab_size)) ///
xsize($x_size) ysize($y_size)

graph export "$output/graphs/pop/dcdh_unemp.png", replace

colorpalette s2, locals

*  x-axis ticks at data –40 –30 … 40 but labelled –4 … 4
local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10  "1"  20  "2"  30  "3"  40 "4"
global x_size 14cm
global y_size 10cm

twoway ///
(scatter estimate period_shift 	 if reg==19, msymbol(o) mcolor("`navy'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==19, lwidth($rspike_lwidth95) lcolor("`navy'%60")) ///
(rspike min90 max90 period_shift if reg==19, lwidth($rspike_lwidth90) lcolor("`navy'%60")) ///
(scatter estimate period_shift 	 if reg==3, msymbol(o) mcolor("`maroon'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==3, lwidth($rspike_lwidth95) lcolor("`maroon'%60")) ///
(rspike min90 max90 period_shift if reg==3, lwidth($rspike_lwidth90) lcolor("`maroon'%60")) ///
(scatter estimate period_shift 	 if reg==11, msymbol(o) mcolor("`forest_green'%60") msize($msize_size)) ///
(rspike min95 max95 period_shift if reg==11, lwidth($rspike_lwidth95) lcolor("`forest_green'%60")) ///
(rspike min90 max90 period_shift if reg==11, lwidth($rspike_lwidth90) lcolor("`forest_green'%60")), ///
yline(0, lpattern(dash) lcolor(gs8)) xlabel(-4(1)4, labsize($xlab_size) ) ///
graphregion(color(white) lcolor(white) margin(l-3 r+1)) scale(0.9) ///
legend(order( 1 "German" 4 "Guest Workers" 7 "Non-German" ) row(1) pos(6) ) ///
ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
xtitle($x_titel, size($xtitle_size) margin(medium)) ///
ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
xlabel(`xl', labsize($xlab_size)) ///
xsize($x_size) ysize($y_size)

graph export "$output/max/graphs/dsdh/dcdh_guest.png", replace

**# Figure Racial composition
/*****************************************************************
* 1.  COLOURS – 7 explicit scheme-s2 colours, 60 % opacity       *
*****************************************************************/
local colist navy%60 maroon%60 forest_green%60 dkorange%60 teal%60 sienna%60 emidblue%60

label define REG                                         ///
    37  "South Europe"  ///
     2  "East Europe"   ///
    16  "Africa"        ///
    17  "Asia"          ///
    25  "Turkey"        ///
    21  "Arabic"        ///
    19  "German", modify   // "modify" keeps any old labels

label values reg REG      // attach the label set to variable reg

/*****************************************************************
* 2.  BUILD LAYERS & LEGEND  (reg = 2 16 17 19 21 25 37)         *
*****************************************************************/
local graphcmd  ""
local legorder  ""
local i   1
local L   1        // scatter layer index

foreach r in 37 19 2 16 17 21 25 {

    local col : word `i' of `colist'
    local lab : label (reg) `r'
    if "`lab'"=="" local lab = "reg`r'"

    local graphcmd `graphcmd' ///
        ( scatter estimate period_shift if reg==`r', ///
            msymbol(o)  mcolor( "`col'" )  msize( $msize_size ) ) ///
        (rspike  min95 max95 period_shift if reg==`r', ///
            lwidth( $rspike_lwidth95 ) lcolor("`col'") ) ///
        (rspike  min90 max90 period_shift if reg==`r', ///
            lwidth( $rspike_lwidth90 ) lcolor("`col'") )

    local legorder `legorder' `L' "`lab'"
    local ++i
    local L = `L' + 3
}

/*****************************************************************
* 3.  DRAW THE GRAPH                                            *
*****************************************************************/
local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10 "1"  20 "2"  30 "3"  40 "4"

global x_size 17cm
global y_size 11cm

twoway `graphcmd', ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xlabel(`xl', labsize($xlab_size)) xscale(range(-45 45)) ///
    graphregion(color(white) lcolor(white) margin(l-3 r+1)) ///
    scale(0.9) legend(order(`legorder') row(2) pos(6)) ///
    ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
    xtitle("$x_titel", size($xtitle_size) margin(medium)) ///
    ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
    xsize($x_size) ysize($y_size)
	
graph export "$output/max/graphs/dsdh/dcdh_p_race_rwi.png", replace

**# Figure Cars
/******************************************************************
* 0.  COLOURS – 11 scheme-s2 colours, 60 % opacity                *
******************************************************************/
local colist navy%60 maroon%60 forest_green%60 dkorange%60 teal%60 ///
             cranberry%60 lavender%60 khaki%60 sienna%60 emidblue%60 emerald%60

/******************************************************************
* 1.  BUILD LAYERS & LEGEND  (reg == 14 … 24)                    *
******************************************************************/
local graphcmd    ""     // will accumulate layers
local legorder    ""     // legend entries
local i           1
local layer       1      // scatter layer index

forvalues r = 30/34 {

    /* colour i */
    local col : word `i' of `colist'
    if "`col'"=="" local col = "gs`=70+`i'*3'"

    /* legend text = value-label of reg, else fallback */
    local lab : label (reg) `r'
    if "`lab'"=="" local lab = "reg`r'"

    /* three layers for this cohort */
    local graphcmd `graphcmd' ///
        (scatter estimate period_shift if reg==`r' & treat == "same_switchers", ///
            msymbol(o) mcolor("`col'") msize($msize_size)) ///
        (rspike  min95 max95 period_shift if reg==`r' & treat == "same_switchers", ///
            lwidth($rspike_lwidth95) lcolor("`col'")) ///
        (rspike  min90 max90 period_shift if reg==`r' & treat == "same_switchers", ///
            lwidth($rspike_lwidth90) lcolor("`col'"))

    /* keep only the scatter layer in the legend */
    local legorder `legorder' `layer' "`lab'"

    local ++i
    local layer = `layer' + 3
}

/******************************************************************
* 2.  DRAW THE GRAPH (unchanged style macros)                     *
******************************************************************/
*  x-axis ticks at data –40 –30 … 40 but labelled –4 … 4
local xl -40 "-4" -30 "-3" -20 "-2" -10 "-1" 0 "0" ///
           10  "1"  20  "2"  30  "3"  40 "4"

global x_size 17cm
global y_size 11cm         // (keep or edit)

twoway `graphcmd', ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xlabel(`xl', labsize($xlab_size)) ///
    graphregion(color(white) lcolor(white) margin(l-3 r+1)) ///
    scale(0.9) legend(order(`legorder') row(2) pos(6)) ///
    ytitle("Estimated Treatment", size($ytitle_size) margin(medium)) ///
    xtitle("$x_titel", size($xtitle_size) margin(medium)) ///
    ylabel(, angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot)) ///
    xsize($x_size) ysize($y_size)
	
graph export "$output/max/graphs/dsdh/dcdh_p_cars_rwi.png", replace


* ================================================================== *
**# = Estimation with eventstudyinteract of Sun and Abraham (2020) = *
* ================================================================== *
drop L_6 L_7 L_8 L_9 L_10 L_11 F_6 F_7 F_8 F_9 F_10 F_11 F_12 F_13 F_14 F_15
* within a100
eventstudyinteract qm_miete_kalt L_2-L_5 F_0-F_5 if a100==1 & inrange(jahr_num, 2009, 2019), vce(cluster PLR_ID_num) absorb(PLR_ID_num jahr_num) cohort(first_treat) control_cohort(never_treat)
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ///
	title("Sun and Abraham (2020)")) stub_lag(L_#) stub_lead(F_#) together

matrix sa_b_a100 = e(b_iw) // storing the estimates for later
matrix sa_v_a100 = e(V_iw)

* outside a100
eventstudyinteract qm_miete_kalt L_2-L_5 F_0-F_5 if a100==0 & inrange(jahr_num, 2007, 2016), vce(cluster PLR_ID_num) absorb(PLR_ID_num jahr_num) cohort(first_treat) control_cohort(never_treat)
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ///
	title("Sun and Abraham (2020)")) stub_lag(L_#) stub_lead(F_#) together

matrix sa_b_no_a100 = e(b_iw) // storing the estimates for later
matrix sa_v_no_a100 = e(V_iw)

drop L_t2_6 L_t2_7 L_t2_8 L_t2_9 L_t2_10 L_t2_11 F_t2_6 F_t2_7 F_t2_8 F_t2_9 F_t2_10 F_t2_11 F_t2_12 F_t2_13 F_t2_14 F_t2_15

* within a100
eventstudyinteract qm_miete_kalt L_t2_2-L_t2_5 F_t2_0-F_t2_5 if a100==1 & inrange(jahr_num, 2007, 2016), vce(cluster PLR_ID_num) absorb(PLR_ID_num t) cohort(Ei_t2) control_cohort(never_treat)
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ///
	title("Sun and Abraham (2020)")) stub_lag(L_t2_#) stub_lead(F_t2_#) together

matrix sa_b_t2_a100 = e(b_iw) // storing the estimates for later
matrix sa_v_t2_a100 = e(V_iw)

* outside a100
eventstudyinteract qm_miete_kalt L_t2_2-L_t2_5 F_t2_0-F_t2_5 if a100==0 & inrange(jahr_num, 2007, 2016), vce(cluster PLR_ID_num) absorb(PLR_ID_num t) cohort(Ei_t2) control_cohort(never_treat)
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ///
	title("Sun and Abraham (2020)")) stub_lag(L_t2_#) stub_lead(F_t2_#) together

matrix sa_b_t2_no_a100 = e(b_iw) // storing the estimates for later
matrix sa_v_t2_no_a100 = e(V_iw)

drop L2_6 L2_7 L2_8 L2_9 L2_10 L2_11 F2_6 F2_7 F2_8 F2_9 F2_10 F2_11 F2_12 F2_13 F2_14 F2_15
* within a100
eventstudyinteract qm_miete_kalt L2_2-L2_5 F2_0-F2_5 if a100==1 & inrange(jahr_num, 2007, 2016), vce(cluster PLR_ID_num) absorb(PLR_ID_num jahr_num) cohort(first_treat) control_cohort(never_treat)
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ///
	title("Sun and Abraham (2020)")) stub_lag(L2_#) stub_lead(F2_#) together

matrix sa_b_2_a100 = e(b_iw) // storing the estimates for later
matrix sa_v_2_a100 = e(V_iw)


drop L2_t2_6 L2_t2_7 L2_t2_8 L2_t2_9 L2_t2_10 L2_t2_11 F2_t2_6 F2_t2_7 F2_t2_8 F2_t2_9 F2_t2_10 F2_t2_11 F2_t2_12 F2_t2_13 F2_t2_14 F2_t2_15
* within a100
eventstudyinteract qm_miete_kalt L2_t2_2-L2_t2_5 F2_t2_0-F2_t2_5 if a100==1 & inrange(jahr_num, 2007, 2016), vce(cluster PLR_ID_num) absorb(PLR_ID_num jahr_num) cohort(first_treat) control_cohort(never_treat)
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ///
	title("Sun and Abraham (2020)")) stub_lag(L2_t2_#) stub_lead(F2_t2_#) together

matrix sa_b_2_t2_a100 = e(b_iw) // storing the estimates for later
matrix sa_v_2_t2_a100 = e(V_iw)

* ================================================================== *
**# = Estimation with eventstudyinteract of Borusyak et al. (2021) = *
* ================================================================== *
* within a100
did_imputation qm_miete_kalt PLR_ID_num t Ei_t1 if a100==1 & inrange(jahr_num, 2009, 2019), allhorizons pretrend(4) delta(1) fe(t PLR_ID_num) autosample minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("Borusyak et al. (2021) imputation estimator") xlabel(-4(1)4))

estimates store bjs_a100 // storing the estimates for later

* outside a100
did_imputation qm_miete_kalt PLR_ID_num t Ei_t1 if a100==0 & inrange(jahr_num, 2009, 2019), allhorizons pretrend(4) delta(1) fe(t PLR_ID_num) autosample minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("Borusyak et al. (2021) imputation estimator") xlabel(-6(1)6))

estimates store bjs_no_a100 // storing the estimates for later

* within a100
did_imputation qm_miete_kalt PLR_ID_num t Ei_t2 if a100==1 & inrange(jahr_num, 2009, 2019), allhorizons pretrend(4) delta(1) fe(t PLR_ID_num) autosample minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("Borusyak et al. (2021) imputation estimator") xlabel(-4(1)4))

estimates store bjs_t2_a100 // storing the estimates for later

* outside a100
did_imputation qm_miete_kalt PLR_ID_num t Ei_t2 if a100==0 & inrange(jahr_num, 2009, 2019), allhorizons pretrend(4) delta(1) fe(t PLR_ID_num) autosample minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("Borusyak et al. (2021) imputation estimator") xlabel(-4(1)6))

estimates store bjs_t2_no_a100 // storing the estimates for later

* *************************************** *
**# ***** ESTIMATES: CS BASE CONTROLS *****
* *************************************** *
* Treatment 1 - within a100
xtset jahr PLR_ID_num

csdid qm_miete_kalt if inrange(jahr_num, 2009, 2019) & a100==1 & ty_treat0>-7 & ty_treat0<=20, ivar(PLR_ID_num) time(t) gvar(gvar_t1)
estat event, estore(cs_a100)
event_plot cs_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* Treatment 3 -  outside a100
csdid qm_miete_kalt if inrange(jahr_num, 2009, 2019) & a100==0 & ty_treat0>-7, ivar(PLR_ID_num) time(t) gvar(gvar_t1)
estat event, estore(cs_no_a100)
event_plot cs_no_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together
	
* Treatment 3 - within a100
csdid qm_miete_kalt if inrange(jahr_num, 2009, 2019) & a100==1 & (ty_treat2>-4 & ty_treat2 <4), ivar(PLR_ID_num) time(t) gvar(gvar_t2)
estat event, estore(cs_t2_a100)
event_plot cs_t2_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* Treatment 3 - outside a100
csdid qm_miete_kalt if inrange(jahr_num, 2009, 2019) & a100==0 & ty_treat2>-6, ivar(PLR_ID_num) time(t) gvar(gvar_t2)
estat event, estore(cs_t2_no_a100)
event_plot cs_t2_no_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* Treatment 3 - outside a100
csdid qm_miete_kalt if inrange(jahr_num, 2009, 2019) & a100==0 & ty_treat2>-7, ivar(PLR_ID_num) time(t) gvar(gvar_t2)
estat event, estore(cs_t2_no_a100)
event_plot cs_t2_no_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* Treatment 1 - within a100
csdid qm_miete_kalt if inrange(jahr_num, 2007, 2016) & a100==1 & ty_treat0_2>-7, ivar(PLR_ID_num) time(t) gvar(gvar2_t1)
estat event, estore(cs_2_t1_a100)
event_plot cs_2_t1_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* Treatment 1 - within a100
csdid qm_miete_kalt if inrange(jahr_num, 2007, 2016) & a100==1 & ty_treat2_2>-7, ivar(PLR_ID_num) time(t) gvar(gvar2_t2)
estat event, estore(cs_2_t2_a100)
event_plot cs_2_t2_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* *************************************** *
**# ***** RESULTS: 4 Estimators *****
* *************************************** *
// Combine all plots using the stored estimates
event_plot dcdh_b_a100#dcdh_v_a100 cs_a100 sa_b_a100#sa_v_a100 bjs_a100, ///
	stub_lag(Effect_# Tp# F_# tau#) stub_lead(Placebo_# Tm# L_# pre#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
	graph_opt(xtitle("Years since the event", size($xtitle_size)) ytitle("Average causal effect", size($ytitle_size)) ///
		legend(order(1 "DCDH" 3 "CSA" 5 "S&A" 7 "BJS") size($legend_size) rows(1) region(style(none)) position(6)) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ysize($y_size) xsize($x_size) xlabel(-5(1)5, labsize($xlab_size)) ylabel( , angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot))) ///
	lag_opt1(msymbol(+) msize($msize_size) color(cranberry) lwidth($rspike_lwidth)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(o) msize($msize_size) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(d) msize($msize_size) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(t) msize($msize_size) color(dkorange)) lag_ci_opt4(color(dkorange))
	
graph export "${output}/max/regression/robust/4est_treat1_t1_est_twfe_a100.png", replace

event_plot dcdh_b_no_a100#dcdh_v_no_a100 cs_no_a100 sa_b_no_a100#sa_v_no_a100 bjs_no_a100, ///
	stub_lag(Effect_# Tp# F_# tau#) stub_lead(Placebo_# Tm# L_# pre#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
	graph_opt(xtitle("Years since the event", size($xtitle_size)) ytitle("Average causal effect", size($ytitle_size)) ///
		legend(order(1 "DCDH" 3 "CSA" 5 "S&A" 7 "BJS") size($legend_size) rows(1) region(style(none)) position(6)) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ysize($y_size) xsize($x_size) xlabel(-5(1)5, labsize($xlab_size)) ylabel( , angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot))) ///
	lag_opt1(msymbol(+) msize($msize_size) color(cranberry) lwidth($rspike_lwidth)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(o) msize($msize_size) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(d) msize($msize_size) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(t) msize($msize_size) color(dkorange)) lag_ci_opt4(color(dkorange))

graph export "${output}/max/regression/robust/4est_treat1_t1_est_twfe_no_a100.png", replace

// Combine all plots using the stored estimates
event_plot dcdh_b_t2_a100#dcdh_v_t2_a100 cs_t2_a100 sa_b_t2_a100#sa_v_t2_a100 bjs_t2_a100, ///
	stub_lag(Effect_# Tp# F_t2_# tau#) stub_lead(Placebo_# Tm# L_t2_# pre#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
	graph_opt(xtitle("Years since the event", size($xtitle_size)) ytitle("Average causal effect", size($ytitle_size)) ///
		legend(order(1 "DCDH" 3 "CSA" 5 "S&A" 7 "BJS") size($legend_size) rows(1) region(style(none)) position(6)) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ysize($y_size) xsize($x_size) xlabel(-5(1)5, labsize($xlab_size)) ylabel( , angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot))) ///
	lag_opt1(msymbol(+) msize($msize_size) color(cranberry) lwidth($rspike_lwidth)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(o) msize($msize_size) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(d) msize($msize_size) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(t) msize($msize_size) color(dkorange)) lag_ci_opt4(color(dkorange))
	
graph export "${output}/max/regression/robust/4est_reat1_t2_est_twfe_a100.png", replace

event_plot dcdh_b_t2_no_a100#dcdh_v_t2_no_a100 cs_t2_no_a100 sa_b_t2_no_a100#sa_v_t2_no_a100 bjs_t2_no_a100, ///
	stub_lag(Effect_# Tp# F_t2_# tau#) stub_lead(Placebo_# Tm# L_t2_# pre#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
	graph_opt(xtitle("Years since the event", size($xtitle_size)) ytitle("Average causal effect", size($ytitle_size)) ///
		legend(order(1 "DCDH" 3 "CSA" 5 "S&A" 7 "BJS") size($legend_size) rows(1) region(style(none)) position(6)) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ysize($y_size) xsize($x_size) xlabel(-5(1)5, labsize($xlab_size)) ylabel( , angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot))) ///
	lag_opt1(msymbol(+) msize($msize_size) color(cranberry) lwidth($rspike_lwidth)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(o) msize($msize_size) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(d) msize($msize_size) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(t) msize($msize_size) color(dkorange)) lag_ci_opt4(color(dkorange))

graph export "${output}/max/regression/robust/4est_treat1_t2_est_twfe_no_a100.png", replace


event_plot dcdh_b_2_a100#dcdh_v_2_a100 cs_2_t1_a100 sa_b_2_a100#sa_v_2_a100, ///
	stub_lag(Effect_# Tp# F2_#) stub_lead(Placebo_# Tm# L2_#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
	graph_opt(xtitle("Years since the event", size($xtitle_size)) ytitle("Average causal effect", size($ytitle_size)) ///
		legend(order(1 "DCDH" 3 "CSA" 5 "S&A") size($legend_size) rows(1) region(style(none)) position(6)) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ysize($y_size) xsize($x_size) xlabel(-5(1)5, labsize($xlab_size)) ylabel( , angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot))) ///
	lag_opt1(msymbol(+) msize($msize_size) color(cranberry) lwidth($rspike_lwidth)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(o) msize($msize_size) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(d) msize($msize_size) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(t) msize($msize_size) color(dkorange)) lag_ci_opt4(color(dkorange))

graph export "${output}/max/regression/robust/4est_treat2_t1_a100.png", replace


event_plot dcdh_b_2_t2_a100#dcdh_v_2_t2_a100 cs_2_t2_a100 sa_b_2_t2_a100#sa_v_2_t2_a100, ///
	stub_lag(Effect_# Tp# F2_t2_#) stub_lead(Placebo_# Tm# L2_t2_#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
	graph_opt(xtitle("Years since the event", size($xtitle_size)) ytitle("Average causal effect", size($ytitle_size)) ///
		legend(order(1 "DCDH" 3 "CSA" 5 "S&A") size($legend_size) rows(1) region(style(none)) position(6)) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ///
		ysize($y_size) xsize($x_size) xlabel(-5(1)5, labsize($xlab_size)) ylabel( , angle(0) labsize($ylab_size) grid valuel glc(gs2) glp(dot))) ///
	lag_opt1(msymbol(+) msize($msize_size) color(cranberry) lwidth($rspike_lwidth)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(o) msize($msize_size) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(d) msize($msize_size) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(t) msize($msize_size) color(dkorange)) lag_ci_opt4(color(dkorange))

graph export "${output}/max/regression/robust/4est_treat2_t2_a100.png", replace

	
	
	
	
	
	




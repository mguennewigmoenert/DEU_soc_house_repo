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
g sh_d_socialh_scale = sh_d_socialh *1000

rename e_e pop
br objects_modern_year PLR_ID_num jahr c_dd_socialh

sum d_socialh if d_socialh>0 & a100_r == 1 & inrange(jahr, 2010, 2019)

drop F_*

xxx

* ================================================================================== *
**# = Estimation with did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020) = *
* ================================================================================== *
*=========================*
* 0) SETUP & BASE SAMPLE  *
*=========================*
preserve
keep PLR_ID_num jahr ln_sqm_rent_avg c_dd_socialh a100_r ln_wohnungen
keep if a100_r==1 & inrange(jahr,2010,2019)
sort PLR_ID_num jahr
quietly compress

*=============================*
* 1) BUILD 5-PERIOD PATHS     *
*    (anchor on FIRST CHANGE) *
*=============================*

* Non-absorbing treatment that can switch 0↔1
by PLR_ID_num (jahr): gen byte D      = c_dd_socialh
by PLR_ID_num (jahr): gen byte Dlag   = D[_n-1]
by PLR_ID_num (jahr): gen byte changed = (D!=Dlag) if _n>1

by PLR_ID_num (jahr): egen first_ch     = min(cond(changed, jahr, .))
by PLR_ID_num:        egen byte ever_changed  = max(changed)
gen byte never_changed = (ever_changed==0)

* Event-time: ℓ=1 is the first year AFTER the first change
capture drop event_l
gen int event_l = jahr - first_ch
replace event_l = . if missing(first_ch)     // never changed

* Build D_l1…D_l5 = treatment status at ℓ=1..5 after first change
foreach l of numlist 1/5 {
    capture drop D_l`l'
    by PLR_ID_num: egen D_l`l' = max(cond(event_l==`l', D, .))
}

* Encode post-change path; flag missing horizons as "M"
capture drop path5s
gen str5 path5s = ""
forvalues l = 1/5 {
    replace path5s = path5s + cond(missing(D_l`l'), "M", cond(D_l`l'==1,"1","0"))
}

* Drop switchers lacking full 5-year window
by PLR_ID_num: egen anyM = max(strpos(path5s,"M")>0)
drop if ever_changed==1 & anyM

* Clean and label
replace path5s = subinstr(path5s,"M","",.)
replace path5s = "" if never_changed==1
drop anyM

encode path5s, gen(path5)
label var path5 "Post-change treatment path (ℓ=1..5)"

* Compatibility flags
gen byte ever_treated  = ever_changed
gen byte never_treated = never_changed

* Save one-row-per-group path map
tempfile pathmap
keep PLR_ID_num path5 path5s ever_treated never_treated
duplicates drop
save `pathmap'

*===================================================*
* 2) BASELINE EFFECTS ON THE FULL SAMPLE (ALL PATHS)*
*===================================================*
restore
merge m:1 PLR_ID_num using `pathmap', nogen

tempname B0
quietly did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh, ///
    effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)
matrix `B0' = e(estimates)

*==============================*
* 3) BY-PATH ESTIMATES         *
*==============================*
tempname BYPATH
postfile `BYPATH' int(path) str20(pathlab) int(Nswitch) ///
    double(d_p1 se_p1 d_p2 se_p2 d_p3 se_p3 d_p4 se_p4 d_p5 se_p5 d_m1 se_m1 d_m2 se_m2 d_m3 se_m3 d_m4 se_m4) ///
    using "${output}/postfiles/by_path_results.dta", replace

levelsof path5 if ever_treated, local(paths)
local npaths : word count `paths'
di as txt "By-path estimations to run: " as res `npaths'

foreach p of local paths {
    preserve
        keep if (path5==`p' & ever_treated==1) | never_treated==1

        * number of SWITCHER GROUPS in this run
        quietly levelsof PLR_ID_num if ever_treated==1, local(swids)
        local nswitch : word count `swids'

        capture noisily did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh, ///
            effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

        * only post if estimates exist
        capture confirm matrix e(estimates)
        if !_rc {
            local lab : label (path5) `p'
            post `BYPATH' (`p') ("`lab'") (`nswitch') ///
                (e(estimates)[1,1]) (sqrt(e(variances)[1,1])) ///
                (e(estimates)[2,1]) (sqrt(e(variances)[2,1])) ///
                (e(estimates)[3,1]) (sqrt(e(variances)[3,1])) ///
                (e(estimates)[4,1]) (sqrt(e(variances)[4,1])) ///
                (e(estimates)[5,1]) (sqrt(e(variances)[5,1])) ///
				(0) (0)                                       ///
				(e(estimates)[7,1]) (sqrt(e(variances)[7,1])) ///
				(e(estimates)[8,1]) (sqrt(e(variances)[8,1])) ///
				(e(estimates)[9,1]) (sqrt(e(variances)[9,1]))
        }
    restore
}
postclose `BYPATH'

*====================================*
* 4) LEAVE-ONE-PATH-OUT (LOO) DELTAS *
*    Δ_bℓ = bℓ(ALL\p) – bℓ(ALL)      *
*====================================*
tempname LOO
postfile `LOO' int(path) str20(pathlab) int(Nremoved) ///
    double(d1 d2 d3 d4 d5) using "${output}/postfiles/loo_by_path.dta", replace

* paths already in memory from the merge above
levelsof path5 if ever_treated, local(paths)

foreach p of local paths {
    preserve
        * count SWITCHER GROUPS removed (not rows)
        quietly levelsof PLR_ID_num if path5==`p' & ever_treated==1, local(rm)
        local Nremoved : word count `rm'

        keep if !(path5==`p' & ever_treated==1)

        capture noisily did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh, ///
            effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

        capture confirm matrix e(estimates)
        if !_rc {
            local lab : label (path5) `p'
            post `LOO' (`p') ("`lab'") (`Nremoved') ///
                (e(estimates)[1,1] - `B0'[1,1]) ///
                (e(estimates)[2,1] - `B0'[2,1]) ///
                (e(estimates)[3,1] - `B0'[3,1]) ///
                (e(estimates)[4,1] - `B0'[4,1]) ///
                (e(estimates)[5,1] - `B0'[5,1])
        }
    restore
}
postclose `LOO'

*==========================================*
* 5) BY-GROUP LEAVE-ONE-GROUP-OUT (LOO)    *
*    (one re-estimation per tract)         *
*==========================================*
preserve
keep PLR_ID_num jahr ln_sqm_rent_avg c_dd_socialh a100_r ln_wohnungen
keep if a100_r==1 & inrange(jahr,2010,2019)
sort PLR_ID_num jahr

quietly did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh, ///
    effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)
matrix B_all = e(estimates)

by PLR_ID_num: egen ever = max(c_dd_socialh==1)
levelsof PLR_ID_num if ever, local(swgroups)

tempname LOOg
postfile `LOOg' long(PLR_ID_num) ///
    double(d1 d2 d3 d4 d5) using "${output}/postfiles/loo_by_group.dta", replace

local n : word count `swgroups'
di as txt "Running group-LOO for " as res `n' as txt " switcher groups…"

local i = 0
foreach g of local swgroups {
    local ++i
    di as txt "  [" `i' "/" `n' "] drop group " as res `g'

    restore, preserve          // <— reset to the snapshot, and preserve again
    keep if PLR_ID_num != `g'

    capture noisily did_multiplegt_dyn ln_sqm_rent_avg PLR_ID_num jahr c_dd_socialh, ///
        effects(5) placebo(3) controls(ln_wohnungen) cluster(PLR_ID_num)

    capture confirm matrix e(estimates)
    if !_rc {
        post `LOOg' (`g') ///
            (e(estimates)[1,1] - B_all[1,1]) ///
            (e(estimates)[2,1] - B_all[2,1]) ///
            (e(estimates)[3,1] - B_all[3,1]) ///
            (e(estimates)[4,1] - B_all[4,1]) ///
            (e(estimates)[5,1] - B_all[5,1])
    }
}
postclose `LOOg'
restore

*------------------------------*
* (Optional) quick inspection  *
*------------------------------*
frame create res
frame change res
use "${output}/postfiles/by_path_results.dta", clear
order path pathlab Nswitch d1 se1 d2 se2 d3 se3 d4 se4 d5 se5 

reshape long d_ph_ se_, i(outcome) j(time) string


use "${output}/postfiles/loo_by_path.dta", clear
order path pathlab Nremoved d1 d2 d3 d4 d5

use "${output}/postfiles/loo_by_group.dta", clear
order PLR_ID_num d1 d2 d3 d4 d5
frame change default
restore


*--- Start from your reshaped long file ---------------------------------
use "${output}/postfiles/by_path_results.dta", clear

* If path alone isn't unique, fall back to (path pathlab Nswitch)
local iid path pathlab Nswitch

reshape long d_ se_, i(`iid') j(h) string
rename d_ d
rename se_ se

* CIs
gen max90 = d + 1.78*se
gen min90 = d - 1.78*se
gen max95 = d + 1.96*se
gen min95 = d - 1.96*se

* Event-time (-4..-1, 1..5) with your shift so post starts at 0→4
gen str1 side   = substr(h,1,1)                 // "p" or "m"
gen     horizon = real(substr(h,2,.))           // 1..5
gen     event   = cond(side=="m", -horizon, horizon)
replace event   = event-1 if event>0            // now -4..-1, 0..4

* 
* Keep only the needed rows
drop if missing(d, event)

*--- Build a color list (23 hues). If any name isn't recognized on your scheme,
*    Stata will complain; in that case replace with colors you know work for you.
local colist navy maroon forest_green dkorange teal cranberry lavender khaki sienna ///
             emidblue emerald brown olive purple magenta cyan gold brick sand ///
             blue red green black

* Collect all paths present
levelsof path, local(paths)

* 1) Base x at scaled event
gen double period_shift = event*100

* 2) Pick how many side-by-side slots you want per event (e.g., 12)
quietly levelsof path, local(allpaths)
local Npaths : word count `allpaths'
local K = 12
if `Npaths' < `K' local K `Npaths'   // don't make more slots than paths

* 3) Assign each path to a slot 1..K (repeat if more paths than K)
egen long path_id = group(path)      // if path already 1..N you can skip this
gen  byte slot = mod(path_id-1, `K') + 1

* 4) Center slots and choose a step so everything stays within ±45 of each tick
gen double slot_c = slot - (`K'+1)/2
local step = floor(90/(`K'-1))       // with K=12 -> step = 8 (±44 max)
gen double x = period_shift + slot_c*`step'


 * Build layers for all paths with a palette
colorpalette RdYlBu, n(23) nograph
local cols `"`r(p)'"'
display `"`cols'"'


local K : word count `cols'
forvalues i = 1/`K' {
    local col : word `i' of `cols'
    di "color `i' = `col'"
    * e.g., mcolor("`col'%60")
}


local graphcmd ""
forvalues p = 10/23 {
    local col : word `p' of `cols' ///
	di "`col'"
    local graphcmd `graphcmd' ///
	
	local graphcmd `graphcmd' ///
        ( scatter d x if path ==`p', ///
            msymbol(o)  mcolor( `col' )  msize( $msize_size ) ) ///
        (rspike  min95 max95 x if path == `p', ///
            lwidth( $rspike_lwidth95 ) lcolor(`col') ) ///
        (rspike  min90 max90 x if path == `p', ///
            lwidth( $rspike_lwidth90 ) lcolor(`col') )
}


* 5) Axis labels: show -4..4 while data live at -400..400
local xl  -400 "-4"  -300 "-3"  -200 "-2"  -100 "-1"  0 "0" ///
           100  "1"   200  "2"    300 "3"   400  "4"

twoway `graphcmd', ///
    yline(0, lpattern(dash) lcolor(gs8) ) ///
    xlabel(`xl') xscale(range(-4 4) ) ///
    xtitle( "Event time (years)" ) ytitle( "Effect (Δ vs. baseline)") 	


* palette → list of quoted RGB triplets
colorpalette RdYlBu, n(23) nograph
local cols `"`r(p)'"'   // e.g. `"165 0 38" "187 27 39" ... "49 54 149"' 

local graphcmd
local legorder
local layer = 1

forvalues p = 2/23 {
    local col : word `p' of `cols'
    display "path `p' color: `col'"

    * skip path if not present (optional safety)
    quietly count if path==`p'
    if r(N)==0 continue

    local graphcmd `graphcmd' ///
        (scatter d x if path==`p', ///
            msymbol(o) mcolor("`col'%70") msize($msize_size)) ///
        (rspike min95 max95 x if path==`p', ///
            lwidth($rspike_lwidth95) lcolor("`col'%70")) ///
        (rspike min90 max90 x if path==`p', ///
            lwidth($rspike_lwidth90) lcolor("`col'%70"))

    local legorder `legorder' `layer' "Path `p'"
    local layer = `layer' + 3
}

* 5) Axis labels: show -4..4 while data live at -400..400
local xl  -400 "-4"  -300 "-3"  -200 "-2"  -100 "-1"  0 "0" ///
           100  "1"   200  "2"    300 "3"   400  "4"

		   
twoway `graphcmd', ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xlabel(`xl', labsize($xlab_size)) ///
    ylabel(, angle(0) labsize($ylab_size) grid glc(gs12) glp(dot)) ///
    legend(order(`legorder') rows(3) pos(6) size($legend_size)) ///
    xtitle("Event time") ytitle("Effect") ///
    graphregion(color(white)) plotregion(color(white))
	
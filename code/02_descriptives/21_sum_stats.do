clear all
set more off

*------------------------------------------------------------
* Summary Table: Treated vs. Untreated LORs within A100 (2010–2019)
*------------------------------------------------------------

*----------------------------
* 1) Load data
*----------------------------
use "${TEMP}/socialhousing_analysis.dta", clear

keep if a100 == 1
*----------------------------
* 2) Generate credit risk variables
*----------------------------
gen risk_low      = r1_mri_risiko_1 + r1_mri_risiko_2 + r1_mri_risiko_3
gen risk_med      = r1_mri_risiko_4 + r1_mri_risiko_5 + r1_mri_risiko_6
gen risk_high     = r1_mri_risiko_7 + r1_mri_risiko_8 + r1_mri_risiko_9
gen risk_low_med  = risk_low + risk_med

gen risk_p_high     = 100 * risk_high / r1_mba_a_haushalt
gen risk_p_low_med  = 100 * risk_low_med / r1_mba_a_haushalt

g non_german = r1_met_italien + r1_met_tuerkei + r1_met_griechen + r1_met_spanport + r1_met_balkan + r1_met_osteurop + r1_met_afrika + r1_met_islam + r1_met_asien + r1_met_uebrige
g non_german_p = (non_german / r1_mba_a_haushalt * 100)

*----------------------------
* 3) Collapse by treatment group (within A100 ring, 2010–2019)
*----------------------------
collapse ///
    (mean) mean_rent        = qm_miete_kalt  ///
           mean_pop         = e_e            ///
           mean_wohn        = wohnungen      ///
           mean_non_german  = non_german_p   ///
           mean_risk_high   = risk_p_high    ///
           mean_risk_low    = risk_p_low_med ///
    (sd)   sd_rent          = qm_miete_kalt  ///
           sd_pop           = e_e            ///
           sd_wohn          = wohnungen      ///
           sd_non_german    = non_german_p   ///
           sd_risk_high     = risk_p_high    ///
           sd_risk_low      = risk_p_low_med ///
    (count) N               = qm_miete_kalt  ///
    (sum)   objects         = objects        ///
    if a100_r==1 & inrange(jahr,2010,2019), by(treated)

*----------------------------
* 4) Reshape to wide format
*----------------------------
gen byte panel = 1
reshape wide mean_rent sd_rent ///
              mean_pop sd_pop ///
              mean_wohn sd_wohn ///
              mean_non_german sd_non_german ///
              mean_risk_high sd_risk_high ///
              mean_risk_low sd_risk_low ///
              N objects, i(panel) j(treated)

*----------------------------
* 5) Format cells with mean (SD) and compute differences
*----------------------------
* Mean (SD) cells
local rent0 = string(mean_rent0, "%9.2f") + " (" + string(sd_rent0, "%9.2f") + ")"
local rent1 = string(mean_rent1, "%9.2f") + " (" + string(sd_rent1, "%9.2f") + ")"

local pop0  = string(mean_pop0,  "%9.2f") + " (" + string(sd_pop0,  "%9.2f") + ")"
local pop1  = string(mean_pop1,  "%9.2f") + " (" + string(sd_pop1,  "%9.2f") + ")"

local wohn0 = string(mean_wohn0, "%9.2f") + " (" + string(sd_wohn0, "%9.2f") + ")"
local wohn1 = string(mean_wohn1, "%9.2f") + " (" + string(sd_wohn1, "%9.2f") + ")"

local non_ger0 = string(mean_non_german0, "%9.2f") + " (" + string(sd_non_german0, "%9.2f") + ")"
local non_ger1 = string(mean_non_german1, "%9.2f") + " (" + string(sd_non_german1, "%9.2f") + ")"

local risk_high0 = string(mean_risk_high0, "%9.2f") + " (" + string(sd_risk_high0, "%9.2f") + ")"
local risk_high1 = string(mean_risk_high1, "%9.2f") + " (" + string(sd_risk_high1, "%9.2f") + ")"

local risk_low0  = string(mean_risk_low0,  "%9.2f") + " (" + string(sd_risk_low0,  "%9.2f") + ")"
local risk_low1  = string(mean_risk_low1,  "%9.2f") + " (" + string(sd_risk_low1,  "%9.2f") + ")"

* Differences in means and SEs
local drent       = string(mean_rent1 - mean_rent0, "%9.2f")
local dpop        = string(mean_pop1  - mean_pop0 , "%9.2f")
local dwohn       = string(mean_wohn1 - mean_wohn0, "%9.2f")
local dnon_ger    = string(mean_non_german1 - mean_non_german0, "%9.2f")
local drisk_high  = string(mean_risk_high1 - mean_risk_high0, "%9.2f")
local drisk_low   = string(mean_risk_low1  - mean_risk_low0 , "%9.2f")

local serent      = string(sqrt((sd_rent0^2)/N0 + (sd_rent1^2)/N1), "%9.2f")
local sepop       = string(sqrt((sd_pop0^2) /N0 + (sd_pop1^2) /N1), "%9.2f")
local sewohn      = string(sqrt((sd_wohn0^2)/N0 + (sd_wohn1^2)/N1), "%9.2f")
local senon_ger   = string(sqrt((sd_non_german0^2)/N0 + (sd_non_german1^2)/N1), "%9.2f")
local serisk_high = string(sqrt((sd_risk_high0^2)/N0 + (sd_risk_high1^2)/N1), "%9.2f")
local serisk_low  = string(sqrt((sd_risk_low0^2) /N0 + (sd_risk_low1^2) /N1), "%9.2f")

* Final formatted diff (SE)
local rentdiff      = "`drent' (`serent')"
local popdiff       = "`dpop' (`sepop')"
local wohndiff      = "`dwohn' (`sewohn')"
local non_gerdiff   = "`dnon_ger' (`senon_ger')"
local risk_highdiff = "`drisk_high' (`serisk_high')"
local risk_lowdiff  = "`drisk_low' (`serisk_low')"

local objects0 = string(objects0, "%9.2f")
local objects1 = string(objects1, "%9.2f")
local Ntotal   = string(N0 + N1, "%9.0f")

* Difference in objects (number of listings)
local dobjects = string(objects1 - objects0, "%9.2f")
local seobjects = ""  // No SD available for sum, so we leave SE blank or estimate it if meaningful
local objectsdiff = "`dobjects'" // Could also write "`dobjects' (–)" if you want to show missing SE

*----------------------------
* 6) Build final table: Variable | Treated=0 | Treated=1 | Difference (SE)
*----------------------------
preserve
    clear
    input str30 var str30 treated0 str30 treated1 str30 diffse
    "Rent (€/m²)"               "" "" ""
    "Population"                "" "" ""
    "Housing units"            "" "" ""
    "Non-German share (%)"     "" "" ""
    "High-risk share (%)"      "" "" ""
    "Low/Med-risk share (%)"   "" "" ""
    "Total observations"       "" "" ""
    end

    replace treated0 = "`rent0'"        in 1
    replace treated1 = "`rent1'"        in 1
    replace diffse   = "`rentdiff'"     in 1

    replace treated0 = "`pop0'"         in 2
    replace treated1 = "`pop1'"         in 2
    replace diffse   = "`popdiff'"      in 2

    replace treated0 = "`wohn0'"        in 3
    replace treated1 = "`wohn1'"        in 3
    replace diffse   = "`wohndiff'"     in 3

    replace treated0 = "`non_ger0'"     in 4
    replace treated1 = "`non_ger1'"     in 4
    replace diffse   = "`non_gerdiff'"  in 4

    replace treated0 = "`risk_high0'"   in 5
    replace treated1 = "`risk_high1'"   in 5
    replace diffse   = "`risk_highdiff'" in 5

    replace treated0 = "`risk_low0'"    in 6
    replace treated1 = "`risk_low1'"    in 6
    replace diffse   = "`risk_lowdiff'" in 6

	replace treated0 = "`objects0'"      in 7
	replace treated1 = "`objects1'"      in 7
	replace diffse   = "`objectsdiff'"   in 7

    * Display
    list, noobs clean

    *----------------------------
    * 7) Export to CSV and LaTeX
    *----------------------------
    export delimited using "$output/tables/balance_var_treated01_withdiff.csv", replace

    file open f using "$output/tables/balance_var_treated01_withdiff.tex", write replace
    file write f "\begin{tabular}{lccc}" _n
    file write f "\toprule" _n
    file write f " & Treated=0 (Mean [SD]) & Treated=1 (Mean [SD]) & Difference (SE) \\\\" _n
    file write f "\midrule" _n
    quietly forvalues i = 1/`=_N' {
        file write f "`=var[`i']' & `=treated0[`i']' & `=treated1[`i']' & `=diffse[`i']' \\\\" _n
    }
    file write f "\bottomrule" _n
    file write f "\end{tabular}" _n
    file close f
restore

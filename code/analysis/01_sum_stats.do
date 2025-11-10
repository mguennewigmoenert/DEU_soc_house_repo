clear all
set more off

*----------------------------
* 1) Load data
*----------------------------
use "${TEMP}/socialhousing_analysis.dta", clear

*----------------------------
* 2) Collapse to means, SDs, and counts by treatment
*   (restrict to a100_r==1 and years 2010–2019)
*----------------------------
collapse ///
    (mean) mean_rent = qm_miete_kalt  ///
           mean_pop  = e_e            ///
           mean_wohn = wohnungen      ///
    (sd)   sd_rent   = qm_miete_kalt  ///
           sd_pop    = e_e            ///
           sd_wohn   = wohnungen      ///
    (count) N        = qm_miete_kalt  ///
	(sum)   objects   = objects  ///
    if a100_r==1 & inrange(jahr,2010,2019), by(treated)

*----------------------------
* 3) Reshape wide (treated=0/1 side by side)
*----------------------------
gen byte panel = 1
reshape wide mean_rent sd_rent mean_pop sd_pop mean_wohn sd_wohn N objects, i(panel) j(treated)

*----------------------------
* 4) Build displays and SE(difference) using SDs and counts
*     Columns show mean (SD); Difference column shows diff (SE_diff)
*----------------------------
* Means (SD) per group
local rent0 = string(mean_rent0, "%9.2f") + " (" + string(sd_rent0, "%9.2f") + ")"
local rent1 = string(mean_rent1, "%9.2f") + " (" + string(sd_rent1, "%9.2f") + ")"

local pop0  = string(mean_pop0,  "%9.2f") + " (" + string(sd_pop0,  "%9.2f") + ")"
local pop1  = string(mean_pop1,  "%9.2f") + " (" + string(sd_pop1,  "%9.2f") + ")"

local wohn0 = string(mean_wohn0, "%9.2f") + " (" + string(sd_wohn0, "%9.2f") + ")"
local wohn1 = string(mean_wohn1, "%9.2f") + " (" + string(sd_wohn1, "%9.2f") + ")"

* Differences in means (treated - untreated)
local drent = string(mean_rent1 - mean_rent0, "%9.2f")
local dpop  = string(mean_pop1  - mean_pop0 , "%9.2f")
local dwohn = string(mean_wohn1 - mean_wohn0, "%9.2f")

* SE of difference = sqrt(sd0^2/n0 + sd1^2/n1)
local serent = string(sqrt((sd_rent0^2)/N0 + (sd_rent1^2)/N1), "%9.2f")
local sepop  = string(sqrt((sd_pop0^2) /N0 + (sd_pop1^2) /N1), "%9.2f")
local sewohn = string(sqrt((sd_wohn0^2)/N0 + (sd_wohn1^2)/N1), "%9.2f")

local rentdiff = "`drent' (`serent')"
local popdiff  = "`dpop'  (`sepop')"
local wohndiff = "`dwohn' (`sewohn')"

local objects0 = string(objects0, "%9.2f")
local objects1 = string(objects1, "%9.2f")

* Total N across both groups
local Ntotal = string(N0 + N1, "%9.0f")

*----------------------------
* 5) Build final table: var | Treated=0 | Treated=1 | Difference (SE)
*   + bottom row with total N
*----------------------------
preserve
    clear
    input str20 var str30 treated0 str30 treated1 str30 diffse
    "Rent (€/m²)"   "" "" ""
    "Population"    "" "" ""
    "Housing units" "" "" ""
    "Total observations" "" "" ""
    end

    replace treated0 = "`rent0'"     in 1
    replace treated1 = "`rent1'"     in 1
    replace diffse   = "`rentdiff'"  in 1

    replace treated0 = "`pop0'"      in 2
    replace treated1 = "`pop1'"      in 2
    replace diffse   = "`popdiff'"   in 2

    replace treated0 = "`wohn0'"     in 3
    replace treated1 = "`wohn1'"     in 3
    replace diffse   = "`wohndiff'"  in 3

    * bottom N row (same total in both columns; diff empty)
    replace treated0 = "`objects0'"     in 4
    replace treated1 = "`objects1'"     in 4
    replace diffse   = ""             in 4

    order var treated0 treated1 diffse
    label var treated0 "Treated=0"
    label var treated1 "Treated=1"
    label var diffse   "Difference (SE)"
    list, noobs clean

    *----------------------------
    * 6) Exports
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

// Project: Social Housing
// Creation Date: 05-02-2024 
// Last Update: 18-04-2024 
// Author: Maximilian Guennewig-Moenert 
// Goal: Generate analysis datafile for DiD estimation

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
* use "${TEMP}/socialhousing_onlytreated.dta", clear
* keep if treated1==1
* keep PLR_ID

* store as tempfile for maerging
* tempfile treatment 
* save `treatment'

*use "${TEMP}/socialhousing_1.dta", clear 
use "${TEMP}/socialhousing_1_since2008.dta", clear 

/* Generate an early check if later changes differ
* Numeric panel id for PLR
encode PLR_ID, gen(plr_id_n)
xtset plr_id_n jahr, yearly

* early change
gen d_socialh_raw = (d.socialh)*(-1) // Change in the social housing

* This for the end of the code
br PLR_ID jahr d_socialh_raw d_socialh
g soc_d2 = d_socialh_raw - d_socialh
*/

* destring PLR_ID, gen(plr_code)
* save "${TEMP}/socialhousing_1_since2008.dta", replace

* tabstat objects, by(jahr) stats(mean)

* merge m:1 PLR_ID using `treatment'

* treatment group indicator
* gen treated = .
* replace treated = 1 if _merge==3
* drop _merge

* merge with control
* merge m:1 PLR_ID using "${TEMP}/socialhousing_onlydonors.dta"

* control group indicator
* replace treated = 0 if _merge==3
* drop _merge treated_2

* merge with sbahn ring
merge m:1 PLR_ID using "${TEMP}/sbahnring_lor.dta"

* within sbahn ring dummy
gen sbahn_r = 0
replace sbahn_r = 1 if sring==1
drop _merge

tab jahr

* merge with sbahn ring
merge m:1 PLR_ID using "${TEMP}/autoring_lor.dta"

* within A100 ring dummy
gen a100_r = 0
replace a100_r = 1 if auto_ring==1
drop _merge

tab jahr

* br treated sbahn_r a100_r jahr PLR_ID 
* drop if jahr>2019

* gen diff_share=d.share 
*gen diff_objects = d.objects 
*gen percentage_change =diff_objects/objects 
*380 observations with a change in the social housing share of -1 
/*
tabstat diff_share if PLR_ID=="05200526", by(jahr)
tabstat diff_share if PLR_ID=="08300935", by(jahr)
* Both of these PLRS had large changes over the course of 2010 until 2014: 
tabstat diff_share if PLR_ID=="12601032", by(jahr)

gen treat1=1 if PLR_ID=="05200526" | PLR_ID=="12601032"
replace treat1=0 if change_share2==0
gen byte post1=(jahr>=2012)

gen treat2=1 if PLR_ID=="08300935"
replace treat2=0 if change_share2==0 
gen byte post2=(jahr>=2014)

* check treatment and control group
tabstat change_share1 change_share2, by(treated)
sum change_share1 if treated==1
sum change_share1 if treated==0
sum change_share1 if treated==.
*/ 
* drop plr_code
encode PLR_ID, gen(plr_code)

* make PLR numeric for example for fixed effects estimation
g PLR_ID_num = PLR_ID
destring PLR_ID_num, replace

* Constant share keeping number of housing units within one LOR fixed 
bysort PLR_ID: egen mean_wohnungen = mean(wohnungen) 
g share2 = socialh/mean_wohnungen
label var share2 "Constant Share of Housing"

* set panel datframe
xtset PLR_ID_num jahr
g d_share2 = d.share2 
label var d_share2 "Difference in Social Housing Share"
* ======================================= *
**# === Multiple Continous Treatments === *
* ======================================= *

* change in social hosuing share by year
bysort PLR_ID (jahr): gen change_share3 = share - share[_n-1] // Change in the social housing share

// bysort PLR_ID (jahr): gen sh_d_socialh = d_socialh / socialh[_n-1] // Share of social housing relative to preexisting housing stock
// bysort PLR_ID (jahr): gen d_socialh = socialh - socialh[_n-1] // Change in the social housing
xtset PLR_ID_num jahr // set panel structure
gen shchange = d.share*(-1) // Change in the social housing share

gen d_socialh = (d.socialh)*(-1) // Change in the social housing

gen sh_d_socialh = d_socialh / l.socialh  // Share of social housing relative to preexisting housing stock

replace sh_d_socialh = 0 if socialh==0

gen g_d_socialh = d_socialh / l.wohnungen  // Share of social housing relative to preexisting housing stock

* Multiple Treatments of identical intensities
g c_dd_socialh = 0 if d_socialh!=.
replace c_dd_socialh = 1 if d_socialh > 0 & d_socialh!=.

* generate log of continous treatments
g ln_d_socialh = ln(d_socialh + 1) //log of change in the total number of social housing units 
g ln_socialh = ln(socialh)

* standard deviation of change in social housing
egen s_d_socialh = std(d_socialh)

/*
* set to zero if change is not larg eneough
replace shchange = 0 if shchange < 0
replace d_socialh = 0 if d_socialh < 0
replace sh_d_socialh = 0 if sh_d_socialh < 0
*/ 

* check treatment distributions
su shchange, d
su d_socialh, d
su sh_d_socialh if sh_d_socialh > 0, d

br PLR_ID_num jahr socialh wohnungen d_socialh sh_d_socialh

* brows variables and check
* br PLR_ID treated jahr share change_share1 change_share3

* sum dummies by LOR and keep only maximum of sum: total changes within lor
egen tot_dd_socialh = total(c_dd_socialh), by(PLR_ID)

list PLR_ID_num jahr socialh d.socialh l.socialh sh_d_socialh ///
     if abs(sh_d_socialh) > 10  // or some cutoff you care about
	 
* ====================================== *
**# === Binary Treatment: 1st change === *
* ====================================== *
* before total change from 2010 to 2022 needed to be larger than 5pp, no decrease to 3pp

g treated_auxil = .
replace treated_auxil = 0 if d_socialh == 0 & d_socialh!=.
replace treated_auxil = 1 if d_socialh > 0 & d_socialh!=.

* make sure old treated variable is not in dataframe anymore
* drop treated

* assign maximum value by group as treatment
egen treated = max(treated_auxil), by(PLR_ID_num)

* first change in social housing by year
gen fy_auxil = jahr if d_socialh > 0  & d_socialh!=.


* first year treatment occured
egen fy_treat0 = min(fy_auxil), by(PLR_ID)
label var fy_treat0 "First year treatment ocurred"

* br d_socialh change_share3 fy_auxil fy_treat0
* br PLR_ID treated jahr share change_share3 fy_auxil fy_treat0

* distance from treatment year
gen ty_treat0 = jahr - fy_treat0

* set treatment counter to zero for control
replace ty_treat0 = 0 if treated == 0

* make categories positive, set t=0 to 15 
gen ty_treat0_p = ty_treat0 +15
label var ty_treat0_p "Distance from Treatment year, +15"

br PLR_ID jahr d_socialh treated ty_treat0 ty_treat0_p

* ====================================== *
**# === Binary Treatment: Max change === *
* ====================================== *
* largest change by PLR
egen max_change = max(d_socialh), by(PLR_ID)
egen max_sh_change = max(sh_d_socialh), by(PLR_ID)

* generate 1st year of largest change in public housing units
g maxchange_year = jahr if d_socialh == max_change
g maxshchange_year = jahr if sh_d_socialh == max_sh_change

* expand treatment year by group
egen fy_treat1_0 = min(maxchange_year), by(PLR_ID)
egen fy_treat1_1 = min(maxshchange_year), by(PLR_ID)

* distance from treatment year
gen ty_treat1_0 = jahr - fy_treat1_0
gen ty_treat1_1 = jahr - fy_treat1_1

* make categories positive, set t=0 to 15 
gen ty_treat1_0_p = ty_treat1_0 +15
gen ty_treat1_1_p = ty_treat1_1 +15

label var ty_treat1_0_p "Distance from largest share change, +15"
label var ty_treat1_1_p "Distance from largest overall change, +15"

* ============================================ *
**# === Binary Treatment: 1st large change === *
* ============================================ *
* check percentiles
_pctile d_socialh if d_socialh>0, p(30)
return list

* large change in social housing
g large_year = jahr if d_socialh > 3 & d_socialh!=. // only consider lors with more than units dropping

* first large change in social housing by year
egen fy_treat2 = min(large_year), by(PLR_ID) // consider only earliest year

* br PLR_ID treated jahr share change_share3 fy_auxil fy_treat0
g treated_2 = .
replace treated_2 =0 if treated == 0
replace treated_2 =1 if fy_treat2 != .

br PLR_ID jahr d_socialh fy_treat2 fy_treat0 treated treated_2

* set treatment years to zero if non treated
replace fy_treat2 =. if treated ==. | treated ==0

* distance from treatment year
gen ty_treat2 = jahr - fy_treat2

* set treatment counter to zero for control
replace ty_treat2 = 0 if treated == 0

* make categories positive, set t=0 to 15 
gen ty_treat2_p = ty_treat2 +15
label var ty_treat2_p "Distance from first drop >3 units, +15"

* =========================== *
**# === Dynamic Treatment === *
* =========================== *
* first change treated, any change
gen dynamic_treat0 = 0
replace dynamic_treat0 = 1 if fy_treat0 <= jahr
label var dynamic_treat0 "Post first change in social housing"
* br dynamic_treat0 jahr fy_treat0

* max change treated
gen dynamic_treat1_0 = 0
replace dynamic_treat1_0 = 1 if fy_treat1_0 < jahr
label var dynamic_treat1_0 "Post largest share change in social housing"

gen dynamic_treat1_1 = 0
replace dynamic_treat1_1 = 1 if fy_treat1_1 < jahr
label var dynamic_treat1_1 "Post largest overall change in social housing"

* max change treated
gen dynamic_treat2 = 0
replace dynamic_treat2 = 1 if fy_treat2 < jahr
label var dynamic_treat2 "Post first large change in social housing"

br PLR_ID jahr treated treated_2 ty_treat0 dynamic_treat0 if tot_dd_socialh <2

/*
* first change treated + 3% change
gen dynamic_treat2_1st = 0 if treated !=.
replace dynamic_treat2_1st = 1 if fy_treat0_2 =< jahr

* first change adjusted treated + 5% change
gen dynamic_treat_1st_max = 0 if treated !=.
replace dynamic_treat_1st_max = 1 if fy_treat2 < jahr

* first change adjusted treated + 3% change
gen dynamic_treat2_1st_max = 0 if treated_2 !=.
replace dynamic_treat2_1st_max = 1 if fy_treat2_2 < jahr

* generate blub
gen blub=1 
*/

* generate log of outcome variables
gen ln_wohnungen=log(wohnungen)
gen ln_qm_miete_kalt = log(qm_miete_kalt)
/*
* ========================== *
**# === Treatment groups === *
* ========================== *

* treatment group id less thabn 5%
gen treat_group = fy_treat0
replace treat_group = 10 if treated==0

* treatment group id less than 5% + timing less than 1%
gen treat_group_t2 = fy_treat2
replace treat_group_t2 = 10 if treated==0

* treatment group id less thabn 3%
gen treat_group_2 = fy_treat0_2
replace treat_group_2 = 10 if treated_2==0

* treatment group id less than 3% + timing less than 1%
gen treat_group_2_t2 = fy_treat2_2
replace treat_group_2_t2 = 10 if treated_2==0

* save as csv
export delimited using "$TEMP/scm_prep_max.csv", replace
*/
* =============================================== *
**# === Generate dummy and continous variable === *
* =============================================== *
* subset
* keep if inrange(jahr, 2009, 2019)

gen other_id = substr(PLR_ID, 1,4)
encode other_id, gen(other_code)
*replace shchange = 0 if year == 2007

*gen implausible_change = ((shchange >= r(p99) & shchange < . ) | shchange <= r(p1) )

*replace implausible_change = 1 if shchange <= r(p1)
*bysort PLR_ID_num: egen drop = max(implausible_change)

* binary dummy for 5% treatment
gen T_dummy = fy_treat0 == fy_auxil
replace T_dummy = 0 if treated == 0

* continous variable for 5% treatment
gen T_scaled = c_dd_socialh

*gen T_scaled = T_dummy * d.share * -1
/*
* binary dummy for 5% treatment + .5 treatment share
gen T_t2_dummy = fy_treat2== fy_auxil2
replace T_t2_dummy=0 if treated==0

* continous variable for for 5% treatment + .5 treatment share
gen T_t2_scaled=  T_t2_dummy * change_share3* -1

* binary dummy for 3% treatment
gen T2_t1_dummy = fy_treat0_2== fy_auxil
replace T2_t1_dummy=0 if treated_2==0

* continous variable for 3% treatment
gen T2_t1_scaled=  T2_t1_dummy * d.share * -1

* generate dummy for treatment year only
gen T2_t2_dummy = fy_treat2_2== fy_auxil2
replace T2_t2_dummy=0 if treated_2==0 

* shock in dummy
gen T2_t2_scaled=  T2_t2_dummy * d.share * -1

* br jahr T_scaled T_dummy treated share
*/

* ========================== *
**# === Generate dummies === *
* ========================== *
* set number of leads and lags
global F = 4
global L = 4

// Create leads and lags of event study coefficients
noi di as text "Create leads and lags ... " _c
foreach var of varlist T_dummy  {
	
	local F = 4
	local L = 4
	noi di as text "`var' " _c
	
	
		*** Generate leads
		forval f = `F'(-1)1 {
			g `var'_F`f' = F`f'.`var' if treated != . // & jahr <= 2019
		} // f

		*** Generate lags
		forval l = 0(1)`L' {

			g `var'_L`l' = L`l'.`var' if treated != . // & jahr <= 2019	Decide if outside treatment should be taken into account
		} // l
	

	*** Bin endpoints
	bysort PLR_ID_num: g `var'_L`L'_tmp = sum(`var'_L`L') if treated != . // & jahr <= 2019

	gsort PLR_ID_num - jahr
	by PLR_ID_num: g `var'_F`F'_tmp = sum(`var'_F`F') if treated != . // & jahr <= 2019

	sort PLR_ID_num jahr

	replace `var'_L`L' = `var'_L`L'_tmp
	replace `var'_F`F' = `var'_F`F'_tmp

	drop *_tmp
	
} // var

* drop T_scaled_*
													  
* =================================== *
**# === Generate Scaled Treatment === *
* =================================== *
* scale treatment variables
* replace d_socialh = d_socialh *10
* replace sh_d_socialh = sh_d_socialh *1000

* set global for potential treatments
global treat_c sh_d_socialh d_socialh ln_d_socialh s_d_socialh c_dd_socialh ln_socialh

* global set to the number of words in treatment global
global treat_count : list sizeof global(treat_c)

replace d_socialh = . if jahr < 2010
replace sh_d_socialh = . if jahr < 2010
replace c_dd_socialh = . if jahr < 2010

// Create leads and lags of event study coefficients
*** Generate leads
forval i = 1/$treat_count{
	di `i'
	
	* call variables from list by index value
	local x: word `i' of $treat_c
	di `x'
	
	* rename scaled tratment by adding a new variable by index
	gen T_scaled_t`i' = `x'
	
	* take only change until 2019 into account. All changes afterwards will be 
	* ignored mute as needed
	* replace T_scaled_t`i' = 0 if jahr > 2019 // important to discuss

	*** loop over global lead length
	forval f = $F(-1)1 {
		g T_scaled_t`i'_F`f' = F`f'.T_scaled_t`i' 
	} // f
	* Generate lags
	*** loop over global lag length
	forval l = 0(1)$L {
		g T_scaled_t`i'_L`l' = L`l'.T_scaled_t`i'
		* assert inrange(year,2007,2009) if `var'_L`l' == .
		* replace T_scaled_t`i'_L`l' = 0 if T_scaled_t`i'_L`l' == .
	} // l

	*** Bin endpoints
	bysort PLR_ID_num: g T_scaled_L${L}_tmp = sum(T_scaled_t`i'_L${L})

	gsort PLR_ID_num - jahr
	by PLR_ID_num: g T_scaled_F${F}_tmp = sum(T_scaled_t`i'_F${F})

	sort PLR_ID_num jahr

	replace T_scaled_t`i'_L${L} = T_scaled_L${L}_tmp if T_scaled_t`i'_L${L} != .
	replace T_scaled_t`i'_F${F} = T_scaled_F${F}_tmp if T_scaled_t`i'_F${F} != .

	drop *_tmp

}

// var

* drop T_dummy_* T_scaled_*
* check dummies
br T_scaled_t5_F4 T_scaled_t5_F3 T_scaled_t5_F2 T_scaled_t5_F1 T_scaled_t5_L0 T_scaled_t5_L1 T_scaled_t5_L2 T_scaled_t5_L3 T_scaled_t5_L4 ///
///T_scaled_F4 T_scaled_F3 T_scaled_F2 T_scaled_F1 T_scaled_L0 T_scaled_L1 T_scaled_L2 T_scaled_L3 T_scaled_L4 ///
T_dummy_F4 T_dummy_F3 T_dummy_F2 ///
T_dummy_L0 T_dummy_L1 T_dummy_L2 T_dummy_L3 T_dummy_L4  ///
jahr T_scaled_t5 s_d_socialh d_socialh c_dd_socialh treated qm_miete_kalt if PLR_ID_num == 04300621


br T_scaled_t2_F* T_scaled_t2_L* jahr plr_code d_socialh

* Define Quartiles for treatments
bysort PLR_ID_num: gen sum_d_socialh = sum(d_socialh)

* group by total public housing drop
egen tot_d_socialh = max(sum_d_socialh), by(PLR_ID)

* set treatment quartiles according to distribution
g qua_d_socialh = 1 if tot_d_socialh <= 22
replace qua_d_socialh = 2 if tot_d_socialh >  22 & tot_d_socialh <= 71
replace qua_d_socialh = 3 if tot_d_socialh >  71 & tot_d_socialh <= 230
replace qua_d_socialh = 4 if tot_d_socialh >  230

* Continuous sum of treatments 
bysort PLR_ID (jahr): gen sum_dd_socialh = sum(c_dd_socialh)
label var sum_dd_socialh "Continuous sum of treatments"

gen byte count = large_year!=. 

bysort PLR_ID: egen total_large_socialh = total(count)
label var total_large_socialh "Total sum of large treatments"

bysort PLR_ID (jahr): gen sum_large_socialh = sum(count)
label var sum_large_socialh "Continuous sum of large treatments"

* =================================== *
**# === Generate Treatment Indicators === *
* =================================== *
g byte treat1  = d_socialh > 1
* Should we restrict this to only compare this 
replace treat1 = . if d_socialh ==. | d_socialh<0  
label var treat1 "Change in Social Housing > 1 units"

g byte treat2  = d_share2 < 0  
replace treat2 = . if d_share2  ==. | d_share2>0  
label var treat2 "Change in Social Housing share"


save "${TEMP}/socialhousing_analysis.dta", replace 




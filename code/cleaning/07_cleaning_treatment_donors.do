// Project: Synthetic Controls 
// Creation Date: 05-02-2024 
// Last Update: 18-04-2024 
// Author: Laura Arnemann 
// Goal: Running the stacked regression



use "${TEMP}/socialhousing_1_since2008.dta", clear 
gen bezirk = substr(PLR_ID, 1, 2)
destring bezirk, replace 
save "${TEMP}/socialhousing_1_since2008_cleaned.dta", replace 
*encode PLR_ID, gen(plr_code)


rename jahr year
encode PLR_ID, gen(plr_code)
xtset plr_code year 
gen diff_share=d.share 
*  380 observations smaller than one percentage point


*gen general_treat = 1 if diff_share<=-1 & diff_share!=. 
* Indicator for unit ever experiencing a change in treatment 

*bysort PLR_ID: egen n_treatments = total(helper_treatments)

* Make graphs for number of treatments each year wo accounting for multiple treatments 
*graph bar (rawsum) general_treat if year>=2011, over(year, label(labsize(small) angle(forty_five))) graphregion(color(white)) bgcolor(white)  bar(1, color(teal%50) ) ytitle("Number of treatments")

* Make graph for number of treatments each year while accounting for multiple treatments 
*graph bar (rawsum) general_treat if n_treatments==1 & year>=2011, over(year, label(labsize(small) angle(forty_five))) graphregion(color(white)) bgcolor(white)  bar(1, color(teal%50) ) ytitle("Number of treatments")
* When excluding multiple treatments only 97 more left
* As a starter I would look at the 18 units that had a percentage point change in social housing larger than -5 percentage points and less than one percentage points in the other years

keep if year>=2011

* Define control & treatment group
* Control group: change in social housing share over observation period between 1 and -1 pp.
gen control = 0
replace  control = 1  if inrange(diff_share, -1, 1) 
bysort PLR_ID: egen total_control=total(control)

forvalues i = 2011/2020 {
	gen helper_treat`i' = 0 
	replace helper_treat`i' = 1 if year==`i' & diff_share<=-5 & diff_share!=.
	bysort PLR_ID: egen treat`i'=max(helper_treat`i')
}

* ===================================== *
**# ===== Increase treatment pool =====
* ===================================== *
* before total change from 2010 to 2022 needed to be larger than 5pp, no decrease to 3pp
gen treated_2 = .
replace treated_2 = 0 if abs(change_share1)<=1
replace treated_2 = 1 if change_share1<-3

gen donorpool = 0 
replace donorpool = 1 if total_control==12
* 235 observations in the ultimate donor pool 

gen byte increase = (diff_share>1 & diff_share!=.) 
bysort PLR_ID: egen max_increase = max(increase)

gen indicator1 = 1 if diff_share<=-5 
bysort PLR_ID: egen treated1 = max(indicator1)
bysort PLR_ID: egen total_treatments = total(indicator1)
replace treated1 = . if max_increase==1 
* 49 units 

* Generate the minimum treatment year
gen treated_year = year if indicator1==1 

bysort PLR_ID: egen min_treatment = min(treated_year)
bysort PLR_ID: egen max_treatment = max(treated_year)

* Generate the maximum treatment year 
keep if donorpool ==1 | treated_2 ==1 

graph bar (rawsum) indicator1, over(year, label(labsize(small) angle(forty_five))) graphregion(color(white)) bgcolor(white)  bar(1, color(teal%50) ) ytitle("Number of treatments")
graph export "${output}/sum_treatments.png", replace


tabstat donorpool if donorpool == 0, by(year) stats(count)
* Ortolanweg missing for some years, check why 
keep if year==2017 

preserve 
keep if treated_2 ==1
save "${TEMP}/socialhousing_onlytreated.dta", replace
restore 

preserve
keep if donorpool ==1
save "${TEMP}/socialhousing_onlydonors.dta", replace
restore 

preserve 
keep if total_treatments >1
save "${TEMP}/socialhousing_multipletreatments.dta", replace
restore 


* Just some graphs to understand the variation better 

merge 1:m PLR_ID using "${TEMP}/plrs_neighbors_cleaned.dta", keepusing(dir_neighbor* adj_neighbors*)


keep if _merge ==3 
drop _merge 
keep if year ==2017 

levelsof PLR_ID if donorpool==0, local(lors) 

foreach l in `lors' {
	
	forvalues i=1/14 {
	drop if dir_neighbor`i'=="`l'" & donorpool==1
	}

}
preserve 

keep if donorpool ==1
save "${TEMP}/socialhousing_adj_neighbors.dta", replace
restore 

levelsof PLR_ID if donorpool==0, local(lors) 

foreach l in `lors' {
	
	forvalues i=1/14 {
	drop if strpos(adj_neighbors`i',"`l'") & donorpool==1
	}

}

keep if donorpool ==1
save "${TEMP}/socialhousing_adjadj_neighbors.dta", replace


* Making the line graphs 
use "${TEMP}/socialhousing_onlytreated.dta", replace
append using "${TEMP}/socialhousing_adj_neighbors.dta"
keep PLR_ID treat* donorpool 


merge 1:m PLR_ID  using "${TEMP}/socialhousing_1_since2008.dta", keepusing(qm_miete_kalt jahr object)
rename jahr year 
keep if _merge==3 
drop _merge 

forvalues i=2011/2020 {
	bysort PLR_ID: egen max_treat`i' = max(treat`i')
}

 
* Make figures for the evolution of prices in treated and untreated units 
preserve 
collapse (mean) qm_miete_kalt object max_treat*, by(year donorpool)
 twoway (line qm_miete_kalt year if donorpool==0 , color(green) ) ///
       (line qm_miete_kalt year if donorpool==1,  color(red)), ///
	   legend(order(1 "Treated" 2 "Control" ))
graph export "${output}/evolution_rents_general.png", replace

 twoway (line object year if donorpool==0 , color(green) ) ///
       (line object year if donorpool==1,  color(red)), ///
	   legend(order(1 "Treated" 2 "Control" ))
graph export "${output}/evolution_objects_general.png", replace

restore 
* Making the graphs for the different treatment years 
forvalues i =2011/2020 {
	preserve 
	keep if max_treat`i'==1 | donorpool==1
	
	* Square meter prices
	collapse (mean) qm_miete_kalt object, by(year donorpool)
   twoway (line qm_miete_kalt year if donorpool==0 , color(green) ) ///
       (line qm_miete_kalt year if donorpool==1,  color(red)), ///
	legend(order(1 "Treatment `i'" 2 "Control" ))
	graph export "${output}/evolution_rents_treat`i'.png", replace
	
	* Objects 	
	 twoway (line object year if donorpool==0 , color(green) ) ///
       (line object year if donorpool==1,  color(red)), ///
	legend(order(1 "Treatment `i'" 2 "Control" ))
	graph export "${output}/evolution_objects_treat`i'.png", replace
	
	restore 
}



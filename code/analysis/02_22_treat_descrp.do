// Project: Social Housing
// Creation Date: 05-02-2024 
// Last Update: 18-04-2024 
// Author: Maximilian Guennewig-Moenert 
// Goal: Generate Descriptive Statistics for treatment


*************************************************************************
* Regression Analyses without stacking
*************************************************************************
* upload treated file
use "${TEMP}/socialhousing_analysis.dta", clear 

* treated and untreated for both categories
count if treated==0 & jahr == 2015
count if treated==1 & jahr == 2015

count if treated_2==0 & jahr == 2015
count if treated_2==1 & jahr == 2015

* Graph evolution of change in Social Housing by treated PLR
twoway connected change_share3 jahr if jahr < 2017 & treated == 1 & a100_r == 1 ///
			,	///
	by(PLR_ID) ///
	xlabel(2007(1)2016, angle(vertical)) ///
	ytitle("PP Change in Social Housing Share") ///
	xtitle("Year") ///
	legend(title("Change in Social Housing Share by Treated PLR"))

* graph export "${output}/max/fig_d_shs_in_a100.png", replace

* ================================= *
**# ====== Dynamic Treatment ======
* ================================= *
* Graph evolution of change in Social Housing by treated PLR
* set local to populate
local fig_housing_change_in_a100

* list of treated for 5% threshold
levelsof PLR_ID_num if treated == 1 & jahr <=2018  & fy_treat0 <= 2017 & a100_r == 1, local(treat1_t1_1a100) 

* list of treated for 5% threshold + treatment timing less than .5%
levelsof PLR_ID_num if treated == 1 & jahr <=2018  & fy_treat2 <= 2017 & a100_r == 1, local(treat1_t2_1a100) 

* list of treated for 3% threshold
levelsof PLR_ID_num if treated_2 == 1 & jahr <=2018 & fy_treat0_2 <= 2017 & a100_r == 1, local(treat2_t1_1a100) 

* list of treated for 3% threshold
levelsof PLR_ID_num if treated_2 == 1 & jahr <=2018 & fy_treat2_2 <= 2017 & a100_r == 1, local(treat2_t2_1a100) 

foreach lor of local treat1_t1_1a100 {
	* store first treatement year to plot as x line
	levelsof treat_group if PLR_ID_num ==  `lor' , local(fy_treat) clean
	di `lor'
	twoway connected change_share3 jahr if treated_2 == 1 & jahr <=2018 & fy_treat2_2 <= 2018 & a100_r == 1 & PLR_ID_num == `lor' ///
			,	///
	xlabel(2007(1)2018, angle(vertical)) ///
	xtitle("") ///
	ytitle("") ///
	xline(`fy_treat') ///
	name(lor_`lor', replace) ///
	title("`lor'")
	local fig_housing_change_in_a100 `fig_housing_change_in_a100'  lor_`lor'
}

* combine graphs stored in local
graph combine `fig_housing_change_in_a100', ///
	l1(Change in Social Housing Share (pp)) b1(Year)
	
graph export "${output}/max/descriptives/treatment/fig_d_shs_treat1_t1_in_a100.png", replace

* ================================= *
macro drop fig_housing_change_in_a100 
graph drop _all

* Graph evolution of change in Social Housing by treated PLR
* set local to populate
local fig_housing_change_out_a100

foreach lor in 01400938 01400940 03200308 03200310 03300411 03300413 03300516 03400618 04100102 05100206 05100208 05100209 05100313 05200423 05200526 05200527 05300737 06100204 06100205 06200311 06300630 07501134 07601238 07601340 07601545 08100520 08200623 08200728 08200831 08200833 08300934 08301036 08401138 08401246 10200421 12200307 12200309 12601032 12601133 {
	di `lor'
	twoway connected change_share3 jahr if treated == 1 & a100_r == 0 & PLR_ID_num == `lor' ///
			,	///
	xlabel(2007(1)2022, angle(vertical)) ///
	ytitle("") ///
	xtitle("") ///
	name(lor_`lor', replace) ///
	title("`lor'")
	local fig_housing_change_out_a100 `fig_housing_change_out_a100'  lor_`lor'
}

* combine graphs stored in local
graph combine `fig_housing_change_out_a100', ///
	l1(Change in Social Housing Share (pp)) b1(Year)
graph export "${output}/max/fig_d_shs_out_a100.png", replace

preserve


* ===================================================== *
**# ====== Average SH Change by Treatment Cohort ======
* ===================================================== *
* set treatment indictor to collapse by
local treat_group treat_group_2

* check treatment cohorts
tab `treat_group' if a100_r == 1

* generate average of the percentage point change in social housing by treatment group
collapse (mean) m_change_share3 = change_share3 (semean) se_change_share3 = change_share3, by(`treat_group' a100_r jahr)

**label values**
lab def a100_r 1 "Within A100" 0 "Outside A100", modify
lab val a100_r a100_r
la li

* plot
twoway ///
	(connected m_change_share3 jahr if jahr <= 2017 & `treat_group'==2011) ///
	(connected m_change_share3 jahr if jahr <= 2017 & `treat_group'==2012) ///
	(connected m_change_share3 jahr if jahr <= 2017 & `treat_group'==2013) ///
	(connected m_change_share3 jahr if jahr <= 2017 & `treat_group'==2014) ///
	(connected m_change_share3 jahr if jahr <= 2017 & `treat_group'==2015) ///
	(connected m_change_share3 jahr if jahr <= 2017 & `treat_group'==2016) ///
			,	///
	by(a100_r) ///
	xlabel(2007(1)2016, angle(vertical)) ///
	ytitle("Mean Change in Social Housing Share") ///
	xtitle("Year") ///
	legend(title("Treat. Group") order(1 "2011" 2 "2012" 3 "2013" 4 "2014" 5 "2015" 6 "2016"))	

graph export "${output}/max/descriptives/treatment/fig_treat1_t2_avg_d_sh.png", replace

* =========================================================== *
**# ====== Average Rent Difference by Treatment Cohort ======
* =========================================================== *
restore, preserve

* description of treatment indicators 
* treat_group_t2: 5% drop of more than 0.7%
* treat_group_2_t2: 3% + drop of more than 0.7%
* set treatment indictor to collapse by
local treat_group treat_group_2

* check treatment cohorts
tab `treat_group' if a100_r == 1

* collapse mean of rent by treatment cohort
collapse (mean) m_rent = qm_miete_kalt (semean) se_rent = qm_miete_kalt, by(`treat_group' a100_r jahr)

* generate upper and lower bounds for rent
gen m_u = m_rent + 1.96 * se_rent
gen m_l = m_rent - 1.96 * se_rent

* drop all observation after 2018
drop if jahr >2018 | treat_group==.

* within A100
twoway ///
	(connected m_rent jahr if `treat_group'==10 & a100_r==1) ///
	(connected m_rent jahr if `treat_group'==2011 & a100_r==1) ///
	(connected m_rent jahr if `treat_group'==2012 & a100_r==1) ///
	(connected m_rent jahr if `treat_group'==2013 & a100_r==1) ///
	(connected m_rent jahr if `treat_group'==2014 & a100_r==1) ///
	(connected m_rent jahr if `treat_group'==2015 & a100_r ==1) ///
			,	///
	xlabel(2007(1)2018, angle(vertical)) ///
	ytitle("Mean rent/sqm") ///
	xtitle("Year") ///
	legend(order(1 "Control" 2 "2011" 3 "2012" 4 "2013" 5 "2014"))	
	
	// (connected m_rent jahr if `treat_group'==2015 & a100_r ==1)
	// (connected m_rent jahr if `treat_group'==2016 & a100_r ==1)
	// 6 "2015" 7 "2016")
		
graph export "${output}/max/descriptives/treatment/fig_treat2_t1_mrent_in_a100.png", replace

* generate control group rent over treatment cohort
g m_rent_control = m_rent if `treat_group'==10 & a100_r==1
bysort jahr (m_rent_control): replace m_rent_control = m_rent_control[_n-1] if missing( m_rent_control)

* subtract control group rent
g m_rent_par =  m_rent - m_rent_control

* within A100
twoway ///
	(connected m_rent_par jahr if `treat_group'==10 & a100_r==1) ///
	(connected m_rent_par jahr if `treat_group'==2011 & a100_r==1) ///
	(connected m_rent_par jahr if `treat_group'==2012 & a100_r==1) ///
	(connected m_rent_par jahr if `treat_group'==2013 & a100_r==1) ///
	(connected m_rent_par jahr if `treat_group'==2014 & a100_r==1) ///
	(connected m_rent_par jahr if `treat_group'==2015 & a100_r ==1) ///
			,	///
	xlabel(2007(1)2018, angle(vertical)) ///
	ytitle("Mean rent/sqm") ///
	xtitle("Year") ///
	legend(order(1 "Control" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015"))	
	
	// (connected m_rent_par jahr if `treat_group'==2015 & a100_r ==1)
	// (connected m_rent_par jahr if `treat_group'==2016 & a100_r ==1)
	// 6 "2015" 7 "2016"))
	
graph export "${output}/max/descriptives/treatment/fig_treat2_t1_d_mrent_in_a100.png", replace


* within A100
twoway ///
	(connected m_rent jahr if treat_group_t2==10 & a100_r==0) ///
	(connected m_rent jahr if treat_group_t2==2011 & a100_r==0) ///
	(connected m_rent jahr if treat_group_t2==2012 & a100_r==0) ///
	(connected m_rent jahr if treat_group_t2==2013 & a100_r==0) ///
	(connected m_rent jahr if treat_group_t2==2014 & a100_r==0) ///
			,	///
	xlabel(2007(1)2016, angle(vertical)) ///
	ytitle("Mean rent/sqm") ///
	xtitle("Year") ///
	legend(order(1 "Control" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015" 7 "2016"))	
	
graph export "${output}/max/fig_treat2_t2_d_mrent_out_a100.png", replace

drop m_l m_u se_rent

reshape wide m_rent, i(jahr a100_r) j(treat_group_adj)
	
gen d_2011 = m_rent2011-m_rent10
gen d_2012 = m_rent2012-m_rent10
gen d_2013 = m_rent2013-m_rent10
gen d_2014 = m_rent2014-m_rent10

twoway ///
	(connected d_2011 jahr if a100_r == 1) ///
	(connected d_2012 jahr if a100_r == 1) ///
	(connected d_2013 jahr if a100_r == 1) ///
	(connected d_2014 jahr if a100_r == 1)	///
	,	///
	xline(4.5 7.5) ///
	xlabel(2007(1)2016, angle(vertical)) ///
	legend(order(1 "2011" 2 "2012" 3 "2013" 4 "2014"))	
	



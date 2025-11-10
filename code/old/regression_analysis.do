// Project: Social Housing
// Creation Date: 05-02-2024 
// Last Update: 18-04-2024 
// Author: Laura Arnemann 
// Goal: Running the stacked regression



*************************************************************************
* Regression Analyses without stacking
*************************************************************************
*use "${TEMP}/socialhousing_1.dta", clear 
use "${TEMP}/socialhousing_1_since2008.dta", clear 
destring PLR_ID, gen(plr_code)
save "${TEMP}/socialhousing_1_since2008.dta", replace


tabstat objects, by(jahr) stats(mean)


encode PLR_ID, gen(plr_code)
xtset plr_code jahr 
gen diff_share=d.share 
gen diff_objects = d.objects 
gen percentage_change =diff_objects/objects 
*380 observations with a change in the social housing share of -1 

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

gen blub=1 

gen ln_socialh=log(socialh)
gen ln_wohnungen=log(wohnungen)

foreach var of varlist qm_miete_kalt objects {

*Cumulated effect
reghdfe `var' 1.treat1#1.post1 if inrange(jahr, 2007, 2016) , absorb(PLR_ID jahr) cl(PLR_ID)

local a=_b[1.treat1#1.post1]
di `a'
*Dynamic Effect
reghdfe `var' 2007.jahr#1.treat1 2008.jahr#1.treat1 2009.jahr#1.treat1 2010.jahr#1.treat1 blub 2012.jahr#1.treat1 2013.jahr#1.treat1 2014.jahr#1.treat1 2015.jahr#1.treat1 2016.jahr#1.treat1 if inrange(jahr, 2007, 2016) , absorb(jahr PLR_ID) cl(PLR_ID)


nlcom ///
	(_b[2007.jahr#1.treat1]) ///
	(_b[2008.jahr#1.treat1]) ///
	(_b[2009.jahr#1.treat1]) ///
	(_b[2010.jahr#1.treat1]) ///
	(0) ///
	(_b[2012.jahr#1.treat1]) ///
	(_b[2013.jahr#1.treat1]) ///
    (_b[2014.jahr#1.treat1]) ///
	(_b[2015.jahr#1.treat1]) ///
	(_b[2016.jahr#1.treat1]) ///
	, post level(95) 

eststo reg1

* Making the Coefplot 
coefplot (reg1, ciopts(recast(rarea) fintensity(inten20)) recast(connected) level(95))  , omitted vertical drop( _cons) coeflabel( _nl_1 = 2007 _nl_2 = 2008 _nl_3 = 2009 _nl_4 = 2010 _nl_5 = 2011 _nl_6 = 2012 _nl_7 = 2013  _nl_8 = 2014 _nl_9 = 2015 _nl_10 = 2016 , angle(45)) xline(2.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing") 
graph export "${output}/regression/large_change1_`var'.png", replace 

*Cumulated Effect
reghdfe `var' 1.treat2#1.post2 if inrange(jahr, 2007, 2018), absorb(jahr PLR_ID) cl(PLR_ID)

local a=_b[1.treat2#1.post2]
di `a'
*Dynamic Effect 
reghdfe `var' 2007.jahr#1.treat1 2008.jahr#1.treat1 2009.jahr#1.treat1 2010.jahr#1.treat1 2011.jahr#1.treat1 2012.jahr#1.treat1 2013.jahr#1.treat1 2015.jahr#1.treat1 2016.jahr#1.treat1 2017.jahr#1.treat1 2018.jahr#1.treat1  if inrange(jahr, 2007, 2018) , absorb(jahr PLR_ID) cl(PLR_ID)



nlcom ///
	(_b[2007.jahr#1.treat1]) ///
	(_b[2008.jahr#1.treat1]) ///
	(_b[2009.jahr#1.treat1]) ///
	(_b[2010.jahr#1.treat1]) ///
	(_b[2011.jahr#1.treat1]) ///
	(_b[2012.jahr#1.treat1]) ///
	(_b[2013.jahr#1.treat1]) ///
  	(0) ///
	(_b[2015.jahr#1.treat1]) ///
	(_b[2016.jahr#1.treat1]) ///
	(_b[2017.jahr#1.treat1]) ///
	(_b[2018.jahr#1.treat1]) ///
	, post level(95) 

eststo reg2	
	
* Making the Coefplot 
coefplot (reg2, ciopts(recast(rarea) fintensity(inten20)) recast(connected) level(95))  , omitted vertical drop( _cons) coeflabel( _nl_1 = 2007 _nl_2 = 2008 _nl_3 = 2009 _nl_4  = 2010  _nl_5 = 2011 _nl_6 = 2012 _nl_7 = 2013 _nl_8 = 2014 _nl_9 = 2015  _nl_10 = 2016 _nl_11 = 2017 _nl_12 = 2018 , angle(45)) xline(5.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years until Large Change in Social Housing") 
graph export "${output}/regression/large_change2_`var'.png", replace 
}




* General Regression Analysis 
reghdfe qm_miete_kalt share, absorb(PLR_ID jahr) cl(PLR_ID)
est sto reg1 
estadd local PLRfe "\checkmark", replace
estadd local yearfe "\checkmark", replace

reghdfe qm_miete_kalt share if jahr<=2014 ,  absorb(PLR_ID jahr) cl(PLR_ID)
est sto reg2 
estadd local PLRfe "\checkmark", replace
estadd local yearfe "\checkmark", replace

reghdfe qm_miete_kalt share if inrange(share, 0, 10),  absorb(PLR_ID jahr) cl(PLR_ID)
est sto reg3 
estadd local PLRfe "\checkmark", replace
estadd local yearfe "\checkmark", replace

reghdfe qm_miete_kalt share if jahr<=2014 & inrange(share, 0 ,10), absorb(PLR_ID jahr) cl(PLR_ID)
est sto reg4 
estadd local PLRfe "\checkmark", replace
estadd local yearfe "\checkmark", replace

esttab reg1 reg2 reg3 reg4 using "${output}/regression/table_regular.tex", replace noconstant keep(share) title("`f'")  mtitles("All" "2010 until 2014" "Share (0,10)"  "Share (0,10), 2010-2014" ) cells(b(star fmt(%9.3f)) se(par)) stats(PLRfe yearfe N r2, fmt( %9.0g %9.0g %9.0g  %9.3f)  label("PLR FE" "Year FE" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label 


*************************************************************************
*************************************************************************
* Regression Analyses with stacking
*************************************************************************
*************************************************************************

use "${TEMP}/socialhousing_1.dta", clear 
keep qm_miete_kalt mietekalt jahr PLR_ID wohnungen socialh share change_share1 change_share2

reshape wide qm_miete_kalt mietekalt wohnungen socialh share , i(PLR_ID) j(jahr)

tempfile socialhousing1 
save `socialhousing1'


use "${TEMP}/plrs_neighbors_stacked.dta", clear 

merge m:1 PLR_ID using `socialhousing1'
keep if _merge==3 
drop _merge

tostring treat, replace 

gen id=PLR_ID + treat 

reshape long qm_miete_kalt mietekalt wohnungen socialh share, i(id) j(jahr)

rename treat event 
encode event, gen(event_code)
encode PLR_ID, gen(PLR_code)

gen treat1=1 if PLR_ID=="05200526" | PLR_ID=="12601032"
replace treat1=0 if change_share2==0
gen byte post1=(jahr>=2012)

gen treat2=1 if PLR_ID=="08300935"
replace treat2=0 if change_share2==0
gen byte post2=(jahr>=2014)

gen blub=1

*Cumulated effect
reghdfe qm_miete_kalt 1.treat1#1.post1 if inrange(jahr, 2010, 2016) & (event=="05200526"  | event=="12601032"), absorb(PLR_code#event_code jahr#event_code) cl(PLR_code#event_code)

local a=_b[1.treat1#1.post1]
di `a'
*Dynamic Effect
reghdfe qm_miete_kalt 2010.jahr#1.treat1 blub 2012.jahr#1.treat1 2013.jahr#1.treat1 2014.jahr#1.treat1 2015.jahr#1.treat1 2016.jahr#1.treat1 if inrange(jahr, 2010, 2016) & (event=="05200526"  | event=="12601032"), absorb(PLR_code#event_code jahr#event_code) cl(PLR_code#event_code)
est sto reg1

nlcom ///
	(_b[2010.jahr#1.treat1]) ///
	(0) ///
	(_b[2012.jahr#1.treat1]) ///
	(_b[2013.jahr#1.treat1]) ///
    (_b[2014.jahr#1.treat1]) ///
	(_b[2015.jahr#1.treat1]) ///
	(_b[2016.jahr#1.treat1]) ///
	, post level(95) 

eststo reg1

* Making the Coefplot 
coefplot (reg1, ciopts(recast(rarea) fintensity(inten20)) recast(connected) level(95))  , omitted vertical drop( _cons) coeflabel( _nl_1 = 2010 _nl_2 = 2011 _nl_3 = 2012 _nl_4  = 2013  _nl_5 = 2014 _nl_6 = 2015 _nl_7 = 2016 ) xline(2.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years") 
graph export "${output}/regression/large_change1_stacking.png", replace 


*Cumulated Effect
reghdfe qm_miete_kalt 1.treat2#1.post2 if inrange(jahr, 2010, 2016) & event=="08300935", absorb(jahr PLR_ID) cl(PLR_ID)

local a=_b[1.treat2#1.post2]
di `a'

*Dynamic Effect 
reghdfe qm_miete_kalt 2010.jahr#1.treat2 2011.jahr#1.treat2 2012.jahr#1.treat2 2013.jahr#1.treat2 2015.jahr#1.treat2 2016.jahr#1.treat2 if inrange(jahr, 2010, 2016) & event=="08300935" , absorb(jahr PLR_ID) cl(PLR_ID)



*Dynamic Effect 
reghdfe qm_miete_kalt 2010.jahr#1.treat1 2011.jahr#1.treat1 2012.jahr#1.treat1 2013.jahr#1.treat1 2015.jahr#1.treat1 2016.jahr#1.treat1 if inrange(jahr, 2010, 2016) , absorb(jahr PLR_ID) cl(PLR_ID)

nlcom ///
	(_b[2010.jahr#1.treat1]) ///
	(_b[2011.jahr#1.treat1]) ///
	(_b[2012.jahr#1.treat1]) ///
	(_b[2013.jahr#1.treat1]) ///
  	(0) ///
	(_b[2015.jahr#1.treat1]) ///
	(_b[2016.jahr#1.treat1]) ///
	, post level(95) 

eststo reg2	
	
* Making the Coefplot 
coefplot (reg2, ciopts(recast(rarea) fintensity(inten20)) recast(connected) level(95))  , omitted vertical drop( _cons) coeflabel( _nl_1 = 2010 _nl_2 = 2011 _nl_3 = 2012 _nl_4  = 2013  _nl_5 = 2014 _nl_6 = 2015 _nl_7 = 2016 ) xline(5.5, lpattern(dash) lwidth(thin) lcolor(black)) xlabel(,labsize(medlarge)) yline(0,  lcolor(red) lwidth(thin)) ylabel(,labsize(medlarge)) graphregion(color(white)) ytitle("Rents per sqm", size(medsmall)) xtitle("Years") 
graph export "${output}/regression/large_change2_stacking.png", replace


*************************************************************************
* Run general regression analyses 
*************************************************************************

reghdfe qm_miete_kalt share, absorb(PLR_code#event_code event_code#jahr) cl(PLR_code#event_code)
est sto reg1 
estadd local PLReventfe "\checkmark", replace
estadd local eventyearfe "\checkmark", replace

reghdfe qm_miete_kalt share if jahr<=2014 , absorb(PLR_code#event_code event_code#jahr) cl(PLR_code#event_code)
est sto reg2 
estadd local PLReventfe "\checkmark", replace
estadd local eventyearfe "\checkmark", replace

reghdfe qm_miete_kalt share if inrange(share, 0, 10), absorb(PLR_code#event_code event_code#jahr) cl(PLR_code#event_code)
est sto reg3 
estadd local PLReventfe "\checkmark", replace
estadd local eventyearfe "\checkmark", replace

reghdfe qm_miete_kalt share if jahr<=2014 & inrange(share, 0 ,10), absorb(PLR_code#event_code event_code#jahr) cl(PLR_code#event_code)
est sto reg4 
estadd local PLReventfe "\checkmark", replace
estadd local eventyearfe "\checkmark", replace

esttab reg1 reg2 reg3 reg4 using "${output}/regression/table_stacking.tex", replace noconstant keep(share) title("Regression with Stacking")  mtitles("All" "2010 until 2014" "Share (0,10)"  "Share (0,10), 2010-2014" )cells(b(star fmt(%9.3f)) se(par)) stats(PLReventfe eventyearfe N r2, fmt( %9.0g %9.0g %9.0g  %9.3f )  label("PLR x Event FE" "Year x Event FE" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label 

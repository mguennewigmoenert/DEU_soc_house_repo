***Preliminary Regressions***

macro drop all

global path /Users/lauraarnemann/Dropbox/Housing Project
global datapath /Users/lauraarnemann/Dropbox/Housing Project/Stata_data
global filepath /Users/lauraarnemann/Desktop/Housing

use "$datapath/housing_all.dta",clear

***Regression Analysis***
*miet_p50 qm_miet_p50
foreach var of varlist miet_mean qm_miet_mean {
qui reg `var' total_sh, robust cluster(district)
eststo `var'_1
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' total_sh, absorb(i.year) vce(cluster district) 
eststo `var'_2
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' total_sh, absorb(i.year i.Stadt) vce(cluster district) 
eststo `var'_3
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' total_sh, absorb(i.district) vce(cluster district) 
eststo `var'_4
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' total_sh, absorb(i.district i.year) vce(cluster district) 
eststo `var'_5
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' total_sh, absorb(i.year##i.Stadt) vce(cluster district) 
eststo `var'_6
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
qui reghdfe `var' total_sh, absorb(i.year i.year#i.Stadt i.district) vce(cluster district) 
eststo `var'_7
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
}


*Same regressions with logs
foreach var of varlist miet_mean qm_miet_mean miet_p10 qm_miet_p10 miet_p25 qm_miet_p25 miet_p50 qm_miet_p50 miet_p75 qm_miet_p75 miet_p90 qm_miet_p90 {
qui reg `var' ln_sh, robust cluster(district)
eststo ln`var'_1
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year) vce(cluster district) 
eststo ln`var'_2
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year i.Stadt) vce(cluster district) 
eststo ln`var'_3
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.district) vce(cluster district) 
eststo ln`var'_4
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.district i.year) vce(cluster district) 
eststo ln`var'_5
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year##i.Stadt) vce(cluster district) 
eststo ln`var'_6
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
qui reghdfe `var' ln_sh, absorb(i.year i.year#i.Stadt i.district) vce(cluster district) 
eststo ln`var'_7
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
}


***Standard Panel Regression***
* quietly by district year:  gen dup = cond(_N==1,0,_n)
* drop if dup!=0

**Total SH und Miet Mean
esttab miet_mean_1 miet_mean_2 miet_mean_3 miet_mean_4 miet_mean_5 miet_mean_6 miet_mean_7 using "$filepath/regressions.tex", replace keep(total_sh) nomtitles noconstant title("Durchschnittsmiete (Gesamtzahl Sozialwohnungen)") cells(b(star) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)

**Total SH und Qm Miet Mean
esttab qm_miet_mean_1 qm_miet_mean_2 qm_miet_mean_3 qm_miet_mean_4 qm_miet_mean_5 qm_miet_mean_6 qm_miet_mean_7 using "$filepath/regressions.tex", append keep(total_sh) nomtitles noconstant title("Durchschnittsmiete pro QM (Gesamtzahl Sozialwohnungen)") cells(b(star) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)

**LN SH und Miet Mean
foreach var of varlist miet_mean miet_p10  miet_p25 miet_p50 miet_p75 miet_p90  {
esttab ln`var'_1 ln`var'_2 ln`var'_3 ln`var'_4 ln`var'_5 ln`var'_6 ln`var'_7  using "$filepath/regressions.tex", append keep(ln_sh) nomtitles noconstant title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}
***LN SH und Qm Miet Mean
foreach var of varlist qm_miet_mean qm_miet_p10 qm_miet_p25 qm_miet_p50 qm_miet_p75 qm_miet_p90 {
esttab ln`var'_1 ln`var'_2 ln`var'_3 ln`var'_4 ln`var'_5 ln`var'_6 ln`var'_7 using "$filepath/regressions.tex", append keep(ln_sh) nomtitles noconstant title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}

estimates drop _all
****Using Log/Log Regressions to get an idea about elasticities***
*Same regressions with logs
foreach var of varlist ln_miet_mean ln_qm_miet_mean ln_miet_p10 ln_qm_miet_p10 ln_miet_p25 ln_qm_miet_p25 ln_miet_p50 ln_qm_miet_p50 ln_miet_p75 ln_qm_miet_p75 ln_miet_p90 ln_qm_miet_p90 {
qui reg `var' ln_sh, robust cluster(district)
eststo ln`var'_1
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year) vce(cluster district) 
eststo ln`var'_2
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year i.Stadt) vce(cluster district) 
eststo ln`var'_3
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.district) vce(cluster district) 
eststo ln`var'_4
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.district i.year) vce(cluster district) 
eststo ln`var'_5
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year##i.Stadt) vce(cluster district) 
eststo ln`var'_6
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
qui reghdfe `var' ln_sh, absorb(i.year i.year#i.Stadt i.district) vce(cluster district) 
eststo ln`var'_7
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
}

foreach var of varlist miet_mean qm_miet_mean miet_p10 qm_miet_p10 miet_p25 qm_miet_p25 miet_p50 qm_miet_p50 miet_p75 qm_miet_p75 miet_p90 qm_miet_p90 {
esttab lnln_`var'_1 lnln_`var'_2 lnln_`var'_3 lnln_`var'_4 lnln_`var'_5 lnln_`var'_6 lnln_`var'_7 using "$filepath/robustness.tex", append keep(ln_sh) nomtitles noconstant title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}

****By year regression***
forvalues i=2007/2018 {
reg miet_mean ln_sh if year==`i'
eststo est1_`i'
reg miet_mean ln_sh i.Stadt if year==`i'
eststo est2_`i'
reg qm_miet_mean ln_sh if year==`i'
eststo est3_`i'
reg qm_miet_mean ln_sh i.Stadt if year==`i'
eststo est4_`i'
}

forvalues i=2/2 {
coefplot (est`i'_2007, aseq(2007) \ est`i'_2008, aseq(2008) \ est`i'_2009, aseq(2009) \ est`i'_2010, aseq(2010) \ est`i'_2011, aseq(2011) \ est`i'_2011, aseq(2011) \ est`i'_2012, aseq(2012) \ est`i'_2013, aseq(2013) \ est`i'_2014, aseq(2014) \ est`i'_2015, aseq(2015) \ est`i'_2016, aseq(2016)\ est`i'_2017, aseq(2017) \ est`i'_2018, aseq(2018)  ), byopts(graphregion(color(white))) swapnames vertical drop(_cons) yline(0) keep(ln_sh) title(Jährlicher Effekt auf Durchschnittsmiete) subtitle(inkl. StadtFE, bcolor(white) size(small))  
graph export "$filepath\graph\estimation_`i'.pdf", as(pdf) replace
}

forvalues i=4/4 {
coefplot (est`i'_2007, aseq(2007) \ est`i'_2008, aseq(2008) \ est`i'_2009, aseq(2009) \ est`i'_2010, aseq(2010) \ est`i'_2011, aseq(2011) \ est`i'_2011, aseq(2011) \ est`i'_2012, aseq(2012) \ est`i'_2013, aseq(2013) \ est`i'_2014, aseq(2014) \ est`i'_2015, aseq(2015) \ est`i'_2016, aseq(2016)\ est`i'_2017, aseq(2017) \ est`i'_2018, aseq(2018)  ), byopts(graphregion(color(white))) swapnames vertical drop(_cons) yline(0) keep(ln_sh) title(Jährlicher Effekt auf Quadratmetermiete) subtitle(inkl. StadtFE, bcolor(white) size(small))  
graph export "$filepath\graph\estimation_`i'.pdf", as(pdf) replace
}


/*foreach var of varlist miet_mean qm_miet_mean miet_p50 qm_miet_p50 {
foreach city in Berlin Cologne Dortmund Dusseldorf Frankfurt Hamburg Stuttgart Munich {
reg `var' total_sh if city=="`city'"
eststo `var'_`city'
}
}

esttab miet_mean_total qm_miet_mean_total miet_p50_total qm_miet_p50_total using reg1.xls,replace b(%9.2f) nonumbers noconstant mtitles("Miete (Durchschnitt)" "QM-Miete (Durchschnitt)""Miete (Median)" "QM-Miete (Median)" title( "All observations" ) )

foreach city in Berlin Cologne Dortmund Dusseldorf Frankfurt Hamburg Stuttgart Munich {
esttab miet_mean_`city' qm_miet_mean_`city' miet_p50_`city' qm_miet_p50_`city' using reg1.xls, append b(%9.2f) nonumbers noconstant mtitles("Miete (Durchschnitt)" "QM-Miete (Durchschnitt)" "Miete (Median)" "QM-Miete (Median)" title(`city') )
}
*/

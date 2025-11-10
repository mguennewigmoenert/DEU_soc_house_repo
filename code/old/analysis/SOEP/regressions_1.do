***********************************************************************************************************************************************************************************************REGRESSIONS: EFFECT OF SOCIAL HOUSING ON RENTS******************************
/* This dofile contains various regressions to assess the effect of social housing on rents*/

set more off 
clear all 
capture log close 

global datapath C:/Users/laura/Desktop/SocialHousing/data/Stadtdaten/data_bearbeitet
global graphpath C:/Users/laura/Desktop/SocialHousing/data/Stadtdaten/output/graphs
global tablepath C:/Users/laura/Desktop/SocialHousing/data/Stadtdaten/output/tables


use "$datapath/housing_merged.dta", clear

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
esttab miet_mean_1 miet_mean_2 miet_mean_3 miet_mean_4 miet_mean_5 miet_mean_6 miet_mean_7 using "$tablepath/regressions_sh_miete.tex", replace keep(total_sh) nomtitles collabels(none) noconstant title("Durchschnittsmiete (Gesamtzahl Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)



**Total SH und Qm Miet Mean
esttab qm_miet_mean_1 qm_miet_mean_2 qm_miet_mean_3 qm_miet_mean_4 qm_miet_mean_5 qm_miet_mean_6 qm_miet_mean_7 using "$tablepath/regressions_sh_miete.tex", append keep(total_sh) nomtitles collabels(none) noconstant title("Durchschnittsmiete pro QM (Gesamtzahl Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)

**LN SH und Miet Mean
foreach var of varlist miet_mean miet_p10  miet_p25 miet_p50 miet_p75 miet_p90  {
esttab ln`var'_1 ln`var'_2 ln`var'_3 ln`var'_4 ln`var'_5 ln`var'_6 ln`var'_7  using "$tablepath/regressions_sh_miete.tex", append keep(ln_sh) nomtitles noconstant collabels(none) title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}



***LN SH und Qm Miet Mean
foreach var of varlist qm_miet_mean qm_miet_p10 qm_miet_p25 qm_miet_p50 qm_miet_p75 qm_miet_p90 {
esttab ln`var'_1 ln`var'_2 ln`var'_3 ln`var'_4 ln`var'_5 ln`var'_6 ln`var'_7 using "$tablepath/regressions_sh_miete.tex", append keep(ln_sh) nomtitles collabels(none) noconstant title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}



estimates drop _all


****Using Log/Log Regressions to get an idea about elasticities***
*Same regressions with logs

foreach var of varlist ln_miet_mean ln_qm_miet_mean ln_miet_p10 ln_qm_miet_p10 ln_miet_p25 ln_qm_miet_p25 ln_miet_p50 ln_qm_miet_p50 ln_miet_p75 ln_qm_miet_p75 ln_miet_p90 ln_qm_miet_p90 {
qui reg `var' ln_sh, robust cluster(district)
eststo ln_sh`var'1
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year) vce(cluster district) 
eststo ln_sh`var'2
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year i.Stadt) vce(cluster district) 
eststo ln_sh`var'3
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.district) vce(cluster district) 
eststo ln_sh`var'4
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.district i.year) vce(cluster district) 
eststo ln_sh`var'5
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' ln_sh, absorb(i.year##i.Stadt) vce(cluster district) 
eststo ln_sh`var'6
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
qui reghdfe `var' ln_sh, absorb(i.year i.year#i.Stadt i.district) vce(cluster district) 
eststo ln_sh`var'7
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
}

foreach var of varlist ln_miet_mean ln_qm_miet_mean ln_miet_p10 ln_qm_miet_p10 ln_miet_p25 ln_qm_miet_p25 ln_miet_p50 ln_qm_miet_p50 ln_miet_p75 ln_qm_miet_p75 ln_miet_p90 ln_qm_miet_p90  {
esttab ln_sh`var'1 ln_sh`var'2 ln_sh`var'3 ln_sh`var'4 ln_sh`var'5 ln_sh`var'6 ln_sh`var'7 using "$tablepath/robustness_sh_miete.tex", append keep(ln_sh) nomtitles noconstant collabels(none) title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}






****Social Housing weighted by population stock and housing stock***
foreach expl in pop_sh share_sh  {
estimates drop _all
foreach var of varlist ln_miet_mean ln_qm_miet_mean ln_miet_p10 ln_qm_miet_p10 ln_miet_p25 ln_qm_miet_p25 ln_miet_p50 ln_qm_miet_p50 ln_miet_p75 ln_qm_miet_p75 ln_miet_p90 ln_qm_miet_p90 {
qui reg `var' `expl', robust cluster(district)
eststo `expl'`var'1
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
qui reghdfe `var' `expl', absorb(i.year) vce(cluster district) 
eststo `expl'`var'2
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace

qui reghdfe `var' `expl', absorb(i.year i.Stadt) vce(cluster district) 
eststo `expl'`var'3
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace

qui reghdfe `var' `expl', absorb(i.district) vce(cluster district) 
eststo `expl'`var'4
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace

qui reghdfe `var' `expl', absorb(i.district i.year) vce(cluster district) 
eststo `expl'`var'5
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace

qui reghdfe `var' `expl', absorb(i.year##i.Stadt) vce(cluster district) 
eststo `expl'`var'6
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace

qui reghdfe `var' `expl', absorb(i.year i.year#i.Stadt i.district) vce(cluster district) 
eststo `expl'`var'7
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace

esttab `expl'`var'1 `expl'`var'2 `expl'`var'3 `expl'`var'4 `expl'`var'5 `expl'`var'6 `expl'`var'7 using "$tablepath/`expl'.tex", append keep(`expl') nomtitles collabels(none) noconstant title("`:var label `var'' (Log Sozialwohnungen)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) note(OLS Regressions. Robust Standard Errors clustered at district level. * p<0.10, ** p<0.05, *** p<0.01)
}
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
graph export "$graphpath/estimation_`i'.pdf", as(pdf) replace
}

forvalues i=4/4 {
coefplot (est`i'_2007, aseq(2007) \ est`i'_2008, aseq(2008) \ est`i'_2009, aseq(2009) \ est`i'_2010, aseq(2010) \ est`i'_2011, aseq(2011) \ est`i'_2011, aseq(2011) \ est`i'_2012, aseq(2012) \ est`i'_2013, aseq(2013) \ est`i'_2014, aseq(2014) \ est`i'_2015, aseq(2015) \ est`i'_2016, aseq(2016)\ est`i'_2017, aseq(2017) \ est`i'_2018, aseq(2018)  ), byopts(graphregion(color(white))) swapnames vertical drop(_cons) yline(0) keep(ln_sh) title(Jährlicher Effekt auf Quadratmetermiete) subtitle(inkl. StadtFE, bcolor(white) size(small))  
graph export "$graphpath/estimation_`i'.pdf", as(pdf) replace
}






****************************************************************************************************************************************************************************************************************************************************************************Different Fixed effects structures plotted in coefficient plots: The following regressions plot the results presented in August 2020 


label variable pop_sh "Social Housing by district population"
label variable share_sh "Social Housing by housing stock"
label variable ln_sh "Log of Social Housing"

foreach expl in ln_sh pop_sh share_sh  {
foreach var of varlist miet_mean qm_miet_mean qm_miet_p10 qm_miet_p25 qm_miet_p50 qm_miet_p75 qm_miet_p90 {
qui reg `var' `expl' if year>=2009 & year<=2018, robust cluster(district)
eststo `expl'`var'1
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "No", replace


qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.year) vce(cluster district) 
eststo `expl'`var'2
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "No", replace

qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.year i.Stadt) vce(cluster district) 
eststo `expl'`var'3
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "No", replace

qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.district) vce(cluster district) 
eststo `expl'`var'4
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "No", replace

qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.district i.year) vce(cluster district) 
eststo `expl'`var'5
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "No", replace

qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.year##i.Stadt) vce(cluster district) 
eststo `expl'`var'6
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
quietly estadd local trendy "No", replace

qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.year i.year#i.Stadt i.district) vce(cluster district) 
eststo `expl'`var'7
quietly estadd local fixedd "Yes", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "Yes", replace
quietly estadd local trendy "No", replace

qui reghdfe `var' `expl' if year>=2009 & year<=2018, absorb(i.district#c.year) vce(cluster district) 
eststo `expl'`var'8
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "No", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "Yes", replace


qui reghdfe `var' `expl'  if year>=2009 & year<=2018 , absorb(i.Stadt i.district#c.year) vce(cluster district) 
eststo `expl'`var'9
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "No", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "No", replace
quietly estadd local trendy "Yes", replace

qui reghdfe `var' `expl'  if year>=2009 & year<=2018 , absorb( i.district#c.year i.Stadt##i.year) vce(cluster district) 
eststo `expl'`var'10
quietly estadd local fixedd "No", replace
quietly estadd local fixedy "Yes", replace
quietly estadd local fixedc "Yes", replace
quietly estadd local fixedyc "Yes", replace
quietly estadd local trendy "Yes", replace

}
}


esttab ln_shqm_miet_mean1 ln_shqm_miet_mean2 ln_shqm_miet_mean3 ln_shqm_miet_mean4 ln_shqm_miet_mean5 ln_shqm_miet_mean6 ln_shqm_miet_mean7 ln_shqm_miet_mean8  ln_shqm_miet_mean9 ln_shqm_miet_mean10 using "$tablepath\regression1.tex", replace noconstant nonumber mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" "Model 7" "Model 8" "Model 9" "Model 10") coeflabel(ln_sh "$\beta_{2009-2018}$") keep(ln_sh) title("The Effect of Social Housing (log) on Rents per sqm") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc trendy N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.0g  %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "District Trend" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01)
*note(OLS Regressions.  All units are observed on a district level. Dependent variables are the mean rent per square meters for the respective districts. The explaining variable is the log of social housing units per district. Robust Standard Errors are clustered at district level. Observations range from 2009 to 2018 p$\<$0.10, ** p$\<$0.05, *** p$\<$0.01)

esttab ln_shmiet_mean1 ln_shmiet_mean2 ln_shmiet_mean3 ln_shmiet_mean4 ln_shmiet_mean5 ln_shmiet_mean6 ln_shmiet_mean7 ln_shmiet_mean8 ln_shmiet_mean9 ln_shmiet_mean10  using "$tablepath\regression1.tex", append nonumbers noconstant  mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" "Model 7" "Model 8" "Model 9" "Model 10") coeflabel(ln_sh "$\beta_{2009-2018}$")  title("The Effect of Social Housing (log) on average rents (log)") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc trendy N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "District Trend" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) 
*note(OLS Regressions.  All units are observed on a district level. Dependent variables are the mean rent for the respective districts.Robust Standard Errors are clustered at district level. Observations range from 2009 to 2018* p$\<$0.10, ** p$\<$0.05, *** p$\<$0.01)

esttab pop_shqm_miet_mean1 pop_shqm_miet_mean2 pop_shqm_miet_mean3 pop_shqm_miet_mean4 pop_shqm_miet_mean5 pop_shqm_miet_mean6 pop_shqm_miet_mean7 pop_shqm_miet_mean8 pop_shqm_miet_mean9 pop_shqm_miet_mean10 using "$tablepath\regression1.tex", append  mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" "Model 7" "Model 8" "Model 9" "Model 10") keep (pop_sh) coeflabel(pop_sh "$\beta_{2009-2018}$") noconstant title("The Effect of Social Housing per capita on Rents per sqm") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc trendy N r2, fmt(%9.0g %9.0g %9.0g %9.0g  %9.0g %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "District Trend" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) 
*note(OLS Regressions.  All units are observed on a district level. Dependent variables are the mean rent per square meters for the respective districts. The explaining variable is the log of social housing units per district. Robust Standard Errors are clustered at district level. Observations range from 2009 to 2018 p$\<$0.10, ** p$\<$0.05, *** p$\<$0.01)

esttab share_shqm_miet_mean1 share_shqm_miet_mean2 share_shqm_miet_mean3 share_shqm_miet_mean4 share_shqm_miet_mean5 share_shqm_miet_mean6 share_shqm_miet_mean7 share_shqm_miet_mean8 share_shqm_miet_mean9 share_shqm_miet_mean10 using "$tablepath\regression1.tex", append noconstant title("The Effect of Social Housing per housing units on Rents per sqm") keep(share_sh) mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6" "Model 7" "Model 8" "Model 9" "Model 10") coeflabel(share_sh "$\beta_{2009-2018}$") cells(b(star fmt(%9.3f)) se(par) t(par)) stats(fixedy fixedc fixedd fixedyc trendy N r2, fmt(%9.0g %9.0g %9.0g %9.0g %9.0g  %9.0g %9.3f ) label("Year FE" "City FE" "District FE" "City x Year FE" "District Trend" "Observations" "R-squared" ))starl(* .10 ** .05 *** .01) 
*note(OLS Regressions.  All units are observed on a district level. Dependent variables are the mean rent per square meters for the respective districts. The explaining variable is the log of social housing units per district. Robust Standard Errors are clustered at district level. Observations range from 2009 to 2018 p$\<$0.10, ** p$\<$0.05, *** p$\<$0.01)

***Plot the distributions of estimates 

coefplot (share_shqm_miet_p105, aseq("10") \ share_shqm_miet_p255, aseq("25") \ share_shqm_miet_p505, aseq("50") \ share_shqm_miet_p755, aseq("75") \ share_shqm_miet_p905, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018")  
graph export "$graphpath\distribution_share_sh_5.pdf", replace

coefplot (pop_shqm_miet_p105, aseq("10") \ pop_shqm_miet_p255, aseq("25") \ pop_shqm_miet_p505, aseq("50") \ pop_shqm_miet_p755, aseq("75") \ pop_shqm_miet_p905, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018") 
graph export "$graphpath\distribution_pop_sh_5.pdf", replace
 
coefplot (ln_shqm_miet_p105, aseq("10") \ ln_shqm_miet_p255, aseq("25") \ ln_shqm_miet_p505, aseq("50") \ ln_shqm_miet_p755, aseq("75") \ ln_shqm_miet_p905, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018")
graph export "$graphpath\distribution_sh_5.pdf", replace

******Model 7******

coefplot (share_shqm_miet_p107, aseq("10") \ share_shqm_miet_p257, aseq("25") \ share_shqm_miet_p507, aseq("50") \ share_shqm_miet_p757, aseq("75") \ share_shqm_miet_p907, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018")  

graph export "$graphpath\distribution_share_sh_7.pdf", replace

coefplot (pop_shqm_miet_p107, aseq("10") \ pop_shqm_miet_p257, aseq("25") \ pop_shqm_miet_p507, aseq("50") \ pop_shqm_miet_p757, aseq("75") \ pop_shqm_miet_p907, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018") 
graph export "$graphpath\distribution_pop_sh_7.pdf", replace
 
coefplot (ln_shqm_miet_p107, aseq("10") \ ln_shqm_miet_p257, aseq("25") \ ln_shqm_miet_p507, aseq("50") \ ln_shqm_miet_p757, aseq("75") \ ln_shqm_miet_p907, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018")
graph export "$graphpath\distribution_sh_7.pdf",replace


*******Model 9******
coefplot (share_shqm_miet_p109, aseq("10") \ share_shqm_miet_p259, aseq("25") \ share_shqm_miet_p509, aseq("50") \ share_shqm_miet_p759, aseq("75") \ share_shqm_miet_p909, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018")  
graph export "$graphpath\distribution_share_sh_9.pdf",  replace

coefplot (pop_shqm_miet_p109, aseq("10") \ pop_shqm_miet_p259, aseq("25") \ pop_shqm_miet_p509, aseq("50") \ pop_shqm_miet_p759, aseq("75") \ pop_shqm_miet_p909, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018") 
graph export "$graphpath\distribution_pop_sh_9.pdf",  replace
 
coefplot (ln_shqm_miet_p109, aseq("10") \ ln_shqm_miet_p259, aseq("25") \ ln_shqm_miet_p509, aseq("50") \ ln_shqm_miet_p759, aseq("75") \ ln_shqm_miet_p909, aseq("90")), graphregion(color(white)) swapnames vertical drop(_cons) yline(0) ytitle("Magnitude of Coefficient", margin(r=3)) xtitle("Percentiles", margin(t=3)) 
*notes("OLS Regressions. All units are observed on a district level. Dependent variables are rent per square meter for the respective percentile. The regression includes district and year fixed effects. Standard errors are clustered on the district level. The dot depicts the coefficient, the whiskers the 95th confidence intevals. Observations range from 2009 to 2018")
graph export "$graphpath\distribution_sh_9.pdf", as(pdf) replace



**** Coefplot for percentile distributions***
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

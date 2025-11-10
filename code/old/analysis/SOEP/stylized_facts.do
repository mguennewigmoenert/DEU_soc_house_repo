/* Making figures and tables */ 
set more off 
capture log close


global datapath C:/Users/laura/Desktop/SocialHousing/data/SOEPdata/databearbeitet
global graphpath C:/Users/laura/Desktop/SocialHousing/data/SOEP/output/graphs
global tablepath C:/Users/laura/Desktop/SocialHousing/data/SOEP/output/tables
use "$datapath/soep_cleaned.dta", replace


gen nosocialh=1 if socialh1==0 
replace nosocialh=0 if socialh1==1
bysort jahr: egen n_nosocial=total(nosocialh)

bysort jahr: egen n_socialh=total(socialh1)
bysort jahr: egen n_socialh2=total(socialh2)

bysort jahr: egen mean_miete=mean(miete) if socialh1==1
bysort jahr: egen mean_rent= mean(rent) if socialh1==1

line mean_miete jahr if jahr>=1995 || line mean_rent jahr if jahr>=1995, graphregion(color(white)) ytitle("Difference actual and market rent") subtitle("Only occupants of social housing") xtitle("Year") legend(label(1 "Rent (Pequiv)") label(2 "Actual rent"))
graph export "$graphpath/evolution_rent_miete.pdf", replace

****Also use the pequiv files***
binscatter share_miete4 share_miete1 netto if socialh1==1, graphregion(color(white)) ytitle("Rent Share") xtitle("Net Income") legend(label(1 "Rent Share (Pequiv)") label(2 "Actual rent share"))
graph export "$graphpath/resid_income_rentshare6.pdf", replace


binscatter miete rent netto if socialh1==1, graphregion(color(white)) ytitle("Rent (total)") xtitle("Net Income") legend(label(1 "Counterfactual rent (Pequiv)") label(2 "Actual rent"))
graph export "$graphpath/resid_income_miete_rent.pdf", replace








***generate missings for the variables yearsinhouse and baujahr 
label variable ln_miete "Log of Rent"

replace baujahr=10 if missing(baujahr)
replace gemeindetyp=20 if missing(gemeindetyp)
replace garden=20 if missing(garden)
replace aircondition=20 if missing(aircondition)
replace alarm=20 if missing(alarm)
replace basement=20 if missing(basement)
replace balcony=20 if missing(balcony)
replace ln_operating=0 if operating==0 

foreach var of varlist yearsinhouse squarefootage housingsatisfaction electricity heatcosts extracosts ln_operating {
gen m1`var'=`var'
replace m1`var'=-99 if missing(`var')

gen missing`var'=1 if m1`var'==-99
replace missing`var'=0 if m1`var'!=-99

local f: variable label `var'
label variable m1`var' "`f' with miss. "
}



*****Label these variables****** 


*****Globals for the regressions
global missingcontrols1 missingyearsinhouse missingsquarefootage missinghousingsatisfaction
global qualitycontrols i.garden i.balcony i.aircondition i.alarm i.basement
global costcontrols1 electricity extracosts heatcosts m1ln_operating missingln_operating
global costcontrols2 m1electricity m1extracosts m1heatcosts m1ln_operating
global misscostcontrols missingelectricity missingextracosts missingheatcosts missingln_operating
global othercontrols i.baujahr m1housingsatisfaction m1yearsinhouse missinghousingsatisfaction missingyearsinhouse




************************************************************************************************
***********************************************************************************************
**********************Regression of Social Housing on Rents************************************

***Generating different fixed effects

capture log close
log using new.log, text replace

label variable miete "Rent"
label variable ln_miete "Log Rent"

foreach var of varlist miete ln_miete {
	estimates clear

foreach type in post {

local polynomial1 `type'income
local polynomial2 c.`type'income##c.`type'income
local polynomial3 c.`type'income##c.`type'income##c.`type'income
local polynomial4 c.`type'income##c.`type'income##c.`type'income##c.`type'income

forvalues y=1/4 {
local controls1 `polynomial`y'' m1squarefootage missingsquarefootage size
local controls2 `polynomial`y'' $costcontrols2 $misscostcontrols m1squarefootage missingsquarefootage size
local controls3 `polynomial`y'' $costcontrols2 $misscostcontrols $qualitycontrols m1squarefootage missingsquarefootage size
local controls4 `polynomial`y'' $costcontrols2 $misscostcontrols $qualitycontrols $othercontrols m1squarefootage missingsquarefootage size
forvalues i=1/4 {

/*reghdfe `var' socialh1 `controls`i'', absorb(jahr) vce(robust)
est sto `var'`i'`type'`y'_1
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd local qualitycontrols "No", replace
	estadd ysumm */
/*
reghdfe `var' socialh1 `controls`i'' [aw=hhweight], absorb(jahr) vce(robust)
	est sto `var'`i'`type'`y'_1
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd local qualitycontrols "No", replace
	estadd ysumm	

reghdfe `var' socialh1 `controls`i'' [aw=hhweight], absorb(jahr gemeindetyp) vce(robust)
	est sto `var'`i'`type'`y'_2
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd local qualitycontrols "No", replace
	estadd ysumm
*/	
	
reghdfe `var' socialh1 `controls`i'' [aw=hhweight], absorb(jahr gemeindeklasse) vce(robust)
	est sto `var'`i'`type'`y'_3
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd local qualitycontrols "No", replace
	estadd ysumm
	
/*reghdfe `var' socialh1 `controls`i'' $qualitycontrols, absorb(jahr gemeindetyp) vce(robust)
est sto `var'`i'`type'`y'_3
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd local qualitycontrols "Yes", replace
	estadd ysumm
*/
}
local f: variable label `var'




}


***Make different tables for different specifications so they look nicer
*First Specification
esttab `var'1`type'1_3 `var'1`type'2_3 `var'1`type'3_3 `var'1`type'4_3 using "$tablepath/specification_1.tex", append noconstant title("  Specification 1: `f'") mtitles("1st" "2nd" "3rd" "4th") cells(b(star fmt(%9.3f)) se(par))  stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f )  label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label drop(missing*)

esttab `var'2`type'1_3 `var'2`type'2_3 `var'2`type'3_3 `var'2`type'4_3 using "$tablepath/specification_2.tex", append noconstant title("  Specification 2: `f' ") mtitles("1st" "2nd" "3rd" "4th") cells(b(star fmt(%9.3f)) se(par)) stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f ) label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label drop(missing*) 

esttab `var'3`type'1_3 `var'3`type'2_3 `var'3`type'3_3 `var'3`type'4_3 using "$tablepath/specification_3.tex", append noconstant title(" `f': Specification 3 : `f'")  mtitles("1st" "2nd" "3rd" "4th") cells(b(star fmt(%9.3f)) se(par)) stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f ) label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label  drop(missing* 1.garden 1.alarm 1.balcony 1.aircondition 1.basement 20.garden 20.alarm 20.balcony 20.aircondition 20.basement)

esttab `var'4`type'1_3 `var'4`type'2_3 `var'4`type'3_3 `var'4`type'4_3 using "$tablepath/specification_4.tex", append  noconstant title(" Specification 4 : `f'") mtitles("1st" "2nd" "3rd" "4th") cells(b(star fmt(%9.3f)) se(par))  stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f ) label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label drop(missing* 1.garden 1.alarm 1.balcony 1.aircondition 1.basement 20.garden 20.alarm 20.balcony 20.aircondition 20.basement *.baujahr)
}
}














*Gemeindetyp für Jahr 2016 unheimlich schlecht besetzt

estpost tabstat share_miete2 preincome postincome bigcity size eligible n_socialh if socialh1==1 & jahr<2018 & jahr>=1995, by(jahr) stats(mean sd) nototal
eststo tab1 
esttab tab1 using "$tablepath\descriptives1.tex", replace cells("share_miete2(fmt(2)) preincome(fmt(0)) postincome(fmt(0)) bigcity(fmt(2)) size(fmt(0)) eligible(fmt(2)) n_socialh(fmt(0)) ") mlabel("Share Rent & Pre Income & Post Income & Big City & HH Size & Eligible & Number") collabels(none) main(mean) aux(sd) noobs 

estpost tabstat share_miete2 preincome postincome bigcity size eligible n_nosocial if socialh1==0 & jahr<2018 & jahr>=1995, by(jahr) stats(mean sd) nototal
eststo tab2 
esttab tab2 using "$tablepath\descriptives2.tex", replace cells("share_miete2(fmt(2)) preincome(fmt(0)) postincome(fmt(0)) bigcity(fmt(2)) size(fmt(0)) eligible(fmt(2)) n_nosocial(fmt(0)) ") mlabel("Share Rent & Pre Income & Post Income & Big City & HH Size & Eligible & Number") collabels(none) main(mean) aux(sd) noobs 


******Fraction of respondents living in social housing
bysort jahr: egen total_sozial1=mean(socialh1)
bysort jahr: egen total_sozial2=mean(socialh2)

sort jahr
line total_sozial1 jahr if jahr>=1995, graphregion(color(white)) ytitle("Fraction of Respondents living in social housing") xtitle("Year") note("Only households living in social housing with a remaining rent cap")
graph export "$graphpath\evolution_sh1.pdf", replace

line total_sozial2 jahr if jahr>=1995, graphregion(color(white)) ytitle("Fraction of Respondents living in social housing") subtitle("With and without rent cap") xtitle("Year") note("Households living in social housing overall")
graph export "$graphpath\evolution_sh2.pdf", replace


***************************************************************
***************************************************************
******Fraction of net income paid for rent SH vs non SH****

forvalues i=1/6 {
bysort jahr socialh1:egen share_miete1_def`i'=mean(share_miete`i')
bysort jahr socialh2:egen share_miete2_def`i'=mean(share_miete`i')
bysort jahr socialh1:egen share_miete3_def`i'=mean(share_miete`i') if share_miete`i'<=0.5
bysort jahr socialh1:egen share_miete4_def`i'=mean(share_miete`i') if eligible==1
bysort jahr socialh1:egen share_miete5_def`i'=mean(share_miete`i') if preincome<25000
*13 observations for which this is the case

line share_miete1_def`i' jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line share_miete1_def`i' jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Fraction of income") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\share_miete1`i'.pdf", replace

line share_miete2_def`i' jahr if socialh2==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line share_miete1_def`i' jahr if socialh2==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Fraction of income") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\share_miete2`i'.pdf", replace

line share_miete3_def`i' jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line share_miete1_def`i' jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Fraction of income") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\share_miete3`i'.pdf", replace

line share_miete4_def`i' jahr if socialh1==1 & jahr>=1995  & jahr<2018 & jahr!=2015 || line share_miete1_def`i' jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Fraction of income") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\share_miete4`i'.pdf", replace

line share_miete5_def`i' jahr if socialh1==1 & jahr>=1995  & jahr<2018 & jahr!=2015 || line share_miete1_def`i' jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Fraction of income") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\share_miete5`i'.pdf", replace
}






*****Apparently social housing does not appear to be working that well, if I understand this correctly? 
*IS this because rents are not that much cheaper in social housing?
bysort jahr socialh1:egen mean_miete1=mean(miete) if preincome<25000
line mean_miete1 jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_miete1 jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Miete") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\miete1_unter25000.pdf", replace

bysort jahr socialh1:egen mean_miete2=mean(miete)
line mean_miete2 jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_miete2 jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Miete") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\miete2.pdf", replace

replace rent=. if rent==0
bysort jahr socialh1:egen mean_miete3=mean(rent)
line mean_miete3 jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_miete3 jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Miete (Pequiv Files)") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\miete3.pdf", replace



bysort jahr socialh1:egen mean_share3=mean(share_miete5)
line mean_share3 jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_share3 jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Miete") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\share_miete3.pdf", replace

*Or because wages are substantially lower? 
bysort jahr socialh1:egen mean_preincome=mean(preincome)
line mean_preincome jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_preincome jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Preincome") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\preincome.pdf", replace

bysort jahr socialh1:egen mean_postincome=mean(postincome)
line mean_postincome jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_postincome jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Postincome") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\postincome.pdf", replace

bysort jahr socialh1:egen mean_netto=mean(netto)
line mean_netto jahr if socialh1==1 & jahr>=1995 & jahr<2018 & jahr!=2015 || line mean_netto  jahr if socialh1==0 & jahr>=1995 & jahr!=2015 , graphregion(color(white)) ytitle("Net Income") xtitle("Year")  legend(label(1 "Social Housing") label(2 "No Social Housing"))
graph export "$graphpath\netto.pdf", replace




****Can we explain this by the fact that social housing is in more densely populated areas, quality of social housing is better, people in social housing have less children? 
replace share_miete2=. if share_miete2<0



************************************************************************************************
***********************************************************************************************
**********************Regression of Social Housing on Rent Share************************************

foreach num of numlist 2 {
	reghdfe share_miete`num' socialh1, absorb(jahr) vce(robust)
	est sto reg1`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 [aw=hhweight], absorb(jahr) vce(robust)
	est sto reg2`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd ysumm

	reghdfe share_miete`num' socialh1 housingsatisfaction size squarefootage i.baujahr yearsinhouse  operating $missingcontrols1, absorb(jahr) vce(robust)
	est sto reg3`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 housingsatisfaction size squarefootage i.baujahr yearsinhouse $missingcontrols1 [aw=hhweight], absorb(jahr) vce(robust)
	est sto reg4`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 laborincome, absorb(jahr) vce(robust)
	est sto reg5`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 laborincome [aw=hhweight], absorb(jahr) vce(robust)
	est sto reg6`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "No", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 laborincome, absorb(jahr gemeindetyp) vce(robust)
	est sto reg7`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 laborincome [aw=hhweight], absorb(jahr gemeindetyp) vce(robust)
	est sto reg8`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd ysumm
	
	reghdfe share_miete`num' socialh1 laborincome housingsatisfaction size squarefootage i.baujahr yearsinhouse $missingcontrols1 [aw=hhweight], absorb(jahr gemeindetyp) vce(robust)
	est sto reg9`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd ysumm
	reghdfe share_miete`num' socialh1 laborincome  housingsatisfaction size squarefootage i.baujahr yearsinhouse operating $missingcontrols1  [aw=hhweight], absorb(jahr gemeindetyp) vce(robust)
	est sto reg10`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd ysumm
	reghdfe share_miete`num' socialh1 laborincome  housingsatisfaction size squarefootage i.baujahr yearsinhouse operating $missingcontrols1 [aw=hhweight], absorb(jahr gemeindetyp) vce(robust)
	est sto reg11`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd ysumm
	reghdfe share_miete`num' socialh1 laborincome housingsatisfaction size squarefootage i.baujahr apartsize operating rentreduced yearsinhouse $missingcontrols1 [aw=hhweight], absorb(jahr gemeindetyp) vce(robust)
	est sto reg12`num'
	estadd local yearfe "Yes", replace
	estadd local gemeindefe "Yes", replace
	estadd ysumm
	
}


*********Make Tables for the Regression Results**********************

foreach num of numlist 2 {
esttab reg1`num' reg2`num' reg3`num' reg4`num' using "$tablepath\tab1`num'.tex", replace noconstant title("House Characteristics") mtitles("Unweighted" "Weighted" "Unweighted" "Weighted")  cells(b(star fmt(%9.3f)) se(par)) stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f ) label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) drop($missingcontrols1  1.baujahr ) collabels(none) starl(* .10 ** .05 *** .01) label 

esttab reg5`num' reg6`num' reg7`num' reg8`num' using "$tablepath\tab2`num'.tex", replace noconstant title("Income and Location") mtitles("Unweighted" "Weighted" "Unweighted" "Weighted") cells(b(star fmt(%9.3f)) se(par)) stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f ) label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label 

esttab reg9`num' reg10`num' reg11`num' reg12`num' using "$tablepath\tab3`num'.tex", replace noconstant drop($missingcontrols1 1.baujahr )  title("Income and Location") nomtitles  cells(b(star fmt(%9.3f)) se(par)) stats( gemeindefe yearfe ymean N r2, fmt(%9.0g %9.0g %9.2f %9.0g  %9.3f ) label("Gemeinde FE" "Year FE"  "Mean" "Observations" "R-squared" )) collabels(none) starl(* .10 ** .05 *** .01) label 

}



**********Residualplots******
binscatter share_miete1 netto if netto<=100000, by(socialh1)  graphregion(color(white))  ytitle("Rent Share") xtitle("Net Income")
graph export "$graphpath/resid_income_rentshare1.pdf", replace

binscatter share_miete2 preincome if preincome<=100000, by(socialh1) graphregion(color(white)) ytitle("Rent Share") xtitle("Income pre Transfers")
graph export "$graphpath/resid_income_rentshare2.pdf", replace

binscatter share_miete3 postincome if postincome<=100000, by(socialh1) graphregion(color(white))  ytitle("Rent Share") xtitle("Income post Transfers")
graph export "$graphpath/resid_income_rentshare3.pdf", replace

binscatter share_miete1 netto if netto<=100000, by(socialh1) controls(housingsatisfaction size squarefootage i.baujahr i.jahr i.gemeindetyp $missingcontrols1)  graphregion(color(white)) ytitle("Rent Share") xtitle("Net Income")
graph export "$graphpath/resid_income_rentshare4.pdf", replace


binscatter miete netto, by(socialh1)  graphregion(color(white)) ytitle("Rent") xtitle("Net Income")
graph export "$graphpath/resid_miete_income1.pdf", replace

binscatter miete preincome,  by(socialh1)  graphregion(color(white))  ytitle("Rent") xtitle("Income pre Transfers")
graph export "$graphpath/resid_miete_income2.pdf", replace

binscatter miete postincome, by(socialh1)  graphregion(color(white)) ytitle("Rent") xtitle("Income post Transfers")
graph export "$graphpath/resid_miete_income3.pdf", replace




*****Generate a counterfactual rent share on the housing market****
reg share_miete1 housingsatisfaction size squarefootage i.baujahr i.jahr i.gemeindetyp $missingcontrols1 [aw=hhweight] if socialh1==0 
*predict hat_share_miete1, xb

binscatter hat_share_miete1 share_miete1 netto if socialh1==1, graphregion(color(white)) ytitle("Rent Share") xtitle("Net Income") legend(label(1 "Counterfactual rent") label(2 "Actual rent"))
graph export "$graphpath/resid_income_rentshare5.pdf", replace



***Only based on 10.693 observations, who received below market rent
*graph export "$graphpath/resid_income_rentshare6.pdf", replace



****Separated by social housing vs. not social housing
binscatter hat_share_miete1 netto, by(socialh1) graphregion(color(white))  ytitle("Rent Share") xtitle("Net Income") 
graph export "$graphpath/resid_income_rentshare7.pdf", replace
// Project: Social Housing
// Creation Date: 18-04-2024
// Last Update: 18-04-2024
// Author: Laura Arnemann & Max GM
// Goal: Descriptive Statistics



********************************************************************
*  First Merge
********************************************************************
* Summary Table with descriptive statistics 

use "${TEMP}/socialhousing_analysis.dta", clear

drop if PLR_ID =="03400831"
* No Social Housing observations for Pankower Tor

* encode PLR_ID, gen(plr_code)
label var wohnungen "Anzahl Wohnungen"
label var share "Share Social Housing"

estpost sum share wohnungen mietekalt qm_miete_kalt objects, detail
est sto housingvars
esttab housingvars using "${output}/descriptives/maintable.tex", replace cells("mean(fmt(%9.2f)) sd(fmt(%9.2f)) p25(fmt(%9.2f)) p50(fmt(%9.2f))  p75(fmt(%9.2f)) count(fmt(%9.0g))") nonum label noobs collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Std.Dev.}} \multicolumn{1}{l}{{25thPerc.}} \multicolumn{1}{l}{{Median}} \multicolumn{1}{l}{{75thPerc.}} \multicolumn{1}{l}{{Obs}}) 


table treated if a100_r==1 & inrange(jahr,2010,2019), ///
    statistic(mean qm_miete_kalt e_e wohnungen) ///
    statistic(sd qm_miete_kalt e_e wohnungen) ///
    statistic(count qm_miete_kalt) ///
    nformat(%9.2f)

asdoc tabstat qm_miete_kalt e_e wohnungen if a100_r==1 & inrange(jahr,2010,2019), ///
    by(treated) stats(mean sd n) columns(stat) ///
    title(Balance Table: Treated vs Control) replace
	
collapse (mean) qm_miete_kalt e_e wohnungen (sd)   qm_miete_kalt e_e wohnungen (count) qm_miete_kalt, by(treated)

use "${TEMP}/socialhousing_analysis.dta", clear

collapse (mean) mean_rent = qm_miete_kalt mean_pop = e_e mean_wohn = wohnungen (semean) se_rent = qm_miete_kalt se_pop = e_e se_wohn = wohnungen (count) objects if a100_r==1 & inrange(jahr,2010,2019), by(treated)


list

********************************************************************
* 
********************************************************************
* Evolution of social housing in treated and untreated over time

* Histogram with large changes 

use "${TEMP}/socialhousing_analysis.dta", clear

drop if PLR_ID =="03400831"


/*
sum d_socialh if d_socialh!=0, d
                          d_socialh
-------------------------------------------------------------
      Percentiles      Smallest
 1%            1              1
 5%            1              1
10%            1              1       Obs               1,043
25%            3              1       Sum of wgt.       1,043

50%           16                      Mean           58.82359
                        Largest       Std. dev.      149.1487
75%           48           1119
90%          134           1514       Variance       22245.35
95%          252           1678       Skewness       6.550585
99%          671           1895       Kurtosis       59.34814

*/


* distribution of all changes in social housing
hist d_socialh if d_socialh != 0 & d_socialh <= 671, graphregion(color(white)) ///
bin(70) fcolor(red*0.5) lcolor(red*0.5) xtitle("") xlabel(0(50)650)
*1.179 observations
graph export "${output}/max/descriptives/d_socialh_general.pdf", replace 


/*
sum tot_d_socialh if tot_d_socialh!=0, d
                        tot_d_socialh
-------------------------------------------------------------
      Percentiles      Smallest
 1%            1              1
 5%            2              1
10%            4              1       Obs               3,509
25%           19              1       Sum of wgt.       3,509

50%           65                      Mean           192.3292
                        Largest       Std. dev.      367.5067
75%          202           2804
90%          470           2804       Variance       135061.1
95%          830           2804       Skewness       4.032415
99%         1898           2804       Kurtosis       22.34755

*/


* distribution of cumulative changes
hist tot_d_socialh if tot_d_socialh != 0 & tot_d_socialh <= 1898, graphregion(color(white)) ///
bin(70) fcolor(red*0.5) lcolor(red*0.5) xtitle("") xlabel(0(150)1950)
graph export "${output}/max/descriptives/sum_d_socialh_general.pdf", replace 

reghdfe ln_qm_miete_kalt i.tot_dd_socialh if a100 ==1 & inrange(jahr, 2009, 2019), absorb(i.jahr) cl(PLR_ID_num) noomitted noempty noconst level(95)


/*
sum tot_dd_socialh if tot_dd_socialh!=0, d

                       tot_dd_socialh
-------------------------------------------------------------
      Percentiles      Smallest
 1%            1              1
 5%            1              1
10%            1              1       Obs               3,509
25%            2              1       Sum of wgt.       3,509

50%            3                      Mean           3.269592
                        Largest       Std. dev.      1.994645
75%            5              9
90%            6              9       Variance        3.97861
95%            7              9       Skewness        .650297
99%            8              9       Kurtosis       2.547909

*/


* generate cumuluative 
bysort PLR_ID_num: gen sum_c_dd_socialh = sum(c_dd_socialh)

* preserve data
preserve

* ============================================================== *
**# === Figure: Average Change in Social Housing by nth Drop === *
* ============================================================== *
* average cumulative change by teratment group, only keep event time not "persistence"
collapse (mean) y = d_socialh (semean) se_y = d_socialh if c_dd_socialh==1, by(sum_c_dd_socialh)

* compute confidence intervals
gen yu = y + 1.96*se_y
gen yl = y - 1.96*se_y

* modify labels
lab def timing 1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th" 6 "6th" 7 "7th" 8 "8th" 9 "9th" 10 "10th" 11 "11th", modify
lab val sum_c_dd_socialh timing
la li

* graph 
twoway bar ///
y sum_c_dd_socialh, barw(0.5) || ///
rspike yu yl sum_c_dd_socialh, ///
xlabel(1(1)11, valuelabel) xtitle("Social Housing Drop") ///
ytitle("Average Social Housing Change") ///
legend(off)

graph export "${output}/max/descriptives/fig_avg_change_timing.pdf", replace 

* ======================================================================================================= *
**# === Figure: Average Cumulative Social Housing Change by LOR grouped by total social housing drops === *
* ======================================================================================================= *
restore, preserve
* sum dummies by LOR and keep only maximum of sum
* egen tot_dd_socialh = total(c_dd_socialh), by(PLR_ID) // generated above!

* average cumulative change by teratment group
collapse (mean) y = tot_d_socialh (semean) se_y = tot_d_socialh, by(tot_dd_socialh)

* drop control group and all 
drop if tot_dd_socialh==0 | tot_dd_socialh==12
* compute confidence intervals
gen yu = y + 1.96*se_y
gen yl = y - 1.96*se_y

* graph 
twoway bar ///
y tot_dd_socialh, barw(0.5) || ///
rspike yu yl tot_dd_socialh, ///
xlabel(1(1)11) xtitle("Total Social Housing Changes by LOR") ///
ytitle("Average Cumulative Social Housing Change") ///
legend(off)

graph export "${output}/max/descriptives/fig_avg_cum_change_timing.pdf", replace 


* ============================================================================= *
**# === Figure: Share of LORs' by LOR grouped by total social housing drops === *
* ============================================================================= *
restore, preserve

* generate auxiliary variable
g tag = 1

* average change over all years by mximum treated
collapse (count) changes = tag if jahr ==2019, by(tot_dd_socialh)

* sum total changes for 
egen tot_change = sum(changes) if tot_dd_socialh>0

* share of changes
g s_change = changes/tot_change

* 
twoway bar s_change tot_dd_socialh if tot_dd_socialh > 0, ///
xlabel(1(1)12) barw(0.5) xtitle("Total Social Housing Changes by LOR") ytitle("Share of LORs'")

graph export "${output}/max/descriptives/fig_share_change_timing.pdf", replace 

* ========================================================================================================== *
**# === Figure: Average Social Housing Change by nth Change by LOR grouped by total social housing drops === *
* ========================================================================================================== *
restore, preserve

* average change over all years by mximum treated
collapse (mean) y_1 = d_socialh (semean) se_y_1 = d_socialh if sum_c_dd_socialh == 1, by(tot_dd_socialh)

* store as tempfile for maerging
tempfile avg_fist_change 
save `avg_fist_change'

restore, preserve

* average change over all years by mximum treated
collapse (mean) y_2 = d_socialh (semean) se_y_2 = d_socialh if sum_c_dd_socialh == 2, by(tot_dd_socialh)

* merge to average change at first impact
merge m:1 tot_dd_socialh using `avg_fist_change'
drop _merge

* store as tempfile for maerging
tempfile avg_sec_change 
save `avg_sec_change'

restore, preserve

* average change over all years by mximum treated
collapse (mean) y_3 = d_socialh (semean) se_y_3 = d_socialh if sum_c_dd_socialh == 3, by(tot_dd_socialh)

* merge to average change at first + second impact
merge m:1 tot_dd_socialh using `avg_sec_change'
drop _merge

* store as tempfile for maerging
tempfile avg_thr_change 
save `avg_thr_change'

restore, preserve

* average change over all years by mximum treated
collapse (mean) y_4 = d_socialh (semean) se_y_4 = d_socialh if sum_c_dd_socialh == 4, by(tot_dd_socialh)

* merge to average change at first + second impact
merge m:1 tot_dd_socialh using `avg_thr_change'
drop _merge

* store as tempfile for maerging
tempfile avg_for_change 
save `avg_for_change'

restore, preserve

* average change over all years by mximum treated
collapse (mean) y_5 = d_socialh (semean) se_y_5 = d_socialh if sum_c_dd_socialh == 5, by(tot_dd_socialh)

* merge to average change at first + second impact
merge m:1 tot_dd_socialh using `avg_for_change'
drop _merge

* drop control group
drop if tot_dd_socialh == 0

* pivot data longer for plotting
reshape long y_ se_y_, i(tot_dd_socialh) j(change) // note that new variable change needs to be string

* set position
generate position = change    if tot_dd_socialh == 1
replace  position = change+6  if tot_dd_socialh == 2
replace  position = change+12 if tot_dd_socialh == 3
replace  position = change+18 if tot_dd_socialh == 4
replace  position = change+24 if tot_dd_socialh == 5
replace  position = change+30 if tot_dd_socialh == 6
replace  position = change+36 if tot_dd_socialh == 7
replace  position = change+42 if tot_dd_socialh == 8
replace  position = change+48 if tot_dd_socialh == 9
replace  position = change+54 if tot_dd_socialh == 10
replace  position = change+60 if tot_dd_socialh == 11

* br PLR_ID jahr d_socialh c_dd_socialh sum_c_dd_socialh
* compute confidence intervals
gen yu = y_ + 1.96 * se_y_
gen yl = y_ - 1.96 * se_y_

* graph
twoway (bar y_ position if change==1) ///
       (bar y_ position if change==2) ///
       (bar y_ position if change==3) ///
	   (bar y_ position if change==4) ///
	   (bar y_ position if change==5) ///
       (rcap yl yu position), ///
       legend( order(1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th") )

graph export "${output}/max/descriptives/fig_avg_change_nth_timing.pdf", replace 

twoway bar ///
y tot_dd_socialh, barw(0.5) || ///
rspike yu yl tot_dd_socialh, ///
xlabel(1(1)11) xtitle("Total Social Housing Changes by LOR") ///
ytitle("Average First Social Housing Change") ///
legend(off)


* graph 
twoway bar ///
y tot_dd_socialh, barw(0.5) || ///
rspike yu yl tot_dd_socialh, ///
xlabel(1(1)11) xtitle("Total Social Housing Changes by LOR") ///
ytitle("Average First Social Housing Change") ///
legend(off)

graph export "${output}/max/descriptives/fig_avg_first_change_timing.pdf", replace 

xxx
twoway (tot_d_socialh tot_dd_socialh if jahr==2019, color(green) ) ///
       (histogram share if jahr==2020 & inrange(share,-5,5) ,  fcolor(none) lcolor(black) ), ///
	   legend(order(1 "2010" 2 "2020" ))
	   graph export "${output}/shares_2010_2020_inrange55.pdf", replace 

	   
* share of lors experiencing a number if treats

gen share_2010 = share if jahr==2010
bysort PLR_ID: egen max_share_2010 = max(share_2010)

* Cross-Sectional Histograms
twoway (histogram share if jahr==2010 , color(green) ) ///
       (histogram share if jahr==2020,  fcolor(none) lcolor(black) ),  ///
	   legend(order(1 "2010" 2 "2020" ))
graph export "${output}/shares_2010_2020.pdf", replace 

twoway (histogram share if jahr==2010 & inrange(share,-5,5)  , color(green) ) ///
       (histogram share if jahr==2020 & inrange(share,-5,5) ,  fcolor(none) lcolor(black) ), ///
	   legend(order(1 "2010" 2 "2020" ))
	   graph export "${output}/shares_2010_2020_inrange55.pdf", replace 

	   twoway (histogram share if jahr==2010 & max_share_2010>=10  , color(green) ) ///
       (histogram share if jahr==2020 & max_share_2010>=10  ,  fcolor(none) lcolor(black) ), ///
	   legend(order(1 "2010" 2 "2020" ))
	    graph export "${output}/shares_2010_2020_share2010_10.pdf", replace 



********************************************
* Making some first graphs 
********************************************

foreach var of varlist change_share1 change_share2 {
	
	if "`var'"== "change_share1" local a "hare2010_2022"
	if "`var'"== "change_share2" local a "hare2010_2014"
	
	
hist `var', graphregion(color(white)) fcolor(red*0.5) lcolor(red*0.5) xtitle("Change 2010-2022")
graph export "${output}/share`a'_general.pdf", replace 

hist `var' if inrange(change_share1,-5,5), graphregion(color(white)) fcolor(red*0.5) lcolor(red*0.5) xtitle("Change 2010-2022")
*5.608 observations 
graph export "${output}/s`a'_inrange55.pdf", replace 

hist `var' if change_share1<=-1, graphregion(color(white)) fcolor(red*0.5) lcolor(red*0.5) xtitle("Change 2010-2022")
*2967 observatsion 
graph export "${output}/s`a'_inrange1.pdf", replace 

hist `var' if change_share1<-5, graphregion(color(white)) fcolor(red*0.5) lcolor(red*0.5) xtitle("Change 2010-2022")
*1.179 observations
graph export "${output}/s`a'_inrange5.pdf", replace 

hist `var' if change_share1!=0, graphregion(color(white)) fcolor(red*0.5) lcolor(red*0.5) xtitle("Change 2010-2022")
*1.179 observations
graph export "${output}/s`a'_inrange5_wo0.pdf", replace 
}


* Some Binscatter Plots 
binscatter mietekalt share, nq(50)
graph export "${output}/descriptives/binscatter/miete1.png", replace 

binscatter mietekalt share if share<=20, nq(50)
graph export "${output}/descriptives/binscatter/miete1_share20.png", replace

binscatter mietekalt share if share<=10, nq(50)
graph export "${output}/descriptives/binscatter/miete1_share10.png", replace 

binscatter mietekalt share if share<=10 & share>0, nq(50)
graph export "${output}/descriptives/binscatter/miete1_share10_0.png", replace 


* Same graph but now with controls for year and plz 
binscatter mietekalt share, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/miete1_c.png", replace 

binscatter mietekalt share if share<=20, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/miete1_share20_c.png", replace 

binscatter mietekalt share if share<=10, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/miete1_share10_c.png", replace  

binscatter mietekalt share if share<=10 & share>0, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/miete1_share10_0_c.png", replace 



* Rent per Sqm 

* Some Binscatter Plots 
binscatter qm_miete_kalt share, nq(50)
graph export "${output}/descriptives/binscatter/qm_miete1.png", replace 

binscatter qm_miete_kalt share if share<=20, nq(50)
graph export "${output}/descriptives/binscatter/qm_miete1_share20.png", replace

binscatter qm_miete_kalt share if share<=10, nq(50)
graph export "${output}/descriptives/binscatter/qm_miete1_share10.png", replace 

binscatter qm_miete_kalt share if share<=10 & share>0, nq(50)
graph export "${output}/descriptives/binscatter/qm_miete1_share10_0.png", replace 

* Same graph but now with controls for year and plz 
binscatter qm_miete_kalt share, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/qm_miete1_c.png", replace 

binscatter qm_miete_kalt share if share<=20, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/qm_miete1_share20_c.png", replace 

binscatter qm_miete_kalt share if share<=10, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/qm_miete1_share10_c.png", replace  

binscatter qm_miete_kalt share if share<=10 & share>0, nq(50) controls(i.jahr i.plr_code)
graph export "${output}/descriptives/binscatter/qm_miete1_share10_0_c.png", replace 



line s_objects jahr 


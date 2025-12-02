/// PROJECT: Housing Policy
/// GOAL: Regressions on object level 
/// AUTHOR: MGM
/// CREATION: 24.10.2024
/// LAST UPDATE: 
/// SOURCE: *

* uplouad dataframe
use "$TEMP/socialhousing_analysis.dta", clear

* drop treated
drop treated

* check 
tab qua_d_socialh

* ====================================================== *
**# === Treatment: 1st change/drop in social housing === *
* ====================================================== *
* dummy equal to if they had a change ever
g treated = 1 if tot_d_socialh>0

* dummy equal to if they had a change ever
g d_treat = 0 if treated!=.
replace d_treat = 1 if tot_d_socialh>0 

* within quartile 
* In Görli

* generate 1st year of largest change in public housing units
g change_year = jahr if d_socialh > 0 & d_socialh!=.

* expand treatment year by group
egen first_treat = min(change_year), by(PLR_ID)

* set time to treatment
gen rel_time = .     // time - first_treat
replace rel_time = jahr - first_treat

* set treatment scale at first treatment
gen first_change = d_socialh if rel_time == 0

br treated tot_d_socialh first_treat change_year
* set treatment dummy back by one period to have t=-1 as base
gen dynamic_first_treat = 1 if rel_time>=0
replace dynamic_first_treat = 0 if rel_time<0

br PLR_ID_num jahr rel_time d_socialh first_treat treated if tot_d_socialh>230 &  inrange(rel_time, -6, 6) & inrange(jahr, 2010, 2019)

/* Distribution of changes in social housing
. sum d_socialh if d_socialh>0, d

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
* check distribution of positive shocks in cumulative group
hist first_change if qua_d_socialh == 4 & d_socialh>0
sum first_change if qua_d_socialh == 4, d
sum sum_d_socialh if sum_d_socialh>0, d
sum d_socialh if d_socialh>0, d

* ============================================================ *
**# === Treatment: 1st above median drop in social housing === *
* ============================================================ *
* year in which above median units drop first
g change_year_med = jahr if d_socialh >= 16 & d_socialh!=.

* expand treatment year by group
egen first_treat_med = min(change_year_med), by(PLR_ID)

* set treatment scale at first treatment if change is above median changes
gen rel_time_med = .     // time - first_treat
replace rel_time_med = jahr - first_treat_med

* size of median change
gen first_change_med = d_socialh if rel_time_med == 0

* average social housing drop
egen avg_d_change = mean(d_socialh) if d_socialh >0, by(PLR_ID)
egen avg2_d_change = min(avg_d_change), by(PLR_ID)

* set treatment dummy back by one period to have t=-1 as base
gen dynamic_first_treat_med = 1 if rel_time_med>=0
replace dynamic_first_treat_med = 0 if rel_time_med<0

* ================================================================== *
**# === Treatment: 1st accumulated change/drop in social housing === *
* ================================================================== *
* dummy equal to if they had a change ever
g change_year_sum = jahr if sum_d_socialh >= 16 & d_socialh != .

* dummy equal to if they had a change ever
g d_treat_sum = 0 if treated!=.
replace d_treat_sum = 1 if sum_d_socialh >= 16 & d_socialh != .

* expand treatment year by group
egen first_treat_sum = min(change_year_sum), by(PLR_ID)

* set time to treatment
gen rel_time_sum = .     // time - first_treat
replace rel_time_sum = jahr - first_treat_sum

* size of first accumulated change
gen first_change_sum = sum_d_socialh if rel_time_sum == 0

* set treatment dummy back by one period to have t=-1 as base
gen dynamic_first_treat_sum = 1 if rel_time_med>=0
replace dynamic_first_treat_sum = 0 if rel_time_med<0

did_multiplegt_dyn qm_miete_kalt PLR_ID_num jahr dynamic_first_treat if inrange(jahr, 2007, 2019) & a100==1, effects(5) placebo(3) cluster(PLR_ID_num)
did_multiplegt_dyn qm_miete_kalt PLR_ID_num jahr dynamic_first_treat_med if inrange(jahr, 2007, 2019) & a100==1, effects(5) placebo(3) cluster(PLR_ID_num)
did_multiplegt_dyn qm_miete_kalt PLR_ID_num jahr dynamic_first_treat_sum if inrange(jahr, 2007, 2019) & a100==1, effects(5) placebo(3) cluster(PLR_ID_num)

* =========================================== *
**# === QUALITY CONTROL: Check treatments === *
* =========================================== *
br PLR_ID_num jahr rel_time_med d_socialh first_change_med tot_d_socialh avg2_d_change if inrange(rel_time, -6, 6) & inrange(jahr, 2010, 2019)

* browse thorugh treatment timing
br PLR_ID_num jahr rel_time_sum d_socialh sum_d_socialh first_change_sum first_change_med first_change shchange
br PLR_ID_num jahr rel_time_sum d_socialh sum_d_socialh change_year change_year_med change_year_sum

* summarize treatment year
sum change_year_sum change_year_med change_year
* only large treatments
xxx
**# Bookmark #5
* 1st change treatment
* all
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time, -6, 6), ivar(PLR_ID_num) time(jahr) gvar(first_treat) method(dripw) notyet
estat event, estore(cs_g1)
event_plot cs_g1, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* within A100
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time, -6, 6) & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat) method(dripw) notyet
estat event, estore(cs_g1_a100)
event_plot cs_g1_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* outside A100
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time, -6, 6) & a100==0, ivar(PLR_ID_num) time(jahr) gvar(first_treat) notyet
estat event, estore(cs_g1_noa100)
event_plot cs_g1_noa100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

**# Bookmark #4
* medium change treatment
* all
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time_med, -6, 6), ivar(PLR_ID_num) time(jahr) gvar(first_treat_med) notyet
estat event, estore(cs_g2)
event_plot cs_g2, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* within A100
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time_med, -6, 6) & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat_med) notyet
estat event, estore(cs_g2_a100)
event_plot cs_g2_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* outside A100
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time_med, -6, 6) & a100==0, ivar(PLR_ID_num) time(jahr) gvar(first_treat_med) notyet
estat event, estore(cs_g2_noa100)
event_plot cs_g2_noa100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

**# Bookmark #3
* 1st change treatment
* all
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time_sum, -6, 6), ivar(PLR_ID_num) time(jahr) gvar(first_treat_sum) method(dripw) notyet
estat event, estore(cs_g3)
event_plot cs_g3, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* within A100
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time_sum, -6, 6) & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat_sum) method(dripw) notyet
estat event, estore(cs_g3_a100)
event_plot cs_g3_a100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

* outside A100
csdid qm_miete_kalt wohnungen if inrange(jahr, 2009, 2019) & inrange(rel_time_sum, -6, 6) & a100==0, ivar(PLR_ID_num) time(jahr) gvar(first_treat_sum) method(dripw) notyet
estat event, estore(cs_g3_noa100)
event_plot cs_g3_noa100, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together


csdid qm_miete_kalt if inrange(jahr, 2010, 2019) & inrange(rel_time, -6, 6) & qua_d_socialh==1 & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat) notyet
estat event, estore(cs_g1)
event_plot cs_g1, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

csdid qm_miete_kalt if inrange(jahr, 2010, 2019)  & inrange(rel_time, -6, 6) & qua_d_socialh==2 & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat) notyet
estat event, estore(cs_g2)
event_plot cs_g2, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

csdid qm_miete_kalt if inrange(jahr, 2010, 2019)  & inrange(rel_time, -6, 6) & qua_d_socialh==3 & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat) notyet
estat event, estore(cs_g3)
event_plot cs_g3, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together

csdid qm_miete_kalt if inrange(jahr, 2010, 2019)  & inrange(rel_time, -6, 6) & qua_d_socialh==4 & a100==1, ivar(PLR_ID_num) time(jahr) gvar(first_treat) notyet
estat event, estore(cs_g4)
event_plot cs_g4, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-4(1)4)) stub_lag(Tp#) stub_lead(Tm#) together









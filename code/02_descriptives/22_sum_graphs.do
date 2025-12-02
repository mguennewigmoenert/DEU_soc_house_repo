*==============================================================*
* 7) Bar: total social housing units by year
*    + line: % of total stock (2nd y-axis)
*==============================================================*

clear all
set more off

*==============================================================*
* 1) Load data and restrict years
*==============================================================*
use "${TEMP}/socialhousing_1_since2008.dta", clear

* Keep analysis window
keep if inrange(jahr, 2010, 2019)

*==============================================================*
* 2) Merge with A100 ring
*==============================================================*
merge m:1 PLR_ID using "${TEMP}/autoring_lor.dta"

gen a100_r = (auto_ring == 1)
drop _merge

* Label inside vs outside ring
label define a100lab 0 "Outside A100" 1 "Inside A100"
label values a100_r a100lab

*==============================================================*
* 3) Panel setup and year-on-year change
*==============================================================*
encode PLR_ID, gen(plr_id_n)
xtset plr_id_n jahr, yearly

* Year-on-year change in social housing per LOR
gen d_socialh = d.socialh
replace d_socialh = . if _n == 1   // first obs per PLR has no prior year

* New construction: only positive changes (absolute units)
gen new_sh = cond(d_socialh > 0, d_socialh, 0)

*==============================================================*
* 4) Collapse to year × A100 ring
*==============================================================*
collapse (sum) socialh wohnungen new_sh, by(jahr a100_r)

* Share of social housing in total stock (%)
gen share_sh = 100 * socialh / wohnungen

* Quick check
list jahr a100_r socialh new_sh share_sh, sepby(jahr) noobs

*==============================================================*
* 5) Positions for clustered bars (twoway)
*==============================================================*
gen x_in  = jahr - 0.15 if a100_r == 1   // inside A100
gen x_out = jahr + 0.15 if a100_r == 0   // outside A100

replace socialh = socialh / 1000

twoway ///
    (bar socialh x_out if a100_r==0, ///
        barwidth(0.25) ///
        fcolor(navy*0.6) lcolor(navy*0.6) ///
        yaxis(1)) ///
    (bar socialh x_in  if a100_r==1, ///
        barwidth(0.25) ///
        fcolor(midblue*0.6) lcolor(midblue*0.6) ///
        yaxis(1) ) ///
    ( line share_sh x_out if a100_r==0, ///
        yaxis(2) ///
        lcolor(navy*0.6) lwidth(thick) ///
        msymbol(circle) mcolor(navy*0.6) ) ///
    (line share_sh x_in if a100_r==1, ///
        yaxis(2) ///
        lcolor(midblue*0.6) lwidth(thick) ///
        msymbol(triangle) mcolor(midblue*0.6) ), ///
    ytitle("Total social housing units (in 1,000)", axis(1)) ///
    ytitle("Social housing as % of total stock", axis(2)) ///
    ///
    yscale( axis(1) ) ///
    /// ylab(10000(20000)120000, axis(1)) ///
    ///
	/// yscale(log axis(1)) ///
	/// ylab(0 500 1500 50000 110000, axis(1)) ///
	ylabel(, angle(0) grid valuel glc(gs2) glp(dot)) ///
    xtitle("Year") ///
    xlabel(2010(1)2019, angle(45)) ///
    ///
    legend(order(2 "Inside A100" ///
				 1 "Outside A100" ///
                 ) ///
           cols(2) position(2) ring(0) region(lstyle(none))) ///
    ///
    /// title("Social Housing: Stock and New Construction by A100 Ring (2010–2019)") ///
    scheme(s1color)
	
graph export "$output/graphs/socialh/fig_socialhousing_stock.pdf", replace

twoway ///
    (bar new_sh x_out if a100_r==0 & jahr > 2010, ///
        barwidth(0.25) ///
        fcolor(navy*0.6) lcolor(navy*0.6) ///
        yaxis(1)) ///
    (bar new_sh x_in  if a100_r==1 & jahr > 2010, ///
        barwidth(0.25) ///
        fcolor(midblue*0.6) lcolor(midblue*0.6) ///
        yaxis(1) ), ///
    ytitle("New social housing (units per year)", axis(1)) ///
    ///
    yscale(axis(1) range(0 1500)) ///
    ylab(0(250)1500, axis(1)) ///
	ylabel(, angle(0) grid valuel glc(gs2) glp(dot)) ///
     ///
    xtitle("Year") ///
    xlabel(2011(1)2019, angle(45)) ///
    ///
    legend(order(2 "Inside A100" ///
				 1 "Outside A100" ///
                 ) ///
           cols(2) position(1) ring(0) region(lstyle(none))) ///
    ///
    /// title("Social Housing: Stock and New Construction by A100 Ring (2010–2019)") ///
    scheme(s1color)
	
graph export "$output/graphs/socialh/fig_socialhousing_new.pdf", replace


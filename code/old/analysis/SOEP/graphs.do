***Preliminary Regressions***
set more off 
clear all 
capture log close 
macro drop all

global datapath C:/Users/laura/Desktop/SocialHousing/data/Stadtdaten/data_bearbeitet
global graphpath C:/Users/laura/Desktop/SocialHousing/data/Stadtdaten/output/graphs
use "$datapath/housing_merged.dta", clear


replace pop_sh=total_sh/population
gen ln_pop_sh=log(pop_sh)
gen ln_share_sh=log(share_sh)
gen house_capita=housing_stock/population



*****Make descriptives about the evolution of certain variables****
bysort year city: egen total_sh_city=total(total_sh)
bysort year city: egen share_sh_city=mean(share_sh)
bysort year city: egen pop_sh_city=mean(pop_sh)
bysort year city: egen house_capita_city=mean(house_capita)
bysort year city: egen rent_city=mean(miet_mean)





**Replace the missing values with values from previous years
gen totalsh2=total_sh
duplicates tag Stadtteil year, gen(dup)
tab city if dup>1 
*no duplicates in terms of Stadtteil and year for Munich
sort Stadtteil year
by Stadtteil: replace city=city[_n-1] if missing(city) & city[_n-1]=="Munich"
bysort year city: egen total_shcity=total(totalsh2)
sort city year
by city: replace total_shcity=total_shcity[_n-1] if total_shcity==0 & city=="Munich"




replace year=year+1 if city=="Hamburg"

*****Smoking Gun Graph****
bysort year: egen socialhy=total(total_shcity)
replace socialhy=socialhy/100000
bysort year: egen renty = mean(miet_mean)
bysort year: egen mean_sharesh=mean(share_sh_city)


twoway line socialhy year if  year>=2010  & year<=2018, yaxis(1)|| line renty year if  year>=2009  & year<=2018, yaxis(2) ||, graphregion(color(white)) xtitle("Years") ytitle("Social Housing (units in 100.000)") ytitle("Rent (mean)", axis(2)) xlabel(2009(3)2018) legend(label(1 "Social housing stock") label(2 "Rent (mean)"))
graph export "$graphpath/rent_totalsh_overall.pdf",  replace 

twoway line mean_sharesh year if  year>=2010  & year<=2018, yaxis(1)|| line renty year if  year>=2009  & year<=2018, yaxis(2) ||, graphregion(color(white)) xtitle("Years")  ytitle( "Share of social housing (mean)") ytitle("Rent (mean)", axis(2)) xlabel(2009(3)2018) legend(label(1 "Share social housing") label(2 "Rent (mean)"))
graph export "$graphpath/rent_sharesh_overall.pdf",  replace 

*generate the totals for all cities, the biggest four and every city

bysort year: egen total_sh4city=total(total_shcity) if city=="Hamburg"  | city=="Berlin" | city=="Cologne" | city=="Munich"
replace total_sh4city=total_sh4city/100000
bysort year: egen renty4city=mean(renty) if city=="Hamburg" | city=="Munich" | city=="Berlin" | city=="Cologne"


*****Evolution of Rent Social Housing stock in the 4 biggest cities in Germany***
*total
twoway line total_sh4city year if  year>=2010 & year<=2018 , yaxis(1)|| line renty4city year if  year>=2010  & year<=2018 , yaxis(2) ||, graphregion(color(white)) xtitle("Years") ytitle("Social Housing (units in 100.000)") ytitle("Rent (mean)", axis(2)) xlabel(2009(3)2018) legend(label(1 "Social housing stock") label(2 "Rent (mean)"))
graph export "$graphpath/rent_totalsh_4city.pdf",  replace 



foreach city in Hamburg Berlin Cologne {
twoway line total_shcity year if  year>=2009 & year<=2018 & city=="`city'", yaxis(1)|| line rent_city year if  year>=2009  & year<=2018 & city=="`city'", yaxis(2) ||, graphregion(color(white)) xtitle("Years") ytitle("Social Housing (units)") ytitle("Rent (mean)", axis(2)) xlabel(2009(3)2018) legend(label(1 "Social housing stock") label(2 "Rent (mean)")) title("`city'")
graph export "$graphpath/rent_totalsh_`city'.pdf",  replace 
}

*housing stock for Munich not available, so we do not have any information on the share of social housing
foreach city in Hamburg  Berlin Cologne {
twoway line share_sh_city year if  year>=2009  & year<=2018 & city=="`city'", yaxis(1)|| line rent_city year if  year>=2009  & year<=2018 & city=="`city'", yaxis(2) ||, graphregion(color(white)) xtitle("Years") ytitle("Share social housing") ytitle("Rent (mean)", axis(2)) xlabel(2009(3)2018) legend(label(1 "Share social housing") label(2 "Rent (mean)")) title("`city'")
graph export "$graphpath/rent_share_sh_`city'.pdf", replace 	
}


***************************************************************************************************************************************************************************************************Graphs for Cities Individually******************************************


line pop_sh_city year if city=="Stuttgart" & year>=2009  & year<=2018 & year!=2016 ||line pop_sh_city year if city=="Hamburg" & year>=2009  & year<=2018   || line pop_sh_city year if city=="Munich" & year>=2009  & year<=2018 || line pop_sh_city year if city=="Frankfurt" & year>=2009 & year<=2018  ||line pop_sh_city year if city=="Cologne" & year>=2009  & year<=2018  || line pop_sh_city year if city=="Berlin" & year>=2009  & year<=2018  ||line pop_sh_city year if city=="Dortmund" & year>=2009  & year<=2018  || line pop_sh_city year if city=="Dusseldorf" & year>=2009  & year<=2018  , graphregion(color(white)) legend(label(1 "Stuttgart") label(2 "Hamburg") label(3 "Munich")label(4 "Frankfurt") label(5 "Cologne") label(6 "Berlin") label(7 "Dortmund")  label(8 "Dusseldorf")) xtitle("Years") ytitle("Social Housing by population") xlabel(2009(3)2018)
graph export "$graphpath/pop_sh_overview.pdf",  replace 

 line share_sh_city year if city=="Stuttgart" & year>=2009  & year<=2018   ||line share_sh_city year if city=="Hamburg" & year>=2009  & year<=2018   || line share_sh_city year if city=="Frankfurt" & year>=2009  & year<=2018  ||line pop_sh_city year if city=="Cologne" & year>=2009  & year<=2018  || line share_sh_city year if city=="Berlin" & year>=2009  & year<=2018  ||line share_sh_city year if city=="Dortmund" & year>=2009  & year<=2018  || line share_sh_city year if city=="Dusseldorf" & year>=2009  & year<=2018  , graphregion(color(white)) legend(label(1 "Stuttgart") label(2 "Hamburg") label(3 "Munich")label(3 "Frankfurt") label(4 "Cologne") label(5 "Berlin") label(6 "Dortmund")  label(7 "Dusseldorf")) xtitle("Years") ytitle("Share of Social Housing") xlabel(2009(3)2018)
graph export "$graphpath/share_sh_overview.pdf",  replace 


 line house_capita_city year if city=="Stuttgart" & year>=2009  & year<=2018   ||line house_capita_city year if city=="Hamburg" & year>=2009  & year<=2018   || line house_capita_city year if city=="Frankfurt" & year>=2009  & year<=2018  ||line house_capita_city year if city=="Cologne" & year>=2009  & year<=2018  || line house_capita_city year if city=="Berlin" & year>=2009  & year<=2018  ||line house_capita_city year if city=="Dortmund" & year>=2009  & year<=2018  || line house_capita_city year if city=="Dusseldorf" & year>=2009  & year<=2018  , graphregion(color(white)) legend(label(1 "Stuttgart") label(2 "Hamburg") label(3 "Munich")label(3 "Frankfurt") label(4 "Cologne") label(5 "Berlin") label(6 "Dortmund")  label(7 "Dusseldorf")) xtitle("Years") ytitle("Housing per Capita") xlabel(2009(3)2018)
graph export "$graphpath/housing_capita_overview.pdf",  replace 

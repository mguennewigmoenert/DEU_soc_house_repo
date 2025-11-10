******Do File Social Housing****

set more off
capture log close 
clear all 

global rawpath /Users/lauraarnemann/Dropbox/Housing Project/raw_data
global datapath /Users/lauraarnemann/Dropbox/Housing Project/Stata_data
global path C:\Users\laura\Desktop\Social_Housing\data

****Wohnungsbestand ****
foreach city in Berlin Cologne Dortmund Dusseldorf Hamburg Frankfurt {

import excel "C:\Users\laura\Desktop\Social_Housing\Wohnungsbestand_21_07.xlsx", sheet("`city'") firstrow clear

foreach v of varlist B C D E F G H I J K {
   local x : variable label `v'
   rename `v' housing_stock`x'
}
duplicates tag Bezirk, gen(dup_id)
drop if dup_id!=0
foreach num of numlist 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 {
destring housing_stock`num', replace force
}
reshape long housing_stock, i(Bezirk) j(year)
gen city=""
replace city="`city'"
keep housing_stock year Bezirk city
save "$path\housing_`city'.dta", replace
}

use "$path\housing_Berlin.dta", clear
foreach city in Cologne Dortmund Dusseldorf Hamburg Frankfurt  {
append using "$path\housing_`city'.dta"
}
rename Bezirk Stadtteil
save "$path\housing_stock.dta", replace


****Bevoelkerungszahlen*****

foreach city in Berlin Cologne Dortmund Dusseldorf Hamburg Frankfurt Munich Stuttgart {
import excel "C:\Users\laura\Desktop\Social_Housing\Bevoelkerungszahlen.xlsx", sheet("`city'") firstrow clear
foreach v of varlist B C D E F G H I J K {
   local x : variable label `v'
   rename `v' population`x'
}

duplicates tag Bezirk, gen(dup_id)
drop if dup_id!=0

foreach num of numlist 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 {
destring population`num', replace force
}
gen city=""
replace city="`city'"
reshape long population, i(Bezirk) j(year)
keep Bezirk year city population
save population_`city'.dta, replace
}
replace Bezirk= substr(Bezirk, 7,.)
foreach city in Berlin Cologne Dortmund Dusseldorf Hamburg Frankfurt Munich {
append using population_`city'.dta
}
rename Bezirk Stadtteil
replace Stadtteil="Hombruch" if Stadtteil=="Hornbruch"
save population_all.dta, replace 

use population_all.dta, clear
**Merge with housing data**
merge 1:1 Stadtteil year city using "$path\housing_stock.dta"
drop if _merge==2
drop _merge

drop if Stadtteil=="Summe"
replace Stadtteil="Berlin-Spandau" if Stadtteil=="Spandau"
replace Stadtteil="Charlottenburg-Willmersdorf" if Stadtteil=="Charlottenburg-Wilmersdorf"
drop if Stadtteil=="Flughafen"
replace Stadtteil="Sankt Georg" if Stadtteil=="St. Georg"
replace Stadtteil="Sankt Pauli" if Stadtteil=="St. Pauli"
replace Stadtteil="Finkenwerder" if Stadtteil=="Waltershof und Finkenwerder"
drop if Stadtteil=="" & city=="Dortmund"
replace Stadtteil="Berg am Laim" if Stadtteil=="Berg"
replace Stadtteil="Thalkirchen-Obersendling" if Stadtteil=="Thalkirchen-Obersendling-Forstenried-Fürstenried-Solln"
replace Stadtteil="Obergiesing-Fasangarten" if Stadtteil=="Obergiesing-Fasanengarten"
replace Stadtteil="Altstadt_Nord" if Stadtteil=="Altstadt-Nord"
replace Stadtteil="Altstadt_Sued" if Stadtteil=="Altstadt-Süd"
replace Stadtteil="Neustadt_Nord" if Stadtteil=="Neustadt-Nord"
replace Stadtteil="Neustadt_Sued" if Stadtteil=="Neustadt-Süd"
save "$path\population_housing_stock.dta", replace


*****Merge with social housing data set****
use "$path\housing_all.dta", clear
drop _merge 
drop _est*
replace Stadtteil= substr(Stadtteil, 2,.) if city=="Cologne"
replace Stadtteil="Altstadt_Nord" if Stadtteil=="ltstadt_Nord"
replace Stadtteil="Altstadt_Sued" if Stadtteil=="ltstadt_Sued"
replace Stadtteil="Neustadt_Nord" if Stadtteil=="eustadt_Nord"
replace Stadtteil="Neustadt_Sued" if Stadtteil=="eustadt_Sued"

merge 1:1 Stadtteil city year using "$path\population_housing_stock.dta"

/* All matched: for some years no observations, for Hamburg no data on Bezirk-level
for Frankfurt no observations for Flughafen*/ 

drop if _merge==2 
drop _merge 

replace share_sh=total_sh/housing_stock
gen pop_sh=total_sh/population

 save "$path\housing_all.dta", replace 
***Importing the raw data into Stata***
set more off
capture log close 
clear all 

global rawpath /Users/lauraarnemann/Dropbox/Housing Project/raw_data
global datapath /Users/lauraarnemann/Dropbox/Housing Project/Stata_data
global path /Users/lauraarnemann/Dropbox/Housing Project


use "$path/descriptives_Stuttgart.dta", clear
replace Stadtteil= substr(Stadtteil, 2,.)
save "$path/descriptives_Stuttgart.dta", replace
*Master
import delimited "$rawpath/Bestand_Stuttgart.csv", clear delimiter(";")
rename jahr ajahr
rename sozwohng total_sh
rename s_sozwohng share_sh
*all data from december**
gen city="" 
replace city="Stuttgart"

foreach name in West Nord Ost Süd Mitte {
replace bezirk="Stuttgart-`name'" if bezirk=="`name'"
}
rename bezirk Stadtteil
save "$path/Stuttgart.dta", replace
merge 1:1 Stadtteil ajahr using "$path/descriptives_Stuttgart.dta"
*several districts included in the rent data are not included in the social housing data
drop _merge 
**Not merged: data from 2006 and districts not included in the housing data
save "$datapath/Stuttgart_merged.dta", replace

clear

***Prepare Social Housing Data for Cologne
***Prepare Miedaten***
 use "$path/descriptives_Cologne.dta", clear
 
replace Stadtteil="Altstadt_Nord" if Stadtteil=="Altstadt-Nord"
replace Stadtteil="Altstadt_Sued" if Stadtteil==" Altstadt-Süd"

replace Stadtteil="Neustadt_Nord" if Stadtteil==" Neustadt-Nord"
replace Stadtteil="Neustadt_Sued" if Stadtteil==" Neustadt-Süd"

save "$path/descriptives_Cologne.dta", replace
import excel "$rawpath\Daten_Köln_AundB.xlsx", sheet("Basisdaten") firstrow clear
*date on which housing units were reported
rename Tag3112 ajahr
//Stichtag 31.12
rename Wohnungen total_sh
rename Stadtbezirk municipal_district
rename Stadtteil town_district
rename WeWohnungsart type_sh
generate str Stadtteil= substr(town_district, 6,.)

**Reshape according to the different types of social housing**
gen incometype=. 
replace incometype=1 if Einkommensart=="Einkommensart A"
replace incometyp=2 if Einkommensart=="Einkommensart B"
replace incometype=3 if Einkommensart=="nicht Einkommensart A oder B"

gen program_sh=. 
replace program_sh=10 if Förderweg=="Nichtöffentlich gefördert (2. Förderweg)"
replace program_sh=20 if Förderweg=="frei finanzierte Wohnungen mit Belegrecht"
replace program_sh=30 if Förderweg=="Öffentlich gefördert (1. Förderweg)"
replace program_sh=40 if Förderweg=="vereinbarte Förderung nach WoFG"

gen sh_id=program_sh+incometype
 drop program_sh
 drop incometype
 drop Förderweg
 drop Einkommensart
reshape wide total_sh, i(Stadtteil ajahr) j(sh_id)

foreach i in 13 23 33 41 42 {
replace total_sh`i'=0 if total_sh`i'==.
}

gen total_sh=total_sh13+total_sh23+total_sh33+total_sh41+total_sh42
replace Stadtteil="Altstadt_Nord" if Stadtteil==" Altstadt/Nord"
replace Stadtteil="Altstadt_Sued" if Stadtteil==" Altstadt/Süd"

replace Stadtteil="Neustadt_Nord" if Stadtteil==" Neustadt/Nord"
replace Stadtteil="Neustadt_Sued" if Stadtteil==" Neustadt/Süd"
gen city=""
replace city="Cologne"
save "$datapath/Cologne.dta", replace
merge 1:1 Stadtteil ajahr using "$path/descriptives_Cologne.dta"
drop _merge total_sh13 total_sh23 total_sh33 total_sh41 total_sh42 municipal_district town_district type_sh
save "$datapath/Cologne_merged.dta", replace
*Cologne data from 2010-2018, Stadtteile Fühlingen (matched for 2010, 2011), Gremberghoven, Hahnwald, Libur, Lövenich not matched

clear
import excel "$rawpath/Daten_München.xlsx", sheet("Stata_format") firstrow
rename Stadtbezirk Stadtteil
rename Sozialwohnungen total_sh
rename SozialwohnungenStadt city_sh
rename year ajahr
replace Stadtteil="Thalkirchen-Obersendling" if Stadtteil=="Thalkirchen-Obersendling-F."
gen city=""
replace city="Munich"
replace total_sh="0" if total_sh=="-"
destring total_sh, replace
save "$rawpath/Munich.dta", replace
use "$path/descriptives_Munich.dta", clear
replace Stadtteil= substr(Stadtteil, 2,.)
save "$path/descriptives_Munich.dta", replace
use "$rawpath/Munich.dta", clear
merge 1:1 Stadtteil ajahr using "$path/descriptives_Munich.dta"
drop F-W city_sh Number
save "$datapath/Munich_merged.dta", replace


*Berlin
use "$path/descriptives_Berlin.dta"
replace Stadtteil= substr(Stadtteil, 2,.)
save "$datapath/descriptives_Berlin.dta", replace
clear 
import excel "$rawpath/berlin_data.xlsx", sheet("Bezirksprofile") firstrow clear
gen city=""
replace city="Berlin"
destring Anteilmietpreisundbelegungsg, replace force
destring Mietwohnungen, replace force
rename Bezirk Stadtteil
rename Wohnungen flats_total
rename Sozialmietwohnungen total_sh
rename Arbeitslosenquote unemployment_quota
rename Anteilmietpreisundbelegungsg share_ph
rename belegungsgebundeneMietwohnungen total_ph
rename Mietwohnungen total_rentalflats
rename AnteilWohnungen share_rentalflats
rename year ajahr
gen share_sh=. 
replace share_sh=total_sh/flats
replace Stadtteil= substr(Stadtteil,10,.)
replace Stadtteil="Berlin-Spandau" if Stadtteil=="Spandau"
drop if Stadtteil==""
replace Stadtteil="Charlottenburg-Willmersdorf" if Stadtteil=="Charlottenburg-Wilmersdorf"
save "$rawpath/Berlin.dta", replace
merge 1:1 Stadtteil ajahr using "$path/descriptives_Berlin.dta"
drop share_sh flats_total share_rentalflats total_rentalflats share_ph unemployment_quota _merge total_ph
save "$datapath/Berlin_merged.dta", replace	


***Dortmund****
import excel "$rawpath/Daten_Dortmund.xlsx", sheet("Stata_format") firstrow clear
rename Stadtbezirk Stadtteil
rename aJahr ajahr

gen city=""
replace city="Dortmund"
replace Stadtteil="Innenstadt-West" if Stadtteil=="Innenstadt - West"
replace Stadtteil="Innenstadt-Nord" if Stadtteil=="Innenstadt - Nord"
replace Stadtteil="Innenstadt-Ost" if Stadtteil=="Innenstadt - Ost"
drop if Stadtteil==""
gen total_sh=AnzahlSozialwohnungen
merge 1:1 Stadtteil ajahr using "$path/descriptives_Dortmund.dta"
*All macthed except for data for all Dortmund
drop _merge AnzahlSozialwohnungen
save "$datapath/Dortmund_merged.dta", replace	


****Dusseldorf****

*import excel "$rawpath/Dusseldorf_Bezirk.xlsx", sheet("Stata_format") firstrow clear
*keep Stadtbezirk Stadtteil
*
*replace Stadtteil="Knittkuhl" if Stadtteil==" Knittkuhl"
*save "$rawpath/Duesseldorf_Bezirk.dta", replace
*
use "$path/descriptives_Dusseldorf.dta", clear
merge m:1 Stadtteil using "$rawpath/Duesseldorf_Bezirk.dta"
drop _merge
gcollapse (mean) miet_mean qm_miet_mean miet_p50 qm_miet_p50 miet_p10 qm_miet_p10 miet_p25 qm_miet_p25 miet_p75 qm_miet_p75 miet_p90 qm_miet_p90 (sd) miet_sd qm_miet_sd (count) N, by(Stadtbezirk ajahr)
save "$rawpath/descriptives_Dusseldorf.dta", replace
*
import delimited  "$rawpath/Daten_Duesseldorf.csv", clear delimiter(";")
rename year ajahr
rename total_units total_sh
gen city="" 
replace city="Dusseldorf"
rename districts Stadtbezirk
merge 1:1 Stadtbezirk ajahr using "$rawpath/descriptives_Dusseldorf.dta"
rename Stadtbezirk Stadtteil
drop _merge
tostring Stadtteil, replace
save "$datapath/Dusseldorf_merged.dta", replace

****Hamburg****

*
use "$path/descriptives_Hamburg.dta", clear
gen t_Stadtteil= substr(Stadtteil, 2,.)
replace t_Stadtteil=Stadtteil if Stadtteil=="Bergstedt" | Stadtteil=="Billbrook" | Stadtteil=="Eidelstedt"
drop Stadtteil
rename t_Stadtteil Stadtteil
save "$path/descriptives_Hamburg.dta", replace

import excel "$rawpath/Daten_Hamburg.xlsx", sheet("Tabelle2") firstrow clear
reshape long sh_ , i(Stadtteil) j(ajahr)

rename sh_ total_sh
replace Stadtteil="Sankt Pauli" if Stadtteil=="St. Pauli"
replace Stadtteil="Sankt Georg" if Stadtteil=="St. Georg"
save "$rawpath/Hamburg.dta", replace
merge 1:1 Stadtteil ajahr using "$path/descriptives_Hamburg.dta"
gen city=""
replace city="Hamburg"
*Everything merged apart from district level aggregations
drop _merge
save "$datapath/Hamburg_merged.dta", replace


*Frankfurt**
*use "$path/descriptives_Frankfurt.dta", clear
*gen t_Stadtteil= substr(Stadtteil, 2,.)
*replace Stadtteil=t_Stadtteil
*drop t_Stadtteil
*save "$path/descriptives_Frankfurt.dta", replace
*
forvalues i=2010/2014 {
import excel "$rawpath/geförderteWhg_all_`i'_Frankfurt.xlsx", sheet("Tabelle1") firstrow clear
rename I total_sh
gen ajahr=`i'
keep ajahr Stadtteil total_sh 
tempfile Frankfurt`i'
save `Frankfurt`i''
}
forvalues i=2015/2017 {
import excel "$rawpath/geförderteWhg_all_2015_2017_Frankfurt.xlsx", sheet("BestandSWG_`i'") firstrow clear
gen ajahr=`i'
tempfile using`i'
drop if Stadtteil==""
rename Wohnungenfürsozialwohnungsbere senior_sh
save `using`i''
import excel "$rawpath/geförderteWhg_all_2015_2017_Frankfurt.xlsx", sheet("Bestand`i'") firstrow clear
gen ajahr=`i'
replace Stadtteil="außerhalb Frankfurt" if Stadtteil=="außerhalb Frankfurts"
drop if Stadtteil==""
rename WohnungenfürSozialwohnungsbere other_sh
merge 1:1 Stadtteil using `using`i''
gen total_sh=senior_sh+other_sh
keep ajahr Stadtteil total_sh 
tempfile Frankfurt`i'
save `Frankfurt`i''
}

forvalues i=2010/2016 {
append using `Frankfurt`i''
}
drop if Stadtteil==""
replace Stadtteil="Schwanheim" if Stadtteil=="Schwanheim/Goldstein"
save "$rawpath/Frankfurt.dta", replace
merge 1:1 Stadtteil ajahr using "$path/descriptives_Frankfurt.dta"
gen city=""
replace city="Frankfurt"
drop if _merge==1
drop _merge
**All matched but airport not available for every year
save "$datapath/Frankfurt_merged.dta", replace


****Appending all data sets***

use "$datapath/Dortmund_merged.dta", clear
foreach city in Berlin Cologne Dusseldorf Frankfurt Hamburg Stuttgart Munich {
append using "$datapath/`city'_merged.dta"
}

rename ajahr year
encode Stadtteil, gen(district)
encode city, gen(Stadt)
****Logs for differents variables***
gen ln_sh=log(total_sh)
foreach var of varlist miet_mean qm_miet_mean miet_p10 qm_miet_p10 miet_p25 qm_miet_p25 miet_p50 qm_miet_p50 miet_p75 qm_miet_p75 miet_p90 qm_miet_p90 {
gen ln_`var'=log(`var')
}

label var miet_mean "Durchschnittsmiete"
label var qm_miet_mean "Durchschnittsmiete pro qm"
label var miet_p10 "Miete 10. Perzentil"
label var qm_miet_p10 "Miete 10. Perzentil pro qm"
label var miet_p25 "Miete 25. Perzentil"
label var qm_miet_p25 "Miete 25. Perzentil pro qm"
label var miet_p50 "Miete Median"
label var qm_miet_p50 "Miete Median pro qm"
label var miet_p75 "Miete 75. Perzentil"
label var qm_miet_p75 "Miete 75. Perzentil pro qm"
label var miet_p90 "Miete 90. Perzentil"
label var qm_miet_p90 "Miete 90. Perzentil pro qm"


save "$datapath/housing_all.dta",replace


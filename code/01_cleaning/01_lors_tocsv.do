// Project: Social Housing
// Creation Date: 05-09-2023
// Last Update: 22-11-2023
// Author: Laura Arnemann 
// Goal: Cleaning Social Housing data 


import excel "${IN}/SozialmietwohnungenWohnungsbestand_2010_2022_Versand.xlsx", sheet("PLR") firstrow clear 


* Rename the respective variables 
rename Wohnungsbestand31122010 wohnungen2010 
rename Sozialmietwohnungsbestand31 socialh2010
rename Anteilin share2010

rename Wohnungsbestand31122011 wohnungen2011
rename G socialh2011
rename H share2011 
rename Wohnungsbestand31122012 wohnungen2012 
rename J socialh2012 
rename K share2012 
rename Wohnungsbestand31122013 wohnungen2013 
rename M socialh2013 
rename N share2013 
rename Wohnungsbestand31122014 wohnungen2014 
rename P socialh2014 
rename Q share2014 
rename Wohnungsbestand31122015 wohnungen2015 
rename S socialh2015 
rename T share2015 
rename Wohnungsbestand31122016 wohnungen2016 
rename V socialh2016 
rename W share2016 
rename Wohnungsbestand31122017 wohnungen2017 
rename Y socialh2017 
rename Z share2017 
rename Wohnungsbestand31122018 wohnungen2018 
rename AB socialh2018 
rename AC share2018 
rename Wohnungsbestand31122019 wohnungen2019 
rename Sozialmietwohnungsbestand311 socialh2019 
rename AF share2019 
rename Wohnungsbestand31122020 wohnungen2020 
rename AH socialh2020
rename AI share2020
rename Wohnungsbestand31122021 wohnungen2021
rename AK socialh2021
rename AL share2021
rename Wohnungsbestand31122022 wohnungen2022 
rename AN socialh2022 
rename AO share2022
destring socialh2022, replace force
* this generates two missing 

* Generate the variables 

gen change_share1=share2022 - share2010
gen change_share2=share2014 - share2010

gen change_absolut1=socialh2022 - socialh2010
gen change_absolut2=socialh2014 - socialh2010

gen change_share_perc1=((share2022 - share2010)/share2010)*100
gen change_share_perc2=((share2014 - share2010)/share2010)*100

br PLRBezeichnung PLR share2022 share2010 change_share1

export delimited "${TEMP}/socialhousing.csv", replace 
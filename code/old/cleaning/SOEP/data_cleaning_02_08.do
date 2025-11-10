***********************************************************************************************************************************************************************************************************************Analysis Social Housing: Soep Data***********************************************

set more off 
capture log close


global datapath C:/Users/laura/Desktop/SocialHousing/data/SOEPdata/databearbeitet
global outputpath C:/Users/laura/Desktop/SocialHousing/data/SOEP/output/graphs

use "$datapath/soep_all.dta", replace

*****Rename Variables (Probably a better way to do this, but atm I can't see it)
/*
rename hh16 sozialw1991
rename hh48 netto1991
rename hh2601 miete1991
rename hhhgr hhsize1991

rename ih16 sozialw1992
rename ih2601 miete1992
rename ih49 netto1992
rename ihhgr hhsize1992 

rename jh16 sozialw1993
rename jh2601 miete1993
rename jh49 netto1993
rename jhhgr hhsize1993 

rename kh16 sozialw1994
rename kh2601 miete1994
rename kh49 netto1994
rename khhgr hhsize1994


****Änderung der Frage in 1994, ab 1995 bis 1997 zwei verschiedenene Fragen
rename lh23a sozialw1995
rename lh2601 miete1995
rename lh50 netto1995
rename lhhgr hhsize1995

rename mh24 sozialw1996
rename mh2701 miete1996
rename mh50 netto1996
rename mhhgr hhsize1996

rename nh24 sozialw1997
rename nh2701 miete1997
rename nh50 netto1997
rename nhhgr hhsize1997
*/



rename oh16 sozialw1998
rename oh11a squarefootage1998
rename oh15 rentreduced1998
rename oh0502 yearsindwell1998
*rename nh24 sozialw297
rename oh2701 miete1998
rename oh50 netto1998
rename oh12 apartsize1998
rename oh01 baujahr1998
*rename ohhgr hhsize1998
rename oggk gemeindeklasse1998
rename ogtyp gemeindetyp1998
rename op0105 housingsatisfaction1998
rename oh34 extracosts1998
rename oh2901 heatcosts1998
rename oh11b rooms1998
rename oh1306 balcony1998
rename oh1307 basement1998
rename oh1308 garden1998
gen electricity1998=. 
gen alarm1998=. 
gen aircondition1998=.


rename ph25 sozialw1999
rename ph16 squarefootage1999
rename ph13 baujahr1999
rename ph0502 yearsindwell1999
*rename nh24 sozialw297
rename ph2601 miete1999
rename ph50 netto1999
rename ph22 apartsize1999
rename ph24 rentreduced1999
*rename phhgr hhsize1999
rename pggk gemeinedklasse1999
rename pgtyp gemeindetey1999
rename pp0105 housingsatisfaction1999
rename ph36 extracosts1999
rename ph2801 heatcosts1999
rename ph17 rooms1999
rename ph1406 balcony1999
rename ph1407 basement1999
rename ph1408 garden1999
gen electricity1999=. 
gen aircondition1999=. 
gen alarm1999=. 

rename qh24 sozialw2000
rename qh15 squarefootage2000 
rename qh13 baujahr2000
rename qh23 rentreduced2000
rename qh0502 yearsindwell2000
*rename nh24 sozialw297
rename qh2501 miete2000
rename qh54 netto2000
rename qh21 apartsize2000
rename qggk gemeindeklasse2000
rename qgtyp  gemeindetyp2000
*rename qhhgr hhsize2000
rename qp0105 housingsatisfaction2000
rename qh35 extracosts2000
rename qh2701 heatcosts2000
rename qh16 rooms2000
rename qh1406 balcony2000
rename qh1407 basement2000
rename qh1408 garden2000
gen electricity2000=. 
gen aircondition2000=. 
gen alarm2000=. 

rename rh24 sozialw2001
rename rh15 squarefootage2001
rename rh13 baujahr2001
rename rh23 rentreduced2001
rename rh0502 yearsindwell2001
*rename nh24 sozialw297
rename rh2501 miete2001
rename rh21 apartsize2001
rename rggk gemeindeklasse2001
rename rgtyp  gemeindetyp2001
rename rh49 netto2001
*rename rhhgr hhsize2000
rename rp0105 housingsatisfaction2001
rename rh35 extracosts2001
rename rh2701 heatcosts2001
rename rh16 rooms2001
rename rh1406 balcony2001
rename rh1407 basement2001
rename rh1408 garden2001
gen electricity2001=. 
gen aircondition2001=. 
gen alarm2001=. 



rename sh24 sozialw2002
rename sh11 squarefootage2002
rename sh08 baujahr2002
rename sh23 rentreduced2002
rename sh0402 yearsindwell2002
*rename nh24 sozialw297
rename sh2501 miete2002
rename sh4901 netto2002
rename sh13 apartsize2002
rename sggk gemeindeklasse2002
rename sgtyp  gemeindetyp2002
*rename shhgr hhsize2002
rename sp0105 housingsatisfaction2002
rename sh35 extracosts2002
rename sh2701 heatcosts2002
rename sh12 rooms2002
rename sh0906 balcony2002
rename sh0907 basement2002
rename sh0908 garden2002
gen electricity2002=. 
gen aircondition2002=. 
gen alarm2002=. 

rename th22 sozialw2003
rename th12 squarefootage2003
rename th14 apartsize2003
rename th09 baujahr2003
gen rentreduced2003=rentreduced2002
rename th0402 yearsindwell2003
*rename nh24 sozialw297
rename th2301 miete2003
rename th4801 netto2003
rename tggk gemeindeklasse2003
rename tgtyp gemeindetyp2003
*rename thhgr hhsize2003
rename tp0105 housingsatisfaction2003
rename th33 extracosts2003
rename th2501 heatcosts2003
rename th13 rooms2003
rename th1006 balcony2003
rename th1007 basement2003
rename th1008 garden2003
gen electricity2003=. 
gen aircondition2003=. 
gen alarm2003=. 

rename uh22 sozialw2004
rename uh14 apartsize2004
rename uh12 squarefootage2004
rename uh09 baujahr2004
rename uh0402 yearsindwell2004
gen rentreduced2004=rentreduced2003
*rename nh24 sozialw297
rename uh2301 miete2004
rename uh4801 netto2004
rename uggk gemeindeklasse2004
rename ugtyp  gemeindetyp2004
*rename uhhgr hhsize2004
rename up0107 housingsatisfaction2004
rename uh33 extracosts2004
rename uh2501 heatcosts2004
rename uh13 rooms2004
rename uh1006 balcony2004
rename uh1007 basement2004
rename uh1008 garden2004
rename uh1009 alarm2004
gen electricity2004=. 
gen aircondition2004=. 


rename vh21 sozialw2005
rename vh10 squarefootage2005
rename vh12 apartsize2005
rename vh08 baujahr2005
rename vh0402 yearsindwell2005
gen rentreduced2005=rentreduced2004
*rename nh24 sozialw297
rename vh2201 miete2005
rename vh5101 netto2005
rename vggk gemeindeklasse2005
rename vgtyp  gemeindetyp2005
*rename vhhgr hhsize2005
rename vp0106 housingsatisfaction2005
rename vh32 extracosts2005
rename vh2401 heatcosts2005
rename vh11 rooms2005
rename vh1406 balcony2005
rename vh1407 basement2005
rename vh1408 garden2005
rename vh1409 alarm2005
gen electricity2005=. 
gen aircondition2005=. 



rename wh21 sozialw2006
rename wh10 squarefootage2006
rename wh12 apartsize2006
rename wh08 baujahr2006
rename wh0402 yearsindwell2006
gen rentreduced2006=rentreduced2005
*rename nh24 sozialw297
rename wh2201 miete2006
rename wh5101 netto2006
rename wggk gemeindeklasse2006
rename wgtyp  gemeindetyp2006
*rename whhgr hhsize2006
rename wp0106 housingsatisfaction2006
rename wh32 extracosts2006
rename wh2401 heatcosts2006
rename wh11 rooms2006
rename wh1406 balcony2006
rename wh1407 basement2006
rename wh1408 garden2006
rename wh1409 alarm2006
gen electricity2006=. 
gen aircondition2006=. 


rename xh21 sozialw2007
rename xh10 squarefootage2007
rename xh12 apartsize2007
rename xh0801 baujahr2007
rename xh0402 yearsindwell2007
gen rentreduced2007=rentreduced2006
*rename nh24 sozialw297
rename xh2201 miete2007
rename xh5101 netto2007
rename xggk gemeindeklasse2007
rename xgtyp gemeindetyp2007
*rename xhhgr hhsize2007
rename xp0106 housingsatisfaction2007
rename xh32 extracosts2007
rename xh2401 heatcosts2007
rename xh11 rooms2007
rename xh1406 balcony2007
rename xh1407 basement2007
rename xh1408 garden2007
rename xh1409 alarm2007
rename xh1410 aircondition2007
gen electricity2007=. 

rename yh22 sozialw2008
rename yh10 squarefootage2008
rename yh12 apartsize2008
rename yh21 rentreduced2008
rename yh0801 baujahr2008
rename yh0402 yearsindwell2008
*rename nh24 sozialw297
rename yh2301 miete2008
rename yh5201 netto2008
rename yggk gemeindeklasse2008
rename ygtyp gemeindetyp2008
*rename yhhgr hhsize2008
rename yp0108 housingsatisfaction2008
rename yh33 extracosts2008
rename yh25 heatcosts2008
rename yh11 rooms2008
rename yh1406 balcony2008
rename yh1407 basement2008
rename yh1408 garden2008
rename yh1409 alarm2008
rename yh1410 aircondition2008
gen electricity2008=. 

rename zh22 sozialw2009
rename zh10 squarefootage2009
rename zh12 apartsize2009
rename zh21 rentreduced2009
rename zh0801 baujahr2009
rename zh0402 yearsindwell2009
*rename nh24 sozialw297
rename zh2301 miete2009
rename zh5201 netto2009
rename zggk gemeindeklasse2009
rename zgtyp  gemeindetyp2009
*rename zhhgr hhsize2009
rename zp0107 housingsatisfaction2009
rename zh33 extracosts2009
rename zh25 heatcosts2009
rename zh11 rooms2009
rename zh1406 balcony2009
rename zh1407 basement2009
rename zh1408 garden2009
rename zh1409 alarm2009
rename zh1410 aircondition2009
gen electricity2009=. 

rename bah22 sozialw2010
rename bah10 squarefootage2010
rename bah12 apartsize2010
rename bah21 rentreduced2010
rename bah0801 baujahr2010
rename bah0402 yearsindwell2010
*rename nh24 sozialw297
rename bah2301 miete2010
rename bah5201 netto2010
rename baggk gemeindeklasse2010
rename bagtyp  gemeindetyp2010
*rename bahhgr hhsize2010
rename bap0107 housingsatisfaction2010
rename bah33 extracosts2010
rename bah2501 heatcosts2010
rename bah11 rooms2010
rename bah2503 electricity2010
rename bah1406 balcony2010
rename bah1407 basement2010
rename bah1408 garden2010
rename bah1409 alarm2010
rename bah1410 aircondition2010

rename bbh22 sozialw2011
rename bbh10 squarefootage2011
rename bbh12 apartsize2011
rename bbh0801 baujahr2011
rename bbh21 rentreduced2011
rename bbh0402 yearsindwell2011
*rename nh24 sozialw297
rename bbh2301 miete2011
rename bbh5101 netto2011
rename bbggk gemeindeklasse2011
rename bbgtyp  gemeindetyp2011
*rename bbhhgr hhsize2011
rename bbp0107 housingsatisfaction2011
rename bbh33 extracosts2011
rename bbh2501 heatcosts2011
rename bbh11 rooms2011
rename bbh2503 electricity2011
rename bbh1406 balcony2011
rename bbh1407 basement2011
rename bbh1408 garden2011
rename bbh1409 alarm2011
rename bbh1410 aircondition2011

rename bch22 sozialw2012
rename bch10 squarefootage2012
rename bch12 apartsize2012
rename bch0801 baujahr2012
rename bch21 rentreduced2012
rename bch0402 yearsindwell2012
*rename nh24 sozialw297
rename bch2301 miete2012
rename bch5101 netto2012
rename bcggk gemeindeklasse2012
rename bcgtyp  gemeindetyp2012
*rename bchhgr hhsize2012
rename bcp0107 housingsatisfaction2012
rename bch33 extracosts2012
rename bch2501 heatcosts2012
rename bch11 rooms2012
rename bch2503 electricity2012
rename bch1406 balcony2012
rename bch1407 basement2012
rename bch1408 garden2012
rename bch1409 alarm2012
rename bch1410 aircondition2012

rename bdh22 sozialw2013
rename bdh10 squarefootage2013
rename bdh12 apartsize2013
rename bdh0801 baujahr2013
rename bdh21 rentreduced2013
rename bdh0402 yearsindwell2013
*rename nh24 sozialw297
rename bdh2301 miete2013
rename bdh5101 netto2013
rename bdggk gemeindeklasse2013
rename bdgtyp  gemeindetyp2013
*rename bdhhgr hhsize2013
rename bdp0107 housingsatisfaction2013
rename bdh33 extracosts2013
rename bdh2501 heatcosts2013
rename bdh11 rooms2013
rename bdh2503 electricity2013
rename bdh1407 balcony2013
rename bdh1408 basement2013
rename bdh1409 garden2013
rename bdh1410 alarm2013
rename bdh1411 aircondition2013

rename beh23 sozialw2014
rename beh07 squarefootage2014
rename beh09 apartsize2014
rename beh22 rentreduced2014
gen yearsindwell2014=yearsindwell2013
gen baujahr2014=baujahr2013
*rename nh24 sozialw297
rename beh2401 miete2014
rename beh5401 netto2014
rename beggk gemeindeklasse2014
rename begtyp  gemeindetyp2014
rename bep0107 housingsatisfaction2014
rename beh36 extracosts2014
rename beh2501 heatcosts2014
rename beh08 rooms2014
rename beh2601 electricity2014 
rename beh1104 balcony2014
rename beh1105 basement2014
rename beh1106 garden2014
rename beh1107 alarm2014
rename beh1108 aircondition2014

rename bfh09 sozialw2015
rename bfh11 squarefootage2015
rename bfh0701 baujahr2015
rename bfh13 apartsize2015
rename bfh32 rentreduced2015
rename bfh0202 yearsindwell2015
*rename nh24 sozialw297
rename bfh3401 miete2015
rename bfh4901 netto2015
rename bfggk gemeindeklasse2015
rename bfgtyp  gemeindetyp2015
rename bfp0107 housingsatisfaction2015
gen extracosts2015=extracosts2014
gen heatcosts2015=heatcosts2014
rename bfh12 rooms2015
gen electricity2015=electricity2014
rename bfh2003 balcony2015
rename bfh2012 basement2015
rename bfh2004 garden2015
rename bfh2005 alarm2015
rename bfh2006 aircondition2015

*2015 nur eine Person, die in einer mietgebundenen Wohnung gewohnt hat


rename bgh31 sozialw2016
rename bgh09 squarefootage2016
rename bgh11 apartsize2016
rename bgh05 baujahr2016
rename bgh32 rentreduced2016
rename bgh0202 yearsindwell2016
*rename nh24 sozialw297
rename bgh3401 miete2016
rename bgh6801 netto2016
rename bgggk gemeindeklasse2016
rename bgtyp  gemeindetyp2016
rename bgp0107 housingsatisfaction2016
rename bgh2501 extracosts2016
rename bgh3601 heatcosts2016
rename bgh10 rooms2016
rename bgh3801 electricity2016
rename bgh41 costofliving_compared
rename bgh1203 balcony2016
rename bgh1212 basement2016
rename bgh1204 garden2016
rename bgh1205 alarm2016
rename bgh1206 aircondition2016

*2017 dann wieder ja/nein Frage ob man in einer Sozialwohung gewohnt hat
rename bhh_27 sozialw2017
rename bhh_11 squarefootage2017
rename bhh_13 apartsize2017
rename bhh_07 baujahr2017
rename bhh_28 rentreduced2017
rename bhh_02_02 yearsindwell2017
*rename nh24 sozialw297
rename bhh_30_01 miete2017
rename bhh_61_01 netto2017
rename bhggk gemeindeklasse2017
rename bhgtyp gemeindetyp2017
*rename bhhhgr hhsize2017
rename bhp_01_07 housingsatisfaction2017
rename bhh_25_01 extracosts2017
rename bhh_32_01 heatcosts2017
rename bhh_12 rooms2017
rename bhh_34_01 electricity2017
rename bhh_14_03 balcony2017
rename bhh_14_12 basement2017
rename bhh_14_04 garden2017
rename bhh_14_05 alarm2017
rename bhh_14_06 aircondition2017


rename bih_27 sozialw2018
rename bih_09 squarefootage2018
rename bih_11 apartsize2018
rename bih_05 baujahr2018
rename bih_28 rentreduced2018
rename bih_02_02 yearsindwell2018
*rename nh24 sozialw297
rename bih_30_01 miete2018
rename bih_61_01 netto2018
rename biggk gemeindeklasse2018
rename bigtyp gemeindetyp2018
rename bip_01_07 housingsatisfaction2018
rename bih_25_01 extracosts2018
rename bih_32_01 heatcosts2018
rename bih_34_01 electricity2018
rename bih_14_03 balcony2018
rename bih_10 rooms2018
rename bih_14_12 basement2018
rename bih_14_04 garden2018
rename bih_14_05 alarm2018
rename bih_14_06 aircondition2018

******Clean the date from the pequiv data files*****

forvalues i=0/9 {
rename i111010`i' preincome200`i'
rename i111020`i' postincome200`i'
rename d111070`i' numchildren200`i'
rename i111030`i' laborincome200`i'
rename d111060`i' size200`i'
rename p111010`i' lifesatisfaction200`i'
rename w111020`i' hhweight200`i'
rename d111010`i' age200`i'
rename e111020`i' employment200`i'
*rename job10`i' wages200`i'
rename opery0`i' operating200`i'
rename i111050`i' rent200`i'
}

forvalues i=10/17 {
rename i11101`i' preincome20`i'
rename i11102`i' postincome20`i'
rename d11107`i' numchildren20`i'
rename i11103`i' laborincome20`i'
rename d11106`i' size20`i'
rename p11101`i' lifesatisfaction20`i'
rename w11102`i' hhweight20`i'
rename d11101`i' age20`i'
rename e11102`i' employment20`i'
*rename job1`i' wages20`i'
rename opery`i' operating20`i'
rename i11105`i' rent20`i'
}

forvalues i=90/99 {
rename i11101`i' preincome19`i'
rename i11102`i' postincome19`i'
rename d11107`i' numchildren19`i'
rename i11103`i' laborincome19`i'
rename d11106`i' size19`i'
rename p11101`i' lifesatisfaction19`i'
rename w11102`i' hhweight19`i'
rename d11101`i' age19`i'
rename e11102`i' employment19`i'
*rename job1`i' wages19`i'
rename opery`i' operating19`i'
rename i11105`i' rent19`i'
}




****Take care of the missings****
forvalues i=1998/2018 {
foreach name in  housingsatisfaction sozialw squarefootage apartsize baujahr yearsindwell rentreduced miete netto extracosts heatcosts rooms electricity balcony basement garden alarm aircondition {
replace `name'`i'=. if `name'`i'<0
} 
}

forvalues i=1998/2017 {
foreach name in lifesatisfaction preincome postincome numchildren laborincome size age employment operating rent  {
replace `name'`i'=. if `name'`i'<0
} 
}




****Collapse the dataset on household level and reshape it 
collapse preincome* postincome* numchildren* laborincome* size* lifesatisfaction* housingsatisfaction* age* employment*  miete* sozialw* netto* operating* gemeindeklasse* gemeindetyp* squarefootage* hhweight* apartsize* baujahr* rent* yearsindwell* extracosts* heatcosts* rooms* electricity* balcony* basement* garden* alarm* aircondition* costofliving_compared, by(hhnr)

reshape long preincome postincome numchildren laborincome size lifesatisfaction housingsatisfaction age employment miete sozialw netto operating squarefootage gemeindeklasse gemeindetyp hhweight apartsize baujahr rent yearsindwell rentreduced extracosts heatcosts rooms electricity balcony basement garden alarm aircondition, i(hhnr) j(jahr)

*Don't account for households which are not missing 
drop if sozialw!=1 & sozialw!=2 & sozialw!=3

label define sozw 1 "Belegungsgebundene SW" 2 "Nicht belegungsgebundene SW" 3 "Keine SW"
label values sozialw sozw


*****replace categorical variables if households responded differently 

foreach var of varlist baujahr numchildren size employment yearsindwell rentreduced rooms electricity balcony basement garden alarm aircondition {
replace `var'=int(`var')
}


replace miete=. if miete<0 
replace netto=. if netto<0 
replace gemeindetyp=. if gemeindetyp<0
replace gemeindeklasse=. if gemeindeklasse<0

*replace sozialw=. if sozialw<=0
gen socialh1=1 if sozialw==1
replace socialh1=0 if sozialw==3

gen socialh2=1 if sozialw==1 | sozialw==2
replace socialh2=0 if sozialw==3


******Generate Indicators for Zersiedlungsgrad****
// Großstadt
gen bigcity = (gemeindetyp == 1)
// Hoch verdichteter Raum
gen g_verd  = (gemeindetyp >= 1 & gemeindetyp < 9)
// Mittel verdichtet
gen m_verd  = (gemeindetyp >= 9 & gemeindetyp < 14)
// keine oder nur egeringe Verdichtung
gen k_verd  = (gemeindetyp >= 15 & gemeindetyp < 18)
//Kernstadt
gen kernstadt = (inlist(gemeindetyp, 1, 2, 9))
// Städtisch geprägter Kreis
gen stadt_kreis = (inlist(gemeindetyp, 3, 4))
// Verdichteteter Kreis
gen verd_kreis  = (inlist(gemeindetyp, 5, 6, 10, 11, 14, 15))
//Ländlicher Kreis
gen land_kreis = (inlist(gemeindetyp, 7, 8, 12, 13, 16, 17))
// Kreis geprägt durch viele kleine Gemeinden
gen gemeinde      = (inlist(gemeindetyp, 4, 6, 8, 11, 13, 17))
// Interaktion für Großstädte im Osten
*gen big_east = bigcity * east



****Account for the currency conversion***
foreach var of varlist netto miete heatcosts extracosts electricity {
	replace `var'=`var'/2
}



***Is the household eligible for social housing (rough proxy)
gen eligible=0 
replace eligible = 1 if size==1 & preincome<=12000
replace eligible = 1 if size==2 & preincome<=18000
replace eligible = 1 if size==3 & preincome<=22600
forvalues i=4/8 {
	local a=22600+`i'*4100
	replace eligible = 1 if size==`i' & preincome<=`a'
} 



******Label the variables*****

label variable squarefootage "Size Apartment (m2)"
label variable hhweight "Haushaltsgewicht"
label variable operating "Maintenance costs"
label variable miete "Rent (self-reported)"
label variable rent "Rent (pequiv file)"
label variable apartsize "Satisfaction Apt. Size"
label variable baujahr "Year Constrution (cat)"
label variable lifesatisfaction "Satisfaction with Life"
label variable housingsatisfaction "Satisfaction with Housing"
label variable preincome "Income (pre) Govt. Transfers"
label variable laborincome "Income from Labor"
label variable postincome "Income (post) Govt. Transfers"
label variable age "Age"
label variable numchildren "Number of children"
label variable size "HH Size"
label variable extracosts "Extra Costs"
label variable heatcosts "Heating Costs"
label variable rooms "Number of rooms"
label variable electricity "Electricity Costs"
label variable garden "Garden"
label variable alarm "Alarm secured"
label variable aircondition "Air Condition"
label variable balcony "Balcony"
label variable basement "Basement"


*****Summary statistics for all people living in social housing
gen share_miete1=miete/netto
replace share_miete1=. if share_miete1>=0.9
label variable share_miete1 "Anteil Miete, Einkommen laut Angaben"

gen share_miete2=miete*12/preincome
replace share_miete2=. if share_miete2>=0.9
label variable share_miete2 "Anteil Miete, Einkommen vor Transfers"

gen share_miete3=miete*12/postincome 
replace share_miete3=. if share_miete3>=0.9
label variable share_miete3 "Anteil Miete, Einkommen nach Tranfers"

gen share_miete4=rent/netto 
replace share_miete4=. if share_miete4>=0.9
replace share_miete4=. if share_miete4==0
label variable share_miete4 "Anteil Miete (Pequiv), Einkommen laut Angaben"

gen share_miete5=rent*12/postincome 
replace share_miete5=. if share_miete5>=0.9
replace share_miete5=. if share_miete5==0
label variable share_miete5 "Anteil Miete (Pequiv), Einkommen vor Transfers"

gen share_miete6=rent*12/preincome
replace share_miete6=. if share_miete6>=0.9
replace share_miete6=. if share_miete6==0
label variable share_miete6 "Anteil Miete (Pequiv), Einkommen nach Transfers"




********************************************************************************
********************************************************************************
********Generate Logs of variables******

gen ln_miete=log(miete)
gen ln_operating=log(operating)
replace ln_operating=0 if opery==0

gen yearsinhouse= yearsindwell
replace yearsinhouse = jahr-yearsindwell if yearsindwell>1900
label variable yearsinhouse "Years in Apart."
label variable socialh1 "Social Housing Indicator"

save "$datapath/soep_cleaned.dta", replace

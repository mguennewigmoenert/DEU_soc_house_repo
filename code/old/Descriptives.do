global path "C:\Users\fbu\Dropbox\Housing Project"
global rentpath "C:\Mietdaten\WM_SUF_ohneText"

foreach city in Frankfurt Munich Cologne Hamburg Stuttgart Dusseldorf Berlin Dortmund {

import excel using "${path}\PostalCodes_sorted.xlsx" , firstrow clear sheet("`city'") 
rename Postleitzahl plz
bysort plz: gen int n = _n
*Reshape is required to merge the data because m:m does not work
reshape wide Stadtteil, i(plz) j(n)
*desc using $rentpath/WM_SUF_ohneText


merge 1:m plz using $rentpath/WM_SUF_ohneText, keepusing(mietekalt ajahr wohnflaeche) keep(match master) 



keep if mietekalt > 0
keep if wohnflaeche > 0

gen qm_mietkalt = mietekalt/wohnflaeche
*Since there are implausible low values  in wohnfläche e.g. 0,02 Square meters we trim stuff and also in the qm_mietkalt share.
gstats winsor qm_mietkalt, replace trim 
sum mietekalt wohnflaeche ajahr qm_mietkalt, d
drop if qm_mietkalt == .
sum mietekalt wohnflaeche ajahr qm_mietkalt, d

drop wohnflaeche

*Now we go back to Stadtteile

gen n1 = _n
reshape long Stadtteil, i(n1) j(n)
drop n1
drop if Stadtteil == ""
*objektzustand mietewarm baujahr wohnflaeche
*use plz  mietekalt using $rentpath/WM_SUF_ohneText, clear



gcollapse (mean) miet_mean = mietekalt qm_miet_mean = qm_mietkalt (sd)  miet_sd = mietekalt qm_miet_sd = qm_mietkalt (p50)  ///
miet_p50 = mietekalt qm_miet_p50 = qm_mietkalt   (p10) miet_p10 = mietekalt qm_miet_p10 = qm_mietkalt (p25) miet_p25 = mietekalt qm_miet_p25 = qm_mietkalt ///
(p75) miet_p75 = mietekalt qm_miet_p75 = qm_mietkalt (p90) miet_p90 = mietekalt qm_miet_p90 = qm_mietkalt (count)  N = mietekalt, by(Stadtteil ajahr)
compress
save "${path}/descriptives_`city'.dta", replace

}


foreach city in Frankfurt Munich Cologne Hamburg Stuttgart Dusseldorf Berlin Dortmund {
use "${path}/descriptives_`city'.dta" ,clear
drop if N < 20
bysort ajahr: egen rank = rank(miet_mean)
egen id = group(Stadtteil)

cap mat drop A   
forvalues i = 1/45 {
reg rank ajahr if id == `i'

mat A = nullmat(A) \ `i', _b[ajahr]

}

}

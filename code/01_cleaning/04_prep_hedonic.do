/// PROJECT: Rent Extraction Project
/// GOAL: Hedonic Regressions
/// AUTHOR: Laura Arnemann
/// CREATION: 27-12-2022
/// LAST UPDATE: 27-12-2022
/// SOURCE: Cleaned RWI Data


use "${IN}/Sonderaufbereitung_RED_v9_WM.dta", clear 

use obid uniqueID_gen duplicateid immobilientyp baujahr ///
                mietekalt mietewarm nebenkosten kaufpreis ///
                wohnflaeche grundstuecksflaeche ///
                ajahr amonat ejahr emonat ///
                plz  kid2019 ///
                zimmeranzahl ausstattung objektzustand kategorie_Haus ///
                kategorie_Wohnung balkon garten gaestewc einbaukueche ///
                keller einliegerwohnung heizkosten_in_wm_enthalten ///
                aufzug PLR_ID using "${IN}/Sonderaufbereitung_RED_v9_WM.dta", clear 


keep if kid2019 == 11000
drop kid2019
rename ajahr jahr 

gen sqm_rent=mietekalt/wohnflaeche 

rename plz zip
rename mietekalt nrent
rename mietewarm wrent
rename nebenkosten acost
rename wohnflaeche sqm
rename immobilientyp adtype
rename kaufpreis sprice

// Hedonic controls, I think we should always use categorial version
rename baujahr conyr
rename zimmeranzahl rooms
rename grundstuecksflaeche plotarea
rename ausstattung equipment
rename objektzustand condition // can be used for first occupancy and more
rename kategorie_Haus housetype
rename kategorie_Wohnung flattype
rename balkon balcony
rename garten garden
rename gaestewc guesttoilet
rename einbaukueche fitkitchen
rename keller cellar
rename einliegerwohnung grannyflat
rename heizkosten_in_wm_enthalten includesheating
rename aufzug elevator


foreach var of varlist * {
      if ("`var'" != "PLR_ID" & "`var'" != "zip" ) replace `var' = . if `var' < 0
}



rename jahr year

 * Drop implausible high values 
 drop if sqm_rent>40 
 drop if sqm_rent<3
 
 
// Hedonic: Construction year
noi di as text "conyr " _c
gen cat_conyr = 1* (conyr == . | conyr < 1850 ) + ///
                2* (inrange(conyr,1850,1899)) + ///
                3* (inrange(conyr,1900,1945)) + ///
                4* (inrange(conyr,1946,1959)) + ///
                5* (inrange(conyr,1960,1969)) + ///
                6* (inrange(conyr,1970,1979)) + ///
                7* (inrange(conyr,1980,1989)) + ///
                8* (inrange(conyr,1990,1999)) + ///
                9* (inrange(conyr,2000,2009)) + ///
                10* (conyr >= 2010 & conyr < .)
qui tab cat_conyr, gen(D_conyr)
label var D_conyr1 "pre-1850"
label var D_conyr2 "1850-99"
label var D_conyr3 "1900-45"
label var D_conyr4 "1946-59"
label var D_conyr5 "1960-69"
label var D_conyr6 "1970-79"
label var D_conyr7 "1980-89"
label var D_conyr8 "1990-99"
label var D_conyr9 "2000-09"
label var D_conyr10 "post-2010"


// Hedonic: Rooms

gen rooms_round = ceil(rooms)               
gen cat_rooms = 0* (rooms_round == . | rooms_round <= 0) + ///
                1* (rooms_round == 1) + ///
                2* (rooms_round == 2) + ///
                3* (rooms_round == 3) + ///
                4* (rooms_round == 4) + ///
                5* (rooms_round == 5) + ///
                6* (rooms_round == 6) + ///
                7* (rooms_round == 7) + ///
                8* (rooms_round == 8) + ///
                9* (rooms_round == 9) + ///
                10* (rooms_round == 10) 
qui tab cat_rooms, gen(D_rooms)
label var D_rooms1 "miss"
label var D_rooms2 "1"
label var D_rooms3 "2"
label var D_rooms4 "3"
label var D_rooms5 "4"
label var D_rooms6 "5"
label var D_rooms7 "6"
label var D_rooms8 "7"
label var D_rooms9 "8"
label var D_rooms10 "9"
label var D_rooms11 "10+"
drop cat_rooms rooms_round rooms



// Hedonic: Equipment
noi di as text "equipment " _c
gen cat_equip = 0* (equipment == . | equipment <= 0) + ///
                1* (equipment == 1) + ///
                2* (equipment == 2) + ///
                3* (equipment == 3) + ///
                4* (equipment == 4) 
qui tab cat_equip, gen(D_equip)
label var D_equip1 "miss"
label var D_equip2 "simple"
label var D_equip3 "normal"
label var D_equip4 "good"
label var D_equip5 "luxury"
drop cat_equip  equipment

// Hedonic: Condition
noi di as text "condition " _c
gen cat_cond =  0* (condition == . | condition <= 0) + ///
                1* (condition == 1) + ///
                2* (condition == 2) + ///
                3* (condition == 3) + ///
                4* (condition == 4) + ///
                5* (condition == 5) + ///
                6* (condition == 6) + ///
                7* (condition == 7) + ///
                8* (condition == 8) + ///
                9* (condition == 9) + ///
                10*(condition == 10)
qui tab cat_cond, gen(D_cond)
label var D_cond1 "miss"
label var D_cond2 "first-time use"
label var D_cond3 "first-time use after redevelopment"
label var D_cond4 "like new"
label var D_cond5 "reveloped"
label var D_cond6 "modernized"
label var D_cond7 "fully renovated"
label var D_cond8 "neat"
label var D_cond9 "needs renovation"
label var D_cond10 "as agreed"
label var D_cond11 "dilapidated"
drop cat_cond condition


// Hedonic: Flat type
noi di as text "flattype " _c
gen cat_ftype = 0* (flattype  == . | flattype  <= 0) + ///
                1* (flattype == 1) + ///
                2* (flattype == 3) + ///
                3* (flattype == 4) + ///
                4* (flattype == 6) + ///
                5* (flattype == 7) + ///
                6* (flattype == 8) + ///
                7* (flattype == 9) + ///
                8*(flattype == 10) + ///
                9*(flattype  == 11) 
qui tab cat_ftype, gen(D_ftype)
label var D_ftype1 "miss"
label var D_ftype2 "attic apartment"
label var D_ftype3 "apartment"
label var D_ftype4 "mezzanine"
label var D_ftype5 "duplex"
label var D_ftype6 "penthouse"
label var D_ftype7 "basement"
label var D_ftype8 "terrace apartment"
label var D_ftype9 "other"
label var D_ftype10 "not specified"
drop cat_ftype   flattype

// Hedonic: Balcony
noi di as text "balcony " _c
gen cat_balc =  0* (balcony == .) + ///
                1* (balcony == 0) + ///
                2* (balcony == 1) 
qui tab cat_balc, gen(D_balc)
label var D_balc1 "miss"
label var D_balc2 "no"
label var D_balc3 "yes"
drop cat_balc balcony

// Hedonic: Garden
noi di as text "garden " _c
gen cat_garden =  0* (garden == .) + ///
                  1* (garden == 0) + ///
                  2* (garden == 1) 
qui tab cat_garden, gen(D_garden)
label var D_garden1 "miss"
label var D_garden2 "no"
label var D_garden3 "yes"
drop cat_garden garden

// Hedonic: Guest toilet
noi di as text "guesttoilet " _c
gen cat_toilet =  0* (guesttoilet == .) + ///
                  1* (guesttoilet == 0) + ///
                  2* (guesttoilet == 1) 
qui tab cat_toilet, gen(D_toilet)
label var D_toilet1 "miss"
label var D_toilet2 "no"
label var D_toilet3 "yes"
drop cat_toilet guesttoilet

// Hedonic: Kitchen included
noi di as text "fitkitchen " _c
gen cat_kitchen = 0* (fitkitchen == .) + ///
                  1* (fitkitchen == 0) + ///
                  2* (fitkitchen == 1) 
qui tab cat_kitchen, gen(D_kitchen)
label var D_kitchen1 "miss"
label var D_kitchen2 "no"
label var D_kitchen3 "yes"
drop cat_kitchen fitkitchen

// Hedonic: Cellar
noi di as text "cellar " _c
gen cat_cellar = 0* (cellar == .) + ///
                 1* (cellar == 0) + ///
                 2* (cellar == 1) 
qui tab cat_cellar, gen(D_cellar)
label var D_cellar1 "miss"
label var D_cellar2 "no"
label var D_cellar3 "yes"
drop cat_cellar cellar

// Hedonic: Elevator
noi di as text "elevator " _c
gen cat_elevator = 0* (elevator == .) + ///
                   1* (elevator == 0) + ///
                   2* (elevator == 1) 
qui tab cat_elevator, gen(D_elevator)
label var D_elevator1 "miss"
label var D_elevator2 "no"
label var D_elevator3 "yes"
drop cat_elevator elevator

// Hedonic: Heating included
noi di as text "includesheating " _c
gen cat_heating =  0* (includesheating == .) + ///
                   1* (includesheating == 0) + ///
                   2* (includesheating == 1) 
qui tab cat_heating, gen(D_heating)
label var D_heating1 "miss"
label var D_heating2 "no"
label var D_heating3 "yes"
drop cat_heating includesheating


// List of hedonic variables
local hedvars conyr rooms plot equip cond htype ftype balc garden toilet ///
              kitchen cellar elevator heating
			  

    //
    // Check characteristics
    //
    
    // Save plot with characteristics over time
    /*
    local setgraph = "`c(graphics)'"
    set graphics off
    foreach h of local hedvars {
        noi di as text "`h' " _c
        local addlabel
        local i = 0
        foreach dvar of varlist D_`h'* {
            local ++i
            local addlabel `addlabel' `i' "`: var label `dvar''"
        }
        graph bar D_`h'*, over(year) stack legend(order(`addlabel') span cols(3))
        graph export "graphs/housechars/`h'_ad`a'.pdf", replace
    } // h
    graph bar sqm, over(year)
    graph export "graphs/housechars/sqm_ad`a'.pdf", replace
    set graphics `setgraph'
    */
    
    // Drop baseline categories

    drop D_conyr6 // baseline: built in the 1970s
    drop D_rooms4 // baseline: 3-rooms for an apartment
    drop D_equip3 // baseline: normal equipment
    drop D_cond1 // baseline: missing (1/3 of sample)
    drop D_ftype2 // baseline: apartment in larger building, missing for houses
    drop D_balc1 // baseline: missing 
    drop D_garden2 // baseline: no use of garden possible (apartments), missing for houses -- always have a garden
    drop D_toilet2 // baseline: no guest toilet (poor owners)
    drop D_kitchen1 // baseline: missing info 
    drop D_cellar3 // baseline: yes
    drop D_elevator1 // baseline: missing
    drop D_heating1 // baseline: missing

    // Rebase sqm (center around median)
  gen sqm_std = sqm -  68 // median;  mean 75
    gen sqm_std2 = (sqm_std/100)^2


    //
    // Run hedonic model
    //
    
    noi di as text "      run hedonics:"
	
	local yvars sqm_rent // Rental apartment
    
    // Select characteristics to net out via hedonic regression
	local hedonics D_conyr* D_rooms* D_equip* D_cond* ///
                                        D_ftype* D_balc* D_garden* D_toilet* ///
                                        D_kitchen* D_cellar* D_elevator* ///
                                        D_heating* sqm_std sqm_std2

    // Loop over outcome variables
    local collectvars                   
    foreach var of local yvars {
        // Run hedonic regression and predict purified time series
        noi areg `var' `hedonics', absorb(PLR_ID) noomitted noempty
        predict dresid if e(sample), dresiduals
        gen `var'_hed = dresid + _b[_cons]
        drop dresid
        local collectvars `collectvars' `var' `var'_hed
    } // var

    // Store average/median/p25/p75/nobs for raw data and hedonic variable
    noi di as text _n "collapse " _c
    foreach stat in avg med p25 p75 num {
        local collect_`stat'
        foreach var of local collectvars {
            local collect_`stat' `collect_`stat'' `var'_`stat'=`var'
        } // var
    } // stat
    
    // Collapse data
    gcollapse (mean) `collect_avg' ///
              (median) `collect_med' ///
              (p25) `collect_p25' ///
              (p75) `collect_p75' ///
              (count) `collect_num', by(PLR_ID year)
    
    // Store data
    noi di as text "save " _c
    save "${TEMP}/hedonic_regressions_a.dta", replace

use "${TEMP}/hedonic_regressions_a.dta", clear 

    //
    // Generate statistics and hedonics for different rental types
    //  Note: Do this only for rental objects for now (not for sales offers!)
    //
	
/*	
        // Loop over indicators for heterogeneous groups
        local collectvars
        foreach grvar of varlist gr_* {
            noi di as text _n "subgroups by `grvar':"
            local het_stub = substr("`grvar'", 4, .)

            // Loop over groups
            glevelsof `grvar'
            foreach gr in `r(levels)' {
                noi di as text _n "`grvar'=`gr'"
                // Prepare standardized size-measure
                cap drop sqm_std*
                // Standardize floor area for houses
                if (`a' == 2) {
                    // EVS-Median single-family home in tertile
                    if ("`grvar'" == "gr_sqm") {
                        if      (`gr' == 1) gen sqm_std = sqm -  96
                        else if (`gr' == 2) gen sqm_std = sqm - 125
                        else if (`gr' == 3) gen sqm_std = sqm - 160
                    }
                    // EVS-Median single-family home below/above median
                    else if ("`grvar'" == "gr_sqmgr") {
                        if      (`gr' == 1) gen sqm_std = sqm - 105
                        else if (`gr' == 2) gen sqm_std = sqm - 150
                    }
                    // EVS-Median single-family home below/above median
                    else if ("`grvar'" == "gr_cysqm") {
                        if      (inlist(`gr', 1, 3)) gen sqm_std = sqm - 105
                        else if (inlist(`gr', 2, 4)) gen sqm_std = sqm - 150
                    }
                    // EVS-Median single-family homes
                    else gen sqm_std = sqm - 125
                }
                // Standardize floor area for partments
                else if (`a' == 4) {
                    // EVS-Median multi-family home in tertile
                    if ("`grvar'" == "gr_sqm") {
                        if      (`gr' == 1) gen sqm_std = sqm -  50
                        else if (`gr' == 2) gen sqm_std = sqm -  70
                        else if (`gr' == 3) gen sqm_std = sqm - 100
                    }
                    // EVS-Median multi-family home below/above median
                    else if ("`grvar'" == "gr_sqmgr") {
                        if      (`gr' == 1) gen sqm_std = sqm - 55
                        else if (`gr' == 2) gen sqm_std = sqm - 88
                    }
                    // EVS-Median multi-family home below/above median
                    else if ("`grvar'" == "gr_cysqm") {
                        if      (inlist(`gr', 1, 3)) gen sqm_std = sqm - 55
                        else if (inlist(`gr', 2, 4)) gen sqm_std = sqm - 88
                    }
                    // EVS-Median multi-family homes
                    else gen sqm_std = sqm - 69
                }
                gen sqm_std2 = (sqm_std/100)^2

                // Run hedonic regressions for each outcome
                foreach yvar of local yvars {
                    // Create group-specific outcome measure
                    noi di as text _n "adtype=`a', grvar=`grvar', gr=`gr', yvar=`yvar'"
                    gen `yvar'_`het_stub'`gr' = `yvar' if `grvar' == `gr'

                    // Run regression and predict non-systematic components
                    noi areg `yvar'_`het_stub'`gr' `hedonics', ///
                        absorb(muniyear) noomitted noempty
                    predict dresid if e(sample), dresiduals
                    gen `yvar'_`het_stub'`gr'_hed = dresid + _b[_cons]
                    drop dresid

                    // Store both raw data and hedonic cleaned variable
                    local collectvars `collectvars' `yvar'_`het_stub'`gr' ///
                                                    `yvar'_`het_stub'`gr'_hed
                } // var
            }
        }
        
        // Keep mean, median, and observations for later use
        noi di as text "collapse " _c
        foreach stat in avg med num {
            local collect_`stat'
            foreach var of local collectvars {
                local collect_`stat' `collect_`stat'' `var'_`stat'=`var'
            } // var
        } // stat
    
        // Collapse data
        gcollapse (mean) `collect_avg' ///
                  (median) `collect_med' ///
                  (count) `collect_num', by(muni2015 year)
        
        // Store data
		save "${TEMP}/hedonic_regressions_het_a.dta", replace
        local datacollect `datacollect' "hedonics-het-a`a'"
        restore
        noi di as text "OK" _c
    }


    // Done. Next ad type.
    noi di as text _n
    
}  // a

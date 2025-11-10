
/**
 * PICTUREIT - PLOT ESTIMATED COEFFICIENTS
 *
 * @project proptax-rents
 * (c) M. Löffler, S. Siegloch
 */


cap prog drop pictureit_new
prog define pictureit_new
    syntax anything(name=laglist id=laglist), ///
         [Hole DL Level(integer 5) rhs(string) ytitle(passthru) title(string) ///
          note(string asis) name(string) save iavar(varlist) ylabel(passthru) ///
          fullshift(string) fulllabel(string) zerolabel(string) ///
          xtitle(string) subtitle(passthru) nonote b(string) v(string)]
    
    *graph drop _all 
    
    local lead = real(word("`laglist'", 1))
    local lag  = real(word("`laglist'", 2))
    
    if ("`iavar'" != "") {
        qui levelsof `iavar', l(IAlev)
        local values : value label `iavar'
    }
    else local IAlev 0
    local IAcount : word count `IAlev'
    
    if ("`dl'" != "") {
    
        if ("`hole'" != "")  error "What the fuck?"
        
        local degrees = e(df_r)

        if ("`iavar'" == "") {
            forval f = 1/`lead' {
                local ff = `f' - 1
                if `f' == 1 local nlcom_lead`f' 0
                else local nlcom_lead`f' _b[`rhs'_F`ff'] + `nlcom_lead`ff''
            }
            forval l = 0/`lag' {
                local ll = `l' - 1 
                if `l' == 0 local nlcom_lag`l' _b[`rhs'_L`l']
                else local nlcom_lag`l' _b[`rhs'_L`l'] + `nlcom_lag`ll''
            }
        } // no IA
        else if ("`iavar'" != "") {
            foreach i of local IAlev {
                forval f = 1/`lead' {
                    local ff = `f' - 1
                    if `f' == 1 local nlcom_lead`f'_IA`i' 0
                    else        local nlcom_lead`f'_IA`i' _b[`i'.`iavar'#c.`rhs'_F`ff'] ///
                                                          + `nlcom_lead`ff'_IA`i''
                }
                forval l = 0/`lag' {
                    local ll = `l' - 1 
                    if `l' == 0 local nlcom_lag`l'_IA`i' _b[`i'.`iavar'#c.`rhs'_L`l']
                    else        local nlcom_lag`l'_IA`i' _b[`i'.`iavar'#c.`rhs'_L`l'] ///
                                                         + `nlcom_lag`ll'_IA`i''
                }
            } // i of IALEV
        } // IA loop
        
        local nlcom_com
        if ("`iavar'" == "") {      
            forval f = `lead'(-1)1 {
                local nlcom_com `nlcom_com' (`rhs'_F`f': -(`nlcom_lead`f'')) 
            }
            forval l = 0/`lag' {
                local nlcom_com `nlcom_com' (`rhs'_L`l': (`nlcom_lag`l'')) 
            }
        } // no IA
        else if ("`iavar'" != "") {
            foreach i of local IAlev {
                forval f = `lead'(-1)1 {
                    local nlcom_com `nlcom_com' (`rhs'_F`f'_IA`i': -(`nlcom_lead`f'_IA`i''))
                }
                forval l = 0/`lag' {
                    local nlcom_com `nlcom_com' (`rhs'_L`l'_IA`i':  (`nlcom_lag`l'_IA`i''))
                }
            } // i of IA lev
        } // IA loop
        noi di ""
        noi di "Cummulative Effects from Distributed Lag Model"
        noi nlcom `nlcom_com', post level(`=100-`level'') df(`degrees') noheader
    }
    else local degrees = e(df_r)
    local obs = e(N)
	
	
	if "`b'" == "" local mb b
	if "`b'" != "" local mb `b'
 
 	if "`v'" == "" local mV V
	if "`v'" != "" local mV `v'
 
    * Prepare data set
    if ("`hole'" != "") local dim = `lead' + `lag'
    else                local dim = `lead' + `lag' + 1
    local dim = `dim' * `IAcount'
    
    mat A = e(`mb')
    mat A = A[1...,1..`dim']
    
    mat B = e(`mV')
    mat B = B[1..`dim',1..`dim']
    mat B = vecdiag(B)
    
    mat C = I(`dim')* `degrees'
    mat C = vecdiag(C)
    
    mat D = A \ B \ C
    mat D = D'
    
    if ("`hole'" != "") {
        ** BUGGY for Event Study if IA **
        mat E = (0,0,0) 
        mat rown E = F1
        mat F = D[1..`=`lead'-1',1...] \ E \ D[`lead'..`=`lead'+`lag'',1...]
    }
    else mat F = D

    mat coln F = b se dof
    
    *if ("`save'" != "") mat `name' = F
    
    * Write data set to mem
    preserve
    svmat F, names(col)
    qui keep if b != .
    qui replace se = sqrt(se)
    sum dof if dof != 0, mean 
    local DOF = r(mean) 
    qui keep b se 
        
    * Generate confidence intervals
    qui gen upp = b + invttail(`DOF', (`level' / 100) / 2) * se
    qui gen low = b - invttail(`DOF', (`level' / 100) / 2) * se
    
    if ("`iavar'" != "") {      
        gen num = _n
        xtile IAgroup = (num), n(`IAcount')
        drop num
    }
    else if ("`iavar'" == "") gen IAgroup = 0
    
    * Generate timing variable
    bys IAgroup: gen timing = _n - `1' -1
    *replace timing = timing + 1 if timing >= 0
    
    if ("`save'" != "")  {
        save "results/estimates/`name'", replace
        estimates save "results/estimates/`name'", replace
*               estwrite "results/estimates/`name'", replace

    }
    
    * Wrap note
    *wordwrap `note', l(100)
   
    local xrange = "range(`=-`lead'' `lag')"
    local xlabel = "#`=(`lag' + `lead' + 1)', valuelabel"

    local symbol1 O
    local symbol2 T
    local symbol3 D
    local symbol4 S
    local symbol5 X
    local symbol6 +
    local symbol7 th
    local symbol8 dh
    local symbol9 sh

    local linep1 solid
    local linep2 dash
    local linep3 dot
    local linep4 dash_dot
    local linep5 shortdash
    local linep6 shortdash_dot
    local linep7 longdash
    local linep8 longdash_dot
    local linep9 solid
    
    if ("`iavar'" == "") {
        local graphs (connected b timing, color("$col1")) ///
                     (rcap upp low timing, color("$col1"))
        local legend legend(off)
    }
    else {
        local graphs
        local legend 
        local run = 0
        local order
        foreach i of local IAlev {
            local run = `run' + 1
            local mrun = `run' - 1
            local graphs `graphs' (connected b timing if IAgroup == `i', ///
                                    lcolor("${col`run'}") ///
                                    lpattern("`linep`run''") ///
                                    mcolor("${col`run'}") ///
                                    msymbol(`symbol`run'')) ///
                                  (rcap upp low timing if IAgroup == `i', ///
                                    lcolor("${col`run'}"))
            local lab`i' : label `values' `i'
            local legend `legend' label(`=`mrun'*2+1' "`lab`i''")
            local order `order' `=`mrun'*2+1'
        }
        
        local order order(`order')
        if inlist(`IAcount', 2, 3) {
            qui replace timing = timing - 0.1 if IAgroup == 1
            qui replace timing = timing + 0.1 if IAgroup == 2
        }
        else if inlist(`IAcount', 4, 5) {
            qui replace timing = timing - 0.1  if IAgroup == 1
            qui replace timing = timing - 0.05 if IAgroup == 2
            qui replace timing = timing + 0.1  if IAgroup == 3
            qui replace timing = timing + 0.05 if IAgroup == 4
        }
        else if inlist(`IAcount', 6, 7) {
            qui replace timing = timing - 0.100 if IAgroup == 1
            qui replace timing = timing - 0.066 if IAgroup == 2
            qui replace timing = timing - 0.033 if IAgroup == 3
            qui replace timing = timing + 0.033 if IAgroup == 4
            qui replace timing = timing + 0.066 if IAgroup == 5
            qui replace timing = timing + 0.100 if IAgroup == 6
        }       
        
        local legend legend(`legend' `order' rows(1) pos(6) span) 
    }
    
    if ("`note'" != "" & "`note'" != "nonote") local putnote note(`note')
    else if ("`note'" == "") local putnote note("Number of obs: `obs'.")
    else local putnote

    * Plot graph
    if ("`xtitle'" == "") local xtitle = "Years Relative to Social Housing Change"
    twoway `graphs', ///
        xline(-0.5) yline(0) `legend' xtitle("`xtitle'") ///
        name(`name', replace) `ytitle' ///
        title("`title'") xscale(`xrange') xlabel(`xlabel') /* `ylabel' */ ///
        `putnote' `subtitle'
    

    * Save graph
    graph export "${output}/`name'.pdf", replace

    restore
end




***

use "${TEMP}/socialhousing_onlytreated.dta", replace
* Also played around a bit with the different control groups 
* append using "${TEMP}/socialhousing_onlydonors.dta"
append using "${TEMP}/socialhousing_adj_neighbors.dta"
* append using "${TEMP}/socialhousing_adjadj_neighbors.dta"


keep PLR_ID treat* donorpool

merge 1:m PLR_ID using "${TEMP}/socialhousing_1_since2008.dta", keepusing(qm_miete_kalt jahr object share)
rename jahr year 
keep if _merge==3 
drop _merge 

merge 1:1 PLR_ID year using "${TEMP}/hedonic_regressions_a.dta", keepusing(sqm_rent_hed_avg sqm_rent_hed_med sqm_rent_hed_p25 sqm_rent_hed_p75)
keep if _merge==3

gen other_id = substr(PLR_ID, 1,4)
encode other_id, gen(other_code)

encode PLR_ID, gen(plr_code)
xtset plr_code year


gen ln_miete_kalt = log(qm_miete_kalt)
gen ln_miete_p75 = log(sqm_rent_hed_p75)
gen ln_objects = log(objects)

gen diff_share = d.share

local F = 4
local L = 4

gen T_dummy = 0
replace T_dummy = 1 if diff_share<=-5 
br diff_share change_share3 change_share1
gen T_scaled = T_dummy * d.share * -1



import delimited using "$TEMP/scm_prep_max.csv", clear

xtset plr_id_num jahr

drop diff_share
gen diff_share = d.share

* set lag length
local F = 4
local L = 4

* OLD TREATMENT DEFINTION
* gen T_dummy = 0
* replace T_dummy = 1 if diff_share <= -5 
* gen T_scaled = T_dummy * d.share * -1

* generate dummy for treatment year only
gen T2_dummy = fy_treat0== fy_auxil2
replace T2_dummy=0 if treated==0 | treated==.

* shock in dummy
gen T2_scaled=  T2_dummy * d.share * -1

* br plr_id_num jahr dynamic_treat_1st_max treated fy_auxil2 share

// Create leads and lags of event study coefficients
noi di as text "Create leads and lags ... " _c
foreach var of varlist T2_dummy T2_scaled  {
	noi di as text "`var' " _c
	
	*** Generate leads
	forval f = `F'(-1)1 {
		g `var'_F`f' = F`f'.`var'
	} // f

	*** Generate lags
	forval l = 0(1)`L' {
	
		g `var'_L`l' = L`l'.`var'
		
	} // l

	*** Bin endpoints
	bysort plr_id_num: g `var'_L`L'_tmp = sum(`var'_L`L')

	gsort plr_id_num -jahr
	by plr_id_num: g `var'_F`F'_tmp = sum(`var'_F`F')

	sort plr_id_num jahr

	replace `var'_L`L' = `var'_L`L'_tmp
	replace `var'_F`F' = `var'_F`F'_tmp

	drop *_tmp
	
} // var

local outcomes qm_miete_kalt
*sqm_rent_hed_avg  
*sqm_rent_hed_med sqm_rent_hed_p25 sqm_rent_hed_p75
// Run event studies 
* first loop over in vs outside A100
forval a = 0/1{
	di "`a'"
	foreach y of local outcomes   {
		foreach x in dummy  scaled   {
		
		local lags_lev                
		forval i = 0/`L' {
			local lags_lev `lags_lev' T2_`x'_L`i'
		}
                
		local leads_lev
		forval i = `F'(-1)2 {
			local leads_lev `leads_lev' T2_`x'_F`i'
		}		
		local mainreg `leads_lev' `lags_lev' 
			
		
		noi reghdfe `y'  `mainreg' if a100_r==`a', ///
                         absorb(i.plr_id_num i.jahr) noomitted noempty cluster(plr_id_num) noconst
						 
		noi pictureit_new `F' `L' , l(5)  rhs(`x')   hole ///
                                            ylabel(, format(%9.2fc))  ///
                                            ytitle("Estimated Effect Relative to Pre Social Housing Year") ///
                                            name(FE_`F'`L'_`y'_`x') ///
                                            nonote
		graph export ${output}/max/regression/t2_dl_`x'_a`a'.png, replace
		} // x
	} // y
}




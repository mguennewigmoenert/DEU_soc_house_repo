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
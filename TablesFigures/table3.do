************************************************************************************************************************
* Create Table 3
************************************************************************************************************************

use masterImputedFiltered if year == 1980 | year == 1990, clear

* Use only if Doms and Lewis PC data is available
keep if d_rpc != . 

generate weightedDpc = d_rpc * afactor * perwt * imputedLaborSupply
generate weightedHours = afactor * perwt * imputedLaborSupply

* Calculate average PC adoption each year in each CZ
collapse (sum) weightedDpc (sum) weightedHours, by(czone year)
preserve
use czRti_all if year == 1980 | year == 1990, clear
save temp/czoneRti_all_8090, replace

restore
naxMerge "m:1 czone year using temp/czoneRti_all_8090" 1 0 1 "Table 3"
naxMerge "m:1 czone using czState" 0 0 1 "Table 3"
naxMerge "m:1 year czone using czPopulation_all, keepusing(population)" 0 0 1 "Table 3"
generate avgDpc = weightedDpc / weightedHours
save table3a, replace

* Panel A - Adjusted PCs per Employee
use table3a if year == 1980, clear
xi: regress avgDpc rtiShare i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table3a 1980" "rtiShare"  

use table3a if year == 1990, clear
xi: regress avgDpc rtiShare i.statefip [aw=population], cluster(statefip) 
naxSaveOutput "Table3a 1990" "rtiShare"   
  
use table3a if year == 1980 | year == 1990, clear
xi: regress avgDpc rtiShare i.year i.statefip [aw=population], cluster(statefip) 
naxSaveOutput "Table3a 1980+1990" "rtiShare" 


* Panel B - Change in Routine Share
foreach i in all college noCollege {
  
  * Keep both the subpopulation and the full-population rtiShare
  * Bring in state and population data calculated previously
  use czRti_`i', clear  
  rename rtiShare rtiShare_subpopulation
  drop highRtiShare
  naxMerge "1:1 czone year using czRti_all, keepusing(rtiShare)" 0 0 1 "Table 3"
  naxMerge "m:1 czone using czState" 0 0 1 "Table 3"
  naxMerge "m:1 year czone using czPopulation_all, keepusing(population)" 0 0 1 "Table 3"
    
  * Calculate differences across years
  keep rtiShare rtiShare_subpopulation statefip czone year population
  reshape wide rtiShare rtiShare_subpopulation population, i(statefip czone) j(year)  
  generate dRtiShare1980 = rtiShare_subpopulation1990 - rtiShare_subpopulation1980
  generate dRtiShare1990 = rtiShare_subpopulation2000 - rtiShare_subpopulation1990
  generate dRtiShare2000 = 2 * (rtiShare_subpopulation2005 - rtiShare_subpopulation2000)
  generate dRtiShare2005 = .  
  reshape long rtiShare rtiShare_subpopulation dRtiShare population, i(statefip czone) j(year)
  drop if year == 2005 | year == 1970 
  
  * Regression
  xi: regress dRtiShare rtiShare i.year i.statefip [aw=population], cluster(statefip) 
  naxSaveOutput "Table3b pop= `i'" "rtiShare"  
}


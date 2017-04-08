************************************************************************************************************************
* Create Table 7
************************************************************************************************************************

use masterImputedFiltered if inlist(year, 1980, 1990, 2000, 2005), clear

* Filter to non-college workers
keep if (college == 0)

generate weightedLabor = perwt * afactor * imputedLaborSupply
drop occ1990dd
collapse (sum) weightedLabor, by(year czone occ1* sex)

* Create table 7 in three different ways (male, female, and all)
save table7a, replace
forvalues index = 1/3 {
  use table7a, clear
    keep if (`index' == 1) | (`index' == 2 & sex == 1) | (`index' == 3 & sex == 2)
    
  collapse (sum) weightedLabor, by(year czone occ1*)    
  save temp/yearCzOcc, replace
  
  * Calculate each occupation group's share of total labor
  collapse (sum) weightedLaborTotal=weightedLabor, by(year czone) 
  naxMerge "1:m year czone using temp/yearCzOcc" 0 0 1 "Table 7"
  replace weightedLabor = weightedLabor / weightedLaborTotal 
  drop weightedLaborTotal 
  
  * Bring in RIOS, instrumental variable, czone states, and population previously calculated
  naxMerge "m:1 czone year using czRti_all, keepusing(rtiShare)" 0 0 1 "Table 7"
  naxMerge "m:1 czone using czRtiIV, keepusing(rtiShareIV)" 0 0 1 "Table 7"
  naxMerge "m:1 czone using czState, keepusing(statefip)" 0 0 1 "Table 7"
  naxMerge "m:1 czone year using czPopulation_all, keepusing(population)" 0 0 1 "Table 7"
  
  * Six different occupation-oriented models per gender group
  capture restore, not
  preserve
  foreach k in occ1_service occ1_transmechcraft occ1_managproftech occ1_clericretail occ1_product occ1_operator {
    restore, preserve
  
    * Choose the correct occupation group for the model
    keep if (`k' == 1)
  
    * Calculate differences across years
    keep weightedLabor rtiShare rtiShareIV population czone statefip year
    reshape wide weightedLabor rtiShare rtiShareIV population, i(czone statefip) j(year)
    generate dweightedLabor1980 = weightedLabor1990 - weightedLabor1980
    generate dweightedLabor1990 = weightedLabor2000 - weightedLabor1990
    generate dweightedLabor2000 = 2 * (weightedLabor2005 - weightedLabor2000)
    generate dweightedLabor2005 = .
    reshape long dweightedLabor weightedLabor rtiShare population rtiShareIV, i(czone statefip) j(year)
    drop if year == 2005
    save table7_`k'_`index', replace
    
    * Regression    
    xi: ivregress 2sls dweightedLabor i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
    naxSaveOutput "Table6 7 index=`index' k=`k'" "rtiShare"    
  }
}

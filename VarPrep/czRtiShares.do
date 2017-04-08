************************************************************************************************************************
* Calculate the RIOS for each commuting zone; also determine if the commuting zone has above/below average RIOS
*
* Input 1: individual-level master data from etlImputeClean.do
* Input 2: occulation-level RTI shares from occRti.do
* Output: czone-level RIOS by year, filtered by college/no-college
************************************************************************************************************************

use masterImputedFiltered, clear   
naxMerge "m:1 occ1990dd using occ1990ddRti, keepusing(rtiIntensive)" 0 0 1 "czRtiShares"

* Separately calculate values among everbody, college, and non-college workers
preserve
foreach i in all college noCollege {
  restore, preserve
  keep if "`i'" == "all" | ("`i'" == "college" & college == 1) | ("`i'" == "noCollege" & (college == 0)) 

  * Individual-level RTI and RTI-intensity
  generate weightedRTI = perwt * afactor * imputedLaborSupply * rtiIntensive
  generate weightedRTILabor = perwt * afactor * imputedLaborSupply * (rtiIntensive != .)
  
  * Average RTI share at czone level
  collapse (sum) weightedRTILabor (sum) weightedRTI, by(czone year)
  generate rtiShare = weightedRTI / weightedRTILabor
  save temp/yearCz, replace

  * National-level rtiShare per year
  collapse (sum) weightedRTILabor (sum) weightedRTI, by(year)
  generate grandRtiShare = weightedRTI / weightedRTILabor 
  drop weightedRTILabor weightedRTI
  save temp/year, replace
  
  * Calculate if CZ is above/below average  
  use temp/yearCz, clear
  naxMerge "m:1 year using temp/year" 1 0 1 "czRtiShares" 
  generate highRtiShare = (rtiShare > grandRtiShare) if rtiShare != .
  keep rtiShare highRtiShare czone year weightedRTILabor
    
  save czRti_`i', replace     
}


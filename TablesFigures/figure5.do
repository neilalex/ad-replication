************************************************************************************************************************
* Create Figure 5
************************************************************************************************************************

use masterImputedFiltered if year == 1980 | year == 2005, clear
preserve

* Filter czRTI to 1980 only
use czRti_all if year == 1980, clear
save temp/czoneRti_all_1980, replace

restore

* Bring in above/below average RIOS, and percentiles, previously calculated
naxMerge "m:1 czone using temp/czoneRti_all_1980, keepusing(highRtiShare)" 0 0 1 "Figure 5"
naxJoinby "occ1990dd using occ1990ddWagePercentiles" 0 0 1 "Figure 5"
replace hourlyWage = log(hourlyWage)

preserve
forvalues i = 0/1 { 
  restore, preserve
  
  keep if highRtiShare == `i' //Two plots, above and below average RIOS

  * Total up data by percentile
  foreach sumYear in 1980 2005 {
    generate weightedPeople`sumYear' = afactor * perwt * imputedLaborSupply * percentileFraction if year == `sumYear'
    generate weightedWage`sumYear' = hourlyWage * afactor * perwt * imputedLaborSupply * percentileFraction if year == `sumYear'
    generate weightedPeopleIfWage`sumYear' = afactor * perwt * imputedLaborSupply * percentileFraction * (hourlyWage != .) if year == `sumYear'
  }
  collapse (sum) weightedPeople1980 (sum) weightedWage1980 (sum) weightedPeopleIfWage1980 (sum) weightedPeople2005 (sum) weightedWage2005 (sum) weightedPeopleIfWage2005, by(percentile)

  * Average wages
  generate averageWage1980 = weightedWage1980 / weightedPeopleIfWage1980
  generate averageWage2005 = weightedWage2005 / weightedPeopleIfWage2005
  save temp/percentile, replace

  * Employment shares
  collapse (sum) weightedPeople1980 (sum) weightedPeople2005
  rename weightedPeople1980 totalPeople1980
  rename weightedPeople2005 totalPeople2005
  cross using temp/percentile
  generate empShare1980 = weightedPeople1980 / totalPeople1980 if totalPeople1980 != .
  generate empShare2005 = weightedPeople2005 / totalPeople2005 if totalPeople2005 != .
  generate empShareChg = (empShare2005 - empShare1980) * 100
    
  * Generate smooth splines for employment and wage changes
  lowess empShareChg percentile, gen(empShareChgSmooth) bwidth(.70) nograph 
  generate wageChg = averageWage2005 - averageWage1980  
  lowess wageChg percentile, gen(wageChgSmooth) bwidth(.50) nograph 
  generate rtiCohort = `i'
  
  save temp/figure5_`i', replace    
}

* Display the figures
use temp/figure5_0
append using temp/figure5_1
keep empShareChgSmooth wageChgSmooth percentile rtiCohort
reshape wide empShareChgSmooth wageChgSmooth, i(percentile) j(rtiCohort)

save figure5, replace
scatter empShareChgSmooth0 empShareChgSmooth1 percentile
scatter wageChgSmooth0 wageChgSmooth1 percentile

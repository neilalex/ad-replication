************************************************************************************************************************
* Create worker percentile groups based on the average hourly wage in each occupation.
* Perform twice, for both occ990dd and occ occupation definitions, since Figure 4 requires the latter
*
* Input: individual-level master data from etlImputeClean.do
* Output: occupation-level percentiles
************************************************************************************************************************

* Percentiles are calculated from 1980 data
use masterImputedFiltered if year == 1980, clear
keep if hourlyWage != .

* Created weighted wages
generate weightedWage = hourlyWage * afactor * perwt * imputedLaborSupply
generate weightedPeopleIfWage = afactor * perwt * imputedLaborSupply * (hourlyWage != .)
save temp/full, replace

preserve
foreach i in occ1990dd occ {
  restore, preserve

  collapse (sum) weightedWage (sum) weightedPeopleIfWage, by(`i')

  generate averageOccWage = weightedWage / weightedPeopleIfWage
  keep if averageOccWage != .
  drop weightedWage weightedPeopleIfWage

  naxMerge "1:m `i' using temp/full" 1 0 1 "occPercentiles"
  drop weightedWage

  * Create 100 discrete percentile buckets
  * Percentages must be double-precision since we perform many very small additions *
  summarize weightedPeopleIfWage
  local totalWeights = r(sum)
  sort averageOccWage hourlyWage 
  generate double cumpercent = weightedPeopleIfWage / `totalWeights' in 1 //
  replace cumpercent = weightedPeopleIfWage / `totalWeights' + cumpercent[_n-1] in 2/l
  generate percentile = ceil(cumpercent*100)

  * Sometimes an occupation spans multiple percentiles. If so, calculate the fraction in each.
  collapse (sum) weightedPeopleIfWage, by(`i' percentile) 
  save temp/occPercentile, replace
  collapse (sum) weightedPeopleIfWage, by(`i')
  rename weightedPeopleIfWage weightedPeopleIfWageOcc
  naxMerge "1:m `i' using temp/occPercentile" 1 0 1 "occPercentiles"
  generate percentileFraction = weightedPeopleIfWage / weightedPeopleIfWageOcc 
  
  drop weightedPeopleIfWage weightedPeopleIfWageOcc
  capture save `i'WagePercentiles, replace
}

************************************************************************************************************************
* Create Figure 2
************************************************************************************************************************

use masterImputedFiltered if year == 1980 | year == 2005, clear
replace hourlyWage = log(hourlyWage)

naxJoinby "occ1990dd using occ1990ddWagePercentiles" 1 0 1 "Figure 2" //Bring in percentile groups previously calculated

* Total up data
foreach sumYear in 1980 2005 {
  generate weightedPeople`sumYear' = afactor * perwt * imputedLaborSupply * percentileFraction if year == `sumYear'
  generate weightedWage`sumYear' = hourlyWage * afactor * perwt * imputedLaborSupply * percentileFraction if hourlyWage != . & year == `sumYear'
  generate weightedPeopleIfWage`sumYear' = afactor * perwt * imputedLaborSupply * percentileFraction if hourlyWage != . & year == `sumYear'
}

* Generate counterfactual data
replace weightedWage2005 = weightedWage1980 if occ1_service == 1
replace weightedPeopleIfWage2005 = weightedPeopleIfWage1980 if occ1_service == 1
replace weightedPeople2005 = weightedPeople2005 * 0.514367816 if occ1_service == 1
replace weightedPeople2005 = weightedPeople2005 * 0.686440678 if occ1_service == 0

* Average wages
collapse (sum) weightedPeople1980 (sum) weightedWage1980 (sum) weightedPeopleIfWage1980 (sum) weightedPeople2005 (sum) weightedWage2005 (sum) weightedPeopleIfWage2005, by(percentile)
generate averageWage1980 = weightedWage1980 / weightedPeopleIfWage1980
generate averageWage2005 = weightedWage2005 / weightedPeopleIfWage2005
save temp/percentile, replace

* Employee share changes
collapse (sum) weightedPeople1980 (sum) weightedPeople2005
rename weightedPeople1980 totalPeople1980
rename weightedPeople2005 totalPeople2005
cross using temp/percentile
generate empShare1980 = weightedPeople1980 / totalPeople1980 if totalPeople1980 != .
generate empShare2005 = weightedPeople2005 / totalPeople2005 if totalPeople2005 != .
generate empShareChg = (empShare2005 - empShare1980) * 100

* Merge with Figure 1 plot data
naxMerge "1:1 percentile using figure1a, keepusing(empShareChgSmooth)" 0 0 1 "Figure 2"

* Panel A Plot
lowess empShareChg percentile, gen(empShareChgSmoothCF) bwidth(1) nograph
save figure2a, replace
scatter empShareChgSmoothCF empShareChgSmooth percentile

* Panel B Plot
generate wageChg = averageWage2005 - averageWage1980
keep if wageChg != .
sort percentile
replace percentile = _n
capture drop wageChgSmooth

naxMerge "1:1 percentile using figure1b, keepusing(wageChgSmooth)" 0 0 1 "Figure 2"

lowess wageChg percentile, gen(wageChgSmoothCF) bwidth(.45) nograph
save figure2b, replace
scatter wageChgSmoothCF wageChgSmooth percentile

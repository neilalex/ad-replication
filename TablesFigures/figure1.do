************************************************************************************************************************
* Create Figure 1
************************************************************************************************************************

use masterImputedFiltered if year == 1980 | year == 2005, clear
replace hourlyWage = log(hourlyWage)

* Bring in percentile groups previously calculated
naxJoinby "occ1990dd using occ1990ddWagePercentiles" 1 0 1 "Figure 1"

//Total up employment and wages in both 1980 and 2005, for each percentile
foreach sumYear in 1980 2005 {
  generate weightedPeople`sumYear' = afactor * perwt * imputedLaborSupply * percentileFraction if year == `sumYear'
  generate weightedWage`sumYear' = hourlyWage * afactor * perwt * imputedLaborSupply * percentileFraction if hourlyWage != . & year == `sumYear'
  generate weightedPeopleIfWage`sumYear' = afactor * perwt * imputedLaborSupply * percentileFraction if hourlyWage != . & year == `sumYear'
}

* Average Wages
collapse (sum) weightedPeople1980 (sum) weightedWage1980 (sum) weightedPeopleIfWage1980 (sum) weightedPeople2005 (sum) weightedWage2005 (sum) weightedPeopleIfWage2005, by(percentile)
generate averageWage1980 = weightedWage1980 / weightedPeopleIfWage1980
generate averageWage2005 = weightedWage2005 / weightedPeopleIfWage2005
save temp/percentile, replace

* Employment Shares
collapse (sum) weightedPeople1980 (sum) weightedPeople2005
rename weightedPeople1980 totalPeople1980
rename weightedPeople2005 totalPeople2005
cross using temp/percentile
generate empShare1980 = weightedPeople1980 / totalPeople1980 if totalPeople1980 != .
generate empShare2005 = weightedPeople2005 / totalPeople2005 if totalPeople2005 != .
generate empShareChg = (empShare2005 - empShare1980) * 100

* Find a smooth spline to fit the employment shares
capture drop empShareChgSmooth
lowess empShareChg percentile, gen(empShareChgSmooth) bwidth(1) nograph
save figure1a, replace
scatter empShareChgSmooth percentile

* Find a smooth spline to fit the wage changes
generate wageChg = averageWage2005 - averageWage1980
keep if wageChg != .
sort percentile
replace percentile = _n
capture drop wageChgSmooth
lowess wageChg percentile, gen(wageChgSmooth) bwidth(.45) nograph

save figure1b, replace
scatter wageChgSmooth percentile

************************************************************************************************************************
* Create Figure 4
************************************************************************************************************************

use masterImputedFiltered if year == 1980, clear

* Percentiles and RIOS previously calculated
naxJoinby "occ using occWagePercentiles" 0 0 1 "Figure 4"
naxJoinby "occ using occRti" 0 0 1 "Figure 4"

generate weightedRti = rtiIntensive * perwt * afactor * imputedLaborSupply * percentileFraction 
generate weights = perwt * afactor * imputedLaborSupply * percentileFraction * (rtiIntensive != .)

collapse (sum) weightedRti (sum) weights, by(percentile)

generate rtiShare = weightedRti / weights

* Generate splines. Use multiple bandwidth parameters to demonstrate over/underfitting possibility.
capture drop rtiShareSmooth rtiShareSmoothOver rtiShareSmoothUnder
lowess rtiShare percentile, gen(rtiShareSmoothOver) bwidth(.15) nograph
lowess rtiShare percentile, gen(rtiShareSmoothUnder) bwidth(10) nograph
lowess rtiShare percentile, gen(rtiShareSmooth) bwidth(.38) nograph
twoway connected rtiShareSmoothOver rtiShareSmoothUnder rtiShareSmooth percentile

save figure4, replace
scatter rtiShareSmoothOver rtiShareSmoothUnder rtiShareSmooth percentile

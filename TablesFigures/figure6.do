************************************************************************************************************************
* Create Figure 6
************************************************************************************************************************

* Figure 6 uses the same data as Appendix Table 1
use tableAppendix1 if year == 1980 | year == 2005, clear 
preserve

* Filter population to 1980 only
use czPopulation_all if year == 1980, clear
save temp/czonePopulation_all_1980, replace
restore
naxMerge "m:1 year czone using temp/czonePopulation_all_1980, keepusing(population populationCount)" 1 1 1 "Figure 6"

* Calculate share change across years
keep czone statefip serviceShare rtiShare year population populationCount
reshape wide serviceShare rtiShare population populationCount, i(czone statefip) j(year)
generate serviceShareChg1980 = serviceShare2005 - serviceShare1980

* Panel A
regress serviceShareChg1980 rtiShare1980 [w=population1980] //Linear regression
graph twoway (lfitci serviceShareChg1980 rtiShare1980 [w=population1980]) (scatter serviceShareChg1980 rtiShare1980)

* Panel B, Population > 750,000
keep if populationCount1980 > 750000
regress serviceShareChg1980 rtiShare1980 [w=population1980] //Linear regression
graph twoway (lfitci serviceShareChg1980 rtiShare1980 [w=population1980]) (scatter serviceShareChg1980 rtiShare1980)


************************************************************************************************************************
* Program qualityChecks.do
* Create control totals and other tabulations to assist with ETL and variable preparation quality control
************************************************************************************************************************


************************************************************************************************************************
* Checks for etlCz.do
************************************************************************************************************************
use czAssembled, clear
preserve

* Check IPUMS geo entity counts by year
tabulate year

* Check cz counts by year
collapse (count) cz_mergevar, by(czone year)
tabulate year

* Check that afactor sums to ~1 for every IPUMS entity (results should be blank)
restore
collapse (sum) afactor, by(year cz_mergevar)
list if afactor < .99


************************************************************************************************************************
* Checks for etlOcc.do
************************************************************************************************************************
use occ1990ddAssembled, clear
preserve

* Check occupation count by year
collapse (count) occ1990dd, by (year occ)
tabulate year

* Check balanced occupation count by year
restore
collapse (count) occ, by(year occ1990dd)
tabulate year


************************************************************************************************************************
* Checks for etlIpumsCzOcc.do
************************************************************************************************************************
use master, clear

* Individual record count by year
tabulate year

* Make sure serial numbers aren't ever duplicated more than ~20 times
duplicates report serial

* Examine group quarters type distribution
tabulate year gqtype

* Examine sex distribution
tabulate year sex

* Examine state distribution
hist statefip

* Examine grade distribution
tabulate higrade year
tabulate educ year
tabulate college year

* Examine employment distribution
tabulate empstat
tabulate classwkr
hist occ
hist ind1990

* Examine labor effort distribution
hist wkswork1
hist wkswork2
hist uhrswork
hist hrswork2

* Examine income distribution
hist incwage


************************************************************************************************************************
* Checks for etlImputeClean.do
************************************************************************************************************************
use masterImputedFiltered, clear

* Individual record count by year
tabulate year

* Make sure serial numbers aren't ever duplicated more than ~20 times
duplicates report serial

* Examine group quarters type distribution
tabulate year gqtype

* Examine sex distribution
tabulate year sex

* Examine state distribution
hist statefip

* Examine grade distribution
tabulate higrade year
tabulate educ year
tabulate college year

* Examine employment distribution
tabulate empstat
tabulate classwkr
hist occ
hist ind1990

* Examine imputed labor distributions
hist hourlyWage
hist hrswork

* Examine prepared variable distributions

hist task_abstract
hist task_routine
hist task_manual
hist task_offshorability
hist d_rpc


************************************************************************************************************************
* Checks for occPercentiles.do
************************************************************************************************************************
use occ1990ddWagePercentiles, clear
hist percentile
hist percentileFraction

use occWagePercentiles, clear
hist percentile
hist percentileFraction


************************************************************************************************************************
* Checks for occRti.do
************************************************************************************************************************
use occ1990ddRti, clear
tabulate rtiIntensive
hist rti
hist task_routine
hist task_manual
hist task_abstract
hist weightedLabor

use occRti, clear
tabulate rtiIntensive
hist rti
hist task_routine
hist task_manual
hist task_abstract
hist weightedLabor


************************************************************************************************************************
* Checks for czPopulation.do
************************************************************************************************************************
use czPopulation_all, clear
hist population

use czPopulation_college, clear
hist population

use czPopulation_noCollege, clear
hist population


************************************************************************************************************************
* Checks for czPopulation.do
************************************************************************************************************************
use czState, clear
tabulate statefip


************************************************************************************************************************
* Checks for czRtiShares.do
************************************************************************************************************************
use czRti_all, clear
hist rtiShare
tabulate highRtiShare

use czRti_college, clear
hist rtiShare
tabulate highRtiShare

use czRti_noCollege, clear
hist rtiShare
tabulate highRtiShare


************************************************************************************************************************
* Checks for czIV.do
************************************************************************************************************************
use czRtiIV, clear
hist rtiShareIV

************************************************************************************************************************
* Per Autor and Dorn communication, if a CZ spans multiple states, then affiliate it with the state in which the 
* greatest number of labor hours were expended in 1980
*
* Input: individual-level master data from etlIpumsCzOcc.do
* Output: commuting zone - state mapping file
************************************************************************************************************************

use master if year == 1980, clear
drop if czone == . | statefip == . 

* Generate candidate states for each CZ
generate population = perwt * afactor
collapse (sum) population, by(statefip czone)
sort czone population

* Find the state with the greatest share of the czone's labor
generate keepRecord = (czone[_n] != czone[_n+1]) 
keep if keepRecord == 1
drop population keepRecord 

save czState, replace

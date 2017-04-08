************************************************************************************************************************
* Create Figure 3
************************************************************************************************************************

use masterImputedFiltered if inlist(year, 1970, 1980, 1990, 2000, 2005), clear
keep if occ1990dd>=4 & occ1990dd<=889 //These occupations are outside A&D's balanced set		

generate laborHours = afactor * perwt * imputedLaborSupply 

* Bring in percentiles previously calculated
naxJoinby "occ1990dd using occ1990ddWagePercentiles" 1 0 1 "Figure 3" 

replace laborHours = laborHours * percentileFraction
generate lowestQuintile = (percentile <= 20)

collapse (sum) laborHours, by(year occ1_service lowestQuintile)
	
save figure3, replace


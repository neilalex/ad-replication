************************************************************************************************************************
* Create an industry-structure-based instrumental variable for each commuting zone
*
* Input: individual-level analytical file from etlImputeClean.do
* Output: instrumental variable tabulated by commuting zone
************************************************************************************************************************

* IV is assembled using purely 1950 data
use masterImputedFiltered if year == 1950, clear 

* Exclude non-reported industries
keep if (ind1990 >= $ivIncludeMin & ind1990 < $ivIncludeMax)

* Use previously calculated RTI scores for each occupation
naxMerge "m:1 occ1990dd using occ1990ddRti, keepusing(rtiIntensive)" 0 0 1 "czIV"
generate weightedLabor = imputedLaborSupply * perwt * afactor
keep if rtiIntensive != .

preserve


************************************************************************************************************************
* Calculate RTI for industry - commuting zone
************************************************************************************************************************

* RTI by industry X state
generate weightedRti = rtiIntensive * imputedLaborSupply * perwt * afactor
generate weight = imputedLaborSupply * perwt * afactor * (rtiIntensive != .)
collapse (sum) weightedRti (sum) weight, by(ind1990 statefip)
save temp/state_industry, replace

* RTI by industry only
collapse (sum) weightedRti (sum) weight, by(ind1990)
rename weightedRti weightedRtiIndustry
rename weight weightIndustry

* Subtract individual state RTIs from total industry
naxMerge "1:m ind1990 using temp/state_industry" 0 0 1 "czIV"
generate weightedRtiExState = weightedRtiIndustry - weightedRti
generate weightExState = weightIndustry - weight

* Associate CZs with these state-industry-level calculations
* Note: not every industry-czone pair created here may truly exist. 
* Here, they are paired together wherever there is a state in common between a CZ and an industry
* The values to actually use from this list are determined during a merge below
naxJoinby "statefip using czState" 0 0 1 "czIV"
collapse (sum) weightedRtiExState (sum) weightExState, by(ind1990 czone statefip)
generate rtiShare = weightedRtiExState / weightExState
save temp/cz_industry_exRti, replace 

************************************************************************************************************************
* Calculate Labor for czone
************************************************************************************************************************
restore

* CZ-Industry Labor
collapse (sum) weightedLabor, by(ind1990 czone)
save temp/cz_industry_labor, replace

* CZ Labor
collapse (sum) weightedLabor, by(czone)
rename weightedLabor czTotalLabor

* Calculate industry labor share within each CZ
naxMerge "1:m czone using temp/cz_industry_labor" 0 0 1 "czIV"
generate industryLaborShare = weightedLabor / czTotalLabor

************************************************************************************************************************
* Combine RTI and Labor
************************************************************************************************************************

* Note: we may in fact drop some of the cz_industry_exRti records, per the note above
naxMerge "1:1 czone ind1990 using temp/cz_industry_exRti, keepusing(rtiShare)" 0 0 1 "czIV"
replace rtiShare = rtiShare * industryLaborShare
collapse (sum) rtiShare, by(czone)
rename rtiShare rtiShareIV

save czRtiIV, replace

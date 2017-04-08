************************************************************************************************************************
* Create Appendix Table 1
************************************************************************************************************************

use masterImputedFiltered, clear
generate weighted_managproftech = occ1_managproftech * afactor * perwt * imputedLaborSupply * (college == 0)
generate weighted_product = occ1_product * afactor * perwt * imputedLaborSupply * (college == 0)
generate weighted_transmechcraft = occ1_transmechcraft * afactor * perwt * imputedLaborSupply * (college == 0)
generate weighted_operator = occ1_operator * afactor * perwt * imputedLaborSupply * (college == 0)
generate weighted_clericretail = occ1_clericretail * afactor * perwt * imputedLaborSupply * (college == 0)
generate weighted_service = occ1_service * afactor * perwt * imputedLaborSupply * (college == 0)
generate weightedLabor = afactor * perwt * imputedLaborSupply * (occ1_service + occ1_product + occ1_transmechcraft + occ1_operator + occ1_clericretail + occ1_service == 1) * (college == 0)

* Find total employment in each category in each CZ in each year
collapse (sum) weighted_managproftech (sum) weighted_product (sum) weighted_transmechcraft (sum) weighted_operator (sum) weighted_clericretail (sum) weighted_service (sum) weightedLabor, by(year czone)

* Bring in RIOS, state data, and population data previously calculated
naxMerge "m:1 czone year using czRti_all, keepusing(rtiShare)" 0 0 1 "Table Appendix 1"
naxMerge "m:1 czone using czState, keepusing(statefip)" 0 0 1 "Table Appendix 1"
naxMerge "m:1 year czone using czPopulation_all, keepusing(population)" 0 0 1 "Table Appendix 1"

* SNESO
generate serviceShare = (weighted_service / weightedLabor)

save tableAppendix1, replace

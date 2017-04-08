************************************************************************************************************************
* Create Table 1
************************************************************************************************************************

* Table 1 is the one table in A&D that only counts people age 18+ 
use masterImputedFiltered if age >= 18

replace hourlyWage = ln(hourlyWage)
generate weightedPeople = afactor * perwt * imputedLaborSupply
generate weightedWage = hourlyWage * weightedPeople
generate weightIfWage = weightedPeople if hourlyWage != .

* Collapse to the occupation group level
collapse (sum) weightedPeople (sum) weightedWage (sum) weightIfWage, by(year occ1_managproftech occ1_clericretail occ1_service occ1_product occ1_operator occ1_transmechcraft)
drop if occ1_managproftech == . | occ1_clericretail == . | occ1_service == . | occ1_product == . | occ1_operator == . | occ1_transmechcraft == .

* Average wages in each occupation group each year
generate avgWage = weightedWage / weightIfWage
save temp/occGroup, replace

* Employment shares in each occupation group each year
collapse (sum) weightedPeople, by(year)
rename weightedPeople TotalPeople
naxMerge "1:m year using temp/occGroup" 0 0 1 "Table 1"
generate employmentShare = weightedPeople / TotalPeople

save table1, replace

************************************************************************************************************************
* Create Table 6
************************************************************************************************************************

use masterImputedFiltered if inlist(year, 1980, 1990, 2000, 2005), clear  
preserve

* Calculate income effect variables
generate weeklyWage = hourlyWage * hrswork * useInWeeklyWageCalc
generate weeklyWageWeight = perwt * afactor * useInWeeklyWageCalc
collapse (p90) weeklyWage [w = weeklyWageWeight], by(year czone)
replace weeklyWage = ln(weeklyWage)
save temp/yearCz, replace

* Assemble offshorability variable using A&D's pre-prepared variable
restore
generate offshorability = task_offshorability * perwt * afactor
generate totalHours = perwt * afactor * (task_offshorability != .)

* Calculate substitution effect variables
generate collegeGradHours = perwt * afactor * imputedLaborSupply * college / 2080
generate totalCollegeGrads = perwt * afactor * college
generate maleCollegeGradHours = perwt * afactor * imputedLaborSupply * college * (sex == 1) / 2080
generate totalMaleCollegeGrads = perwt * afactor * college * (sex == 1)
generate femaleCollegeGradHours = perwt * afactor * imputedLaborSupply * college * (sex == 2) / 2080
generate totalFemaleCollegeGrads = perwt * afactor * college * (sex == 2)
collapse (sum) offshorability (sum) totalHours (sum) collegeGradHours (sum) totalCollegeGrads (sum) maleCollegeGradHours (sum) totalMaleCollegeGrads (sum) femaleCollegeGradHours (sum) totalFemaleCollegeGrads, by(year czone)
replace offshorability = offshorability / totalHours 
replace collegeGradHours = collegeGradHours / totalCollegeGrads
replace maleCollegeGradHours = maleCollegeGradHours / totalMaleCollegeGrads
replace femaleCollegeGradHours = femaleCollegeGradHours / totalFemaleCollegeGrads

* Bring in RIOS, instrumental variable, and commutinng zone states previously calculated
naxMerge "1:1 year czone using temp/yearCz, keepusing(weeklyWage)" 1 1 1 "Table 6" 
naxMerge "m:1 year czone using czRti_all, keepusing(rtiShare)" 1 0 1 "Table 6"
naxMerge "m:1 czone using czRtiIV, keepusing(rtiShareIV)" 0 0 1 "Table 6"
naxMerge "m:1 czone using czState, keepusing(statefip)" 0 0 1 "Table 6"

* Calculate differences across years
keep rtiShare rtiShareIV weeklyWage offshorability collegeGradHours maleCollegeGradHours femaleCollegeGradHours statefip czone year
reshape wide rtiShare rtiShareIV weeklyWage offshorability collegeGradHours maleCollegeGradHours femaleCollegeGradHours, i(statefip czone) j(year)
foreach varName in rtiShare weeklyWage offshorability collegeGradHours maleCollegeGradHours femaleCollegeGradHours {
  generate d`varName'1980 = `varName'1990 - `varName'1980
  generate d`varName'1990 = `varName'2000 - `varName'1990
  generate d`varName'2000 = 2 * (`varName'2005 - `varName'2000) //Multiply by 2 since time window is 1/2 as large as the others
  generate d`varName'2005 = .
}
reshape long rtiShare rtiShareIV weeklyWage offshorability collegeGradHours maleCollegeGradHours femaleCollegeGradHours drtiShare drtiShareIV dweeklyWage doffshorability dcollegeGradHours dmaleCollegeGradHours dfemaleCollegeGradHours, i(statefip czone) j(year)
drop if year == 2005

* Bring in SNESO and population previously calculated
naxMerge "1:1 czone year using table4_czServiceShareChgNoCollege, keepusing(serviceShareChg)" 0 0 1 "Table 6"
naxMerge "1:1 czone year using czPopulation_all" 0 0 1 "Table 6"

save table6, replace


* Regressions
xi: ivregress 2sls serviceShareChg offshorability i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table6 1" "offshorability"

xi: ivregress 2sls serviceShareChg offshorability i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table6 2" "rtiShare offshorability"

xi: ivregress 2sls serviceShareChg dweeklyWage i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table6 3" "dweeklyWage"

xi: ivregress 2sls serviceShareChg dweeklyWage i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table6 4" "rtiShare dweeklyWage"

xi: ivregress 2sls serviceShareChg dcollegeGradHours i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table6 5" "dcollegeGradHours"

xi: ivregress 2sls serviceShareChg dcollegeGradHours i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table6 6" "rtiShare dcollegeGradHours"

xi: ivregress 2sls serviceShareChg dmaleCollegeGradHours i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table6 7" "rtiShare dmaleCollegeGradHours"

xi: ivregress 2sls serviceShareChg dfemaleCollegeGradHours i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table6 8" "rtiShare dfemaleCollegeGradHours"

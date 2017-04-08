************************************************************************************************************************
* Apply a second, more comprehensive set of rules and filters to the raw IPUMS data.
* Impute any missing critical labor supply variables.
*
* Input: master analytical file output from etlIpumsCzOcc.do
* Output: a refined master individual-level analytical file drawn on by several downstream analyses
*
* (Note that some downstream analyses must use the earlier, less-refined analytical file from etlIpumsCzOcc.do)
************************************************************************************************************************

use master, clear


************************************************************************************************************************
* Filter sample to the analysis population
************************************************************************************************************************

* Restrict to working individuals 
* Variable codes available at https://usa.ipums.org/usa-action/variables/WORKEDYR#codes_section
keep if (workedyr == $workedyrYes & inlist(year, 1970, 1980, 1990, 2000, 2005)) ///
  | (year == 1950 & ((wkswork1 != . & wkswork1 >= 1) | (wkswork2 != . & wkswork2 >= 1)))

* Restrict to individuals living outside of institutional and/or group quarters
* Variable codes available at https://usa.ipums.org/usa-action/variables/GQTYPE#codes_section
keep if gqtyped < $gqtypedInstitutionMin | gqtyped > $gqtypedInstitutionMax

* Restrict to individuals of working age
keep if age >= $minAge & age <= $maxAge

* Remove unpaid family workers
* Variable codes available at https://usa.ipums.org/usa-action/variables/CLASSWKR#codes_section
keep if classwkrd != $classwkrdUnpaidFamily


************************************************************************************************************************
* Clean and Impute labor Supply Variables
************************************************************************************************************************

replace uhrswork = . if uhrswork == 00
replace wkswork1 = . if wkswork1 == 00

* If wkswork1 is missing, use the midpoint of wkswork2 (per Dorn communication)
* Value ranges from https://usa.ipums.org/usa-action/variables/WKSWORK2#codes_section
generate wkswork = .
forvalues i = 1/6 {
  replace wkswork = ${wkswork`i'mid} if wkswork2 == `i' & wkswork1 == .
}
replace wkswork = wkswork1 if wkswork1 != .
drop wkswork1 wkswork2

* If uhrswork is missing, use the midpoint of hrswork2 (per Dorn communication)
* Variable value ranges from https://usa.ipums.org/usa-action/variables/HRSWORK2#codes_section
generate hrswork = .
forvalues i = 1/8 {
  replace hrswork = ${hrswork`i'mid} if hrswork2 == `i' & uhrswork == .
}
replace hrswork = uhrswork if uhrswork != .
drop uhrswork hrswork2

* Create education and occupations cohorts for imputing any missing labor hours
* "Educational attainment" (educ) and "Highest Grade of Schooling" (higraded) are 
* two separate IPUMS education variables that we combine for doinog so                                           
replace higraded = 000 if higraded == .
replace educ = 00 if educ == .
egen educ_higraded = concat(educ higraded), punct("_")                                                      
replace educ_higraded = "e" + string(educ) if higraded == 000 
replace educ_higraded = "d" + string(higraded) if educ == 00
replace educ_higraded = "" if (higraded == 000 & educ == 00)
drop higraded

* Create population-weighted annual labor supply variables
* "perwt" is the Census/ACS population weight for the given record
* Don't use imputed data for wage-related results, per Dorn communication,
* and don't use in weekly wage calculations if not a full-week worker
* Create variables for tracking this
generate laborSupply = wkswork * hrswork  
generate weightedLaborSupply = laborSupply * perwt 
generate weightIfLabor = perwt if laborSupply != .
generate useInWageCalc = (classwkr != 1 & wkswork != . & hrswork != . & incwage != .) 

* Also, don't perform wage-related calculations for farm workers, per Dorn communication
replace useInWageCalc = useInWageCalc * (occ1990dd < $occ1990ddFarmWorkerMin | occ1990dd > $occ1990ddFarmWorkerMax)

* Only use workers working minimum hours per week and weeks per year for weekly wage calculations
generate useInWeeklyWageCalc = useInWageCalc * (wkswork >= $minYearlyWks & hrswork >= $minWeeklyHrs & wkswork != . & hrswork != .) 
drop wkswork
preserve

* Education-occupation cohort average labor supply hours, for imputation
collapse (sum) weightedLaborSupply (sum) weightIfLabor, by(occ educ_higraded)
generate avglaborSupplyOccEduc = weightedLaborSupply / weightIfLabor
drop weightedLaborSupply weightIfLabor
keep if occ != . & educ_higraded != ""
save temp/sumOccEduc, replace

* If occupation record is missing, average the full education cohort
restore, preserve
collapse (sum) weightedLaborSupply (sum) weightIfLabor, by(educ_higraded)
generate avglaborSupplyEduc = weightedLaborSupply / weightIfLabor
drop weightedLaborSupply weightIfLabor
keep if educ_higraded != ""
save temp/sumEduc, replace

* Impute missing labor supply hours using the above cohort averages 
restore
drop weightedLaborSupply weightIfLabor
naxMerge "m:1 occ educ_higraded using temp/sumOccEduc" 1 0 1 "etlImputeClean"
naxMerge "m:1 educ_higraded using temp/sumEduc" 1 0 1 "etlImputeClean"
drop educ_higraded
generate imputedLaborSupply = . 
replace imputedLaborSupply = laborSupply if laborSupply != .
replace imputedLaborSupply = avglaborSupplyOccEduc if laborSupply == . & occ != . 
replace imputedLaborSupply = avglaborSupplyEduc if laborSupply == . & (occ == . | avglaborSupplyOccEduc == .) 
drop laborSupply avglaborSupplyOccEduc avglaborSupplyEduc

* Create inflation indices using Personal Consumption Expenditure Index values from BEA website
* See https://www.bea.gov/newsreleases/national/pi/2016/pi1116.htm
* Normalize relative to 2005's PCEI index
* Also, divide by a set of hand-tuned calibration figures as to match A&D's inflation adjustments as closely as possible
* (accounting for BEA restatements following A&D publication)
generate PCEI = 0.0
foreach i in 1950 1970 1980 1990 2000 2005 {
  replace PCEI = (${PCEI`i'} / $PCEI2005) / ${PCEI`i'Adjust} if year == `i'
}

* Top-code and inflation-adjust wages
* Per Dorn communication, when top-coded, multiply IPUMS top-code values by a factor
generate topWage = 0
foreach i in 1950 1970 1980 1990 2000 2005 {
  replace topWage = ${topWage`i'} if year == `i'
}
generate topCodeAdjustedWage = 0
replace topCodeAdjustedWage = topWage * 1.5 if incwage >= topWage & topWage != .
replace topCodeAdjustedWage = incwage if incwage < topWage & topWage != .
replace topCodeAdjustedWage = . if incwage == $unknownWage  
replace topCodeAdjustedWage = topCodeAdjustedWage / PCEI 

* Hourly wages are calculated assuming specified hours worker per week, weeks weeks per year
generate topHourlyWage = (topWage * $topCodeWageFactor) / ($avgWeeklyHrs * $avgYearlyWks)
replace topHourlyWage = topHourlyWage / PCEI
generate hourlyWage = topCodeAdjustedWage / imputedLaborSupply if useInWageCalc == 1
replace hourlyWage = topHourlyWage if useInWageCalc == 1 & hourlyWage > topHourlyWage & hourlyWage != .

* Also bottom-code any wages below the first percentile
summarize hourlyWage [weight = perwt * imputedLaborSupply] if useInWageCalc == 1, detail 
local bottomHourlyWage = r(p1)
replace hourlyWage = `bottomHourlyWage' if hourlyWage < `bottomHourlyWage' & useInWageCalc == 1
drop useInWageCalc topWage incwage PCEI topHourlyWage


************************************************************************************************************************
* Clean Task Score Variables
************************************************************************************************************************

* Bottom-code abstract and manual task scores at the 5th percentile level, as discussed in A&D paper
summarize task_abstract [weight = perwt * imputedLaborSupply * afactor], detail
local abstractP1 = r(p5)
replace task_abstract = `abstractP1' if task_abstract < `abstractP1' & task_abstract != . & `abstractP1' != . 

summarize task_manual [weight = perwt * imputedLaborSupply * afactor], detail
local manualP1 = r(p5)
replace task_manual = `manualP1' if task_manual < `manualP1' & task_manual != . & `manualP1' != .


************************************************************************************************************************
* Perform Final Filters and Save
************************************************************************************************************************

* Drop data with missing occupation or geographic records; they won't be usable
drop if occ1990dd == . | czone == . | statefip == .

save masterImputedFiltered, replace

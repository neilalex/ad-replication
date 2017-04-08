************************************************************************************************************************
* Create Table 5
************************************************************************************************************************

use master if inlist(year, 1980, 1990, 2000, 2005), clear

* Assemble initial control variable data
replace college = (educ >= 7) * perwt * afactor * (educ != .)
generate collegeAvailable = (educ != 00 & educ != .) * perwt * afactor
generate foreignBornNonCollege = (bpl > 120 & bpl != . & (college == 0)) * perwt * afactor
generate birthplaceAvailable = (bpl != . & (college == 0)) * perwt * afactor
generate manufacturing = (ind1990 >= 100 & ind1990 <= 392 & empstat == 1) * perwt * afactor
generate industryAvailable = (ind1990 != . & empstat == 1) * perwt * afactor
generate unemploymentRate = (empstat == 2) * perwt * afactor
generate employmentStatusAvailable = (empstat == 1 | empstat == 2) * perwt * afactor
generate femaleEmployed = (sex == 2 & empstat == 1) * perwt * afactor
generate femalePopulation = (sex == 2 & empstat != 0) * perwt * afactor
generate atLeast65 = (age >= 65 & age != . & age != 0) * perwt * afactor
generate ageAvailable = (age != . & age != 0) * perwt * afactor
preserve

* Collapse control variable data to year-CZ level
collapse (sum) college (sum) collegeAvailable (sum) foreignBornNonCollege (sum) birthplaceAvailable (sum) manufacturing (sum) industryAvailable, by(year czone) 
save temp/yearCz, replace

restore
collapse (sum) unemploymentRate (sum) employmentStatusAvailable (sum) femaleEmployed (sum) femalePopulation (sum) atLeast65 (sum) ageAvailable, by(year czone) 
naxMerge "1:1 year czone using temp/yearCz" 1 1 1 "Table 5"

* Summarize control variables at year-CZ level
replace college = ln(college/(collegeAvailable - college))
replace foreignBornNonCollege = foreignBornNonCollege / birthplaceAvailable
replace manufacturing = manufacturing / industryAvailable
replace unemploymentRate = unemploymentRate / employmentStatusAvailable
replace femaleEmployed = femaleEmployed / femalePopulation
replace atLeast65 = atLeast65 / ageAvailable

* Bring in minimum wage data, which A&D provide in a separate dataset
* Plus RIOS values, instrumental variable, and commuting zone states previously calculated
naxMerge "m:1 czone year using workfile2012, keepusing(l_sh_minw)" 1 0 1 "Table 5"
naxMerge "m:1 czone year using czRti_all, keepusing(rtiShare)" 1 0 1 "Table 5"
naxMerge "m:1 czone using czRtiIV" 0 0 1 "Table 5"
naxMerge "m:1 czone using czState" 0 0 1 "Table 5"

* Calculate differences across years
keep rtiShare rtiShareIV college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 l_sh_min statefip czone year
reshape wide rtiShare rtiShareIV college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 l_sh_minw, i(statefip czone) j(year)
foreach varName in rtiShare college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 {
  generate d`varName'1980 = `varName'1990 - `varName'1980
  generate d`varName'1990 = `varName'2000 - `varName'1990
  generate d`varName'2000 = 2 * (`varName'2005 - `varName'2000) //Multiply by 2 since time window is 1/2 as large as the others
  generate d`varName'2005 = .
}
reshape long rtiShare rtiShareIV college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 l_sh_minw drtiShare drtiShareIV dcollege dforeignBornNonCollege dmanufacturing dunemploymentRate dfemaleEmployed datLeast65, i(statefip czone) j(year)
drop if year == 2005

* Bring in SNESO and population data previously calculated
naxMerge "1:1 czone year using table4_czServiceShareChgNoCollege, keepusing(serviceShareChg)" 0 0 1 "Table 5" 
naxMerge "1:1 czone year using czPopulation_all" 0 0 1 "Table 5"

save table5, replace

* Regressions Panel A
xi: regress serviceShareChg rtiShare i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 1" "rtiShare"

xi: regress serviceShareChg rtiShare college i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 2" "rtiShare college"

xi: regress serviceShareChg rtiShare foreignBornNonCollege i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 3" "rtiShare foreignBornNonCollege"

xi: regress serviceShareChg rtiShare manufacturing unemploymentRate i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 4" "rtiShare manufacturing unemploymentRate"

xi: regress serviceShareChg rtiShare femaleEmployed atLeast65 i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 5" "rtiShare femaleEmployed atLeast65"

xi: regress serviceShareChg rtiShare l_sh_minw i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 6" "rtiShare l_sh_minw"

xi: regress serviceShareChg rtiShare college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 l_sh_minw i.year i.statefip [aw=population], cluster(statefip)
naxSaveOutput "Table5a 7" "rtiShare college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 l_sh_minw"


* Regressions Panel B
xi: ivregress 2sls serviceShareChg i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 1" "rtiShare"

xi: ivregress 2sls serviceShareChg college i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 2" "rtiShare"

xi: ivregress 2sls serviceShareChg foreignBornNonCollege i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 3" "rtiShare"

xi: ivregress 2sls serviceShareChg manufacturing unemploymentRate i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 4" "rtiShare"

xi: ivregress 2sls serviceShareChg femaleEmployed atLeast65 i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 5" "rtiShare"

xi: ivregress 2sls serviceShareChg l_sh_minw i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 6" "rtiShare"

xi: ivregress 2sls serviceShareChg college foreignBornNonCollege manufacturing unemploymentRate femaleEmployed atLeast65 l_sh_minw i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5b 7" "rtiShare"


* Regressions Panel C
xi: ivregress 2sls serviceShareChg i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 1" "rtiShare"

xi: ivregress 2sls serviceShareChg dcollege i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 2" "rtiShare"

xi: ivregress 2sls serviceShareChg dforeignBornNonCollege i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 3" "rtiShare"

xi: ivregress 2sls serviceShareChg dmanufacturing dunemploymentRate i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 4" "rtiShare"

xi: ivregress 2sls serviceShareChg dfemaleEmployed datLeast65 i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 5" "rtiShare"

xi: ivregress 2sls serviceShareChg l_sh_minw i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 6" "rtiShare"

xi: ivregress 2sls serviceShareChg dcollege dforeignBornNonCollege dmanufacturing dunemploymentRate dfemaleEmployed datLeast65 l_sh_minw i.year i.statefip (rtiShare = i.year*rtiShareIV) [aw=population], cluster(statefip)
naxSaveOutput "Table5c 7" "rtiShare"


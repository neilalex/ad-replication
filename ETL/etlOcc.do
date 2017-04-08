************************************************************************************************************************
* Combine A&D's balanced occupation panel mapping files into a single cross-year file
*
* Input: individual balanced occupation mapping files, one per year
* Output: a consolidated balanced-occupation mapping file, merge-able with IPUMS census data
************************************************************************************************************************


* Include a year variable in each of A&D's occupation files
foreach i in 1950 1970 1980 1990 2000 2005 {
  use ${occ`i'File}, clear
  gen year = `i'
  save temp/occ`i', replace
}

* Combine files together
use temp/occ1950, clear
foreach i in 1970 1980 1990 2000 2005 {
  append using temp/occ`i'  
}

* Club workers into six occupation groups; definition subfile provided by David Dorn
do "$programPath/Utilities/$occCategoryDefFile"

save occ1990ddAssembled, replace

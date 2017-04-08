************************************************************************************************************************
* Combine A&D's commuting zone mapping files into a single cross-year file
* The resulting data will eventually be merged with IMPUS census data for the sake of tracking commuting zones
*
* Input: individual commuting zone mapping files, one per year
* Output: a consolidated commuting zone mapping file, merge-able with IPUMS census data
************************************************************************************************************************


* Add year variables, and update the names of the primary keys, for consistency across files
foreach i in 1950 1970 1980 1990 2000 2005 {
  use ${cz`i'File}, clear
  gen year = `i'
  
  * Each year can have a potentially different primary key format
  if (`i' == 1950) rename sea cz_mergevar
  if (`i' == 1970) rename cntygp97 cz_mergevar
  if (`i' == 1980) rename cntygp98 cz_mergevar
  if (inlist(`i', 1990, 2000, 2005)) rename puma cz_mergevar  
  
  save temp/cz`i', replace
}

* Combine files together
use temp/cz1950, clear
foreach i in 1970 1980 1990 2000 2005 {
  append using temp/cz`i'
}

save czAssembled, replace

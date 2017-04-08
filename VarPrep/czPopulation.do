************************************************************************************************************************
* Calculate the population of each state
* Many of the regression models use this as a weight
*
* Input: master individual-level data from etlIpumsCzOcc.do
* Output: czone populations by year, filtered by college/no-college
************************************************************************************************************************

use master, clear

preserve
foreach i in all college noCollege {
  restore, preserve
    
  * Create separate population files counting everybody, college, and non-college
  keep if "`i'" == "all" | ("`i'" == "college" & college == 1) | ("`i'" == "noCollege" & (college == 0)) 
      
  * Calculate the population
  generate population = perwt * afactor

  * Population for each CZ for each year  
  collapse (sum) population, by(year czone)
  generate populationCount = population
  save temp/yearCz, replace
  
  * Total population for each year
  collapse (sum) population, by(year)
  rename population yearPopulation    
  save temp/year, replace
  
  * Combine czone-level and national data to calculate percentages
  use temp/yearCz, clear
  naxMerge "m:1 year using temp/year" 1 0 1 "czPopulation"    
  replace population = populationCount / yearPopulation   
  drop yearPopulation
  
  keep if czone != .    
  save czPopulation_`i', replace      
  
}


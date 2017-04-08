************************************************************************************************************************
* Perform a Stata joinby using passed arguments, displaying the full venn join diagram in the log
*
* The macro starts by creating a full outer join, regardless of whether the join will ultimately be 
* left, right, inner, or outer. Once the venn has been displayed, records are potentially removed so that the 
* resulting data set corresponds to the specified left, right, inner (or potentially still outer) join
************************************************************************************************************************

capture program drop naxJoinby
program define naxJoinby
  args joinArgs pMaster pUsing pMatch description 
  
  log on
  display char(10) + "`description' : `joinArgs'"     
  display("Left-side record count : " + strofreal(_N,"%13.0gc"))

  * Perform out join
  joinby `joinArgs', unmatched(both)
  
  * Display full venn diagram to log
  tabulate _merge
  
  * Adjust final dataset to left/right/inner/outer specification
  drop if (`pMaster' == 0 & _merge == 1)
  drop if (`pUsing' == 0 & _merge == 2)
  drop if (`pMatch' == 0 & _merge == 3) 
  drop _merge
  
  log off
end

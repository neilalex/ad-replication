************************************************************************************************************************
* Perform a Stata merge using passed arguments, displaying the full venn merge diagram in the log
*
* It starts by creating a full outer merge, regardless of whether the merge will ultimately be 
* left, right, inner, or outer. Once the venn has been displayed, records are potentially removed so that the 
* resulting data set corresponds to the specified left, right, inner (or potentially still outer) merge
************************************************************************************************************************

capture program drop naxMerge
program define naxMerge
  args mergeArgs pMaster pUsing pMatch description  
  
  log on
  display char(10) + "`description' : `mergeArgs'"  
  display("Left-side record count : " + strofreal(_N,"%13.0gc"))
  
  * Perform outer merge, displaying full venn diagram
  merge `mergeArgs'
  
  * Adjust final dataset to left/right/inner/outer specification
  drop if (`pMaster' == 0 & _merge == 1)
  drop if (`pUsing' == 0 & _merge == 2)
  drop if (`pMatch' == 0 & _merge == 3)
  drop _merge
  
  log off
end

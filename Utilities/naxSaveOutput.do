************************************************************************************************************************
* Append passed arguments to the outputs.dta dataset
* (Creating outputs.dta if it does not already exist)
************************************************************************************************************************

capture program drop naxSaveOutput 
program define naxSaveOutput 
  args descriptionText saveParams

  preserve
  
  *Create an outputs dataset if one doesn't already exist
  capture confirm file "outputs.dta"
  if _rc != 0 {
    clear   
    gen desc = ""   
    save outputs, replace
  } 
  
  *Load the outputs dataset, which we will use for storing results
  use outputs, clear
  local nplus = _N + 1   
  set obs `nplus'
  
  *Loop through all of the parameters passed into this function, and store their values
  foreach saveParam in `saveParams' { 
    capture generate c_`saveParam' = . in l
    replace c_`saveParam' = _b[`saveParam'] in l
    capture generate SE_`saveParam' = . in l
    replace SE_`saveParam' = _se[`saveParam'] in l
  } 
  capture generate R2 = . in l  
  replace R2 = e(r2) in l
  
  *Save the description of the particular output we are saving
  capture generate desc = . in l  
  replace desc = "`descriptionText'" in l
  
  *Save and exit
  save outputs, replace
  restore
  
end

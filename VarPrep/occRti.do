************************************************************************************************************************
* Calculate the RTI for each 1980 occupation, since Figure 4 needs them
* Perform twice, for both occ990dd and occ occupation definitions, since Figure 4 requires the latter
*
* Input: individual-level master data from etlImputeClean.do
* Output: occupation-level RTI
************************************************************************************************************************


* RTI is defined using 1980 Labor Weights
use masterImputedFiltered if year == 1980, clear

* Create RTI figures
generate weightedLabor = perwt * afactor * imputedLaborSupply * (task_manual != . & task_abstract != . & task_routine != .)
generate rti = ln(task_routine) - ln(task_manual) - ln(task_abstract) //RTI score for each occupation
xtile rtiThird = rti [w = weightedLabor], nquantiles(3)
generate rtiIntensive = (rtiThird==3) //Occupation is RI, yes/no

preserve

* SDs should be zero since the original task scores should not vary across the occupations
collapse (mean) rti (mean) rtiIntensive (sd) sdrti=rti (sd) sdrtiIntensive=rtiIntensive (mean) task_routine (mean) task_manual (mean) task_abstract (sum) weightedLabor, by(occ1990dd occ1* occ2* occ3*)
keep occ1990dd occ1* occ2* occ3* rti rtiIntensive task_routine task_manual task_abstract weightedLabor
save occ1990ddRti, replace

restore
collapse (mean) rti (mean) rtiIntensive (sd) sdrti=rti (sd) sdrtiIntensive=rtiIntensive (mean) task_routine (mean) task_manual (mean) task_abstract (sum) weightedLabor, by(occ)
keep occ rti rtiIntensive task_routine task_manual task_abstract weightedLabor
save occRti, replace

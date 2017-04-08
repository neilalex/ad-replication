************************************************************************************************************************
* Create Table 2
************************************************************************************************************************

use occ1990ddRti
preserve

* Occupation grouping
collapse (mean) rti (mean) task_routine (mean) task_manual (mean) task_abstract [w=weightedLabor], by(occ1_managproftech occ1_clericretail occ1_service occ1_product occ1_operator occ1_transmechcraft)
save temp/occGrouping, replace

* Caluclate averages across all occupations
restore
collapse (mean) rti (mean) task_routine (mean) task_manual (mean) task_abstract [w=weightedLabor] //Collapse to total level to find overall averages

rename rti rtiAvg
rename task_routine task_routineAvg
rename task_manual task_manualAvg
rename task_abstract task_abstractAvg

* Cross occupations and overall averages
cross using temp/occGrouping //

save table2, replace


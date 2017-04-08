************************************************************************************************************************
* Labor Inequality Paper Replication
* 
* Replicated Paper:
* The Growth of Low-Skill Service Jobs and
* the Polarization of the US Labor Market
* By David H. Autor and David Dorn
* American Economic Review 2013, 103(5): 1553-1597
* 
* For discussion, please see
* http://www.neilalex.com/are-studies-in-inequality-robust-this-ones-pretty-good/
*
* Please contact me directly with questions or comments
* Neil Alexander McQuarrie
* neil@neilalex.com
************************************************************************************************************************


************************************************************************************************************************
* Instructions for Use
************************************************************************************************************************
* 1. Acquire necessary census, commuting zone, and occupation data; please refer to readme.md for instructions
* 2. Set the paths below for the local program DO files and the raw data acquired in step 1
* 3. Review the file "parameters.do" to ensure filenames to all local data files are correct
* 4. Run or do this batch file in Stata
************************************************************************************************************************


************************************************************************************************************************
* Set program and data paths here
************************************************************************************************************************
* Path to local programs 
global programPath "/home/user/ad-replication"

* Path to raw data files
cd "/home/user/data"


************************************************************************************************************************
* Preliminaries 
************************************************************************************************************************
clear
set more off
capture log close
capture mkdir temp
log using runBatch.log, replace
log off


************************************************************************************************************************
* Run programs
************************************************************************************************************************

* Load global parameters
do "$programPath/parameters.do"

* Load utility macros 
do "$programPath/Utilities/naxSaveOutput.do" 
do "$programPath/Utilities/naxMerge.do" 
do "$programPath/Utilities/naxJoinby.do" 

* Load and clean raw data
do "$programPath/ETL/etlCz.do"
do "$programPath/ETL/etlOcc.do"
do "$programPath/ETL/etlIpumsCzOcc.do"
do "$programPath/ETL/etlImputeClean.do"

* Prepare commonly-used variables
do "$programPath/VarPrep/occPercentiles.do"
do "$programPath/VarPrep/occRti.do"
do "$programPath/VarPrep/czPopulation.do"
do "$programPath/VarPrep/czState.do"
do "$programPath/VarPrep/czRtiShares.do"
do "$programPath/VarPrep/czIV.do"

* Prepare tables and figures
do "$programPath/TablesFigures/table1.do"
do "$programPath/TablesFigures/table2.do"
do "$programPath/TablesFigures/table3.do"
do "$programPath/TablesFigures/tableAppendix1.do"
do "$programPath/TablesFigures/table4.do"
do "$programPath/TablesFigures/table5.do"
do "$programPath/TablesFigures/table6.do"
do "$programPath/TablesFigures/table7.do" 
do "$programPath/TablesFigures/figure1.do"
do "$programPath/TablesFigures/figure2.do"
do "$programPath/TablesFigures/figure3.do"
do "$programPath/TablesFigures/figure4.do"
do "$programPath/TablesFigures/figure5.do"
do "$programPath/TablesFigures/figure6.do" 


************************************************************************************************************************
* Remove temporary data files and close logging
************************************************************************************************************************
!rm -rf temp
capture log close

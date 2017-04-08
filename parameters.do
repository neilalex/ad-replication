************************************************************************************************************************
* Program parameters.do
* Global parameters for use throughout replication programs
************************************************************************************************************************

* Input dataset names
global ipumsDataset ipums.dta

global cz1950File cw_sea1950_czone.dta
global cz1970File cw_ctygrp1970_czone.dta
global cz1980File cw_ctygrp1980_czone.dta
global cz1990File cw_puma1990_czone.dta
global cz2000File cw_puma2000_czone.dta
global cz2005File cw_puma2000_czone.dta

global occ1950File occ1950_occ1990dd.dta
global occ1970File occ1970_occ1990dd.dta
global occ1980File occ1980_occ1990dd.dta
global occ1990File occ1990_occ1990dd.dta
global occ2000File occ2000_occ1990dd.dta
global occ2005File occ2005_occ1990dd.dta

global occTaskAlmFile occ1990dd_task_alm.dta
global occTaskOffshoreFile occ1990dd_task_offshore.dta
global rpcFile workfile2012.dta

global occCategoryDefFile subfile_occ1990dd_occgroups.do

* IMPUS "educ" variable value representing college
global collegeWorkerEducThreshold 7

global alaska 02
global hawaii 15

* Min and max gqtyped values for institutional quarters (for restricting sample)
* Variable codes taken from https://usa.ipums.org/usa-action/variables/GQTYPE#codes_section
global gqtypedInstitutionMin 100
global gqtypedInstitutionMax 499

* workedyr working individuals code
* Variable code taken from https://usa.ipums.org/usa-action/variables/WORKEDYR#codes_section
global workedyrYes 3

* classwkrd unpaid family members code
* Variable codes taken from https://usa.ipums.org/usa-action/variables/CLASSWKR#codes_section
global classwkrdUnpaidFamily 29

* Age range for analysis sample
global minAge 16
global maxAge 64

* Midpoints of wkswork2 (for imputation)
* Ranges taken from https://usa.ipums.org/usa-action/variables/WKSWORK2#codes_section
global wkswork1mid 7
global wkswork2mid 20
global wkswork3mid 33
global wkswork4mid 43.5
global wkswork5mid 48.5
global wkswork6mid 51

* Midpoints of hrswork2 (for imputation)
* Ranges taken from https://usa.ipums.org/usa-action/variables/HRSWORK2#codes_section
global hrswork1mid 7.5
global hrswork2mid 22
global hrswork3mid 32
global hrswork4mid 37
global hrswork5mid 40
global hrswork6mid 44.5
global hrswork7mid 54
global hrswork8mid 65

* Min and max occ1990dd for farm workers
global occ1990ddFarmWorkerMin 473
global occ1990ddFarmWorkerMax 498

* Minimum weeks and hours worked for inclusion in weekly wage calculations
global minWeeklyHrs 35
global minYearlyWks 40

* Week and hour assumptions for the average worker
global avgWeeklyHrs 35
global avgYearlyWks 50

* PCEI Inflation indices from BEA
* See https://www.bea.gov/newsreleases/national/pi/2016/pi1116.htm
global PCEI1950 14.660
global PCEI1970 22.325
global PCEI1980 43.977
global PCEI1990 67.439
global PCEI2000 83.128
global PCEI2005 89.703

* Hand-tuned inflation calibration factors to account for BEA restatements following A&D publication
global PCEI1950Adjust 1.088
global PCEI1970Adjust 1.020
global PCEI1980Adjust 1.044
global PCEI1990Adjust 1.024
global PCEI2000Adjust 1.014
global PCEI2005Adjust 1.016

* IPUMS top-coded wages
* See https://cps.ipums.org/cps/topcodes_tables.shtml
global topWage1950 10000
global topWage1970 50000
global topWage1980 75000
global topWage1990 140000
global topWage2000 175000
global topWage2005 200000

* Per Dorn communication, apply a factor to all top-coded wages
global topCodeWageFactor 1.5

* Wage representing unknown
global unknownWage 999999

* ind1990 industries to include in instrumental variable
global ivIncludeMin 1
global ivIncludeMax 992

*******************************************************************
* Occ1990dd Occupation Groups
*******************************************************************

* David Dorn, version October 12, 2012

* The file can be called whenever the data in memory contains the
* variable occ1990dd.


********************************************************************
* Occupation Dummies Level 3: Subgroups of Low-Skill Service Occupations
********************************************************************

gen occ3_clean=0            /* housekeeping, cleaning, laundry */
replace occ3_clean=1 if     (occ1990dd>=405 & occ1990dd<=408)

gen occ3_protect=0        /* all protective service */
replace occ3_protect=1 if (occ1990dd>=415 & occ1990dd<=427)

gen occ3_guard=0          /* supervisors of guards; guards */
replace occ3_guard=1 if (occ1990dd==415 | (occ1990dd>=425 & occ1990dd<=427))

gen occ3_food=0           /* food preparation and service occs */
replace occ3_food=1 if (occ1990dd>=433 & occ1990dd<=444)

gen occ3_shealth=0        /* health service occs (dental ass., health/nursing aides) */
replace occ3_shealth=1 if (occ1990dd>=445 & occ1990dd<=447)

gen occ3_janitor=0          /* building and grounds cleaning and maintenance occs */
replace occ3_janitor=1 if (occ1990dd>=448 & occ1990dd<=455)

gen occ3_beauty=0           /* personal appearance occs */
replace occ3_beauty=1 if (occ1990dd>=457 & occ1990dd<=458)

gen occ3_recreation=0      /* recreation and hospitality occs */
replace occ3_recreation=1 if (occ1990dd>=459 & occ1990dd<=467)

gen occ3_child=0           /* child care workers */
replace occ3_child=1 if (occ1990dd==468)

gen occ3_othpers=0        /* misc. personal care and service occs */
replace occ3_othpers=1 if (occ1990dd>=469 & occ1990dd<=472)


********************************************************************
* Occupation Dummies Level 2: 16 Non-Service Occupation Groups
********************************************************************

gen occ2_exec=0          /* executive, administrative and managerial occs */
replace occ2_exec=1 if (occ1990dd>=3 & occ1990dd<=22)

gen occ2_mgmtrel=0       /* management related occs */
replace occ2_mgmtrel=1 if (occ1990dd>=23 & occ1990dd<=37)

gen occ2_prof=0          /* professional specialty occs */
replace occ2_prof=1 if (occ1990dd>=43 & occ1990dd<=200)

gen occ2_tech=0          /* technicians and related support occs */
replace occ2_tech=1 if (occ1990dd>=203 & occ1990dd<=235)

gen occ2_finsales=0      /* financial sales and related occs */
replace occ2_finsales=1 if (occ1990dd>=243 & occ1990dd<=258)

gen occ2_retsales=0      /* retail sales occs */
replace occ2_retsales=1 if (occ1990dd>=274 & occ1990dd<=283)

gen occ2_cleric=0        /* administrative support occs */
replace occ2_cleric=1 if (occ1990dd>=303 & occ1990dd<=389)

gen occ2_firepol=0       /* fire fighting, police, and correctional insitutions */
replace occ2_firepol=1 if (occ1990dd>=417 & occ1990dd<=423)

gen occ2_farmer=0        /* farm operators and managers */
replace occ2_farmer=1 if (occ1990dd>=473 & occ1990dd<=475)

gen occ2_otheragr=0      /* other agricultural and related occs */
replace occ2_otheragr=1 if (occ1990dd>=479 & occ1990dd<=498)

gen occ2_mechanic=0      /* mechanics and repairers */
replace occ2_mechanic=1 if (occ1990dd>=503 & occ1990dd<=549)

gen occ2_constr=0        /* construction trades */
replace occ2_constr=1 if (occ1990dd>=558 & occ1990dd<=599)

gen occ2_mining=0        /* extractive occs */
replace occ2_mining=1 if (occ1990dd>=614 & occ1990dd<=617)

gen occ2_product=0       /* precision production occs */
replace occ2_product=1 if (occ1990dd>=628 & occ1990dd<=699)

gen occ2_operator=0      /* machine operators, assemblers, and inspectors */
replace occ2_operator=1 if (occ1990dd>=703 & occ1990dd<=799)

gen occ2_transp=0        /* transportation and material moving occs */
replace occ2_transp=1 if (occ1990dd>=803 & occ1990dd<=889)


********************************************************************
* Occupation Dummies Level 1: 6 Aggregate Occupation Groups
* as used in Autor and Dorn, "The Growth of Low-Skill Service Jobs
* and the Polarization of the U.S. Labor Market"
********************************************************************

* (1) management/professional/technical/financial sales/public security occs
gen occ1_managproftech=occ2_exec+occ2_mgmtrel+occ2_prof+occ2_tech+occ2_finsales+occ2_firepol

* (2) administrative support and retail sales occs
gen occ1_clericretail=occ2_cleric+occ2_retsales

* (3) low-skill services
gen occ1_service=occ3_clean+occ3_guard+occ3_food+occ3_shealth+occ3_janitor+occ3_beauty+occ3_recreation+occ3_child+occ3_othpers

* (4) precision production and craft occs
gen occ1_product=occ2_product

* (5) machine operators, assemblers and inspectors
gen occ1_operator=occ2_operator

* (6) transportation/construction/mechanics/mining/agricultural occs
gen occ1_transmechcraft=occ2_transp+occ2_constr+occ2_mechanic+occ2_mining+occ2_farmer+occ2_otheragr



* set values to missing for missing/non-civilian occupations *
foreach var of varlist occ1_* occ2_* occ3_* {
   quietly replace `var'=. if occ1990dd<4 | occ1990dd>889 | occ1990dd==.
}

* Neil edit Dorn original file; the commented line didn't seem right.
* assert occ1_managproftech+occ1_clericretail+occ1_service+occ1_product+occ1_operator+occ1_transmechcraft==1 if occ1990dd<4 | occ1990dd>889 | occ1990dd==.  
assert occ1_managproftech+occ1_clericretail+occ1_service+occ1_product+occ1_operator+occ1_transmechcraft==1 if occ1990dd>=4 & occ1990dd<=889 

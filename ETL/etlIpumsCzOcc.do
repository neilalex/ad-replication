************************************************************************************************************************
* Apply a first set of rules to the raw IPUMS data.
* Merge in commuting zone, occupation, task, and RPC variables from external files.
*
* Input: raw IPUMS data as specified in readme.md, plus several external variable files
* Output: a master individual-level analytical file, used in several downstream analyses
*
* Note that a second, more-refined master file is prepared in etlImputeClean.do, drawn on by several
* addtional downstream analyses
************************************************************************************************************************

use $ipumsDataset

* Do not perform analyses on Alaska or Hawaii, per Autor and Dorn communication
drop if (statefip == $alaska | statefip == $hawaii) 

* Create a dummy variable indicating whether the individual attended college
generate college = (educ>=$collegeWorkerEducThreshold) if (educ != 00 & educ != .) 

* Prefix local county/puma identifiers with state identifiers for compatibility with A&D commuting zone files
replace cntygp98 = statefip * 1000 + cntygp98
replace puma = statefip * 10000 + puma 

* Create a unified local sea/county/puma foreign key
generate cz_mergevar = sea if year == 1950
replace cz_mergevar = cntygp97 if year == 1970
replace cz_mergevar = cntygp98 if year == 1980
replace cz_mergevar = puma if inlist(year, 1990, 2000, 2005)
drop sea cntygp97 cntygp98 puma

* Update the occupation foreign key for compatibility with A&D balanced occupation panel
replace occ = occ / 10 if year == 2005 

* Merge external data
naxJoinby "year cz_mergevar using czAssembled" 1 0 1 "etlIpumsCzOcc"
naxMerge "m:1 year occ using occ1990ddAssembled" 1 0 1 "etlIpumsCzOcc"
naxMerge "m:1 occ1990dd using $occTaskAlmFile" 1 0 1 "etlIpumsCzOcc"
naxMerge "m:1 occ1990dd using $occTaskOffshoreFile" 1 0 1 "etlIpumsCzOcc"
naxMerge "m:1 year czone using $rpcFile, keepusing(d_rpc)" 1 0 1 "etlIpumsCzOcc"

* Commuting zone weight
replace afactor = 1 if afactor == . 

compress
save master, replace

************************************************************************************************************************
* Create Table 4
************************************************************************************************************************

* Start with Appendix Table 1 data, which Table 4 draws upon
use tableAppendix1, clear

* Calculate differences across years
keep czone statefip serviceShare rtiShare population year
reshape wide serviceShare rtiShare population, i(czone statefip) j(year)

drop if population1950 == . 
generate serviceShareChg1950 = (serviceShare1970 - serviceShare1950) / 2
generate serviceShareChg1970 = serviceShare1980 - serviceShare1970
generate serviceShareChg1980 = serviceShare1990 - serviceShare1980
generate serviceShareChg1990 = serviceShare2000 - serviceShare1990
generate serviceShareChg2000 = (serviceShare2005 - serviceShare2000) * 2

* Regressions
xi: regress serviceShareChg1950 rtiShare1950 i.statefip [aw=population1950], cluster(statefip)
naxSaveOutput "Table4 1950" "rtiShare _cons"

xi: regress serviceShareChg1970 rtiShare1970 i.statefip [aw=population1970], cluster(statefip)
naxSaveOutput "Table4 1970" "rtiShare _cons"

xi: regress serviceShareChg1980 rtiShare1980 i.statefip [aw=population1980], cluster(statefip)
naxSaveOutput "Table4 1980" "rtiShare _cons"

xi: regress serviceShareChg1990 rtiShare1990 i.statefip [aw=population1990], cluster(statefip)
naxSaveOutput "Table4 1990" "rtiShare _cons"

xi: regress serviceShareChg2000 rtiShare2000 i.statefip [aw=population2000], cluster(statefip)
naxSaveOutput "Table4 2000" "rtiShare _cons"

* Calculate means and SDs for Table 4
reshape long serviceShare serviceShareChg rtiShare population, i(czone statefip) j(year)
drop if year == 2005
keep czone year serviceShareChg
save table4_czServiceShareChgNoCollege, replace

collapse (mean) avgSvcShareChg=serviceShareChg (sd) sdSvcShareChg=serviceShareChg, by(year)

save table4means, replace

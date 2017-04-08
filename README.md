# ad-replication
> Paper Replication: The Growth of Low-Skill Service Jobs and the Polarization of the U.S. Labor Market (AER 2013)

Replicates David Autor and David Dorn's 2013 American Economic Review paper titled "The Growth of Low-Skill Service Jobs and the Polarization of the U.S. Labor Market." For a discussion, please see [http://www.neilalex.com/are-studies-in-inequality-robust-this-ones-pretty-good/](http://www.neilalex.com/are-studies-in-inequality-robust-this-ones-pretty-good/).


&nbsp;
### Attaining Necessary Data
A few raw data files are required before the replication will execute.

#### I. IPUMS U.S. Census Data
To download the relevant IPUMS (Integrated Public Use Microdata Series) data:

1. Register for an IPUMS account [here](https://uma.pop.umn.edu/usa/user/new).

2. Follow [this link](https://usa.ipums.org/usa-action/variables/group) to create a data extract request containing the variables and samples listed below. 

3. IPUMS will provide a download link typically over email. Follow the link to download the data itself plus the "STATA" command file.

4. Execute the command file inside Stata, which will load the IPUMS data into memory.

5. Save the loaded data as "ipums.dta". (If you choose a different name, update this name in parameters.do.)

#### II. Files from Dorn's Public Website
Autor and Dorn provide several auxiliary files required in addition to the IPUMS data. Visit David Dorn's data page [here](http://www.ddorn.net/data.htm) to download:
* A set of occ to occ1990dd bridge files (mapping Department of Labor occupations to a balanced occupation panel). Download for 1950, 1970, 1980, 1990, 2000, and ACS (which are Dorn's files A1, A3, A4, A5, A6, and A7).
* Abstract, routine and manual task content of occupations (Dorn's file B1)
* Offshorability of occupations (Dorn's file B2)
* Local labor market geography crosswalk files for 1950, 1970, 1980, 1990, and 2000 (Dorn's files E1, E2, E3, E4, and E5)
* Doms and Lewis's PC utilization dataset. For this, download Dorn's "P2" file package zip; the relevant file is named "workfile2012.dta" inside the "dta" folder. (None of the additional files in this zip are needed.)

Once downloaded, place these files into a single folder along with the Stata IPUMS dataset created above.

&nbsp; 
### Running the Replication
The "runBatch.do" file contains two path entries that must be updated: one for the raw data folder created above and one for the Stata programs from this repository.

Once the paths are set, run "runBatch.do" in Stata to re-create all tables and figures.

&nbsp;
### Testing and Quality Control
Executing "qualityChecks.do" produces several tabulations to aid in reviewing the ETL output and variable prep routines. 

Also, Venn match diagrams from all joins and merges are ouptut into "runBatch.log"  during runBatch.do execution.

&nbsp;
### IPUMS Variables and Samples
The above IPUMS extract should contain the following variables and samples.

#### Variables
* YEAR
* DATANUM
* SERIAL
* HHWT
* GQ
* PERNUM
* PERWT
* STATEFIP
* CNTYGRP97
* CNTYGP98
* PUMA
* SEA
* GQTYPE
* SLWT
* SEX
* AGE
* BPL
* HIGRADE
* EDUC
* EMPSTAT
* OCC
* IND1990
* CLASSWKR
* WKSWORK1
* WKSWORK2
* HRSWORK2
* UHRSWORK
* WORKEDYR
* INCWAGE

#### Samples
* 1950 1%
* 1970 1% metro fm1
* 1980 5% state
* 1990 5%
* 2000 5%
* 2005 ACS

&nbsp;

Please contact [neil@neilalex.com](mailto:neil@neilalex.com) with questions or comments.

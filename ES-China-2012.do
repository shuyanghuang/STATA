/*------------------------------------------------------------------------------
# Name:		China Enterprise Survey Data Analysis (Partial)
# Purpose:	Clean Survey Data and ConductAnalysis and Visualization
# Author:	Shuyang Huang
# Date:	    Last edit on April. 7th, 2018
# Data Source: World Bank Enterprise Survey Data
------------------------------------------------------------------------------*/

version 14.1
capture log close
log using "D:\文档\STATA\Sample\INNOVATION\Log\ESD_Innovation.log", replace
clear all
set more off

global pathin "D:\文档\STATA\Sample\INNOVATION"
cd $pathin

use Data\China-2012-ES-data.dta,clear

des	//287 var

/*------------------------Extract Innovation Data-----------------------------*/

ds id a* c* CNo*
local renamelist = r(varlist)

	foreach v of local renamelist {
		tab `v' 
	}
*end of loop

keep id a* c* CNo* //This 3 category contains the information for analysis

drop a1a a3a a3c a4b a5 a6b a7 a7a a8 a9 a10 a11 a12 a13 a14 a15* a16 a17 a18 a19*
drop c3 c4 c5  c6 c7 c8 c9a c9b c10-c21 c30a
drop CNo13* CNo15* CNo18 CNo19 CNo20 CNo17g-CNo17m


rename a0 questionaire
rename a1 country 

decode a2, gen (region)
	split region, parse(" ")
	drop a2 region region2
	rename region1 city
	order city, a(country)
	label var city "A.2. Sampling Region"
	
rename a3b capital
rename a3 population
rename a4a sector
rename a6a size
rename c22a email
rename c22b website
rename c23 internet
rename c24b intprocurement
rename c24f intsales
rename c24d intresearch

rename c28 telephone
	order telephone, a(internet)
	
rename c30b telecommunication
rename CNo1 newproduct
rename CNo2 salespercent
rename CNo3 rd
rename CNo4 rdspend
rename CNo5 rdcontract
rename CNo6 rdcontractspend
rename CNo7a eqpspend
rename CNo7b nonittechspend
rename CNo8 pcusage
rename CNo9 ppcusage
rename CNo10 intrev
rename CNo11a partner
rename CNo11b product
rename CNo11c operation
rename CNo11d sales
rename CNo11e customer
rename CNo12a iophone
rename CNo12b ioemail
rename CNo12c ioedi
rename CNo12d iowebsys
rename CNo12e iosoftware
rename CNo14a newtech
rename CNo14b newoper
rename CNo14c newadmin
rename CNo14d training
rename CNo14e newservice
rename CNo14f newfeatures
rename CNo14g redcost
rename CNo14h impflx
rename CNo17a inhouse
rename CNo17b supplier
rename CNo17c client
rename CNo17d newver
rename CNo17e internalrd
rename CNo17f externalrd

d //52 var

ds, not (type string)
local checklist = r(varlist)

foreach v of local checklist{
	replace `v' =. if inlist(-9, `v') //Convert Don't know to missing value
	replace `v' =. if inlist(-7, `v') //Convert NA to missing value
}
*end of loop

foreach v of varlist capital{
	replace `v' = 1 if city == "Hefei"  //fix the wrong answer
	replace `v' = 2 if city == "Dongguan"
	replace `v' = 2 if city == "Qingdao"
}
*end of loop

gen salespercent1=. 
	replace salespercent1 = 1 if salespercent <=10
	replace salespercent1 = 2 if salespercent >10 & salespercent <=20
	replace salespercent1 = 3 if salespercent >20 & salespercent <=30
	replace salespercent1 = 4 if salespercent >30 & salespercent <=40
	replace salespercent1 = 5 if salespercent >40 & salespercent <=50
	replace salespercent1 = 6 if salespercent >50
	
	label salespercent1 "CNO2. In 2011, % of products/services introduced last year i"
	label define salespercent1 1 "0-10" 2 "11-20" 3 "21-30" 4 "31-40" 5 "41-50" 6 ">50"
drop salespercent
	
/*----------------------------Quick View---------------------------------------*/

foreach v of varlist email website internet telephone {
		tab `v' if questionaire == 1 //Manufacturing
	}
*In manufacturing (1692), 90.0% email, 74% website, 99.4% internet, 99.1% cell-phone

foreach v of varlist email website internet telephone {
		tab `v' if questionaire != 1 //Manufacturing
	}
*In other sector (1008), 82.1% email, 68.0% website, 98.6% internet, 99.6% cell-phone

*New product and company R&D 

sum rdspend rdcontractspend, d
* r&d spending mean is $4,476.028 (median is 1,000,000)，external r&d spending mean is $2,732,906
sum rdspend rdcontractspend if questionaire == 1, d
* Manufacturing: r&d  4,483,476, r&d external  2,750,094 

sum rdspend rdcontractspend if capital ==1, d
*Capital: r&d $6,121,940, r&d external $2,709,630
sum rdspend rdcontractspend if capital ==2, d
*Non Capital: r&d 2,941,392, r&d external  2,744,764


tab newproduct 
tab rd  //58.73% no
tab rdcontract //88.27% no
sum nonittechspend 



*Internal operation technology applicaiton
	foreach v of varlist iophone ioemail ioedi iowebsys iosoftware newtech{
		tab `v' 
	}
*end of loop

*Innovation adoption
	foreach v of varlist newtech newoper newadmin training{
		tab `v' 
	}
*end of loop




 








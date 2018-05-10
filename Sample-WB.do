/*------------------------------------------------------------------------------
# Name:		Sample - World Bank Indictor
# Purpose:	
# Author:	Shuyang Huang
# Date:	    Last edite on Jan. 20th 2018
# Ado(s):	see below
------------------------------------------------------------------------------*/

version 14.1
capture log close
log using "D:\文档\STATA\Sample\STATA\LOG.log", replace
clear all
set more off

global pathin "D:\文档\STATA\Sample"
cd $pathin
ls

import delimited "DATA\WB_Indicator_LI.csv", rowrange(:94)

describe

/*-----------------------------Reformat Dataset-------------------------------*/
rename (v1 v2 v3 v4)/*
		*/(Category CategoryCode CountryName CountryCode)
rename (v5 v6 v7 v8 v9 v10 v11 v12 v13 v14)/*
		*/(yr2007 yr2008 yr2009 yr2010 yr2011 yr2012 yr2013 yr2014 yr2015 yr2016)
drop in 1		


count if inlist("..", yr2007, yr2008, yr2009, yr2010, yr2011, yr2012)==1
count if inlist("..", yr2013, yr 2014, yr 2015, yr2016)==1
* There 75 missing value in the dataset

foreach x of varlist yr2007 yr2008 yr2009 yr2010 yr2011 yr2012 yr2013 yr2014 yr2015 yr2016 {
		replace `x' = "" if inlist("..", `x')
		destring `x', replace
}
*end of loop


replace Category = "ag_gdp" if Category == "Agriculture, value added (% of GDP)"
replace Category = "tax_gdp" if Category == "Tax revenue (% of GDP)"
replace Category = "td_gdp" if Category == "Trade (% of GDP)"

drop CategoryCode


*convert long variable to wide
reshape wide yr*, i(CountryName) j(Category, string)

*Rename variable and convert wide variable to long 
ds, not(type string)
local renamelist = r(varlist)
foreach v of local renamelist{
		local x: variable label `v'
		local y = strtoname("`x'")
		rename `v' `y'
}
*end of loop
rename *_yr* **
				
reshape long ag_gdp@ tax_gdp@ td_gdp@, i(CountryName) j(year)

label var ag_gdp "agricultural sector (value added) as % of gdp"
label var td_gdp "trade value as % of gdp"
label var tax_gdp "taxes collected as % of gdp"

rename CountryName country

/*-------------------------Data Analysis and Viz------------------------------*/
encode country, gen(country_id)
tsset country_id year
gen lnag_gdp = ln(ag_gdp)
bys country_id (year): gen growth_rate=d.lnag_gdp
list

table country year, c(mean growth_rate) f(%9.2fc)
twoway (connected growth_rate year), by(country)





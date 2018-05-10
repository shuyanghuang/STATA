/*------------------------------------------------------------------------------
# Name:		Sample - World Bank Indictor
# Purpose:	Compile and Clean Economic Indicator Dataset and Conduct Data Analysis
# Author:	Shuyang Huang
# Date:	    Last edit on Jan. 20th 2018
# Data Source: World Bank Data Bank - Global Economic Monitor
------------------------------------------------------------------------------*/

version 14.1
capture log close
log using "D:\文档\STATA\Sample\STATA\LOG.log", replace
clear all
set more off

global pathin "D:\文档\STATA\Sample"
cd $pathin


import delimited "DATA\WB_GEM.csv", rowrange(:43)

describe

/*------------------------Clean and Combine Dataset---------------------------*/
rename (v1 v2 v3 v4)/*
		*/(CountryName CountryCode Category CategoryCode)
rename (v5 v6 v7 v8 v9 v10 v11 v12 v13 v14)/*
		*/(m1 m2 m3 m4 m5 m6 m7 m8 m9 m10)
drop in 1		

*Missing data reformat
	count if inlist("..", m1, m2, m3, m4, m5)==1
	count if inlist("..", m6, m7, m8, m9, m10)==1 // There 51 missing value in the dataset
	
	foreach x of varlist m1 m2 m3 m4 m5 m6 m7 m8 m9 m10{
			replace `x' = "" if inlist("..", `x')
			destring `x', replace
	}	
	*end of loop

*Clear up dataset
	replace CategoryCode = "cpi" if CategoryCode == "CORENS"
	replace CategoryCode = "ex_rate" if CategoryCode == "DPANUSLCU"
	replace CategoryCode = "exp" if CategoryCode == "DXGSRMRCHNSCD"
	replace CategoryCode = "imp" if CategoryCode == "DMGSRMRCHNSCD"
	replace CategoryCode = "unempy" if CategoryCode == "UNEMPSA_"
	replace CategoryCode = "gdp" if CategoryCode == "NYGDPMKTPSAKN"
drop Category
drop CountryCode


*Convert long variable to wide
	reshape wide m*, i(CountryName) j(CategoryCode, string)

*Rename variable and convert wide variable to long 
	ds, not(type string)
		local renamelist = r(varlist)

			foreach v of local renamelist{
				local x: variable label `v'
				local y = strtoname("`x'")
				rename `v' `y'
			}
			*end of loop
	rename *_m* **
	describe
	drop gdp* //Variable GDP contains no value in this dataset
	
reshape long cpi@ ex_rate@ exp@ imp@ unempy@,i(CountryName)j(month)

*Reset Name and Label
	label var cpi "core CPI"
	label var ex_rate "official exchange rate LCU to USD"
	label var exp "export merchandise in million USD"
	label var imp "import merchandise in million USD"
	label var unempy "unemployment rate %"
	rename CountryName country
		replace country = "EMED" if country == "Emerging Market and Developing Economies"
		replace country = "Russia" if country == "Russia Federation"

		
*Because the GDP data is missing , I have to merge outside data source

*Create merge ID 
	encode country, gen(country_id)
	gen country_id_mon = real( string(country_id) + string(month) )
	isid country_id_mon
*Merge dataset I have prepared in the same format before
	merge 1:1 country_id_mon using "DATA\GDP.dta"	
		label var dgp "GDP value"
	describe

sum


*Reformating dataset
gen year= 2017
order year, b(month)

format imp exp %10.0gc
format ex_rate %10.3f
format unempy %10.2f

save WBEconOutlook, replace

/*-------------------------Data Exploration and Viz-----------------------------*/
*Time series analysis (monthly growth rate for 2017)
tsset country_id month

gen lngdp = ln(gdp)
bys country_id (month): gen gdp_growth=d.lngdp
	table country month, c(mean gdp_growth) f(%9.2fc)
	twoway (connected gdp_growth month)  ///
	,									 ///
	by(country)							 ///
	title(2017 GDP Growth)				 ///
	xtitle(Month)						 ///
	ytitle(GDP Monthly Growth)			 ///
			save gdp_growth.gph, replace


gen lncpi = ln(cpi)
bys country_id (month): gen cpi_growth=d.lncpi
	table country month, c(mean cpi_growth) //India has no CPI data
	twoway (connected cpi_growth month) ///
	,                                   ///
	by(country)							///
	title(2017 CPI Growth Trend) 		///
	xtitle(Month)						///
	ytitle(CPI Monthly Growth Rate)     ///
	xlabel(1 5 9)									
		save cpi_growth.gph, replace
			
		
gen lnex_rate = ln(ex_rate)
bys country_id (month): gen ex_growth=d.lnex_rate
	table country month, c(mean ex_growth)
	twoway (connected ex_growth month)  ///
	,                                   ///
	by(country)							///
	title(2017 Exchange Rate Growth)	///
	xtitle(Month)						///
	ytitle(Exchange Rate Monthly Change) ///
	xlabel(1 5 9)									
		save exrate_growth.gph, replace
			
gen lnexport = ln(exp)
bys country_id (month): gen export_growth=d.lnexport
	table country month, c(mean export_growth)
	twoway (connected export_growth month) ///
	, 									///
	by(country)							///
	title(2017 Export Growth)			///
	xtitle(Month)						///
	ytitle(Export Monthly Change) 		///
	xlabel(1 5 9)	
			save export_growth.gph, replace
			
gen lnimport = ln(import)
bys country_id (month): gen import_growth=d.lnimport
	table country month, c(mean import_growth) 
	twoway (connected import_growth month) ///
	, 									///
	by(country)							///
	title(2017 Import Growth)			///
	xtitle(Month)						///
	ytitle(Import Monthly Change) 		///
	xlabel(1 5 9)	
			save import_growth.gph, replace
			
gen lnunempy = ln(unempy)
bys country_id (month):gen unempy_growth=d.lnunempy
	table country month, c(mean unempy_growth) f(%9.2fc)
	twoway (connected unempy_growth month)  ///
	, 										///
	by(country)								///
	title(2017 Unemployment Rate Change)	///
	xtitle(Month)							///
	ytitle(Unemployment Monthly Change) 	///
	xlabel(1 5 9)
			save unemployment_change.gph, replace
			






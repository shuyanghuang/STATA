version 14.1
capture log close
log using "D:\文档\STATA\Sample\STATA\LOG.log", replace
clear all
set more off

global pathin "D:\文档\STATA\Sample\IMF"
cd $pathin

ssc install tidy

import delimited "WEOApr2018all.csv"
rename (v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31)/*
		*/(y1980 y1981 y1982 y1983 y1984 y1985 y1986 y1987 y1988 y1989 y1990 y1991 y1992 y1993 y1994 y1995 y1996 y1997 y1998 y1999 y2000 y2001)

rename (v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 )/*
		*/(y2002 y2003 y2004 y2005 y2006 y2007 y2008 y2009 y2010 y2011 y2012 y2013 y2014 y2015 y2016 y2017 y2018 y2019 y2020 y2021 y2022 y2023)

drop weocountrycode
drop subjectdescriptor
drop units
drop scale
drop estimatesstartafter
drop subjectnotes
drop countryseriesspecificnotes
		
gather y*

rename variable year

replace value=subinstr(value, "n/a","",.)
replace value=subinstr(value, ",","",.)

gen factvalue = real(value)

drop value
drop if weosubjectcode == ""


spread weosubjectcode factvalue

replace year=subinstr(year,"y","",.)

/*-----------------------------------------------------------------------------*/
foreach var of varlist _all {
	label var `var' ""
}
label var NGDP_RPCH "GDP Growth in %"
label var NGDPDPC "GDP PerCapita in $"
label var NGDPD "GDP in $"
label var NGSD_NGDP "Gross national savings in %GDP"
label var PCPI "Inflation (CPI Index)"
label var PCPIPCH "Inflation Growth in %"
label var TM_RPCH "Volume of imports of goods and services in % change"
label var TMG_RPCH "Volume of Imports of goods in % change"
label var TX_RPCH "Volume of exports of goods and services in % change"
label var TXG_RPCH "Volume of exports of goods in % change"
label var LUR "Unemployment rate in labor force %"
label var LP "Population"
label var GGR_NGDP "General government revenue in % GDP"
label var GGX_NGDP "General government total expenditure"

export delimited IMF_reshape,replace
















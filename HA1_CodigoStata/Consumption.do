
//Daniela Solá - CEMFI

************************************************
************Constructing Consumption************
************************************************

 *** Opening 
 use "\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\UNPS 2013-14 Consumption Aggregate.dta", clear

 gen consumption = (cpexp30)*12 // yearly consumption
 
 keep HHID district_code urban ea region regurb consumption wgt_X hsize
 
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hh)
 drop HHID
 
 bysort hh: gen n = _n
 drop if n==2
 
 save "\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\consumption.dta", replace
 
  
 ************************************************************************************

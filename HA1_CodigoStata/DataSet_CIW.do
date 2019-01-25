
//Daniela Solá - CEMFI

*************************************************
***************Final Dataset*********************
*************************************************


 * Merge all the datasets 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\consumption.dta", clear

 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\income.dta"
 drop _merge
 
 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\wealth.dta"
 drop _merge
 
 
 * Merge with HH roster to get household head, age, education
 
 merge m:m HHID using "\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\GSEC2.dta" // get gender and age
 drop _merge
 keep if h2q4==1 // keep the household
 rename h2q8 age 
 rename h2q3 gender
 keep  HHID  PID district_code urban ea region regurb consumption income wealth wgt_X hsize wealth age gender h2q4
 
 merge 1:1 HHID PID using "\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\GSEC4.dta" //get education
 drop _merge
 keep if h2q4 == 1 
 rename h4q7 education
 keep HHID district_code urban ea region regurb consumption income wealth wgt_X hsize wealth age gender education
 
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
  
 drop if consumption ==.
 drop if income == 0
 drop if consumption > wealth+income 
 
 bysort HHID: gen n = _n
 drop if n>1
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\output\final_dataset.dta", replace
 
 ************************************************************************************

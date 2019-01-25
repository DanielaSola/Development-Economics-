
// Daniela Solá - CEMFI

*********************************************
************Constructing Wealth**************
*********************************************


 *Housing assets

 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\GSEC14A.dta", clear
 gen  HousingAssets_t = . 
 replace HousingAssets_t = h14q5 if h14q3==1 // only for those who own assets
 replace HousingAssets_t = 0 if h14q3==2
 replace HousingAssets_t = 0 if HousingAssets_t==.

 bysort HHID: egen HousingAssets = sum(HousingAssets_t)

 collapse (mean) HousingAssets, by(HHID)
 rename HHID hh

 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta", replace 
 
 
 ************************************************************************************ 
 ************************************************************************************ 

 * Agricultural equipment and structure capital
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC10.dta", clear
 
 gen  AgrEquip_t = . 
 replace AgrEquip_t = a10q2 if  a10q1>0 // only for those who own some item 
 replace AgrEquip_t= 0 if AgrEquip_t == . 

 bysort HHID: egen AgrEquip = sum(AgrEquip_t)

 collapse (mean) AgrEquip, by(hh)

 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta"
 drop _merge
 replace AgrEquip = 0 if AgrEquip==.
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta", replace 
 

 ************************************************************************************ 
 ************************************************************************************ 

 * Livestock capital
 
 ** Cattle 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC6A.dta", clear
 
 bysort LiveStockID: egen Pb = mean(a6aq13b) //mean buying price
 replace Pb = 0 if Pb==. 
 bysort LiveStockID: egen Ps = mean(a6aq14b) //mean selling price
 replace Ps = 0 if Ps==. 
 
 gen P_Cattle = (Pb + Ps)/2 if Pb!=0 & Ps!=0
 replace P_Cattle = Ps if Ps>0 & Pb==0
 replace P_Cattle = Pb if Ps==0 & Pb>0
 replace P_Cattle = 0 if Ps==0 & Pb==0
 
 gen Cattle_t = . 
 replace Cattle_t = a6aq3a*P_Cattle if a6aq3a>0 // only for those who currently own it
 replace Cattle_t = 0 if Cattle_t==. // missing values do not have nor own

 bysort HHID: egen Cattle = sum(Cattle_t)

 collapse (mean) Cattle, by(hh)

 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta"
 drop _merge
 replace Cattle = 0 if Cattle==.

 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta", replace 


 ** Small animals 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC6B.dta", clear

 bysort ALiveStock_Small_ID: egen Pb = mean(a6bq13b) //mean buying price
 replace Pb = 0 if Pb==. 
 bysort ALiveStock_Small_ID: egen Ps = mean(a6bq14b) //mean selling price
 replace Ps = 0 if Ps==. 
 
 gen P_Small = (Pb + Ps)/2 if Pb!=0 & Ps!=0
 replace P_Small = Ps if Ps>0 & Pb==0
 replace P_Small = Pb if Ps==0 & Pb>0
 replace P_Small = 0 if Ps==0 & Pb==0
 
 gen  Small_t = . 
 replace Small_t = a6bq3a*P_Small if a6bq3a>0 // only for those who currently own it
 replace Small_t = 0 if Small_t==. //missing values do not have nor own

 bysort HHID: egen Small = sum(Small_t)

 collapse (mean) Small, by(hh)

 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta"
 drop _merge
 replace Small = 0 if Small==.

 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta", replace 

 ** Poultry 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC6C.dta", clear

 bysort APCode: egen Pb = mean(a6cq13b) //mean buying price
 replace Pb = 0 if Pb==. 
 bysort APCode: egen Ps = mean(a6cq14b) //mean selling price
 replace Ps = 0 if Ps==. 
 
 gen P_T = (Pb + Ps)/2 if Pb!=0 & Ps!=0
 replace P_T = Ps if Ps>0 & Pb==0
 replace P_T = Pb if Ps==0 & Pb>0
 replace P_T = 0 if Ps==0 & Pb==0
 
 gen  Poultry_t = . 
 replace Poultry_t = a6cq3a*P_T if a6cq3a>0 // only for those who currently own it
 replace Poultry_t= 0 if Poultry_t== . // Missing values do not have nor own

 bysort HHID: egen Poultry = sum(Poultry_t)

 collapse (mean) Poultry, by(hh)

 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta"
 drop _merge
 replace Poultry = 0 if Poultry==.

 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta", replace 
 

 ************************************************************************************ 
 ************************************************************************************ 

 * Agricultural Land Value
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC2B.dta", clear

 keep if a2bq9!=. //drop missing prices 
 
 gen P_r = a2bq9/a2bq5 // Rental_Price/acres, overall mean rental price per acre for each plots
 drop if P_r == .
 
 collapse (mean) P_r

 *rental_price = 69778.398

 ** Ownership data 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC2A.dta", clear

 gen AgrLand = . 
 replace AgrLand = 69778.398 * 10 * a2aq5 if a2aq5!=0 

 collapse (sum) AgrLand, by(hh) 
 
 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta"
 drop _merge
 replace AgrLand = 0 if AgrLand==. 
 
 
 ************************************************************************************ 
 ************************************************************************************ 

 * Generate wealth
 gen wealth = HousingAssets + AgrEquip + Cattle + Small + Poultry + AgrLand
 
 gen hhid = hh
 replace hh = subinstr(hh, "H", "", .)
 replace hh = subinstr(hh, "-", "", .)
 destring hh, gen(HHID)
 drop hh
 rename HHID hh
 rename hhid HHID
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\wealth.dta", replace 
 
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\tempw.dta"
 
 
 ************************************************************************************ 
 ************************************************************************************

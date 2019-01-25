
// Daniela Solá - CEMFI

******************************************
************Constructing Income***********
******************************************
 
 * Agricultural net production
 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC5A.dta", clear
 drop if cropID==.
 
 keep HHID parcelID plotID cropID a5aq6a a5aq6b a5aq6c a5aq6d a5aq16 a5aq7a a5aq7b a5aq7c a5aq7d a5aq8 a5aq10 a5aq5_2
 drop if a5aq6a==. & a5aq6d==. & a5aq16==. & a5aq7a==. & a5aq7d==. & a5aq8==. & a5aq10==. & a5aq5_2 ==2 // no revenue but crop was mature
 replace a5aq6d = a5aq7d if  a5aq6b == a5aq7b & a5aq6c== a5aq7c & a5aq6d != a5aq7d //conversion weights are the same for buy and sell 

 ** Harvested crop
 gen AgNetProd_temp = .
 replace AgNetProd_temp = a5aq6a*a5aq6d if a5aq6d!=.
 replace AgNetProd_temp = a5aq6a if a5aq6c==1
 // all the AgNetProd_temp = . are observations missing in a5aq6a-a5aq6d (10 obs)
 
 *replace a5aq16 = a5aq16/100 if a5aq16>=1
 *replace a5aq16 = 0 if a5aq16==.
 *replace AgNetProd_temp = (1-a5aq16)*AgNetProd_temp //total quantity - quantity lost 
 
 ** Harvested crop sold
 gen AgNetProd2_temp = .
 replace AgNetProd2_temp = a5aq7a*a5aq7d if a5aq7d!=.
 replace AgNetProd2_temp = 0 if a5aq7a==0
 replace AgNetProd2_temp = 0 if a5aq7a==.
 replace AgNetProd2_temp = a5aq7a if a5aq7c==1
 
 gen dif = (AgNetProd_temp - AgNetProd2_temp) 
 replace AgNetProd2_temp = AgNetProd_temp if dif<0

 bysort HHID cropID: egen AgNetProd2 = sum(AgNetProd2_temp) //quantity sold by HH and crop
 bysort HHID cropID: egen AgNetProd1 = sum(AgNetProd_temp) //quantity by HH and crop
  
 bysort HHID cropID: egen AgNetProd2_tempp = sum(a5aq8) //revenue by HH and crop

 gen P_t = (AgNetProd2_tempp/AgNetProd2)
 bysort cropID: egen P = mean(P_t)
 
 ** Value of retained output
 gen AgNetProd1_2 = P*(AgNetProd1 - AgNetProd2) //46 missings due to P==.
 
 replace AgNetProd1_2 = 0 if AgNetProd1_2== . 
 replace AgNetProd2_tempp = 0 if AgNetProd2_tempp == . 
 
 ************************************************************************************ 
 ************************************************************************************ 


 ** Costs
 *** Transportation costs
 bysort HHID cropID: gen AgNetProd3 = a5aq10 
 replace AgNetProd3 = 0 if AgNetProd3==. 

 collapse (mean) AgNetProd1_2 AgNetProd3 AgNetProd2_tempp, by(HHID cropID) 
 collapse (sum) AgNetProd1_2 AgNetProd3 AgNetProd2_tempp, by(HHID) 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta", replace
 
 *** Rent-in land
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC2B.dta", clear
 bysort HHID parcelID: gen AgNetProd4 = a2bq9
 replace AgNetProd4 = 0 if AgNetProd4==. 

 collapse (sum) AgNetProd4, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta"
 drop _merge
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta", replace

 *** Hired labor
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC3A.dta", clear
 bysort HHID parcelID plotID: gen AgNetProd5 = a3aq36
 replace AgNetProd5 = 0 if AgNetProd5==. 
 
 *** Pesticides and fertilizers
 bysort HHID parcelID plotID: gen AgNetProd6 = a3aq8 
 bysort HHID parcelID plotID: gen AgNetProd7 = a3aq18 
 bysort HHID parcelID plotID: gen AgNetProd8 = a3aq27 
 replace AgNetProd6 = 0 if AgNetProd6 ==. 
 replace AgNetProd7 = 0 if AgNetProd7==. 
 replace AgNetProd8 = 0 if AgNetProd8 ==. 
 
 collapse (sum) AgNetProd*, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta"
 drop _merge
 
 foreach var of varlist _all {
  replace `var' = 0 if `var'==.
 }
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta", replace
 
 *** Seeds
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC4A.dta", clear
 bysort HHID parcelID plotID cropID: gen AgNetProd9 = a4aq15 
 replace AgNetProd9 = 0 if AgNetProd9==. 

 collapse (sum) AgNetProd*, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta"
 drop _merge
 
 foreach var of varlist _all {
  replace `var' = 0 if `var'==.
 }
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta", replace

 gen AgNetProd = AgNetProd1_2 + AgNetProd2_temp - AgNetProd3 - AgNetProd4 - AgNetProd5 - AgNetProd6 - AgNetProd7 - AgNetProd8 - AgNetProd9
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta", replace
 
 ************************************************************************************ 
 ************************************************************************************ 


 * Livestock
 
 ** Other costs
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC7.dta", clear
 
 keep if a7aq1 == 1 // we keep only those who own or raise cattle
 bysort HHID: egen LS7 = sum(a7bq2e) 
 bysort HHID: egen LS8 = sum(a7bq3f) 
 bysort HHID: egen LS9 = sum(a7bq5d) 
 bysort HHID: egen LS10 = sum(a7bq6c) 
 bysort HHID: egen LS11 = sum(a7bq7c) 
 bysort HHID: egen LS12 = sum(a7bq8c) 
 gen LS13 = LS7 + LS8 + LS9 + LS10 + LS11 + LS12
 
 collapse (mean) LS13, by(HHID)
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta", replace
 
 ** Cattle
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC6A.dta", clear
 keep if a6aq2 != 2 & a6aq3a != 0 & a6aq3a != . // we keep only those who own 

 gen LS1 = a6aq14a*a6aq14b if a6aq14a !=. & a6aq14a != 0  & a6aq14b !=. & a6aq14b !=0 //revenues = quantity * revenue by unit, only for those who sell and report value
 replace LS1 = 0 if LS1==.

 gen LS2 = . 
 replace LS2 = a6aq5c if a6aq5c >0 & a6aq5c != . //cost labor
 replace LS2 = 0 if LS2 ==. 

 collapse (sum) LS1 (mean) LS2, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta"
 drop _merge
 replace LS1 = 0 if LS1==. 
 replace LS2 = 0 if LS1==.
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta", replace
 
 ** Small animals
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC6B.dta", clear
 keep if a6bq2 != 2 & a6bq3a != 0 & a6bq3a != . // we keep only those who own 
 
 gen LS3 = .
 replace LS3 = a6bq14a*a6bq14b if a6bq14a !=. & a6bq14a != 0  & a6bq14b !=. & a6bq14b !=0 //revenues = quantity * revenue by unit
 replace LS3 = 0 if LS3==.
 
 gen LS4 = . 
 replace LS4 = a6bq5c if a6bq5c >0 & a6bq5c != . //cost labor
 replace LS4 = 0 if LS4 ==.  
 
 collapse (sum) LS3 (mean) LS4, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta"
 drop _merge
 replace LS3 = 0 if LS3 ==.
 replace LS4 = 0 if LS4 ==.
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta", replace
 
 ** Rabbits
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC6C.dta", clear
 keep if a6cq2 != 2 & a6cq3a != 0 & a6cq3a != . // we keep only those who own 
 
 gen LS5 = .
 replace LS5 = a6cq14a*a6cq14b if a6cq14a !=. & a6cq14a != 0  & a6cq14b !=. & a6cq14b !=0 //revenues = quantity * revenue by unit
 replace LS5 = 0 if LS5==.
 
 gen LS6 = . 
 replace LS6 = a6cq5c if a6cq5c >0 & a6cq5c != . 
 replace LS6 = 0 if LS6 ==. //cost labor
 
 collapse (sum) LS5 (mean) LS6, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta"
 drop _merge
 
  foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen LS = LS1 + LS3 + LS5 - LS2 - LS4 - LS6 - LS13
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta", replace

 ************************************************************************************ 
 ************************************************************************************ 

 * Livestock product
 
 ** Meat
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC8A.dta", clear

 gen Pm_t = .
 replace Pm_t = a8aq5/a8aq3 if a8aq1 != 0 & a8aq5 != 0 & a8aq5 !=. & a8aq3 != 0 & a8aq3 !=. //price = revenue/quantity
 bysort AGroup_ID: egen Pm = mean(Pm_t)

 gen LM =. 
 replace LM = Pm*((a8aq1*a8aq2)-a8aq3) + a8aq5 if a8aq5 !=. 
 replace LM = Pm *((a8aq1*a8aq2)-a8aq3) if a8aq5 ==.
 replace LM = a8aq5 if ((a8aq1*a8aq2)-a8aq3) == 0 & a8aq5 !=.
 replace LM = 0 if LM==.

 collapse (sum) LM, by(HHID)
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta", replace

 ** Milk
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC8B.dta", clear
 
 gen daily_milk = a8bq1* a8bq3 //number of animals milked * avg milk production/day
 replace daily_milk = 0 if daily_milk==.
 replace a8bq5_1 = daily_milk if a8bq5_1 > daily_milk & a8bq5_1!=0 & a8bq5_1!=. //sales = production, for those who report more sales than production

 replace a8bq7 = 0 if a8bq6==0 | a8bq6==.
 replace a8bq7 = a8bq6 if a8bq7>a8bq6 // sales = amount converted, for those who report selling more than they convert per day

 replace a8bq5_1 = daily_milk if daily_milk < a8bq5 & a8bq5_1!=0 & a8bq9!=0 & a8bq9!=. & a8bq6==0
 replace a8bq5 = 0 if daily_milk<a8bq5 & a8bq5_1!=0 & a8bq9!=0 & a8bq9!=.
 
 replace a8bq5_1 = a8bq5_1 * 30 * a8bq2
 replace a8bq7 = a8bq7 * 30 * a8bq2
 replace a8bq7 = 0 if a8bq5_1==a8bq1*a8bq2*30*a8bq3 // convert daily to yealry
 
 gen Pmi_t = .
 replace Pmi_t = a8bq9/(a8bq5_1+a8bq7) if a8bq1!=0 & a8bq5_1!=0 & a8bq5_1 !=. & a8bq9!=0 & a8bq9 !=.| a8bq1 != 0 & a8bq6 != 0 & a8bq6 != . & a8bq7 != 0 & a8bq7 !=. & a8bq9 != 0 & a8bq9 !=.
 //revenue/(quantity milk + quantity dairy) for those who milked, sold and earned or milked, converted to dairy, sold and earn.
 bysort AGroup_ID: egen Pmi = mean(Pmi_t)
 
 replace a8bq2 = a8bq2*30 //months*30
 gen Milk = a8bq1*a8bq2*a8bq3 //liters of milk = quantity cows * days * avg day production
 replace Milk = 0 if Milk ==. 

 replace a8bq7 = 0 if a8bq7 ==. 
 replace a8bq5_1 = 0 if a8bq5_1==. 
 gen dif = (Milk-(a8bq5_1+a8bq7)) //quantity milk production - quantity sold

 gen LMi = .
 replace LMi = Pmi*(Milk-(a8bq5_1+a8bq7))
 replace LMi = Pmi*(Milk-(a8bq5_1+a8bq7)) + a8bq9 if a8bq9!=. 
 replace LMi = a8bq9 if Milk-(a8bq5_1+a8bq7)==0 &  a8bq9!=. 

 collapse (sum) LMi, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta"
 drop _merge
 replace LMi = 0 if LMi==.
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta", replace
 
 
 ** Eggs
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC8C.dta", clear 
 replace a8cq2 = a8cq2*4 //quantity eggs by year
 replace a8cq3 = a8cq3*4 //quantity sold by year
 replace a8cq5 = a8cq5*4 //revenue by year

 replace a8cq3=a8cq2 if a8cq3 > a8cq2
 
 
 gen Pe_t = a8cq5/a8cq3 if a8cq1 != 0 & a8cq1 != 0 & a8cq2 !=. & a8cq2 !=0
 bysort AGroup_ID: egen Pe = mean(Pe_t)

 gen LE = .
 replace LE = Pe*(a8cq2 - a8cq3)
 replace LE = Pe*(a8cq2 - a8cq3) + a8cq5 if a8cq5 !=. 
 replace LE = 0 if LE==. 
 
 collapse (sum) LE, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta", replace
 
 
 ** Dung
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC11.dta", clear
 
 gen LD = a11q1c + a11q5 //revenues dung + revenues ploughing
  
 collapse (sum) LD, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }

 gen LP = LM + LMi + LE + LD
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta", replace
 
 ************************************************************************************ 
 ************************************************************************************ 

 
 * Renting in agricultural equipment and capital
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC10.dta", clear
 
 rename a10q8 rentals //value rentals
 collapse (sum) rentals, by(HHID)
   
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta"
 drop _merge
 
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta"
 drop _merge

 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta"
 drop _merge 
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen AgNetProd_total = AgNetProd + LS + LP - rentals
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\AgNetProd.dta", replace
 
 ************************************************************************************ 
 ************************************************************************************ 

 
 * Labor market income
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\GSEC8_1.dta", clear
 
 gen LaborIncome1 = .
 replace LaborIncome1 = (h8q31a+h8q31b)*56 if h8q31c==1 //assume 8hrs every day of the week
 replace LaborIncome1 = (h8q31a+h8q31b)*4 if h8q31c==2 //assume 30 days per month
 replace LaborIncome1 = (h8q31a+h8q31b) if h8q31c==3 //assume 4 weeks per month
 replace LaborIncome1 = (h8q31a+h8q31b)/4 if h8q31c==4 //assume 4 weeks per month
 replace LaborIncome1 = LaborIncome1*h8q30b*h8q30a //earnings in last year
 // main job
 
 gen LaborIncome2 = .
 replace LaborIncome2 = (h8q45a+h8q45b)*56 if h8q45c==1 //assume 8hrs every day of the week
 replace LaborIncome2 = (h8q45a+h8q45b)*4 if h8q45c==2 //assume 30 days per month
 replace LaborIncome2 = (h8q45a+h8q45b) if h8q45c==3 //assume 4 weeks per month
 replace LaborIncome2 = (h8q45a+h8q45b)/4 if h8q45c==4 //assume 4 weeks per month
 replace LaborIncome2 = LaborIncome2*h8q44b*h8q44 //earnings in last year
 //second job
 
 //use usual activity status?
 
 gen LaborIncome = LaborIncome1 + LaborIncome2 //income per year
 replace LaborIncome = 0 if LaborIncome==. 
 collapse (sum) LaborIncome, by(HHID)
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\LaborIncome.dta", replace

 ************************************************************************************ 
 ************************************************************************************ 

 
 * Business income
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\gsec12.dta", clear
 rename hhid HHID
 
 gen BusinessIncome1 = .
 replace BusinessIncome1 = h12q13 //month gross revenue
 replace BusinessIncome1= 0 if BusinessIncome1 ==. 

 gen BusinessIncome2 = .
 replace BusinessIncome2 = h12q15 //month labor costs
 replace BusinessIncome2= 0 if BusinessIncome2 ==. 
 
 gen BusinessIncome3 = .
 replace BusinessIncome3 = h12q16 + h12q17 //month expenditure raw materials + others
 replace BusinessIncome3= 0 if BusinessIncome3 ==. 
 
 gen BusinessIncome = (BusinessIncome1 - BusinessIncome2 - BusinessIncome3)*h12q12 //business income per year (ignore VAT)
 replace BusinessIncome = 0 if BusinessIncome ==. 
 collapse (sum) BusinessIncome, by(HHID)
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\BusinessIncome.dta", replace
 
 
 ************************************************************************************ 
 ************************************************************************************ 

 
 * Other income sources
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\GSEC11A.dta", clear
  
 gen OtherSourceIncome = h11q5 + h11q6
 replace OtherSourceIncome = 0 if OtherSourceIncome==.
 
 collapse (sum) OtherSourceIncome, by(HHID)
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\OtherSourceIncome.dta", replace

 ************************************************************************************ 
 ************************************************************************************ 

  
 * Transfers (from expenditures in consumption)
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\GSEC15B.dta", clear
 
 gen Tr = .
 replace Tr = h15bq10*h15bq11
 replace Tr = 0 if Tr==.
 
 collapse (sum) Tr, by(HHID)

 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\LaborIncome.dta"
 drop _merge
  
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\BusinessIncome.dta"
 drop _merge

 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\OtherSourceIncome.dta"
 drop _merge 
  
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hh)
 drop HHID
 rename hh HHID
 
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\AgNetProd.dta"
 drop _merge 
 rename HHID hh
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\income.dta", replace
 
 
 ************************************************************************************ 
 ***************************** Agricultural second visit  *************************** 
 ************************************************************************************ 
 

 
 * Agricultural net production
 
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC5B.dta", clear
 drop if cropID==.
 
 keep HHID parcelID plotID cropID a5bq6a a5bq6b a5bq6c a5bq6d a5bq16 a5bq7a a5bq7b a5bq7c a5bq7d a5bq8 a5bq10 a5bq5_2
 drop if a5bq6a==. & a5bq6d==. & a5bq16==. & a5bq7a==. & a5bq7d==. & a5bq8==. & a5bq10==. & a5bq5_2==2 // no revenue but crop was mature
 replace a5bq6d = a5bq7d if a5bq6b==a5bq7b & a5bq6c==a5bq7c & a5bq6d!=a5bq7d //conversion weights are the same for buy and sell 
 
 ** Harvested crop
 gen AgNetProd_temp2 = .
 replace AgNetProd_temp2 = a5bq6a*a5bq6d if a5bq6d!=.
 replace AgNetProd_temp2  = a5bq6a if a5bq6c==1
  
 ** Harvested crop sold 
 gen AgNetProd2_temp2 = .
 replace AgNetProd2_temp2 = a5bq7a*a5bq7d if a5bq7d!=.
 replace AgNetProd2_temp2 = 0 if a5bq7a==0 
 replace AgNetProd2_temp2 = 0 if a5bq7a==. 
 replace AgNetProd2_temp2 = a5bq7a if a5bq7c==1
 
 gen dif = (AgNetProd_temp2 - AgNetProd2_temp2)
 replace AgNetProd2_temp = AgNetProd_temp2 if dif<0
 
 bysort HHID cropID: egen AgNetProd2_2 = sum(AgNetProd2_temp2) //quantity sold by HH and crop
 bysort HHID cropID: egen AgNetProd1_2 = sum(AgNetProd_temp2) //quantity by HH and crop
  
 bysort HHID cropID: egen AgNetProd2_tempp2 = sum(a5bq8) //revenue by HH and crop

 gen P_t2 = (AgNetProd2_tempp2/AgNetProd2_2)
 bysort cropID: egen P_2 = mean(P_t2)
 
// value of kept crops 
 gen AgNetProd1_2_2 = P_2*(AgNetProd1_2 - AgNetProd2_2) 
 
 replace AgNetProd1_2_2 = 0 if AgNetProd1_2_2 == . 
 replace AgNetProd2_tempp2 = 0 if AgNetProd2_tempp2 == . 

 ************************************************************************************ 
 ************************************************************************************ 

 ** Costs
 *** Transportation costs
 bysort HHID cropID: gen AgNetProd3_2 = a5bq10
 replace AgNetProd3_2 = 0 if AgNetProd3_2==.
  
 collapse (mean) AgNetProd1_2_2 AgNetProd3_2 AgNetProd2_tempp2, by(HHID cropID) 
 collapse (sum) AgNetProd1_2_2 AgNetProd3_2 AgNetProd2_tempp2, by(HHID) 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp_second.dta", replace
 
 *** Land rents are given as annual 

 *** Hired labor
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC3B.dta", clear
 bysort HHID parcelID plotID: gen AgNetProd5_2 = a3bq36
 replace AgNetProd5_2= 0 if AgNetProd5_2==. 
 
 *** Pesticides and fertilizers
 bysort HHID parcelID plotID: gen AgNetProd6_2 = a3bq8 
 bysort HHID parcelID plotID: gen AgNetProd7_2 = a3bq18 
 bysort HHID parcelID plotID: gen AgNetProd8_2 = a3bq27 
 replace AgNetProd6_2 = 0 if AgNetProd6_2 == . 
 replace AgNetProd7_2 = 0 if AgNetProd7_2 == . 
 replace AgNetProd8_2 = 0 if AgNetProd8_2 == . 
 
 collapse (sum) AgNetProd*, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp_second.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp_second.dta", replace
 
 *** Seeds
 use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\UGA_2013_UNPS_v01_M_Stata\UGA_2013_UNPS_v01_M_STATA8\AGSEC4B.dta", clear
 bysort HHID parcelID plotID cropID: gen AgNetProd9_2 = a4bq15 
 replace AgNetProd9_2 = 0 if AgNetProd9_2==. 
 
 collapse (sum) AgNetProd*, by(HHID)
 merge 1:1 HHID using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp_second.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen AgNetProd_2 = AgNetProd1_2_2 + AgNetProd2_tempp2 - AgNetProd3_2 - AgNetProd5_2 - AgNetProd6_2 - AgNetProd7_2 - AgNetProd8_2 - AgNetProd9_2
 rename HHID hh
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp_second.dta", replace


 ************************************************************************************ 
 ************************************************************************************ 

 
 ** Merge with previous data to get annual income 
 merge 1:1 hh using "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\income.dta" // people who do not merge is because they have no AgNetProd in second visit
 drop _merge 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 * Generate income
 generate income = AgNetProd_2 + AgNetProd_total + LaborIncome + BusinessIncome + OtherSourceIncome
 
 save "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\income.dta", replace
 
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp2.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp3.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\temp_second.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\BusinessIncome.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\OtherSourceIncome.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\LaborIncome.dta"
 rm "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 1\temporal\AgNetProd.dta"

  
 ************************************************************************************
 ************************************************************************************ 


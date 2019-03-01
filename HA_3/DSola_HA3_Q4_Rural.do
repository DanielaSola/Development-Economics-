 * Daniela Solá - Problem Set 3 - Development, CEMFI   
 *----------------------------------------------------------------------------*  
 *------------------------------ Question 4 ----------------------------------*
 *----------------------------------------------------------------------------* 
  
* Open given dataset 
use "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 3\dataUGA.dta" , clear

 // Keep needed variables. (For some reason, the variables sex and female have different values. I assume that the correct one is female)
keep hh year wave lnc lninctotal_trans age age_sq familysize ethnic female urban
  
// Correct the variable "year" as suggested.
bysort year hh: gen cnt = _N 
replace year = 2010 if wave=="2010-2011" & year==2011 & cnt==2
drop cnt

bysort year hh: gen cnt = _N 
replace year = 2009 if wave=="2009-2010" & year==2010 & cnt==2
drop cnt   
 

 *-----------------------------------------------------------------------------*  
 *------------------------------ RURAL ----------------------------------------*
 *-----------------------------------------------------------------------------* 
 
 	drop if urban==1
	 
	 // Construct the residuals for consumption
reg lnc age age_sq familysize i.ethnic i.female i.year 
predict res
rename res res_consumption

// Construct the residuals for income
reg lninctotal_trans age age_sq familysize i.ethnic i.female i.year 
predict res
rename res res_income  
rename lninctotal_trans income  
  
 
// Construct the aggregate consumption
bysort year: egen agg_consumption = sum(lnc)

// Set and balance the panel data
keep res_consumption res_income agg_consumption hh year income
xtset hh year

reshape wide res_consumption res_income agg_consumption income, i(hh) j(year)

forvalues y = 10(1)14 {
egen agg_consumption20`y'_t = mean(agg_consumption20`y')
drop agg_consumption20`y'
rename agg_consumption20`y'_t agg_consumption20`y'
}
egen agg_consumption2009_t = mean(agg_consumption2009)
drop agg_consumption2009
rename agg_consumption2009_t agg_consumption2009

reshape long res_consumption res_income agg_consumption income, i(hh)
rename _j year

// Ipolate missing values and drop observations when we have the value of only one year:
bysort hh: ipolate res_consumption year, generate(res_consumption_ip) epolate
bysort hh: ipolate res_income year, generate(res_income_ip) epolate  
bysort hh: ipolate income year, generate(income_ip) epolate  

gen ones = 1
replace ones = 0 if res_consumption_ip ==.
egen numyears = sum(ones), by(hh)
drop if numyears <= 1
drop res_consumption res_income ones numyears



************************************************************************************
*Run Regressions for Question (1) and (3)
************************************************************************************

*Regression for question (3): average coefficients 

reg d.res_consumption_ip d.res_income_ip d.agg_consumption, nocons
display _b[d.res_income_ip]
display _b[d.agg_consumption]



*Regression for question (1): random coefficients 

// Simplify the identification variable for each individual to be able to do the loop of the regression
sort hh year
egen ID = group(hh) 


// Regressions for each household with random coefficients 
generate beta = .
generate phi = .

forvalues i = 1(1)2239 {
reg d.res_consumption_ip d.res_income_ip d.agg_consumption if ID==`i', nocons
replace beta = _b[d.res_income_ip] if ID==`i'
replace phi = _b[d.agg_consumption] if ID==`i'
}


// Generate histogram and calculate mean and median for Beta and Phi
preserve
collapse beta phi, by(hh)

*Triming
drop if beta > 1.5
drop if beta < -1.5 

sum beta, detail

histogram beta, title("Coefficient Beta across households - Rural", color(black)) xtitle ("Betas") graphregion(color(white)) bcolor(blue)
graph export "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 3\HistBetaRur.png", replace 
restore

preserve
collapse beta phi, by(hh)

*Triming
drop if phi >= 0.00003
drop if phi <= -0.00003 

sum phi, detail

histogram phi, title("Coefficient Phi across households - Rural", color(black)) xtitle ("Phis") graphregion(color(white)) bcolor(pink) 
graph export "C:\Users\Usuario\Desktop\CEMFI\Term 5\Development\HA\HA 3\HistPhiRur.png", replace 
restore


 *----------------------------------------------------------------------------*  
 *------------------------------ Question 2 ----------------------------------*
 *----------------------------------------------------------------------------* 

 * Average hh income
 gen ones = 1
 replace ones = 0 if income_ip ==.
 egen numyears = sum(ones), by(hh)
 drop if numyears <= 1
 drop ones numyears income
 
 collapse (mean) income_ip beta, by(hh)
 
 *(a)For each household, compute the average household income across all waves.
 *   Rank individuals by income and define five groups of income  Within each 
 *   income group compute the mean and median βi
 
 * Define five income groups
 sort income_ip
 gen nobs = _N // total of 2879 observations
 gen nhh = _n 
 
 gen income_group = 0
 replace income_group = 1 if nhh<=445
 replace income_group = 2 if nhh>445 & nhh<=890
 replace income_group = 3 if nhh>890 & nhh<=1335
 replace income_group = 4 if nhh>1335 & nhh<=1780
 replace income_group = 5 if nhh>1780 & nhh<=2239
 
 * Compute mean and median betas
 forvalues i = 1(1)5 {
	sum beta if income_group==`i', detail
 }
 drop nhh
 
 *(c) Rank individuals by their estimated βi and create five groups of individuals.
 *    Within each group of β’s compute average income and wealth across groups.
 
 * Define five income groups
 sort beta
 gen nhh = _n 
 
 gen beta_group = 0
 replace beta_group = 1 if nhh<=445
 replace beta_group = 2 if nhh>445 & nhh<=890
 replace beta_group = 3 if nhh>890 & nhh<=1335
 replace beta_group = 4 if nhh>1335 & nhh<=1780
 replace beta_group = 5 if nhh>1780 & nhh<=2239
 
 * Compute mean and median betas
 forvalues i = 1(1)5 {
	sum income_ip if beta_group==`i', detail
 }


 
 

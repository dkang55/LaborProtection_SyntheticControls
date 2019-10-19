**Daniel Kang
**Econ 980AA Rise of Asia in the Global Economy
**Labor Regulation Analysis


*installing synthetic control package
ssc install synth , replace all 

*panel data set, state variable as units and year as time period
tsset country year 

*linear interpolation to replace missing values with a linear function 
ipolate edu year, gen(edu2)
ipolate gcf year, gen(gcf2)
ipolate manuval year, gen(man2)

*generating rates of change variables
gen edurt = D.edu/(L.edu*100)
gen lpoppercrt = D.lpopperc/(L.lpopperc*100)

gen ledu2 = ln(edu2) 
gen llpopperc = ln(lpopperc)
gen lgcf2 = ln(gcf2)
gen lgdp = ln(gdp) 
gen lgcf = ln(gcf)
gen lman = ln(man) 
gen lserv = ln(servval)

*developing synthetic control for India Labor Regulation 22 (***) 
synth gdp popgrowth lpopperc edu gcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

*developing synthetic control for India Labor Regulation 22 (logged GDP) 
synth lgdp popgrowth lpopperc edu gcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

*developing synthetic control for India Labor Regulation 22 (logged GDP & GCF) 
synth lgdp popgrowth lpopperc edu lgcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

* Y = AKL --> lnY = lnA + BetalnK + BetalnL 
synth lgdp popgrowth lpopperc edu lgcf lgdp(1972) lgdp(1975), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

*Manu value added 
synth manuval popgrowth lpopperc edu gcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

*Log manu value added 
synth lman popgrowth lpopperc edu gcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

*Serv value added 
synth servval popgrowth lpopperc edu gcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig

*Logged Serv value added 
synth lserv popgrowth lpopperc edu gcf lgdp(1974), trunit(1) trperiod(1984) xperiod(1970(1)1975) nested allopt fig


***********Prelimary graphs/charts*************

*GDP predictor means (india v other countries) 
gen Indav = .
replace Indav = 

by year, sort: egen GDPav = mean(gdp)
by year, sort: gen GDPInd2 = gdp[country[1]] 
line  GDPav inddd year, legend(size(medsmall)) xline(1984)
line  lGDPav lind year, legend(size(medsmall))

gen lGDPav = ln(GDPav)
gen lind = ln(inddd)

******Generating placebo effect in space*******
tempname resmat
        forvalues i = 2/10 {
		synth gdp popgrowth lpopperc edu gcf lgdp(1974), trunit(`i') trperiod(1984) xperiod(1970(1)1975) keep(test`i')
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        }
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
 
merge m:1 year using test2 test4 test5 test6 test7 test8 test9 test10


************************Difference in differences estimator*************************

*generating dummy to indicate time when treatment started 
gen time = (year >= 1983) & !missing(year)

*generating dummy to indentify group exposed to treatment
gen treatedx = 0
replace treatedx = 1 if country == 1 | country == 8

*generating interaction between time and treated: "DID effect"
gen did1 = time * treatedx
*Estimating the DID estimator 
reg gdprt popgrowth llpopperc ledu2 lgcf2 time treatedx  did1, r

***********************Interaction continuous regression**************************
*generating interaction between labor population dividend and labor protection
gen llpr22d = lpr22 * llpopperc
gen llpr27d = lpr27 * llpopperc
gen llpr13d = lpr13 * llpopperc
gen llpr40d = lpr40 * llpopperc
gen llpr4d = lpr4 * llpopperc


gen AMEND = 0
replace AMEND = 1 if year >= 1984 
gen Popreg = AMEND * lpopperc
reg lgdp i.year popgrowth lpopperc lgcf edu Popreg

**********************Isolated India xtreg *****************************
xtset country year 

ipolate edu year, gen(edu2)
ipolate gcf year, gen(gcf2)

gen ledu2 = ln(edu2) 
gen llpopperc = ln(lpopperc)
gen lgcf2 = ln(gcf2)
gen llpr22d = lpr22 * llpopperc

xtreg ag popgrowth llpopperc ledu2 lgcf2 lpr22, fe
xtreg manu i.year popgrowth llpopperc ledu2 lgcf2 lpr22, fe
xtreg trade i.year popgrowth llpopperc ledu2 lgcf2 lpr22, fe
xtreg fin i.year popgrowth llpopperc ledu2 lgcf2 lpr22, fe
xtreg serv i.year popgrowth llpopperc ledu2 lgcf2 lpr22, fe


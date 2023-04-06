******************************************************************************

* SUB par emissions carbone

*24/03/23
********************************************************************************

clear
capture log close  // Fermer un fichier logfile si déjà ouvert
local date "18-11-2022"	// Créer une boîte appelée date contenant la date du jour / Pour le nom du fichier logfile
/*cd "C:\Users\alexi\Desktop\CEPII-Covid19\CISS"*/	// Définir le répertoire de travail, ici dans le logfile
global base  "C:\Users\abaldi\Dropbox\Prof\research\PolMon\Redaction\Data"
global fig "fig"
cd "$base"

set scheme s1color

log using logfile_`date'.log, replace // Créer le fichier logfile

import excel "$base/bilanBdF_4299.xlsx", sheet("PIB") firstrow clear 
save "$base/PIB.dta", replace

import excel "$base/_SB.xlsx", sheet("valeurs_annuelles") firstrow clear
destring, replace
keep if strpos(Activité,"A38")
destring, replace
local col AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW
foreach c of local col{
    destring `c', replace force
}

rename (AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW) SUB#, addnumber(1978)
keep idBank Activité SUB* 
drop SUB2021
reshape long SUB, i(Activité) j(Année)

gen Secteur = 1 if strpos(Activité,"A38-AZ") 
replace Secteur = 2 if strpos(Activité,"A38-BZ") 
replace Secteur = 3 if strpos(Activité,"A38-CA") |strpos(Activité,"A38-CB") |strpos(Activité,"A38-CC") |strpos(Activité,"A38-CD") |strpos(Activité,"A38-CE") |strpos(Activité,"A38-CF") |strpos(Activité,"A38-CG") | ///
strpos(Activité,"A38-CH") |strpos(Activité,"A38-CI") |strpos(Activité,"A38-CJ") |strpos(Activité,"A38-CK") |strpos(Activité,"A38-CL") |strpos(Activité,"A38-CM") 
replace Secteur = 4 if strpos(Activité,"A38-DZ") 
replace Secteur = 5 if strpos(Activité,"A38-EZ") 
replace Secteur = 6 if strpos(Activité,"A38-FZ") 
replace Secteur = 7 if strpos(Activité,"A38-GZ") 
replace Secteur = 8 if strpos(Activité,"A38-HZ") 
replace Secteur = 9 if strpos(Activité,"A38-IZ") 
replace Secteur = 10 if strpos(Activité,"A38-JA") |strpos(Activité,"A38-JB") |strpos(Activité,"A38-JC")
replace Secteur = 11 if strpos(Activité,"A38-KZ") 
replace Secteur = 12 if strpos(Activité,"A38-LZ") 
replace Secteur = 13 if strpos(Activité,"A38-MA") |strpos(Activité,"A38-MB") |strpos(Activité,"A38-MC")
replace Secteur = 14 if strpos(Activité,"A38-NZ") 
replace Secteur = 15 if strpos(Activité,"A38-OZ") 
replace Secteur = 16 if strpos(Activité,"A38-PZ") 
replace Secteur = 17 if strpos(Activité,"A38-QA") |strpos(Activité,"A38-QB") 
replace Secteur = 18 if strpos(Activité,"A38-RZ") 
replace Secteur = 19 if strpos(Activité,"A38-SZ") 
replace Secteur = 20 if strpos(Activité,"A38-TZ") 

egen SUB_ag = sum(SUB), by(Secteur Année) 
duplicates drop Secteur Année, force
drop SUB
save "$base/SUB_val.dta", replace

import excel "$base/VA_branches.xlsx", sheet("valeurs_annuelles") firstrow clear
destring, replace
save "$base/VA_val.dta", replace

import excel "$base/VA_branches.xlsx", sheet("caractéristiques") firstrow clear 
keep if strpos(Activité,"A38")
keep if strpos(Opérationsdanslacomptabilité,"B1G - Valeur ajoutée brute")
keep if strpos(Prixderéférence,"Prix courant")

drop Dernièremiseàjour Correction Prixderéférence Zonegéographique Périodicité Indicateur Opérationsdanslacomptabilité Puissance Unité Nature

destring, replace 

merge 1:1 idBank using "$base/VA_val.dta"
drop if _m !=3
local colva AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY
foreach c of local colva{
    destring `c', replace force
}
rename (AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY) VA#, addnumber(1978)
keep idBank Activité Libellé VA*
reshape long VA, i(Activité) j(Année)
drop Libellé

gen Secteur = 1 if strpos(Activité,"A38-AZ") 
replace Secteur = 2 if strpos(Activité,"A38-BZ") 
replace Secteur = 3 if strpos(Activité,"A38-CA") |strpos(Activité,"A38-CB") |strpos(Activité,"A38-CC") |strpos(Activité,"A38-CD") |strpos(Activité,"A38-CE") |strpos(Activité,"A38-CF") |strpos(Activité,"A38-CG") | ///
strpos(Activité,"A38-CH") |strpos(Activité,"A38-CI") |strpos(Activité,"A38-CJ") |strpos(Activité,"A38-CK") |strpos(Activité,"A38-CL") |strpos(Activité,"A38-CM") 
replace Secteur = 4 if strpos(Activité,"A38-DZ") 
replace Secteur = 5 if strpos(Activité,"A38-EZ") 
replace Secteur = 6 if strpos(Activité,"A38-FZ") 
replace Secteur = 7 if strpos(Activité,"A38-GZ") 
replace Secteur = 8 if strpos(Activité,"A38-HZ") 
replace Secteur = 9 if strpos(Activité,"A38-IZ") 
replace Secteur = 10 if strpos(Activité,"A38-JA") |strpos(Activité,"A38-JB") |strpos(Activité,"A38-JC")
replace Secteur = 11 if strpos(Activité,"A38-KZ") 
replace Secteur = 12 if strpos(Activité,"A38-LZ") 
replace Secteur = 13 if strpos(Activité,"A38-MA") |strpos(Activité,"A38-MB") |strpos(Activité,"A38-MC")
replace Secteur = 14 if strpos(Activité,"A38-NZ") 
replace Secteur = 15 if strpos(Activité,"A38-OZ") 
replace Secteur = 16 if strpos(Activité,"A38-PZ") 
replace Secteur = 17 if strpos(Activité,"A38-QA") |strpos(Activité,"A38-QB") 
replace Secteur = 18 if strpos(Activité,"A38-RZ") 
replace Secteur = 19 if strpos(Activité,"A38-SZ") 
replace Secteur = 20 if strpos(Activité,"A38-TZ") 

egen Va_ag = sum(VA), by(Secteur Année) 
duplicates drop Secteur Année, force
drop VA
save "$base/VA_val.dta", replace

import excel  "$base/EmissionsCO2.xlsx", sheet("Feuille 1") cellrange(A11:L32) clear
destring, replace

rename A Secteur
rename (C D E F G H I J K L) CAR#, addnumber(2011)

reshape long CAR, i(Secteur) j(Année)
destring Secteur, replace force
drop if Secteur ==0 | Secteur == .
rename B Activité
merge 1:1 Année Secteur using "$base/VA_val.dta"
drop if Année ==2021
drop _m
gen CAR_pond = CAR/ Va_ag

merge 1:1 Année Secteur using "$base/SUB_val.dta"
gen SUB_pond = -SUB_ag/Va_ag
rename SUB_ag SUB

 forvalues s=1/20  {
     tw line SUB Année if Secteur ==`s',  name(g`s', replace) 
	 
 }
 
 forvalues s=1/20  {
     tw line SUB_pond Année if Secteur ==`s',  name(g`s', replace) 
	 
 }


xtset Année Secteur, yearly

/* Classement des secteurs en valeur absolue et subventions en valeur absolue*/
egen xt= xtile(CAR), by(Année) nq(4)
sort Secteur Année
bys Secteur: replace xt = xt[_n-1] if missing(xt) 
gsort Secteur -Année 
bys Secteur: replace xt = xt[_n-1] if missing(xt) 


sort xt
by xt: sum CAR


preserve
collapse (sum) SUB, by(Année xt)
replace SUB = -SUB 
reshape wide SUB, i(Année) j(xt)
rename Année year
merge m:1 year using "$base/pib.dta" 
drop _merge
foreach x in SUB1 SUB2 SUB3 SUB4 {
	gen `x'_ = 100000000*`x'/PIB
}
br year SUB1_ SUB2_ SUB3_ SUB4_

gen sum2 = SUB1_ + SUB2_
gen sum3= SUB1_ + SUB2_+ SUB3_
gen sum4 = SUB1_ + SUB2_+ SUB3_+ SUB4_
twoway area SUB1_ year if year > 1975, color(gs12) || rarea SUB1_ sum2 year if year > 1975, color(gs8) || rarea sum2 sum3 year if year > 1975, color(gs4) ///
|| rarea sum3 sum4 year if year > 1975, color(gs1) ///
legend(order(1 "Secteur 1 (le moins polluant)" 2 "Secteur 2" 3 "Secteur 3" 4 "Secteur 4 (le plus polluant)")) xtitle("") ///
xla(1980(10)2020)  ytitle("En % du PIB") /*title("Niches fiscales") note("Source: Comptes d'exploitation par Branches (INSEE) et comptes d'émissions atmosphériques (EUROSTAT) ", size(vsmall))*/
gr export "$fig/SUBcouleursAbs.png", replace

restore



/* Tout pondéré par VA*/
egen xt_pond= xtile(CAR_pond), by(Année) nq(4)
sort Secteur Année
bys Secteur: replace xt_pond = xt_pond[_n-1] if missing(xt_pond) 
gsort Secteur -Année 
bys Secteur: replace xt_pond = xt_pond[_n-1] if missing(xt_pond) 


sort xt_pond
by xt_pond: sum CAR_pond
by xt_pond: sum SUB_pond


preserve
collapse (sum) SUB_pond, by(Année xt_pond)
reshape wide SUB_pond, i(Année) j(xt_pond)
rename Année year
gen sum2 = SUB_pond1 + SUB_pond2
gen sum3= SUB_pond1 + SUB_pond2+ SUB_pond3
gen sum4 = SUB_pond1 + SUB_pond2+ SUB_pond3+ SUB_pond4
twoway area SUB_pond1 year if year > 1975, color(gs12) || rarea SUB_pond1 sum2 year if year > 1975, color(gs8) || rarea sum2 sum3 year if year > 1975, color(gs4) ///
|| rarea sum3 sum4 year if year > 1975, color(gs1) ///
legend(order(1 "Secteur 1 (le moins polluant)" 2 "Secteur 2" 3 "Secteur 3" 4 "Secteur 4 (le plus polluant)")) xtitle("") ///
xla(1980(10)2020)  ytitle("En % du PIB") /*title("Niches fiscales") note("Source: Comptes d'exploitation par Branches (INSEE) et comptes d'émissions atmosphériques (EUROSTAT) ", size(vsmall))*/
gr export "$fig/SUBcouleursPond.png", replace

restore



erase "$base/PIB.dta"







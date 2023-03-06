******************************************************************************

* Répartition Impôts et Aides publiques France depuis 1949  
*TEE, INSEE Dep APU, PLF, PLFSS
********************************************************************************
clear
capture log close  // Fermer un fichier logfile si déjà ouvert
local date "02-05-2022"	// Créer une boîte appelée date contenant la date du jour / Pour le nom du fichier logfile
/*cd "C:\Users\alexi\Desktop\CEPII-Covid19\CISS"*/	// Définir le répertoire de travail, ici dans le logfile
global base  "C:\Users\abaldi\Dropbox\Prof\research\PolMon\Redaction\Data"
global fig "figwp"
cd "$base"

set scheme s1color

log using logfile_`date'.log, replace // Créer le fichier logfile

import excel "$base/bilanBdF_4299.xlsx", sheet("PIB") firstrow clear 
save "$base/PIB.dta"
import excel "$base/DepRecetAPU_Insee.xlsx", sheet("Feuil1" ) firstrow clear
save "$base/DepRecetAPU_Insee.dta", replace
/*import excel TEE_Final0422.xlsx, sheet("Stata") firstrow case(lower) clear*/
import excel Data_Liepp.xlsx, sheet("Stata") firstrow case(lower) clear

merge m:1 year using "$base/pib.dta" 
drop _merge
merge m:1 year using "$base/DepRecetAPU_Insee.dta" 
drop _merge

erase "$base/PIB.dta"
erase "$base/DepRecetAPU_Insee.dta"
tsset year, yearly

rename credit_imp_entaa creditimp_ent
rename credit_imp_menaa creditimp_men
 
gen is= is_nf + is_f
gen ip= ip_nf + ip_f 
gen sube= subv_nf + subv_f
gen cotsoce= cotsoc_nf+ cotsoc_f 
br year cotsoc_nf cotsoc_f  cotsoc_m
gen va= va_f+ va_nf
gen pib = PIB/1000000000
drop PIB
rename subv_m subm
rename cotsoc_m cotsocm

gen subt= sube+subm

gen depfisctAA= depfisc_maa + depfisc_emaa + depfisc_eaa
gen depfiscdecAA= depfiscdec_maa + depfiscdec_eaa

gen credit_impAA= creditimp_ent + creditimp_men

/* vérif crédit impôts dans doc budg et crédits d'impôts dans INSEE. Comme attendu, légère différence*/

tsline credit_impAA credit_imp

g totdepfiscAA = depfisctAA + depfiscdecAA


/* jusque 2010, les crédits d'impots ne sont pas comptés dans les subventions*/


gen subtAA = subt-credit_impAA 
gen subeAA = sube - creditimp_ent
gen submAA  = subm- creditimp_men

gen aidepubeAA= subeAA + depfisc_eaa+ depfiscdec_eaa
gen aidepubmAA= submAA+ depfisc_maa+ depfiscdec_maa

g credit_impbudg = creditimp_ent + creditimp_men

rename patrimoine pat

gen tot_imp= is+ip+pat+tva+ir
br year is ip pat tva ir
gen Prelev = tot_imp + cotsoce + cotsocm /* je n'inclus pas les cotosco des APU ce qui explique pourquoi le total est inférieur au total agrégée de l'INSEE */
br year tot_imp cotsoce cotsocm
g PrelevEnt = is+ip+ cotsoce
g PrelevMen = tva+ ir+ pat + cotsocm

g exosoc_aa= exosoce_aa+ exosocm_aa

g aideputote_AA= aidepubeAA + exosoce_aa

/* Détail des aides publiques*/

br year subeAA depfisc_eaa depfiscdec_eaa exosoce_aa aideputote_AA

gen ImpMenages = (tva+ ir+ pat)/pib
gen ImpEntr = (is+ip)/pib
gen ImpMenBrut = (tva+ ir+ pat)/(rev_m)
gen PrelevMenBrut = (tva+ ir+ pat + cotsocm)/(rev_m)
gen ImpEntBrut = (is+ip)/(rev_e)
gen PrelevEntrBrut= (is+ip+cotsoce)/(rev_e)
g EFm= impaa_m/ rev_m
g EFe = impaa_e/ rev_e
g EFsnf = impaa_snf/rev_snf


rename Dépensesdefonctionnement Fonctionnement
rename IntérêtsD41 Intérêts
rename Prestationssocialesautresque prestasoc
rename Impôtsetcotisationssociales ImpCotis
rename CotisationssocialesnettesD61 CSnettes


gen prestation= prestasoc + Transfertssociauxennaturede
rename SubventionsD3 subventions
rename Acquisitionsmoinscessionsdac InvPub
rename Totaldesdépenses Dépenses

gen ImpInsee = ImpCotis - CSnettes
gen DeptPub = Dépenses-prestation

foreach x in Fonctionnement Intérêts prestation InvPub ImpCotis ImpInsee {
	gen `x'_norm = `x'/pib
	}
	
	foreach x in tva ir pat is ip tot_imp Prelev depfisctAA depfiscdecAA aidepubeAA aidepubmAA  creditimp_men creditimp_ent credit_impAA ///
	DeptPub cotsoce cotsocm PrelevEnt PrelevMen subtAA subeAA submAA  totdepfiscAA depfisc_eaa /// 
	depfisc_maa depfiscdec_eaa depfiscdec_maa exosocm_aa exosoce_aa exosoc_aa {
gen `x'_norm = `x'/(pib) 
}
	
rename subtAA_norm subtAA_
rename subeAA_norm subeAA_
rename submAA_norm submAA_ 


*** vérification que les subventions  + transferts calculées à partir du TEE correspondent aux subventions + transferts à partir du t_3201

gen subt2= subventions + TransfertsencapitalàpayerD
gen subt2_norm=subt2/(pib)

***********************
generate str periods = ""
replace periods="1949-1975" if year >=1949 & year <1976
replace periods="1976-1992" if year >=1976 & year <1993
replace periods="1993-2009" if year >=1993 & year <2010
replace periods="2010-2021" if year >=2010 & year <=2021

**************Graph IMPÖTS**************************

rename tot_imp_norm PO
rename Prelev_norm PRELEV
rename ImpCotis_norm PRELEVInsee
rename tva_norm TVA
rename ir_norm REVENUS 
rename pat_norm PATRIMOINES
rename is_norm SOCIETES
rename ip_norm PRODUCTION
rename cotsoce_norm COTSOCE
rename cotsocm_norm COTSOC
rename PrelevEnt_norm PRELEVENT
rename PrelevMen_norm PRELEVMEN

rename ImpInsee_norm IMPINSEE

tsline PRELEV PRELEVInsee
tsline PO IMPINSEE
br year tot_imp ImpInsee
gr export "$fig/PO.pdf", replace


foreach x in PO subtAA_ ImpMenages ImpEntr ImpMenBrut ImpEntBrut TVA REVENUS PATRIMOINES SOCIETES PRODUCTION PRELEVENT PRELEVMEN EFe EFm EFsnf {
	egen `x'1= mean(`x') if year >=1949 & year <1976
	egen `x'2= mean(`x') if year >=1976 & year <1993
	egen `x'3= mean(`x') if year >=1993 & year <2010
	egen `x'4= mean(`x') if year >=2010 & year <=2021
}

foreach x in PO subtAA_ ImpMenages ImpEntr ImpMenBrut ImpEntBrut TVA REVENUS PATRIMOINES SOCIETES PRODUCTION PRELEVENT PRELEVMEN EFe EFm EFsnf {
generate `x'm=`x'
replace `x'm=`x'1 if year >=1949 & year <1976
replace `x'm=`x'2 if year >=1976 & year <1993
replace `x'm=`x'3 if year >=1993 & year <2010 
replace `x'm=`x'4 if year >=2010 & year <=2021
}

twoway (tsline PO, lpattern(dot) lcolor(black)) (tsline POm, lpattern(dash) lcolor(black)), legend(label(1 "Somme des impôts") /// 
label(2 "Moyenne par période")) /* title("Evolution de la fiscalité française")*/ ///
/*subtitle("en proportion des revenus")*/ ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20" 0.25 "25" 0.3 "30") xtitle("") xlabel(1949(6)2021)  ///
note(, size(tiny))
gr export "$fig/pPO_m.png", replace

br year PO POm

*Graph 1*

twoway (tsline PO, lpattern(dot) lcolor(black)) (tsline POm, lpattern(dash) lcolor(black)) (tsline subtAA_, lpattern(solid) lcolor(gs6)) (tsline subtAA_m, lpattern(dash) lcolor(black)), ///
 ytitle("% du PIB") ymtick(0.05(0.05)0.2) ///
  ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20" 0.25 "25" 0.30 "30")  legend(label(1 "Somme des impôts") /// 
label(2 "") label(3 "Dépenses publiques de soutien à l'économie") order(1 3 ) size(small)) ///
/*ylabel(0.16 "16%" 0.18 "18%" 0.2 "20%" 0.22 "22%" 0.24 "24%" 0.26 "26%" ) */ xtitle("") xlabel(1949(6)2021)  ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu est la somme de la valeur ajoutée des entreprises et du PIB disponible brut des ménages", size(tiny))*/
gr export "$fig/pPOSout_m.png", replace

br year PO POm
sum subtAA_
br year subtAA_

*Graph 2*
multiline TVA REVENUS PATRIMOINES year , xtitle("") recast(connected) separate by(legend(off)) ms(O D T) lc(black black black) mc(black black black) ///
 ylab(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20") xlabel(1950(10)2020) name(g1, replace) nodraw
multiline SOCIETES PRODUCTION year , xtitle("") recast(connected) separate by(legend(off)) ms(D T) lc(gs10 gs10) mc(gs10 gs10) ylab(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20") ///
 xlabel(1950(10)2020) name(g2, replace) nodraw
tw (tsline ImpEntr, lcolor(gs10) lwidth(thick) lpattern(solid)) (tsline ImpEntrm, lcolor(gs10) lpattern(dash)) (tsline ImpMenages, lwidth(thick) lcolor(black) ///
 lpattern(solid)) (tsline ImpMenagesm, lcolor(black) ///
lpattern(dash)), xtitle("") xlabel(1949(6)2021) legend(label(1 "Impôt versés par les entreprises") /// 
label(2 "Impôts versés par les ménages"))  ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20" 0.25 "25") name(g3, replace) nodraw
grc1leg g1 g2, ycommon rows(1) name(row1, replace)
grc1leg row1 g3, col(1)
gr export "$fig/pPO_multi.png", replace
 
 
 br year TVA REVENUS PATRIMOINES SOCIETES PRODUCTION ImpMenages ImpMenagesm ImpEntr ImpEntrm
 sum TVA
*Graph 3*
graph bar (mean) ir tva pat is ip  , over(periods) percentage stack ///
bar(1, bcolor(gs13)) bar(2, bcolor(gs11)) bar(3, bcolor(gs8)) bar(4, bcolor(gs5)) bar(5, bcolor(gs2)) ///
 legend(label(2 "TVA et autres impôts sur produits") /// 
label(1 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production")) /*title("Répartition des impôts depuis 1949") */ ///
ytitle("en % ") ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu est la somme de la valeur ajoutée des entreprises et du PIB disponible brut des ménages", size(tiny))*/
gr export "$fig/pbar3.png", replace

**************Contribution à la croissance*****************

foreach x in tot_imp is ip tva ir pat exosoce_aa exosocm_aa {
	gen d_`x'=(`x'-`x'[_n-1])/`x'[_n-1]
	gen `x'_pond= `x'[_n-1]/tot_imp
	gen `x'_cont=`x'_pond*d_tot_imp
	egen `x'_conT1=sum(`x'_cont) if year >=1949 & year <1976
	egen `x'_conT2=sum(`x'_cont) if year >=1976 & year <1993
	egen `x'_conT3=sum(`x'_cont) if year >=1993 & year <2010
	egen `x'_conT4=sum(`x'_cont) if year >=2010 & year <=2021
	replace `x'_conT1=0 if `x'_conT1==. | `x'_conT1<=0
	replace `x'_conT2=0 if `x'_conT2==. | `x'_conT2<=0
	replace `x'_conT3=0 if `x'_conT3==. | `x'_conT3<=0
	replace `x'_conT4=0 if `x'_conT4==. | `x'_conT4<=0
	gen ev`x'= `x'_conT1+`x'_conT2+`x'_conT3+ `x'_conT4
	}

	*Graph 4*
	

graph pie evtva evir evpat evis evip if year == 1975, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) size(small) ) subtitle(1949-1975) ptext("+ 8,2% ") name(g1, replace) nodraw
graph pie evtva  evir evpat  evis evip if year == 1994, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) ) subtitle(1976-1992) name(g2, replace) nodraw
graph pie evtva  evir evpat  evis evip if year == 2000, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) ) subtitle(1993-2009) name(g3, replace) nodraw
graph pie evtva  evir evpat  evis evip if year == 2015, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) ) subtitle(2010-2021) name(g4, replace) nodraw
grc1leg g1 g2 g3 g4, /*title("Contribution à l'augmentation totale des prélèvements") note(Source: données INSEE. Calculs de l'auteure) */
gr export "$fig/ppie1.png", replace

br year evtva evir evpat evis evip

**Inclusion des COTSOC**

*Graph 4bis*
	

graph pie evtva evir evpat evis evip evexosoce_aa evexosocm_aa if year == 1975, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) size(small) ) subtitle(1949-1975) ptext("+ 8,2% ") name(g1, replace) nodraw
graph pie evtva  evir evpat  evis evip evexosoce_aa evexosocm_aa if year == 1994, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) ) subtitle(1976-1992) name(g2, replace) nodraw
graph pie evtva  evir evpat  evis evip evexosoce_aa evexosocm_aa if year == 2000, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) ) subtitle(1993-2009) name(g3, replace) nodraw
graph pie evtva  evir evpat  evis evip evexosoce_aa evexosocm_aa if year == 2015, pie(1, color(gs8)) pie(2, color(gs11)) pie(3, color(gs5)) pie(4, color(gs13)) pie(5, color(gs2)) legend(label(1 "TVA et autres impôts sur produits") label(2 "Impôt sur les revenus") label(3 "Impôt sur les patrimoines") label(4 "Impôt sur les sociétés") label(5 "Impôt de production") order(1 5 3 4 2) ) subtitle(2010-2021) name(g4, replace) nodraw
grc1leg g1 g2 g3 g4, /*title("Contribution à l'augmentation totale des prélèvements") note(Source: données INSEE. Calculs de l'auteure) */
gr export "$fig/ppie2.png", replace


/*Graph 5 */

generate str periodbis = ""
replace periods="1959-1975" if year >=1959 & year <1976
replace periods="1976-1992" if year >=1976 & year <1993
replace periods="1993-2009" if year >=1993 & year <2010
replace periods="2010-2021" if year >=2010 & year <=2021


foreach x in PRELEV PrelevEntrBrut PrelevMenBrut PRELEVInsee {
	egen `x'1= mean(`x') if year >=1959 & year <1976
	egen `x'2= mean(`x') if year >=1976 & year <1993
	egen `x'3= mean(`x') if year >=1993 & year <2010
	egen `x'4= mean(`x') if year >=2010 & year <=2021
}

foreach x in PrelevEntrBrut PrelevMenBrut PRELEV PRELEVInsee {
generate `x'm=`x'
replace `x'm=`x'1 if year >=1959 & year <1976
replace `x'm=`x'2 if year >=1976 & year <1993
replace `x'm=`x'3 if year >=1993 & year <2010 
replace `x'm=`x'4 if year >=2010 & year <=2021
}

twoway (tsline PRELEVInsee if year > 1958, lpattern(dot) lcolor(black)) (tsline PRELEVInseem if year > 1958, lpattern(dash) lcolor(black)), legend(label(1 "Somme des prélèvements") /// 
label(2 "Moyenne par période")) /* title("Evolution des Prélèvements en France")*/ ///
/*subtitle("en proportion des revenus")*/ ylabel(0.15 "15" 0.2 "20" 0.25 "25" 0.3 "30" 0.35 "35" 0.4 "40" 0.45 "45" 0.5 "50") xtitle("") xlabel(1959(6)2021)  ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu est la somme de la valeur ajoutée des entreprises et du PIB disponible brut des ménages", size(tiny))*/
gr export "$fig/pImpot.png", replace
br year PRELEVInsee PRELEVInseem POm
sum cotsocm Prelev if year >= 1976 & year <= 1992



/*Graph optionnel*/ 
multiline TVA REVENUS PATRIMOINES year , xtitle("") recast(connected) separate by(legend(off)) ms(O D T) lc(black black black) mc(black black black) ylab(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20") xlabel(1950(10)2020) name(g1, replace) nodraw
multiline SOCIETES PRODUCTION COTSOCE COTSOCM year , xtitle("") recast(connected) separate by(legend(off)) ms(O D T) lc(gs10 gs10) mc(gs10 gs10 gs10) ylab(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20") xlabel(1949(6)2021) name(g2, replace) nodraw
tw (tsline PRELEVENT, lcolor(gs10) lwidth(thick) lpattern(solid)) (tsline PRELEVENTm, lcolor(gs10) lpattern(dash)) (tsline ImpMenages, lwidth(thick) lcolor(black) lpattern(solid)) (tsline ImpMenagesm, lcolor(black) ///
lpattern(dash)), xtitle("") xlabel(1950(10)2020) legend(label(1 "Impôt versés par les entreprises") /// 
label(2 "Impôts versés par les ménages"))  ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20" 0.25 "25") name(g3, replace) nodraw
grc1leg g1 g2, ycommon rows(1) name(row1, replace)
grc1leg row1 g3, col(1)
gr export "$fig/pPObis_multi.png", replace



/*Fig. 6*/ 


graph bar (mean) cotsocm ir tva pat cotsoce is ip if year> 1958, over(periods) percentage stack ///
bar(1, bcolor(gs15)) bar(2, bcolor(gs13)) bar(3, bcolor(gs11)) bar(4, bcolor(gs9)) bar(5, bcolor(gs7)) bar(6,bcolor(gs5)) bar(7,bcolor(gs9))   ///
 legend(label(3 "TVA") /// 
label(1 "Cot soc ménages") label(2 "Impôt sur les revenus") label(4 "Impôt sur les patrimoines") label(6 "Impôt sur les sociétés") label(7 "Impôt de production") label(5 "Cot soc entreprises")) ///
 /*title("Répartition des Prélèvements depuis 1949")*/ ///
ytitle("en % du total") ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu est la somme de la valeur ajoutée des entreprises et du PIB disponible brut des ménages", size(tiny))*/
gr export "$fig/pbar3bis.png", replace
br year ir tva pat is ip cotsoc 
sum Prelev PrelevEnt PrelevMen
sum Prelev PrelevEnt PrelevMen if year >= 1976 & year <= 1992
sum Prelev PrelevEnt PrelevMen if year >= 2010


twoway (line PrelevEntrBrut year if year > 1958,  lwidth(thick) lcolor(black)  lpattern(dot)) (line PrelevMenBrut year if year > 1958,  lwidth(thick) lcolor(black) lpattern(dash)) ///
 (line PrelevMenBrutm year if year > 1958, lcolor(black) lpattern(solid)) (line PrelevEntrBrutm year if year > 1958, lcolor(black) lpattern(solid) lwidth(thin)), ///
 ytitle("% des revenus respectifs") xtitle("") xlabel(1959(6)2021) ///
 legend(label(1 "Prélèvements versés par les entreprises") label(2 "Prélèvements versés par les ménages") order(1 2 ) size(tiny) col(2)) ///
/*title("Evolution du poids des prélèvements") subtitle("en proportion du PIB respectif")*/ ymtick(0.15(0.05)0.2) ylabel(0.15 "15" 0.2 "20" 0.25 "25" 0.3 "30" 0.35 "35" 0.4 "40" 0.45 "45") ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu des entreprises et des ménages est respectivement la valeur ajoutée et le revenu disponible brut", size(tiny)) */
gr export "$fig/pImpCot.png", replace

twoway (line EFe year,  lwidth(thick) lcolor(black)  lpattern(dot)) (line EFm year,  lwidth(thick) lcolor(black) lpattern(dash)) ///
 (line EFem year, lcolor(black) lpattern(solid)) (line EFmm year, lcolor(black) lpattern(solid) lwidth(thin)), ///
 ytitle("% des revenus respectifs") xtitle("") xlabel(1959(6)2021) ///
 legend(label(1 "Prélèvements versés par les entreprises") label(2 "Prélèvements versés par les ménages") order(1 2 ) size(tiny) col(2)) ///
/*title("Evolution du poids des prélèvements") subtitle("en proportion du PIB respectif")*/ ymtick(0.15(0.05)0.2) ylabel(0.2 "20" 0.25 "25" 0.3 "30" 0.35 "35" 0.4 "40" 0.45 "45" 0.5 "50") ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu des entreprises et des ménages est respectivement la valeur ajoutée et le revenu disponible brut", size(tiny)) */
gr export "$fig/pImpCot.png", replace

twoway (line EFsnf year,  lwidth(thick) lcolor(black)  lpattern(dot)) (line EFm year,  lwidth(thick) lcolor(black) lpattern(dash)) ///
 (line EFsnfm year, lcolor(black) lpattern(solid)) (line EFmm year, lcolor(black) lpattern(solid) lwidth(thin)), ///
 ytitle("% des revenus respectifs") xtitle("") xlabel(1949(6)2021) ///
 legend(label(1 "Prélèvements versés par les entreprises") label(2 "Prélèvements versés par les ménages") order(1 2 ) size(tiny) col(2)) ///
/*title("Evolution du poids des prélèvements") subtitle("en proportion du PIB respectif")*/ ymtick(0.15(0.05)0.2) ylabel(0.2 "20" 0.25 "25" 0.3 "30" 0.35 "35" 0.4 "40" 0.45 "45" 0.5 "50") ///
/*note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu des entreprises et des ménages est respectivement la valeur ajoutée et le revenu disponible brut", size(tiny)) */
gr export "$fig/pImpCotsnf.png", replace

****Aides publiques ***************************
**** Comparaison data AA et ALD*****************


foreach x in subeAA_ submAA_ /*aidepubtAA_ */ {
	egen `x'1= mean(`x') if year >=1949 & year <1976
	egen `x'2= mean(`x') if year >=1976 & year <1993
	egen `x'3= mean(`x') if year >=1993 & year <2010	
	egen `x'4= mean(`x') if year >=2010 & year <=2021
}

foreach x in subeAA_ submAA_ /*aidepubtAA_*/  {
generate `x'm=`x'
replace `x'm=`x'1 if year >=1949 & year <1976
replace `x'm=`x'2 if year >=1976 & year <1993
replace `x'm=`x'3 if year >=1993 & year <2010  
replace `x'm=`x'4 if year >=2010 & year <=2021
}


/*Figure 1: je prends les subventions brutes sans retirer les crédits d'impôts*/

/*Figure 1bis*/

preserve
collapse (sum) subeAA_ submAA_, by(year)

gen sum2 = subeAA_ + submAA_ 

twoway area subeAA_ year, color(gs8) || rarea subeAA_ sum2 year, color(gs11)  ///
legend(order( 2 "Pour les ménages" 1 "Pour les entreprises")) xtitle("") ///
xla(1949(6)2021)  ylabel(0 "0" 0.05 "5" 0.075 "7.5" ) ytitle("En % du PIB") /*title("Dépenses publiques de soutien à l'économie (subventions)") note("Source: Tableaux Economiques d'Ensemble (INSEE). Le revenu est la somme de la valeur ajoutée des entreprises et du PIB disponible brut des ménages", size(tiny)) */
gr export "$fig/psubAA.png", replace
restore

br year subeAA_ submAA_ subeAA submAA
sum subeAA_ submAA_
sum subeAA_ submAA_ if year <= 1976
sum subeAA_ submAA_ if year >= 1976

/*Figure 2 bis*/
preserve
collapse (sum) subtAA_ depfiscdecAA_norm depfisctAA_norm credit_impAA_norm, by(year)

gen sum2 = depfiscdecAA_norm + depfisctAA_norm
gen sum3 = depfiscdecAA_norm + depfisctAA_norm + subtAA_

twoway area depfiscdecAA_norm year if year >= 1979, color(gs4) || rarea depfiscdecAA_norm sum2 year if year >= 1979, color(gs8) ||rarea sum2 sum3 year if year >= 1979, color(gs11) ///
||  line credit_impAA_norm year if year >= 1979, color(gs1)  /// 
legend(order(1 "Niches fiscales déclassées" 2 "Niches fiscales classées" 4 "Crédits d'impôt"  3 "Subventions et transferts")) xtitle("") ///
xla(1979(6)2021)  ytitle("En % du PIB") ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6" 0.08 "8" 0.1 "10" 0.12 "12" 0.14 "14" )/*title("Niches fiscales") note("Source: PLF Voies et Moyens (1979-2020) et INSEE ")*/
gr export "$fig/pniches.png", replace
restore

br year subtAA_ depfiscdecAA_norm depfisctAA_norm credit_impAA_norm subtAA depfiscdecAA depfisctAA credit_impAA
g aidepubT = subtAA + depfiscdecAA + depfisctAA
g aidepubT_ = aidepubT/pib
sum aidepubT_ if year >= 1979

g nichesfiscT = depfiscdecAA + depfisctAA
g nichesfiscT_ = nichesfiscT/pib
br year aidepubT aidepubT_ 
sum nichesfiscT_ if year <=2000
sum nichesfiscT_ if year >2000
br year nichesfiscT subtAA



/*Figure 2 ter: avec Cotsoc*/
preserve
collapse (sum) subtAA_ depfiscdecAA_norm depfisctAA_norm credit_impAA_norm exosoc_aa_norm, by(year)

gen sum2 = depfisctAA_norm + subtAA_
gen sum3 = depfiscdecAA_norm + depfisctAA_norm + subtAA_
gen sum4 = depfiscdecAA_norm + depfisctAA_norm + subtAA_+ exosoc_aa_norm

twoway area subtAA_ year if year >= 1979, color(gs4) || rarea subtAA_ sum2 year if year >= 1979, color(gs8) ||rarea sum2 sum3 year if year >= 1979, color(gs12) ||rarea sum3 sum4 year if year >= 1979, color(gs14) ///
||  line credit_impAA_norm year if year >= 1979, color(gs1)  ///
legend(order(3 "Niches déclassées" 2 "Niches fiscales" 5 "Crédits d'impôt" 1 "Subventions et transferts" 4 "Exo soc")) xtitle("") ///
xla(1979(6)2021)  ytitle("En % du PIB") ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6" 0.08 "8" 0.1 "10" 0.12 "12" 0.14 "14" 0.16 "16")/*title("Niches fiscales") note("Source: PLF Voies et Moyens (1979-2020) et INSEE ")*/
gr export "$fig/pnichesex.png", replace
restore


/*Figure 3bis*/

preserve
collapse (sum) subtAA_ totdepfiscAA_norm, by(year)

gen sum2 = subtAA_ + totdepfiscAA_norm 

twoway area subtAA_ year if year >=1979, color(gs8) || rarea subtAA_ sum2 year if year >=1979, color(gs11)  ///
legend(order( 2 "Niches fiscales" 1 "Subventions")) xtitle("") ///
xla(1979(6)2021)  ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" ) ytitle("En % des revenus") /*title("Dépenses publiques pour l'économie marchande") note("Source: PLF Voies et Moyens (2006-2020) et INSEE ")*/
gr export "$fig/pAPTAA.png", replace
restore

/*Figure 4bis*/

preserve 
collapse (sum) aidepubeAA_ aidepubmAA_, by(year)

g sum2 = aidepubeAA_ + aidepubmAA_

twoway area aidepubeAA_ year if year >= 1979, color(gs8) || rarea aidepubeAA_ sum2 year if year >= 1979, color(gs11)  ///
legend(order( 2 "Pour les ménages" 1 "Pour les entreprises")) xtitle("") ///
xla(1979(6)2021)  ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" ) ytitle("En % des revenus") /*title("Dépenses publiques pour l'économie marchande") note("Source: PLF Voies et Moyens (2006-2020) et INSEE ")*/
gr export "$fig/pAPTdisAA.png", replace
restore

/*Figure 5 Crée une base panel: entreprises, ménages, total*/


/* FIGURE DANS BOUQUIN en % du PIB*/ 


preserve
rename subeAA_ sub1
rename submAA_ sub2
rename depfisc_eaa_norm depfisc1
rename depfisc_maa_norm depfisc2
rename depfiscdec_eaa_norm depfiscdec1
rename depfiscdec_maa_norm depfiscdec2
rename exosoce_aa exosoc1
rename exosocm_aa exosoc2

keep year sub1 sub2 depfisc1 depfisc2 depfiscdec1 depfiscdec2 exosoc1 exosoc2
reshape long sub depfisc depfiscdec exosoc, i(year) j(id)

generate str ind = ""
replace ind="Entreprises" if id == 1
replace ind="Ménages" if id==2
 graph bar (mean) sub depfisc depfiscdec  if year > = 1979 & year < 1993 , over(ind) stack bar(1, bcolor(gs13)) bar(2, bcolor(gs11)) bar(3, bcolor(gs9)) ///
 bar(4, lcolor(gs2) bcolor(gs14)) ///
 legend(label(1 "Subventions") label(2 "Niches classées") label(3 "Niches déclassées") label(4 "Crédits d'impôts") size(small) ) ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6" ) ///
 subtitle(1979-1992)  name(g1, replace) 
 graph bar (mean) sub depfisc depfiscdec  if year > = 1993 & year <2010, over(ind) stack bar(1, bcolor(gs13)) bar(2, bcolor(gs11)) bar(3, bcolor(gs9)) ///
 bar(4, lcolor(gs2) bcolor(gs14)) ///
 legend(label(1 "Subventions") label(2 "Niches classées") label(3 "Niches déclassées") label(4 "Crédits d'impôts") size(small) ) ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6" ) ///
 subtitle(1993-2009) name(g2, replace) 
  graph bar (mean) sub depfisc depfiscdec  if year > = 2010, over(ind) stack bar(1, bcolor(gs13)) bar(2, bcolor(gs11)) bar(3, bcolor(gs9)) /// 
  bar(4, lcolor(gs2) bcolor(gs14)) ///
 legend(label(1 "Subventions") label(2 "Niches classées") label(3 "Niches déclassées") label(4 "Crédits d'impôts") size(small) ) ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6" ) ///
 subtitle(2010-2021) name(g3, replace) 
 graph combine g1 g2 g3
gr export "$fig/pbarAidesPubdis.png", replace
restore

br year subeAA submAA depfisc_eaa depfisc_maa depfiscdec_eaa depfiscdec_maa pib
g aidepube = subeAA + depfisc_eaa + depfiscdec_eaa 
g aidepube_ = aidepube/pib
br year aidepube_ subeAA_ depfisc_eaa_norm depfiscdec_eaa_norm
 
sum aidepube_ if year >= 1979 & year <=1992
sum aidepube_ if year >= 1993 & year <=2009
sum aidepube_ if year >= 2009 & year <=2021
sum subeAA_ if year >= 1979 & year <=1992
sum depfisc_eaa_norm if year >= 1979 & year <=1992
sum depfiscdec_eaa_norm if year >= 1979 & year <=1992


g aidepubm = submAA + depfisc_maa + depfiscdec_maa 
g aidepubm_ = aidepubm/pib
sum aidepubm_ if year >= 1979 & year <=1992
sum aidepubm_ if year >= 2009 & year <=2021


/* Figure 6 : Intègre les exosoc */ 

preserve
rename subeAA_ sub1
rename submAA_ sub2
rename depfisc_eaa_norm depfisc1
rename depfisc_maa_norm depfisc2
rename depfiscdec_eaa_norm depfiscdec1
rename depfiscdec_maa_norm depfiscdec2
rename exosoce_aa_norm exosoc1
rename exosocm_aa_norm exosoc2

keep year sub1 sub2 depfisc1 depfisc2 depfiscdec1 depfiscdec2 exosoc1 exosoc2
reshape long sub depfisc depfiscdec exosoc, i(year) j(id)

generate str ind = ""
replace ind="Entreprises" if id == 1
replace ind="Ménages" if id==2
  graph bar (mean) sub depfisc depfiscdec exosoc if year > = 1995 & year <2010, over(ind) stack bar(1, bcolor(gs13)) bar(2, bcolor(gs11)) bar(3, bcolor(gs9)) ///
 bar(4, lcolor(gs2) bcolor(gs14)) ///
 legend(label(1 "Subventions") label(2 "Niches classées") label(3 "Niches déclassées") label(4 "Exo sociales") size(small) ) ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6"  0.08 "8" 0.1 "10") ///
 subtitle(1995-2009) name(g2, replace) 
  graph bar (mean) sub depfisc depfiscdec exosoc  if year > = 2010, over(ind) stack bar(1, bcolor(gs13)) bar(2, bcolor(gs11)) bar(3, bcolor(gs9)) /// 
  bar(4, lcolor(gs2) bcolor(gs14)) ///
 legend(label(1 "Subventions") label(2 "Niches classées") label(3 "Niches déclassées") label(4 "Exo sociales") size(small) ) ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6"  0.08 "8" 0.1 "10") ///
 subtitle(2010-2021) name(g3, replace) 
 graph combine g2 g3
gr export "$fig/pbarAidesPubExosocdis.png", replace
restore

br year exosoce_aa_norm exosocm_aa_norm
sum exosoce_aa_norm exosocm_aa_norm if year >= 2010
sum exosoce_aa_norm exosocm_aa_norm if year <= 2010
g aidepubexe = subeAA + depfisc_eaa + depfiscdec_eaa + exosoce_aa
g aidepubexe_ = aidepubexe/pib
g aidepubexm = submAA + depfisc_maa + depfiscdec_maa + exosocm_aa
g aidepubexm_ = aidepubexm/pib

sum aidepubexe_ aidepubexm_ if year >= 2010
sum aidepubexe_ aidepubexm_ if year < 2010
sum aidepubexe aidepubexm if year >= 2010
sum aidepubexe aidepubexm if year < 2010

 
*set excelxlsxlargefile on
*cd "C:\Users\migom\OneDrive - Fundacio Institut d'Investigacio en ciencies de la salut Germans Trias i Pujol\COBATEST\Longitudinal"


*import excel "COBATEST SQL 20220523.xlsx", sheet("export_cobatest") firstrow clear
use "COBATEST_long.dta", clear

// Borrar si formulario es missing
drop if form==""
rename *, lower
*cambiar nombres de variables
rename (cbvct_name cbvct_city testing_site date_of_visit cbvct_identifier client_identifier date_of_birth foreign_national country_of_birth) /// 
(cbvctname cbvctcity testingsite dateofvisit cbvctidentifier cobaid dateofbirth foreignnational countryofbirth)
rename (previous_hiv_test  result_last_hiv_test test_12months_cbvct sex_with condom_use sex_worker unprotected_sex_sw2 unprotected_sex_idu unprotected_sex_hiv_positive unprotected_sex_msm) ///
 (previoushivtest  resultlasthivtest test12monthscbvct sexwith condomuse sexworker unprotectedsexsw2 unprotectedsexidu unprotectedsexhivpositive unprotectedsexmsm)
rename (intravenous_drug_use test_used screening_test_result confirm_hiv_test date_confirm_hiv_test confirm_hiv_test_res linkage_healthcare linkage_date cd4_count cd4_date) ///
(intravenousdruguse testused screeningtestresult confirmhivtest dateconfirmhivtest confirmhivtestres linkagehealthcare linkagedate cd4count cd4date)
rename (previous_syphilis date_last_syphilis syphilis_test date_syphilis_test type_syphilis_test syphilis_rapid_test_result syphilis_confirmation date_syphilis_confirmation syphilis_diagnosis) ///
 (previoussyphilis datelastsyphilis syphilistest datesyphilistest typesyphilistest syphilisrapidtestresult syphilisconfirmation datesyphilisconfirmation syphilisdiagnosis)
rename (previous_hcv date_previous_hcv hcv_test hcv_test_date hcv_test_type hcv_rapid_test_result hcv_confirmation hcv_confirmation_date hcv_diagnosis hep_a_vaccination hep_b_vaccionation) ///
 (previoushcv dateprevioushcv hcvtest hcvtestdate hcvtesttype hcvrapidtestresult hcvconfirmation hcvconfirmationdate hcvdiagnosis hepavaccination hepbvaccionation)

*ASIGNAR MISSINGS A LOS 0
foreach var in testingsite prenatal_screening gender tourist internet previoushivtest resultlasthivtest test12monthscbvct sexwith condomuse ///
	sexworker sti jail unprotectedsexsw2 unprotectedsexidu unprotectedsexhivpositive unprotectedsexmsm ///
	intravenousdruguse syringes_needles spoons_filters pretest_counselling testused screeningtestresult ///
	test_result_received post_test_counselling confirmhivtest confirmhivtestres confirm_hiv_test_res_rec ///
	linkagehealthcare previoussyphilis syphilistest typesyphilistest syphilisrapidtestresult syphilisconfirmation ///
	syphilisdiagnosis previoushcv hcvtest hcvtesttype hcvrapidtestresult hcvconfirmation hcvdiagnosis ///
	hepavaccination hepbvaccionation chemsex_drugs prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06 chemsex_which_drugs01 chemsex_which_drugs02 chemsex_which_drugs03 ///
	chemsex_which_drugs04 chemsex_which_drugs05{
	replace `var'=. if `var'==0
	}

//creamos la variable centros
do "id centres.do"
* 15 missings, recuperar manualmente por el código de usuario que creó el registro

// país del centro
do "pais centres.do"

// PAÍS
*match country coding to name (unim amb el llistat de països)
destring countryofbirth, replace
replace countryofbirth=891 if countryofbirth==688|countryofbirth==499
replace countryofbirth=736 if countryofbirth==728
replace countryofbirth=840 if countryofbirth==581
replace countryofbirth=250 if countryofbirth==260
replace countryofbirth=154 if countryofbirth==86
*drop nom_pais codi_subregio nom_subregio codi_regio nom_regio codi_continent nom_continent
merge m:1 countryofbirth using "country code.dta"
rename *, lower
drop if _merge==2
drop _merge
*País a nacionales
replace countryofbirth=paiscentre if foreignnational==2 & countryofbirth==.
replace foreignnational=. if foreignnational==3
tab countryofbirth, m


// fechas, pasar a missing
*pendiente agregar fecha ultimo test vih
foreach var in dateofvisit dateofbirth date_last_time date_speciment_collection date_test_result dateconfirmhivtest ///
	confirm_hiv_test_res_rec_date linkagedate cd4date datelastsyphilis datesyphilistest datesyphilisconfirmation ///
	dateprevioushcv hcvtestdate hcvconfirmationdate{
	replace `var'="" if `var'=="00/00/0000" | `var'=="00/00/00"
	}


//fecha visita
replace dateofvisit= ustrregexrf(dateofvisit, "/00", "/") if ustrpos(dateofvisit,"/00")>4
replace dateofvisit= ustrregexrf(dateofvisit, "00/", "15/") if ustrpos(dateofvisit,"00/")<4
replace dateofvisit= ustrregexrf(dateofvisit, "O", "0")
replace dateofvisit="" if id=="C81299"
replace dateofvisit="26/09/2019" if id=="C69624"
replace dateofvisit="26/06/2020" if id=="C86383"
gen dateofvisit2 = date(dateofvisit, "DMY",2022), after (dateofvisit)  
sort dateofvisit2
replace dateofvisit="" if dateofvisit2<date("01/01/2012", "DMY")
replace date_speciment_collection="" if date(date_speciment_collection, "DMY")<date("01/01/2012", "DMY")
replace date_speciment_collection="" if ustrregexm(date_speciment_collection,"00/00")==1
replace datesyphilistest="" if date(datesyphilistest, "DMY")<date("01/01/2012", "DMY")
replace hcvtestdate="" if date(hcvtestdate, "DMY")<date("01/01/2012", "DMY")
*
replace dateofvisit=date_speciment_collection if dateofvisit==""
*371 recup
replace dateofvisit=datesyphilistest if dateofvisit=="" & date_speciment_collection==""
* 8 recup
replace dateofvisit=hcvtestdate if dateofvisit=="" & date_speciment_collection=="" & datesyphilistest==""
* 2 recup
sort dateofvisit
drop dateofvisit2
gen idreal= real(ustrregexra(id,"[A-Z]","" ))
sort centros idreal
bysort centros (idreal): gen datevisit_pre=dateofvisit[_n-1] if dateofvisit=="" 
bysort centros (idreal): replace datevisit_pre=dateofvisit[_n-2] if dateofvisit=="" & datevisit_pre==""
bysort centros (idreal): replace datevisit_pre=dateofvisit[_n-3] if dateofvisit=="" & datevisit_pre==""
bysort centros (idreal): gen datevisit_pos=dateofvisit[_n+1] if dateofvisit==""
bysort centros (idreal): replace datevisit_pos=dateofvisit[_n+2] if dateofvisit=="" & datevisit_pos==""
bysort centros (idreal): replace datevisit_pos=dateofvisit[_n+3] if dateofvisit=="" & datevisit_pos==""
sort dateofvisit
replace dateofvisit= ustrregexrf(dateofvisit, "00/", "15/") if ustrpos(dateofvisit,"00/")<4
* no hay mucha diferencia entre la fecha anterior y posterior de visita por ID de formulario en cada centro. Se reemplazará missing por fecha de visita del registro anterior del mismo centro
replace dateofvisit=datevisit_pre if dateofvisit=="" & datevisit_pre!=""
drop idreal datevisit_pre datevisit_pos
gen dateofvisit2 = date(dateofvisit, "DMY",2022), after (dateofvisit)  
format dateofvisit2 %td
sort dateofvisit2 dateofvisit
*Recuperar missing con la fecha de creación del registro



//date of birth
replace cbvctidentifier= ustrupper(cbvctidentifier)
replace cobaid= ustrupper(cobaid)
*drop dateofbirth_rec
gen dateofbirth_rec = dateofbirth, after(dateofbirth)


**intentar convertir directament dateofvisit_rec (format text) al format data de Stata*/
replace dateofbirth_rec="" if dateofbirth=="01/01/1901"
gen datbirth_aprox=.
replace datbirth_aprox= 1 if ustrregexm(dateofbirth,"00/")==1
replace dateofbirth_rec= ustrregexrf(dateofbirth_rec, "00", "15") if ustrpos(dateofbirth_rec,"00")<3
replace dateofbirth_rec= ustrregexrf(dateofbirth_rec, "00", "06") if ustrpos(dateofbirth_rec,"00")>3 & ustrpos(dateofbirth_rec,"00")<6

*quitar primeros dos dígitos del año cuando no es compatible
replace dateofbirth_rec= ustrregexra(dateofbirth_rec, "/[0][0-9][0-9][0-9]", "/"+substr(dateofbirth_rec,-2,2)) 
replace dateofbirth_rec= ustrregexra(dateofbirth_rec, "/[1][0-8][0-9][0-9]", "/"+substr(dateofbirth_rec,-2,2)) 

gen dateofbirth2 = date(dateofbirth_rec,"DMY",2010), after(dateofbirth_rec)
format %td dateofbirth2
*Eliminación manual de fechas outliers
sort dateofbirth2 cobaid
replace dateofbirth2=. if dateofbirth2>=date("31/12/2006", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
*revisar fechas límites

*Reemplazar con nva variable a partir de cobaid (código hecho)
generate poscobaid = strpos(cobaid,"-") 
gen str sdayofbirth3 =  substr(cobaid,2,2) 
gen str smonthofbirth3 =  substr(cobaid,5,2) 
gen str syearofbirth3 =  substr(cobaid,8,4) 
replace sdayofbirth3 = substr(cobaid,10,2) if poscobaid==6
replace smonthofbirth3 = substr(cobaid,7,2) if poscobaid==6
replace syearofbirth3 = substr(cobaid,2,4) if poscobaid==6
replace sdayofbirth3 = substr(cobaid,-13,2) if poscobaid>6
replace smonthofbirth3 = substr(cobaid,-10,2) if poscobaid>6
replace syearofbirth3 = substr(cobaid,-7,4) if poscobaid>6

destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
//assignar la nova data generada a partir del cobaid generat automàticament si la data de naixament és missing
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
drop dateofbirth3 poscobaid sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3
sort dateofbirth2 cobaid
*Revisar extremos, el mayor desde 2012
replace dateofbirth2=. if dateofbirth2>=date("31/12/2006", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")

*generar fecha nacimiento desde identificador de la entidad
gen largoid=strlen(cbvctidentifier)
sort dateofbirth2 largoid
gen str sdayofbirth3 =  substr(cbvctidentifier,2,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,6,4) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][a-zA-Z]$")==1
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (446 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3
sort dateofbirth2 cbvctidentifier
*reemplazar manualmente
replace dateofbirth2 = date("20/11/1961","DMY") if id=="C50267"
replace dateofbirth2=. if dateofbirth2>=date("31/12/2006", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")

*Otras recuperaciones desde id de entidad
sort dateofbirth2 largoid
gen str sdayofbirth3 =  substr(cbvctidentifier,1,2) if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-3][0-9][0-1][0-9][0-9][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-3][0-9][0-1][0-9][2-9][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-3][0-9][0-1][0-9][0-1][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (7 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
sort dateofbirth2 largoid
replace dateofbirth2=. if dateofbirth2>=date("31/12/2006", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
*
gen str sdayofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,2) if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-9][0-9][0-1][0-9][0-3][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[2-9][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==6 & dateofbirth2==. & ustrregexm(cbvctidentifier,"[0-1][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (2 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
sort dateofbirth2 largoid
replace dateofbirth2=. if dateofbirth2>=date("31/12/2006", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")

* mirar si, en los casos en que sólo hay año, asignarles fecha nac igual
*
gen str sdayofbirth3 =  substr(cbvctidentifier,2,2) if strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,6,2) if (strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XX[0-1][0-9][0-9][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XXXX[0-9][0-9]$")==1) 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==7 & dateofbirth2==. & (ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][2-9][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XX[0-1][0-9][2-9][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XXXX[2-9][0-9]$")==1)
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==7 & dateofbirth2==. & (ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][0-1][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XX[0-1][0-9][0-1][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XXXX[0-1][0-9]$")==1)
replace syearofbirth3=syearofbirth3a+syearofbirth3
replace datbirth_aprox=1 if (smonthofbirth3=="00" & syearofbirth3!="2000")|(sdayofbirth3=="00" & syearofbirth3!="2000") | (strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XX[0-1][0-9][0-9][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XXXX[0-9][0-9]$")==1)
replace sdayofbirth3="15" if (sdayofbirth3=="00" & syearofbirth3!="2000")|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XX[0-1][0-9][0-9][0-9]$")==1)|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XXXX[0-9][0-9]$")==1)
replace smonthofbirth3="06" if (smonthofbirth3=="00" & syearofbirth3!="2000")|(strlen(cbvctidentifier)==7 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z]XXXX[0-9][0-9]$")==1)
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (10.666 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
* 
gen str sdayofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[2-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-1][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (41 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][2-9][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-1][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (8 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][2-9][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-1][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (36 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* DDMMYYYY
gen str sdayofbirth3 =  substr(cbvctidentifier,1,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,5,4) if strlen(cbvctidentifier)==8 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (3 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

*
gen str sdayofbirth3 =  substr(cbvctidentifier,2,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,6,4) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (30 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,8,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,6,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][2-9][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-1][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (59 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,6,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,8,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][2-9][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-1][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (18 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,2,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-2][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-2][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,6,4) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-2][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (7 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
* 
gen str sdayofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,2) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[2-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-1][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (1 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
replace datbirth_aprox=1 if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str sdayofbirth3 = "15" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 = "06" if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,4) if strlen(cbvctidentifier)==9 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (7 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,3,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,7,4) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (22 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,9,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][2-9][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-1][0-9][0-1][0-9][0-3][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (5 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid
*
gen str sdayofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,9,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-9][0-9]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][2-9][0-9]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][0-1][0-9]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (2 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

*
gen str sdayofbirth3 =  substr(cbvctidentifier,9,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,6,2) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,4) if strlen(cbvctidentifier)==10 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (3 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* 3 letras y fecha DDMMYYYY
gen str sdayofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==11 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,6,2) if strlen(cbvctidentifier)==11 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,8,4) if strlen(cbvctidentifier)==11 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (64 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* YYYMMDD + 3 letras
gen str sdayofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==11 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==11 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,4) if strlen(cbvctidentifier)==11 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (2 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* 4 letras + DDMMYYY
gen str sdayofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,9,4) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (52 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* n+ DDMMYYY + nn + letra
gen str sdayofbirth3 =  substr(cbvctidentifier,2,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9][0-9][0-9][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9][0-9][0-9][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,6,4) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[0-9][0-3][0-9][0-1][0-9][1-2][0-9][0-9][0-9][0-9][0-9][a-zA-Z]$")==1 
*cambiar manualmente dçias incorrectos (ie: 31/09)
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (17 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* YYYYMMDD+ 4 letras
gen str sdayofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,4) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (3 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

*4 letras +YYMMDD + 2 letras
gen str sdayofbirth3 =  substr(cbvctidentifier,9,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1 
gen str syearofbirth3a = "19" if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][2-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
replace syearofbirth3a = "20" if strlen(cbvctidentifier)==12 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][0-1][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z]$")==1
replace syearofbirth3=syearofbirth3a+syearofbirth3
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (3 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 syearofbirth3a
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

*13
* YYYYMMDD+ 5 letras
gen str sdayofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==13 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,5,2) if strlen(cbvctidentifier)==13 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,4) if strlen(cbvctidentifier)==13 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (161 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

* AAA DD/MM/YYYY 
gen str sdayofbirth3 =  substr(cbvctidentifier,4,2) if strlen(cbvctidentifier)==13 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,7,2) if strlen(cbvctidentifier)==13 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,10,4) if strlen(cbvctidentifier)==13 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[a-zA-Z][a-zA-Z][a-zA-Z][0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (161 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

*15
* YYYY-MM-DD+ 5 letras
gen str sdayofbirth3 =  substr(cbvctidentifier,9,2) if strlen(cbvctidentifier)==15 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str smonthofbirth3 =  substr(cbvctidentifier,6,2) if strlen(cbvctidentifier)==15 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1
gen str syearofbirth3 =  substr(cbvctidentifier,1,4) if strlen(cbvctidentifier)==15 & dateofbirth2==. & ustrregexm(cbvctidentifier,"^[1-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$")==1 
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
*reemplazar fechas missings (12-1 reemplazos)
replace dateofbirth2=dateofbirth3 if dateofbirth2==.
*borrar variables y ordenar
drop dateofbirth3  sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 
replace dateofbirth2=. if dateofbirth2>=date("31/12/2010", "DMY")
replace dateofbirth2=. if dateofbirth2<date("01/01/1929", "DMY")
sort dateofbirth2 largoid

*** pasar manualmente
do "recup_mannual_dnac.do"


sort dateofbirth2 dateofbirth_rec
codebook dateofbirth2
*867/93089 missings


// mirar repetidores

replace cobaid="" if cobaid=="000-00-000000"|cobaid=="000-00-0000000"|cobaid=="100-00-000000"| ///
	cobaid=="100-00-0000000"|cobaid=="200-00-000000"|cobaid=="200-00-0000000"| ///
	cobaid=="300-00-000000"|cobaid=="300-00-0000000"

sort centros cobaid cbvctidentifier dateofbirth2 gender 
*borrar prueba
drop if centros==5

tab centros gender, m nolab
tab centros dateofbirth2 if dateofbirth2==., m nolab
tab centros cbvctidentifier if cbvctidentifier=="", m nolab
tab centros cobaid if cobaid=="", m nolab
tab cbvctidentifier cobaid if cobaid=="" & cbvctidentifier=="", m nolab


//date of last hiv test
*Pendiente de recuperar variable
* de momento no trabajaremos en fechas, a menos que sea necesario


*recode sw
rename sexworker sw
replace sw=. if sw==0

*recode pwid
rename intravenousdruguse pwid
replace pwid=. if pwid==0

*recode migrant
replace foreignnational=. if foreignnational==0
rename foreignnational migrant


// VAR SALUD
*renombramos
rename testused hivtestused
rename previoussyphilis sypheverdiagnosed
rename syphilistest syphilistest
rename typesyphilistest syphtestused
rename syphilisrapidtestresult syphscreeningtestresult
rename syphilisconfirmation syphconfirmatorytest
rename syphilisdiagnosis syphconfirmatorytestresult
rename previoushcv hcveverdiagnosed
rename hcvtesttype hcvtestused
rename hcvrapidtestresult hcvscreeningtestresult
rename hcvconfirmation hcvrnatest
rename hcvdiagnosis hcvconfirmatorytestresult

*evertested
rename previoushivtest evertested
rename resultlasthivtest resultlasthiv
rename unprotectedsexsw2 unprotectedsw
rename unprotectedsexidu unprotectedidu
rename unprotectedsexhivpositive unprotectedhiv
rename unprotectedsexmsm unprotectedmsm

// más missings
foreach var in evertested resultlasthiv test12monthscbvct condomuse sw sti jail unprotectedsw ///
	unprotectedidu unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	screeningtestresult test_result_received post_test_counselling confirmhivtest confirmhivtestres confirm_hiv_test_res_rec ///
	linkagehealthcare sypheverdiagnosed syphilistest syphscreeningtestresult syphconfirmatorytest syphconfirmatorytestresult ///
	hcveverdiagnosed hcvtest hcvscreeningtestresult hcvconfirmatorytest hcvconfirmatorytestresult ///
	hepavaccination hepbvaccionation{
	replace `var'=. if `var'==3
	}
foreach var in evertested resultlasthiv sexwith unprotectedhiv unprotectedmsm pwid sypheverdiagnosed ///
	hcveverdiagnosed hepavaccination hepbvaccionation{
	replace `var'=. if `var'==9
	}
foreach var in resultlasthiv confirmhivtest confirmhivtestres confirm_hiv_test_res_rec syphtestused ///
	syphscreeningtestresult syphconfirmatorytest hcvtestused hcvscreeningtestresult hcvconfirmatorytest{
	replace `var'=. if `var'==8
	}	
foreach var in sexwith{
	replace `var'=. if `var'==5
	}

// Resultados tests --> poner como + a los que se hicieron convencional y está informado + en confirmatory test result
**VIH
tab screeningtestresult if hivtestused==3,m 
*113 missings
tab confirmhivtestres if hivtestused==3 & screeningtestresult==., m 
*1 negativo
replace screeningtestresult=confirmhivtestres if hivtestused==3 & screeningtestresult==.
**Sifilis
tab syphscreeningtestresult if syphtestused==2,m 
* 1128 missings
tab syphconfirmatorytestresult if syphtestused==2 & syphscreeningtestresult==., m 
*21 pos y 30 neg
replace syphscreeningtestresult=1 if syphtestused==2 & syphscreeningtestresult==. & syphconfirmatorytestresult==1
replace syphscreeningtestresult=2 if syphtestused==2 & syphscreeningtestresult==. & syphconfirmatorytestresult==4
**HepC
tab hcvscreeningtestresult if hcvtestused==3,m 
* 796 missings
tab hcvconfirmatorytestresult if hcvtestused==3 & hcvscreeningtestresult==., m 
* 6 pos y 3 neg
replace hcvscreeningtestresult=1 if hcvtestused==3 & hcvscreeningtestresult==. & hcvconfirmatorytestresult==1
replace hcvscreeningtestresult=2 if hcvtestused==3 & hcvscreeningtestresult==. & hcvconfirmatorytestresult==4


//Variable screening para quitar observaciones que no se han realizado ninguna prueba

*generamos variable screening para quitar registros que no han realizado ningún test
* primero generar variable test vih
*modifiquem la variable hivscreeningtestresult per a incloure tb els positius amb tests convencional
replace screeningtestresult=1 if hivtestused==3 & confirmhivtestres==1
replace screeningtestresult=1 if hivtestused==1 & confirmhivtestres==1 
replace screeningtestresult=1 if hivtestused==2 & confirmhivtestres==1 
replace screeningtestresult=0 if hivtestused==3 & confirmhivtestres==0 
replace screeningtestresult=0 if hivtestused==1 & confirmhivtestres==0 
replace screeningtestresult=0 if hivtestused==2 & confirmhivtestres==0 
replace test_result_received=1 if hivtestused==3 & confirmhivtestres==1 & confirm_hiv_test_res_rec==1
replace test_result_received=0 if hivtestused==3 & confirmhivtestres==1 & confirm_hiv_test_res_rec==0
***Decidir el criteri per a seleccionar els que s'han fet el test de VIH
*Només els que tenten el resultat del test informat, o només els que tenen el tipus de test informat, o la combinació de tots 2 (les 2 variables informades, o alguna de les 2 informades...)?????
*Aquí fem el criteri més inclusiu: que tiguin alguna de les 2 variables informades
gen screeninghivtest=.
replace screeninghivtest=1 if screeningtestresult!=. | hivtestused!=. 
tab screeninghivtest, m
* cambiar resultado test, agregando respuesta "no informado"
replace screeningtestresult=3 if screeninghivtest==1 & screeningtestresult==. 
tab screeningtestresult
replace test_result_received=3 if screeninghivtest==1 & test_result_received==.
replace test_result_received=. if screeninghivtest!=1 
replace post_test_counselling=3 if screeninghivtest==1 & post_test_counselling==.
replace post_test_counselling=. if screeninghivtest!=1 
replace confirmhivtest=3 if screeningtestresult==1 & confirmhivtest==.
replace confirmhivtest=1 if confirmhivtestres<3 & confirmhivtest!=1
replace confirmhivtest=. if screeningtestresult!=1 
replace confirmhivtestres=3 if confirmhivtest==1 & confirmhivtestres==.
replace confirmhivtestres=. if confirmhivtest!= 1
replace confirm_hiv_test_res_rec=3 if confirmhivtest==1 & confirm_hiv_test_res_rec==.
replace confirm_hiv_test_res_rec=. if confirmhivtest!= 1
replace linkagehealthcare=3 if screeningtestresult==1 & linkagehealthcare==.
replace linkagehealthcare=. if screeningtestresult!=1 

* quitamos a los VIH+ previos
foreach var in screeninghivtest screeningtestresult test_result_received confirmhivtest confirmhivtestres confirm_hiv_test_res_rec {
	replace `var'=. if resultlasthiv==1
	}	 
*CD4 --> mirar qué eliminar. Hay números <1 y con decimales
*replace cd4count=real(strltrim(ustrregexra(cd4count,"[a-zA-Z]","")))


**sífilis
*tabulamos y pasamos a missing los "no sé"
replace syphilistest=1 if syphtestused<3 & syphilistest==.
tab syphilistest syphscreeningtestresult, m
* hay 86 registros con test "no realizado" y resultado reportado.
* Usamos criterio más sensible
replace syphilistest=1 if syphscreeningtestresult<3 & syphilistest!=1
replace syphtestused=3 if syphilistest==1 & syphtestused==.
replace syphscreeningtestresult=3 if syphilistest==1 & syphscreeningtestresult==. 
replace syphconfirmatorytest=3 if syphscreeningtestresult==1 & syphconfirmatorytest==.
replace syphconfirmatorytest=1 if syphconfirmatorytestresult<3 & syphconfirmatorytest!=1
replace syphconfirmatorytest=. if syphscreeningtestresult!=1 
replace syphconfirmatorytestresult=3 if syphconfirmatorytest==1 & syphconfirmatorytestresult==.
replace syphconfirmatorytestresult=. if syphconfirmatorytest!= 1


*HCV
tab hcvtest hcvtestused, m
* hay 92 registros con test "no realizado" y tipo de test reportado.
* Usamos criterio más sensible
replace hcvtest=1 if hcvtestused<4 & (hcvtest==2|hcvtest==.)
tab hcvtest hcvscreeningtestresult, m
*igual con el resultado del test (2706 obs)
replace hcvtest=1 if hcvscreeningtestresult<3 & (hcvtest==2|hcvtest==.)
replace hcvtestused=3 if hcvtest==1 & hcvtestused==.
replace hcvscreeningtestresult=3 if hcvtest==1 & hcvscreeningtestresult==. 
replace hcvrnatest=3 if hcvscreeningtestresult==1 & hcvrnatest==.
replace hcvrnatest=1 if hcvconfirmatorytestresult<3 & hcvrnatest!=1
replace hcvrnatest=. if hcvscreeningtestresult!=1 
replace hcvconfirmatorytestresult=3 if hcvrnatest==1 & hcvconfirmatorytestresult==.
replace hcvconfirmatorytestresult=. if hcvrnatest!= 1



** variable screening
gen screening=.
replace screening=1 if (screeninghivtest==1|syphilistest==1|hcvtest==1)
tab screening, m
*401 obs sin ningún test

// Any test +
gen anypos=0
replace anypos=1 if screeningtestresult==1|syphscreeningtestresult==1|hcvscreeningtestresult==1
tab anypos, m

// Confirmados
*vih
gen confirmat_vih=0 if screeningtestresult==1
replace confirmat_vih=1 if confirmhivtestres==1
tab confirmat_vih
*sif
gen confirmat_sif=0 if syphscreeningtestresult==1
replace confirmat_sif=1 if syphconfirmatorytestresult==1
tab confirmat_sif
*vhc
gen confirmat_vhc=0 if hcvscreeningtestresult==1
replace confirmat_vhc=1 if hcvconfirmatorytestresult==1
tab confirmat_vhc



// Variable nueva ID
* Criterios: Si tienen cobaid completo se mantiene; si id propio es fiable y no cobaid, se mantiene id propio; si no cobaid ni id propio confiable, se genera nuevo id
* gender + ddmmyyy + pais (3dig) + cod centro (3 dig)

** Borramos centros con sgte criterio: pocas observaciones + no activos + no Id cobaid
drop if (centros==7|centros==20|centros==84)
** Borramos pruebas opentic
drop if ustrregexm(cbvctidentifier,"OPEN")==1
** Variable gender_cobaid
gen gender_cobaid=(gender-1)
tostring gender_cobaid, replace
replace gender_cobaid="" if gender_cobaid=="."

** centros que usan cobaid
* generar cobaid+genero reportado
gen cobaid2=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-2]","") if (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & gender_cobaid!="" & cobaid!="", after(cobaid)
*si no está reportado género, usar código original del cobaid
	replace cobaid2= strltrim( ustrregexra(cobaid,"-","")) if (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & gender_cobaid=="" & cobaid!=""
*generar variable largo id2 (del cobaid2) para quitar no válidos
gen largoid2=ustrlen(cobaid2) if (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & cobaid!="", after(cobaid2)
sort centros largoid2
*revisar manualmente, los que tienen 11 dígitos se eliminan
replace cobaid2="" if largoid2==11 & ustrregexm(cobaid2, "[A-Z]")!=1
* variable largo id centro
gen largocbvctid=ustrlen(cbvctidentifier)
* primero averiguar cómo reemplazar caracteres especiales con alguna letra o identificar caracteres especiales
replace cobaid2=ustrnormalize( cobaid2, "nfd" )
* borrar si largo cobaid2 es 12, no tiene letra o el formato no es correcto
replace cobaid2="" if ((largoid2==12 & ustrregexm(cobaid2, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")!=1) | ustrregexm(cobaid, "[0-2]00-")==1) & (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) 

*largo cobaid2 mayor a 12 (borrar sólo dígitos extra cuando están al principio)
sort largoid2
replace cobaid2=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-9][0-9]","") if  strpos(cobaid,"-")==5 & largoid2==13  & gender_cobaid!="" & cobaid!=""
*70/70 cambios
replace cobaid2=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-9][0-9][0-9]","") if  strpos(cobaid,"-")==6 & largoid2==14  & gender_cobaid!="" & cobaid!=""
*8/8 cambios
replace cobaid2=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-9][0-9][0-9][0-9]","") if  strpos(cobaid,"-")==7 & largoid2==15  & gender_cobaid!="" & cobaid!=""
*3/3 cambios
replace cobaid2="" if id=="C62871"| id=="C63698"| id=="C90525"| id=="C90056"

*reemplazar cobaid2 cuando el id del centro también es cobaid y está completo
sort cobaid2 largocbvctid
replace cobaid2= gender_cobaid + ustrregexrf(cbvctidentifier,"[0-2]","")  if largocbvctid==12 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & (cobaid2==""|ustrlen(cobaid2)>12) & gender_cobaid!=""
replace cobaid2= cbvctidentifier if largocbvctid==12 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112)  & (cobaid2==""|ustrlen(cobaid2)>12)  & gender_cobaid==""
replace cobaid2= gender_cobaid + ustrregexrf(cbvctidentifier,"[0-2]","")  if largocbvctid==13 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & cobaid2=="" & gender_cobaid!=""
replace cobaid2= gender_cobaid + ustrregexrf(cbvctidentifier,"[0-2]","")  if largocbvctid==14 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & cobaid2=="" & gender_cobaid!=""
replace cobaid2= cbvctidentifier  if largocbvctid==13 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & cobaid2=="" & gender_cobaid==""
replace cobaid2= cbvctidentifier  if largocbvctid==14 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & cobaid2=="" & gender_cobaid==""
*revisar manualmente
drop largoid2
gen largoid2=ustrlen(cobaid2) if (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112) & cobaid!="", after(cobaid2)
sort largoid2
edit if (centros==21|centros==25|centros==27|centros==28|centros==30 ///
	|centros==31|centros==32|centros==33|centros==35|centros==37|centros==48|centros==49|centros==52|centros==55|centros==63|centros==65 ///
	|centros==66|centros==69|centros==72|centros==73|centros==75|centros==90|centros==91|centros==97|centros==101|centros==102|centros==103 ///
	|centros==105|centros==106|centros==107|centros==109|centros==110|centros==111|centros==112)
replace cobaid2="00504199902Y" if id=="C91885"
replace cobaid2="12601199500M" if id=="C3082"
replace cobaid2="00504200100M" if id=="C93915"
replace cobaid2="00705199801P" if id=="C88271"
replace cobaid2="00104198200L" if id=="C92509"
replace cobaid2="01702199401G" if id=="C88519"
replace cobaid2="13102200054Z" if id=="C72003"
replace cobaid2="01411199000A" if id=="C54804"
replace cobaid2="10805199500N" if id=="C87268"
replace cobaid2="12403199816Z" if id=="C70757"
replace cobaid2="11004200354Z" if id=="C71698"
replace cobaid2="10307197911N" if id=="C58428"
replace cobaid2="115091998164Z" if id=="C72217"
replace cobaid2="001031995196Z" if id=="C71546"
replace cobaid2="11909198800B" if id=="C5913"
replace cobaid2="12609198500M" if id=="C4326"
replace cobaid2="02404198512V" if id=="C93264"
replace cobaid2="11806199700D" if id=="C63724"
replace cobaid2="02904199810F" if id=="C85462"
replace cobaid2="00208198501N" if id=="SCS272"

*corregir por fecha de nacimiento reportada
gen real=real(usubstr(cobaid2,6,4))
sort real
replace cobaid2=usubstr(cobaid2,1,5)+ usubstr(dateofbirth,7,4) + usubstr(cobaid2,10,3) if real(usubstr(cobaid2,6,4))> real(usubstr(dateofbirth,7,4)) & ustrlen(cobaid2)==12 & datbirth_aprox!=1
replace cobaid2=usubstr(cobaid2,1,5)+ usubstr(dateofbirth,7,4) + usubstr(cobaid2,10,4) if real(usubstr(cobaid2,6,4))> real(usubstr(dateofbirth,7,4)) & ustrlen(cobaid2)==13 & datbirth_aprox!=1
replace cobaid2=usubstr(cobaid2,1,5)+ usubstr(dateofbirth,7,4) + usubstr(cobaid2,10,5) if real(usubstr(cobaid2,6,4))> real(usubstr(dateofbirth,7,4)) & ustrlen(cobaid2)==14 & datbirth_aprox!=1
replace cobaid2= usubstr(cobaid2,1,5)+ "19" + usubstr(cobaid2,8,12) if ustrregexm(cobaid2, "[0-2][0-3][0-9][0-1][0-9]219[0-9][0-9][0-9][A-Z]")==1 | ustrregexm(cobaid2, "[0-2][0-3][0-9][0-1][0-9]29[0-9][0-9][0-9][0-9][A-Z]")==1 | ustrregexm(cobaid2, "[0-2][0-3][0-9][0-1][0-9][0-1][0-8][0-9][0-9][0-9][0-9][A-Z]")==1 
replace cobaid2= usubstr(cobaid2,1,5)+ "20" + usubstr(cobaid2,8,12) if ustrregexm(cobaid2, "[0-2][0-3][0-9][0-1][0-9]190[0-9][0-9][0-9][A-Z]")==1
drop real


*replace usubstr(cobaid2,6,4)= usubstr(dateofbirth,7,4) if real(usubstr(cobaid2,6,4))> real(usubstr(dateofbirth,7,4)) & dateofbirth!="" & cobaid2!=""
	
** centros que no usan cobaid
*obs con cobaid en el id propio
gen cobaid3= gender_cobaid + ustrregexrf(cbvctidentifier,"[0-2]","")  if largocbvctid==12 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid!="", after(cobaid2)
replace cobaid3= cbvctidentifier  if largocbvctid==12 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid==""
replace cobaid3= gender_cobaid + ustrregexrf(cbvctidentifier,"[0-2]","")  if largocbvctid==13 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid!=""  & cobaid3=="" & ustrlen(cobaid)!=14
replace cobaid3= gender_cobaid + ustrregexrf(cbvctidentifier,"[0-2]","")  if largocbvctid==14 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid!=""  & cobaid3=="" & ustrlen(cobaid)!=14
replace cobaid3= cbvctidentifier  if largocbvctid==13 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid=="" & cobaid3=="" & ustrlen(cobaid)!=14
replace cobaid3= cbvctidentifier  if largocbvctid==14 & ustrregexm(cbvctidentifier, "[0-2][0-3][0-9][0-1][0-9][0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1  ///
	& (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid=="" & cobaid3=="" & ustrlen(cobaid)!=14
* mirar manualmente si largo id3>12 para ver si corregir código cuando dígitos extras están al principio o en el año de nacimiento
gen largoid3= ustrlen(cobaid3)
sort largoid3
replace cobaid3="01605197000A" if id=="C13837"
replace cobaid3="11201198500A" if id=="C15477"
replace cobaid3="10110199001M" if id=="C63847"
replace cobaid3="00810198501M" if id=="C9480"
replace cobaid3="10109198300C" if id=="C6954"
replace cobaid3="10601199100M" if id=="SCS59"
replace cobaid3="11601199010A" if id=="C6951"
replace cobaid3="12708199920D" if id=="C50711"
replace cobaid3="12506197400E" if id=="C36739"
replace cobaid3="00111197511M" if id=="C63453"
replace cobaid3="" if id=="C74924"
replace cobaid3="03010196401C" if id=="C95869"
replace cobaid3="00151199900P" if id=="C89434"
replace cobaid3="00408197011M" if id=="C77774"
replace cobaid3="10505197711M" if id=="C6693"
replace cobaid3="10810197810A" if id=="C12710"
replace cobaid3="21406196710I" if id=="C13021"
replace cobaid3="02101199000S" if id=="C32188"
replace cobaid3="00704198600A" if id=="C11102"
replace cobaid3="01503198100V" if id=="C31940"
replace cobaid3="00607197610G" if id=="C5265"
replace cobaid3="00909199200A" if id=="C29144"
replace cobaid3="01604199820P" if id=="C53047"
replace cobaid3="02812198111J" if id=="C49904"
replace cobaid3="00103199200A" if id=="C52315"
replace cobaid3="00305194400G" if id=="C7070"
replace cobaid3="00104198103P" if id=="C10046"
replace cobaid3="00108196401N" if id=="C13830"
replace cobaid3="02809198602M" if id=="C52637"
replace cobaid3="11801199510E" if id==" C49725"
replace cobaid3="02411199301C" if id=="C49034"
replace cobaid3="13009198900M" if id=="C5552"
replace cobaid3="11109198610M" if id=="C5975"
replace cobaid3="00201197900E" if id=="C4609"
replace cobaid3="00407198801M" if id=="C53280"
replace cobaid3="01206198900K" if id=="C4407"
replace cobaid3="02009198910M" if id=="C3794"
replace cobaid3="11311197802M" if id=="C7907"
replace cobaid3="00410194400A" if id=="C6003"
replace cobaid3="10108199110S" if id=="C23516"
replace cobaid3="02505197200I" if id=="C8987"
replace cobaid3="02504196711F" if id=="C65078"
replace cobaid3="11905198802A" if id=="C63472"
replace cobaid3="01002196010M" if id=="C27719"
replace cobaid3="02507198100T" if id=="C24956"
replace cobaid3="01002196010M" if id=="C24836"
replace cobaid3="00307197600L" if id=="C25197"
replace cobaid3="01205198710S" if id=="C21920"
replace cobaid3="01004200000M" if id=="C61485"
replace cobaid3="11206198010M" if id=="C31861"
replace cobaid3="01509197400W" if id=="C78711"
drop largoid3

* mismo sujeto pero código diferente
replace cobaid3="206011991100M" if id=="C66888"
replace cobaid="001-03-1988812A" if id=="C61958"
*obs con cobaid completo
*mirar largo cobaid
sort cobaid3 cobaid2 cobaid largoid
replace cobaid3=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-2]","") if (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid!="" & cobaid!="" & ustrregexm(cobaid, "[0-2][0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")==1 ///
	 & cobaid3=="" & ustrregexm(cobaid, "[0-2]00-")!=1
replace cobaid3=  strltrim( ustrregexra(cobaid,"-","")) if (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid=="" & cobaid!="" & ustrregexm(cobaid, "[0-2][0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9][0-9][0-9][A-Z]")==1 ///
	 & cobaid3=="" & ustrregexm(cobaid, "[0-2]00-")!=1
replace cobaid3=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-2]","") if (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid!="" & cobaid!="" & ustrregexm(cobaid, "[0-2][0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1 ///
	 & cobaid3=="" & ustrregexm(cobaid, "[0-2]00-")!=1
replace cobaid3=  strltrim( ustrregexra(cobaid,"-","")) if (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid=="" & cobaid!="" & ustrregexm(cobaid, "[0-2][0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1 ///
	 & cobaid3=="" & ustrregexm(cobaid, "[0-2]00-")!=1
replace cobaid3=  gender_cobaid + ustrregexrf(strltrim( ustrregexra(cobaid,"-","")),"[0-2]","") if (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid!="" & cobaid!="" & ustrregexm(cobaid, "[0-2][0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1 ///
	 & cobaid3=="" & ustrregexm(cobaid, "[0-2]00-")!=1
replace cobaid3=  strltrim( ustrregexra(cobaid,"-","")) if (centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100) & gender_cobaid=="" & cobaid!="" & ustrregexm(cobaid, "[0-2][0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]")==1 ///
	 & cobaid3=="" & ustrregexm(cobaid, "[0-2]00-")!=1
* mirar manualmente si largo id3>12 para ver si corregir código cuando dígitos extras están al principio
gen largoid3= ustrlen(cobaid3)
sort largoid3
edit if centros==6|centros==7|centros==18|centros==19|centros==20 ///
	|centros==22|centros==23|centros==26|centros==29|centros==34|centros==36|centros==40|centros==42|centros==43|centros==50|centros==51 ///
	|centros==54|centros==59|centros==64|centros==67|centros==77|centros==79|centros==80|centros==82|centros==83|centros==84|centros==86 ///
	|centros==87|centros==98|centros==100	
edit id cbvctidentifier cobaid cobaid3 centros gender dateofbirth dateofbirth2 countryofbirth largoid3 
*reemplazo fecha nac
gen real=real(usubstr(cobaid3,6,4))
sort real
replace cobaid3=usubstr(cobaid3,1,5)+ usubstr(dateofbirth,7,4) + usubstr(cobaid3,10,3) if real(usubstr(cobaid3,6,4))> real(usubstr(dateofbirth,7,4)) & ustrlen(cobaid3)==12 & datbirth_aprox!=1
replace cobaid3=usubstr(cobaid3,1,5)+ usubstr(dateofbirth,7,4) + usubstr(cobaid3,10,4) if real(usubstr(cobaid3,6,4))> real(usubstr(dateofbirth,7,4)) & ustrlen(cobaid3)==13 & datbirth_aprox!=1
replace cobaid3=usubstr(cobaid3,1,5)+ usubstr(dateofbirth,7,4) + usubstr(cobaid3,10,5) if real(usubstr(cobaid3,6,4))> real(usubstr(dateofbirth,7,4)) & ustrlen(cobaid3)==14 & datbirth_aprox!=1
replace cobaid3= usubstr(cobaid3,1,5)+ "19" + usubstr(cobaid3,8,12) if ustrregexm(cobaid3, "[0-2][0-3][0-9][0-1][0-9]09[0-9][0-9][0-9][0-9][A-Z]")==1 | ustrregexm(cobaid3, "[0-2][0-3][0-9][0-1][0-9]1[0-8][0-9][0-9][0-9][0-9][A-Z]")==1 
drop real
	
	
	
** Recuperación de missings (se hará por cada centro)
*6..CBVCTIDENTIFIER 
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==6
codebook gender if centros==6
codebook countryofbirth if centros==6
codebook dateofbirth2 if centros==6
* 72 missings
by cbvctidentifier, sort: gen rep=_N if centros ==6 & ustrregexm(cbvctidentifier, "000")!=1 & largocbvctid>6  & ustrregexm(cbvctidentifier, "[A-Z][A-Z]")!=1
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 11 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep cbvctidentifier
sort centros cbvctidentifier countryofbirth
bysort cbvctidentifier (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
replace countryofbirth=count_1 if countryofbirth==.
*668 recuperaciones
codebook countryofbirth if centros==6
drop  count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*1 recuperaciones
drop rep fechanac_1


*18.. COBAID3
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==18
codebook cobaid3 if centros==18
codebook gender if centros==18
codebook countryofbirth if centros==18
codebook dateofbirth2 if centros==18
*- cobaid3 es el mismo cobaid
by cobaid3, sort: gen rep=_N if centros ==18 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 1 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
*37 recuperaciones
codebook countryofbirth if centros==18
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*no recuperaciones
drop rep fechanac_1


*19..CBVCTIDENTIFIER 
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==19
codebook gender if centros==19
codebook countryofbirth if centros==19
codebook dateofbirth2 if centros==19
by cbvctidentifier, sort: gen rep=_N if centros ==19 & cbvctidentifier!="" & ustrlen(cbvctidentifier)>5
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth cbvctidentifier
sort centros countryofbirth rep  cbvctidentifier 
sort centros cbvctidentifier countryofbirth
bysort cbvctidentifier (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros cbvctidentifier countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
*1 recuperaciones
codebook countryofbirth if centros==19
drop  count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier 
sort centros cbvctidentifier dateofbirth2 
bysort cbvctidentifier (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*0 recuperaciones
codebook dateofbirth2 if centros==19
drop rep fechanac_1

*21.. COBAID2
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==21
codebook gender if centros==21
codebook countryofbirth if centros==21
codebook dateofbirth2 if centros==21
by cobaid2, sort: gen rep=_N if centros ==21 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
*1 recuperaciones
codebook countryofbirth if centro==21
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* recuperaciones
drop rep fechanac_1

*22..CBVCTIDENTIFIER
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==22
codebook gender if centros==22
codebook countryofbirth if centros==22
codebook dateofbirth2 if centros==22
by cbvctidentifier, sort: gen rep=_N if centros ==22 & cbvctidentifier!="" & ustrlen(cbvctidentifier)>5  
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*23.. COBAID3
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==23
codebook cobaid3 if centros==23
codebook gender if centros==23
codebook countryofbirth if centros==23
codebook dateofbirth2 if centros==23
*- cobaid3... cbvctidentifier no repetidor, es número correlativo
by cobaid3, sort: gen rep=_N if centros ==23 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*25.. COBAID2
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==25
codebook gender if centros==25
codebook countryofbirth if centros==25
codebook dateofbirth2 if centros==25
by cobaid2, sort: gen rep=_N if centros ==25 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 2 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
*25 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*26.. COBAID3
edit cbvctidentifier cobaid2 cobaid3 gender dateofbirth2 countryofbirth if centros==26
codebook cobaid3 if centros==26
codebook gender if centros==26
codebook countryofbirth if centro==26
codebook dateofbirth2 if centros==26
*- cobaid3 = cbvctidentifier 
by cobaid3, sort: gen rep=_N if centros ==26 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 6 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
*56 recuperaciones
codebook countryofbirth if centros==26
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1



*27.. reemplazar cobaid2 por el mismo según id propio, se ha visto mismo patrón según Nº del id propio, y varía algún dígito. Pero es mismo usuario
edit id cbvctidentifier cobaid2 centros gender dateofbirth2 countryofbirth if centros ==27
codebook cobaid2 if centros==27
*184 m
codebook gender if centros==27
codebook countryofbirth if centros==27
codebook dateofbirth2 if centros==27
*- cobaid2
replace cobaid2="" if id=="C42714"
replace cobaid2="" if id=="C13824"
replace cbvctidentifier="76735-1" if id=="C9026"
gen cbvctidentifier2=cbvctidentifier, after(cbvctidentifier)
replace cbvctidentifier2= ustrtrim(subinstr(cbvctidentifier2, "AD","",1)) if centros==27 &  ustrlen(cbvctidentifier2)<11
replace cbvctidentifier2= ustrtrim(subinstr(cbvctidentifier2, "AH","",1)) if centros==27 &  ustrlen(cbvctidentifier2)<11
replace cbvctidentifier2= ustrtrim(subinstr(cbvctidentifier2, "CA","",1)) if centros==27 &  ustrlen(cbvctidentifier2)<11
replace cbvctidentifier2= ustrtrim(subinstr(cbvctidentifier2, "NIT","",1)) if centros==27 &  ustrlen(cbvctidentifier2)<11
sort centros cbvctidentifier2
by cbvctidentifier2, sort: gen rep=_N if centros ==27 & cbvctidentifier2!="" 
gsort centros  rep  cbvctidentifier2
gsort centros cbvctidentifier2 cobaid2
bysort cbvctidentifier2 (cobaid2): gen cobaid_1=cobaid2[_N] if rep!=., after (cobaid2)
gsort centros rep cbvctidentifier2  -cobaid2
replace cobaid2=cobaid_1 if centros ==27 & cobaid2==""
* 94 RECUPERACIONES 
drop  cobaid_1 cbvctidentifier2 rep
*
by cobaid2, sort: gen rep=_N if centros ==27 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 2 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 4 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 5 recuperaciones
drop rep fechanac_1

*28.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==28
codebook cobaid2 if centros==28
codebook gender if centros==28
codebook countryofbirth if centros==28
codebook dateofbirth2 if centros==28
by cobaid2, sort: gen rep=_N if centros ==28 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 1 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 4 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*29.. COBAID3
edit id cobaid3 centros gender dateofbirth2 countryofbirth if centros ==29
codebook cobaid3 if centros==29
codebook gender if centros==29
codebook countryofbirth if centros==29
codebook dateofbirth2 if centros==29
by cobaid3, sort: gen rep=_N if centros ==29 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*30.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==30
codebook cobaid2 if centros==30
codebook gender if centros==30
codebook countryofbirth if centros==30
codebook dateofbirth2 if centros==30
*- cobaid2
sort centros cobaid2 cbvctidentifier
by cbvctidentifier, sort: gen rep=_N if centros ==30 & cbvctidentifier!="" & ustrlen(cbvctidentifier)>5
gsort centros -cobaid2 rep  cbvctidentifier 
gsort centros cbvctidentifier cobaid2
bysort cbvctidentifier (cobaid2): gen cobaid_1=cobaid2[_N] if rep!=.
gsort centros cbvctidentifier -cobaid2
replace cobaid2=cobaid_1 if cobaid2==""
* 22 reemplazos
drop  cobaid_1 rep
by cobaid2, sort: gen rep=_N if centros ==30 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 13 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*31.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==31
codebook cobaid2 if centros==31
codebook gender if centros==31
codebook countryofbirth if centros==31
codebook dateofbirth2 if centros==31
*- cobaid2 NO RECUPERABLE
by cobaid2, sort: gen rep=_N if centros ==31 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 3 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*32..COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==32
codebook cobaid2 if centros==32
codebook gender if centros==32
codebook countryofbirth if centros==32
codebook dateofbirth2 if centros==32
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==32 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 6 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 26 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*33.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==33
codebook cobaid2 if centros==33
codebook gender if centros==33
codebook countryofbirth if centros==33
codebook dateofbirth2 if centros==33
*- cobaid2
sort centros cobaid2 cbvctidentifier
by cbvctidentifier, sort: gen rep=_N if centros ==33 & cbvctidentifier!="" 
gsort centros -cobaid2 rep  cbvctidentifier 
gsort centros cbvctidentifier cobaid2
bysort cbvctidentifier (cobaid2): gen cobaid_1=cobaid2[_N] if rep!=.
replace cobaid2=cobaid_1 if cobaid2==""
* 4 reemplazos
drop  cobaid_1 rep
by cobaid2, sort: gen rep=_N if centros ==33 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*34.. COBAID3
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==34
codebook cobaid3 if centros==34
codebook gender if centros==34
codebook countryofbirth if centros==34
codebook dateofbirth2 if centros==34
*- cobaid3 igual que id centro
by cobaid3, sort: gen rep=_N if centros ==34 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 1 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 47 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
replace cobaid3="02001197700M" if id=="C40761"
replace dateofbirth2=date("20/01/1977", "DMY") if id=="C40761"
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1 


*35.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==35
codebook cobaid2 if centros==35
codebook gender if centros==35
codebook countryofbirth if centros==35
codebook dateofbirth2 if centros==35
*- cobaid2
sort centros cobaid2 cbvctidentifier
* no recup
by cobaid2, sort: gen rep=_N if centros ==35 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 2 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 9 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*36.. COBAID3 cbvctidentifier
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==36
codebook cobaid3 if centros==36
codebook gender if centros==36
codebook countryofbirth if centro==36
codebook dateofbirth2 if centros==36
*- cobaid3
sort centros cobaid3 cbvctidentifier
by cbvctidentifier, sort: gen rep=_N if centros ==36 & cbvctidentifier!="" & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1
gsort centros -cobaid3 rep  cbvctidentifier 
gsort centros cbvctidentifier cobaid3
bysort cbvctidentifier (cobaid3): gen cobaid_1=cobaid3[_N] if rep!=.
replace cobaid3=cobaid_1 if cobaid3==""
* 54 reemplazos
drop rep cobaid_1 
by cbvctidentifier, sort: gen rep=_N if centros ==36 & cbvctidentifier!="" & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*37.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==37
codebook cobaid2 if centros==37
codebook gender if centros==37
codebook countryofbirth if centros==37
codebook dateofbirth2 if centros==37
*- cobaid2
sort centros cobaid2 cbvctidentifier
* no recup
by cobaid2, sort: gen rep=_N if centros ==37 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 1 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 21 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*40.. COBAID3
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==40
codebook cobaid3 if centros==40
codebook gender if centros==40
codebook countryofbirth if centros==40
codebook dateofbirth2 if centros==40
*- cobaid3 no recup
by cobaid3, sort: gen rep=_N if centros ==40 & cobaid3!=""
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
*  recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*  recuperaciones
drop rep fechanac_1



*42.. COBAID3
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==42
codebook cobaid3 if centros==42
codebook gender if centros==42
codebook countryofbirth if centros==42
codebook dateofbirth2 if centros==42
*- cobaid3: no recup
by cobaid3, sort: gen rep=_N if centros ==42 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 4 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 4 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*43.. CBVCTIDENTIFIER 
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==43
codebook cbvctidentifier if centros==43
codebook gender if centros==43
codebook countryofbirth if centro==43
codebook dateofbirth2 if centros==43
by cbvctidentifier, sort: gen rep=_N if centros ==43 & cbvctidentifier!="" 
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier 
sort centros cbvctidentifier countryofbirth
bysort cbvctidentifier (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 5 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier 
sort centros cbvctidentifier dateofbirth2
bysort cbvctidentifier (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*0 recuperaciones
drop rep fechanac_1


*48.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==48
codebook cobaid2 if centros==48
codebook gender if centros==48
codebook countryofbirth if centros==48
codebook dateofbirth2 if centros==48
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==48 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*49.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==49
codebook cobaid2 if centros==49
codebook gender if centros==49
codebook countryofbirth if centros==49
codebook dateofbirth2 if centros==49
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==49 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*50.. No hay id
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==50
codebook gender if centros==50
* 0 miss
codebook countryofbirth if centro==50
* 66 miss
codebook dateofbirth2 if centros==50
* 3 miss


*51.. COBAID3
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==51
codebook cobaid3 if centros==51
codebook gender if centros==51
codebook countryofbirth if centro==51
codebook dateofbirth2 if centros==51
*- cobaid3
sort centros cobaid3 cbvctidentifier
by cbvctidentifier, sort: gen rep=_N if centros ==51 & cbvctidentifier!="" &  ustrlen(cbvctidentifier)>8 & ustrregexm(cbvctidentifier, "[A-Z]")==1
gsort centros -cobaid3 rep  cbvctidentifier 
gsort centros cbvctidentifier cobaid3
bysort cbvctidentifier (cobaid3): gen cobaid_1=cobaid3[_N] if rep!=.
replace cobaid3=cobaid_1 if cobaid3==""
* 5 reemplazos
drop rep cobaid_1 
by cobaid3, sort: gen rep=_N if centros ==51 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1



*52.. CBVCTIDENTIFIER 
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==52
codebook cobaid2 if centros==52
codebook gender if centros==52
codebook countryofbirth if centros==52
codebook dateofbirth2 if centros==52
*- cobaid2
sort centros cobaid2 cbvctidentifier
gen cbvctidentifier2= real(ustrtrim(usubinstr(ustrleft(cbvctidentifier,3),"-","",1))) if ustrlen(cbvctidentifier)>3 & centros==52
gen cbvctidentifier2b= real(usubinstr(ustrright(ustrtrim(cbvctidentifier),4),"-","",1)) if ustrlen(cbvctidentifier)>3 & centros==52
replace cbvctidentifier2b= real(usubinstr(ustrright(ustrtrim(cbvctidentifier),4),")","",1)) if ustrlen(cbvctidentifier)>3 & centros==52 & cbvctidentifier2b==.
replace cbvctidentifier2b= real(usubinstr(ustrright(ustrtrim(cbvctidentifier),3),")","",1)) if ustrlen(cbvctidentifier)>3 & centros==52 & cbvctidentifier2b==.
replace cbvctidentifier2b= real(usubinstr(ustrright(ustrtrim(cbvctidentifier),2),")","",1)) if ustrlen(cbvctidentifier)>3 & centros==52 & cbvctidentifier2b==.
replace cbvctidentifier2=cbvctidentifier2b if cbvctidentifier2>cbvctidentifier2b & cbvctidentifier2b!=.
replace cbvctidentifier=strofreal(cbvctidentifier2) if cbvctidentifier2!=. & centros==52
by cbvctidentifier, sort: gen rep=_N if centros ==52 & cbvctidentifier!=""
gsort centros -cobaid2 rep  cbvctidentifier 
bysort cbvctidentifier (cobaid2): gen cobaid_1=cobaid2[_N] if rep!=.
replace cobaid2=cobaid_1 if cobaid2==""
* 256 recuperaciones
drop rep cobaid_1 cbvctidentifier2 cbvctidentifier2b
by cbvctidentifier, sort: gen rep=_N if centros ==52 & cbvctidentifier!=""
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 2 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 17 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 16 recuperaciones
drop rep fechanac_1


*54.. no hay id
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==54
codebook gender if centros==54
* 0 miss
codebook countryofbirth if centros==54
* 10 miss
codebook dateofbirth2 if centros==54
* 7 miss


*55.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==55
codebook cobaid2 if centros==55
codebook gender if centros==55
codebook countryofbirth if centros==55
codebook dateofbirth2 if centros==55
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==55 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*59.. CBVCTIDENTIFIER 
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==59
codebook cobaid2 if centros==59
codebook gender if centros==59
codebook countryofbirth if centros==59
codebook dateofbirth2 if centros==59
by cbvctidentifier, sort: gen rep=_N if centros ==59 & cbvctidentifier!=""
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
*  recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier 
sort centros cbvctidentifier countryofbirth
bysort cbvctidentifier (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier
sort centros cbvctidentifier dateofbirth2
bysort cbvctidentifier (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*2 recuperaciones
drop rep fechanac_1


*63.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==63
codebook cobaid2 if centros==63
codebook gender if centros==63
codebook countryofbirth if centros==63
codebook dateofbirth2 if centros==63
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==63 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*64.. COBAID3
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==64
codebook cobaid3 if centros==64
codebook gender if centros==64
codebook countryofbirth if centros==64
codebook dateofbirth2 if centros==64
*- cobaid3 no miss
by cobaid3, sort: gen rep=_N if centros ==64 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*65.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==65
codebook cobaid2 if centros==65
codebook gender if centros==65
codebook countryofbirth if centros==65
codebook dateofbirth2 if centros==65
*- cobaid2
by cbvctidentifier, sort: gen rep=_N if centros ==65 & cbvctidentifier!="" &  ustrlen(cbvctidentifier)>3 & ustrregexm(cbvctidentifier, "[A-Z]")==1
gsort centros cobaid2 rep  cbvctidentifier
gsort centros cbvctidentifier cobaid2
bysort cbvctidentifier (cobaid2): gen cobaid_1=cobaid2[_N] if rep!=., after (cobaid2)
gsort centros rep cbvctidentifier  -cobaid2
replace cobaid2=cobaid_1 if centros ==65 & cobaid2==""
*0 recup
drop  cobaid_1 rep
by cobaid2, sort: gen rep=_N if centros ==65 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*66.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==66
codebook cobaid2 if centros==66
codebook gender if centros==66
codebook countryofbirth if centros==66
codebook dateofbirth2 if centros==66
*- cobaid2: cbvctidentifier no único
gsort centros  cbvctidentifier cobaid2
by cobaid2, sort: gen rep=_N if centros ==66 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 1 recuperaciones
drop rep fechanac_1


*67.. COBAID3 cbvctidentifier
edit id cbvctidentifier cobaid3  gender dateofbirth2 countryofbirth if centros ==67
codebook cbvctidentifier  if centros==67
codebook gender if centros==67
codebook countryofbirth if centros==67
codebook dateofbirth2 if centros==67
*- cobaid3
gen cbvctidentifier2= usubinstr(usubinstr(usubinstr(cbvctidentifier," ","",5),"-","",5),"/","",2) if ustrlen(cbvctidentifier)>3 & centros==67 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1
by cbvctidentifier2, sort: gen rep=_N if centros ==67 & cbvctidentifier2!="" 
gsort centros cobaid3 rep  cbvctidentifier2
gsort centros cbvctidentifier2 cobaid3
bysort cbvctidentifier2 (cobaid3): gen cobaid_1=cobaid3[_N] if rep!=., after (cobaid3)
gsort centros rep cbvctidentifier2  -cobaid3
replace cobaid3=cobaid_1 if centros ==67 & cobaid3==""
* 3 recuperaciones
drop cobaid_1 
*- gender
sort centros gender rep  cbvctidentifier2  
sort centros cbvctidentifier2  gender
bysort cbvctidentifier2  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier2  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier2  
sort centros cbvctidentifier2  countryofbirth
bysort cbvctidentifier2  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier2  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 5 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier2  
sort centros cbvctidentifier2  dateofbirth2
bysort cbvctidentifier2  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier2  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1 cbvctidentifier2


*69.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==69
codebook cobaid2 if centros==69
codebook gender if centros==69
codebook countryofbirth if centros==69
codebook dateofbirth2 if centros==69
*- cobaid2: id propio no único
by cobaid2, sort: gen rep=_N if centros ==69 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 12 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*72, 73, 75.. COBAID2
edit id centros cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==72 | centros ==73 |centros ==75
codebook cobaid2 if centros ==72 | centros ==73 |centros ==75
codebook gender if centros ==72 | centros ==73 |centros ==75
codebook countryofbirth if centros ==72 | centros ==73 |centros ==75
codebook dateofbirth2 if centros ==72 | centros ==73 |centros ==75
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if (centros ==72 | centros ==73 |centros ==75) & cobaid2!="" 
*- gender
sort gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 5 recuperaciones
drop gend_1
*- pais nacimiento
sort countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 41 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*77.. COBAID3 cbvctidentifier
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==77
codebook cobaid3 if centros==77
codebook gender if centros==77
codebook countryofbirth if centros==77
codebook dateofbirth2 if centros==77
*- cobaid3
by cbvctidentifier, sort: gen rep=_N if centros ==77 & cbvctidentifier!="" 
gsort centros cobaid3 rep  cbvctidentifier
gsort centros cbvctidentifier cobaid3
bysort cbvctidentifier (cobaid3): gen cobaid_1=cobaid3[_N] if rep!=., after (cobaid3)
gsort centros rep cbvctidentifier  -cobaid3
replace cobaid3=cobaid_1 if centros ==77 & cobaid3==""
* 0 recuperaciones
drop  cobaid_1
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*79.. CBVCTIDENTIFIER 
edit id cbvctidentifier  gender dateofbirth2 countryofbirth if centros ==79
codebook cbvctidentifier  if centros==79
codebook gender if centros==79
codebook countryofbirth if centros==79
codebook dateofbirth2 if centros==79
by cbvctidentifier, sort: gen rep=_N if centros ==79 & cbvctidentifier!="" & ustrlen(cbvctidentifier)>5 
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*80.. 
edit id cbvctidentifier cbvctidentifier  gender dateofbirth2 countryofbirth if centros ==80
codebook cbvctidentifier  if centros==80
codebook gender if centros==80
codebook countryofbirth if centros==80
codebook dateofbirth2 if centros==80
by cbvctidentifier, sort: gen rep=_N if centros ==80 & cbvctidentifier!="" & ustrregexm(cbvctidentifier, "XX")!=1 
*no repetidores
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*82.. CBVCTIDENTIFIER 
edit id cbvctidentifier cbvctidentifier  gender dateofbirth2 countryofbirth if centros ==82
codebook cbvctidentifier  if centros==82
codebook gender if centros==82
codebook countryofbirth if centros==82
codebook dateofbirth2 if centros==82
by cbvctidentifier, sort: gen rep=_N if centros ==82 & cbvctidentifier!="" & ustrregexm(cbvctidentifier, "XX")!=1 
*no repetidores
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*83.. CBVCTIDENTIFIER 
edit id cbvctidentifier cbvctidentifier  gender dateofbirth2 countryofbirth if centros ==83
codebook cbvctidentifier  if centros==83
codebook gender if centros==83
codebook countryofbirth if centros==83
codebook dateofbirth2 if centros==83
by cbvctidentifier, sort: gen rep=_N if centros ==83 & cbvctidentifier!="" & ustrregexm(usubinstr(cbvctidentifier," ","",5), "XX")!=1 & ustrregexm(usubinstr(cbvctidentifier," ","",5), "00000")!=1 & ustrlen(cbvctidentifier)>5 
*no repetidores
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*86.. COBAID3 cbvctidentifier
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==86
codebook cobaid3 if centros==86
codebook gender if centros==86
codebook countryofbirth if centros==86
codebook dateofbirth2 if centros==86
*- cobaid3
gen cbvctidentifier2= usubinstr(usubinstr(usubinstr(cbvctidentifier," ","",5),"-","",5),"/","",2) if ustrlen(cbvctidentifier)>3 & centros==67 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1 & ustrregexm(cbvctidentifier, "XX")!=1 & ustrregexm(cbvctidentifier, "PSIDA")!=1 
by cbvctidentifier2, sort: gen rep=_N if centros ==86 & cbvctidentifier2!="" 
gsort centros cobaid3 rep  cbvctidentifier2
gsort centros cbvctidentifier2 cobaid3
bysort cbvctidentifier2 (cobaid3): gen cobaid_1=cobaid3[_N] if rep!=., after (cobaid3)
gsort centros rep cbvctidentifier2  -cobaid3
replace cobaid3=cobaid_1 if centros ==86 & cobaid3==""
* 0 recuperaciones
drop  cobaid_1 
*- gender
sort centros gender rep  cbvctidentifier2  
sort centros cbvctidentifier2  gender
bysort cbvctidentifier2  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier2  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier2  
sort centros cbvctidentifier2  countryofbirth
bysort cbvctidentifier2  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier2  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier2  
sort centros cbvctidentifier2  dateofbirth2
bysort cbvctidentifier2  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier2  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*87.. CBVCTIDENTIFIER 
edit id cbvctidentifier  gender dateofbirth2 countryofbirth if centros ==87
codebook cbvctidentifier  if centros==87
codebook gender if centros==87
codebook countryofbirth if centros==87
codebook dateofbirth2 if centros==87
by cbvctidentifier, sort: gen rep=_N if centros ==87 & cbvctidentifier!="" & ustrregexm(cbvctidentifier, "ANON")!=1 
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
*8 recuperaciones
drop rep fechanac_1


*90.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==90
codebook cobaid2 if centros==90
codebook gender if centros==90
codebook countryofbirth if centros==90
codebook dateofbirth2 if centros==90
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==90 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1



*91.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==91
codebook cobaid2 if centros==91
codebook gender if centros==91
codebook countryofbirth if centros==91
codebook dateofbirth2 if centros==91
by cobaid2, sort: gen rep=_N if centros ==91 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*97.. COBAID2 
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==97
codebook cobaid2 if centros==97
codebook gender if centros==97
codebook countryofbirth if centros==97
codebook dateofbirth2 if centros==97
by cobaid2, sort: gen rep=_N if centros ==97 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1



*98.. COBAID3
edit id cbvctidentifier cobaid3 gender dateofbirth2 countryofbirth if centros ==98
codebook cobaid3 if centros==98
codebook gender if centros==98
codebook countryofbirth if centros==98
codebook dateofbirth2 if centros==98
*- cobaid3 no recup
by cobaid3, sort: gen rep=_N if centros ==98 & cobaid3!="" 
*- gender
sort centros gender rep  cobaid3 
sort centros cobaid3 gender
bysort cobaid3 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid3 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid3 
sort centros cobaid3 countryofbirth
bysort cobaid3 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid3 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid3 
sort centros cobaid3 dateofbirth2
bysort cobaid3 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid3 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*100.. CBVCTIDENTIFIER 
edit id cbvctidentifier  gender dateofbirth2 countryofbirth if centros ==100
codebook cbvctidentifier  if centros==100
codebook gender if centros==100
codebook countryofbirth if centros==100
codebook dateofbirth2 if centros==100
by cbvctidentifier, sort: gen rep=_N if centros ==100 & cbvctidentifier!="" & ustrlen(cbvctidentifier)>5 
*- gender
sort centros gender rep  cbvctidentifier  
sort centros cbvctidentifier  gender
bysort cbvctidentifier  (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cbvctidentifier  gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cbvctidentifier  
sort centros cbvctidentifier  countryofbirth
bysort cbvctidentifier  (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cbvctidentifier  countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cbvctidentifier  
sort centros cbvctidentifier  dateofbirth2
bysort cbvctidentifier  (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cbvctidentifier  dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*101.. COBAID2
edit id cbvctidentifier cobaid2  gender dateofbirth2 countryofbirth if centros ==101
by cobaid2, sort: gen rep=_N if centros ==101 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*102.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==102
codebook cobaid2 if centros==102
codebook gender if centros==102
codebook countryofbirth if centros==102
codebook dateofbirth2 if centros==102
*- cobaid2 NO RECUP
by cobaid2, sort: gen rep=_N if centros ==102 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*103.. 
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==103
codebook cobaid2 if centros==103
codebook gender if centros==103
codebook countryofbirth if centros==103
codebook dateofbirth2 if centros==103
*- cobaid2
by cbvctidentifier, sort: gen rep=_N if centros ==103 & cbvctidentifier!="" 
gsort centros cobaid2 rep  cbvctidentifier
gsort centros cbvctidentifier cobaid2
bysort cbvctidentifier (cobaid2): gen cobaid_1=cobaid2[_N] if rep!=., after (cobaid2)
gsort centros rep cbvctidentifier  -cobaid2
replace cobaid2=cobaid_1 if centros ==103 & cobaid2==""
* 0 recuperaciones
drop  cobaid_1 rep
*decidir si usar cobaid2 o id propio para recuperar
by cobaid2, sort: gen rep=_N if centros ==103 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*105.. 
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==105
codebook cobaid2 if centros==105
codebook gender if centros==105
codebook countryofbirth if centros==105
codebook dateofbirth2 if centros==105
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==105 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 3 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*106.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==106
codebook cobaid2 if centros==106
codebook gender if centros==106
codebook countryofbirth if centros==106
codebook dateofbirth2 if centros==106
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==106 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*107.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==107
codebook cobaid2 if centros==107
codebook gender if centros==107
codebook countryofbirth if centros==107
codebook dateofbirth2 if centros==107
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==107 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*109.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==109
codebook cobaid2 if centros==109
codebook gender if centros==109
codebook countryofbirth if centros==109
codebook dateofbirth2 if centros==109
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==109 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1

*110.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==110
codebook cobaid2 if centros==110
codebook gender if centros==110
codebook countryofbirth if centros==110
codebook dateofbirth2 if centros==110
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==110 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 2 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*111.. COBAID2
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==111
codebook cobaid2 if centros==111
codebook gender if centros==111
codebook countryofbirth if centros==111
codebook dateofbirth2 if centros==111
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==111 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 0 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1


*112.. 
edit id cbvctidentifier cobaid2 gender dateofbirth2 countryofbirth if centros ==112
codebook cobaid2 if centros==112
codebook gender if centros==112
codebook countryofbirth if centros==112
codebook dateofbirth2 if centros==112
*- cobaid2 no recup
by cobaid2, sort: gen rep=_N if centros ==112 & cobaid2!="" 
*- gender
sort centros gender rep  cobaid2 
sort centros cobaid2 gender
bysort cobaid2 (gender): gen gend_1=gender[1] if rep!=.
sort centros rep cobaid2 gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort centros countryofbirth rep  cobaid2 
sort centros cobaid2 countryofbirth
bysort cobaid2 (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort centros rep cobaid2 countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 1 recuperaciones
drop count_1
*- fecha nacimiento
sort centros dateofbirth2 rep  cobaid2 
sort centros cobaid2 dateofbirth2
bysort cobaid2 (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros cobaid2 dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop rep fechanac_1



** Recuperación de missings desde cobaid
gen id_fin=cobaid2 if cobaid2!=""
replace id_fin=cobaid3 if cobaid3!="" & id_fin==""
*- gender
codebook gender dateofbirth2 countryofbirth if cobaid2!="" | cobaid3!=""
sort gender
replace gender=(real(usubstr(cobaid2,1,1)))+1 if gender==. & cobaid2!=""
*75 recup
replace gender=(real(usubstr(cobaid3,1,1)))+1 if gender==. & cobaid3!=""
*19 recup
sort dateofbirth2 cobaid2 cobaid3
*
by id_fin, sort: gen rep=_N if id_fin!="" 
*- pais nacimiento
sort  countryofbirth rep  id_fin 
sort  id_fin countryofbirth
bysort id_fin (countryofbirth): gen count_1=countryofbirth[1] if rep!=.
sort rep id_fin countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 54 recuperaciones
drop count_1
*- fecha nacimiento
sort dateofbirth2 rep  id_fin 
sort  id_fin dateofbirth2
bysort id_fin (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep!=.
sort centros id_fin dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 1 recuperaciones
drop rep fechanac_1
gen largoidfin=ustrlen(id_fin)
sort largoidfin
gen str sdayofbirth3 =  substr(id_fin,2,2) 
gen str smonthofbirth3 =  substr(id_fin,4,2) 
gen str syearofbirth3 =  substr(id_fin,6,4)
destring sdayofbirth3, generate(dayofbirth3)
destring smonthofbirth3, generate(monthofbirth3)
destring syearofbirth3, generate(yearofbirth3)
gen dateofbirth3 = mdy(monthofbirth3, dayofbirth3, yearofbirth3)
format dateofbirth3 %td
order dateofbirth3, after (dateofbirth_rec)
sort dateofbirth2 rep  id_fin 
*assignar la nova data generada a partir del cobaid generat automàticament si la data de naixament és missing
replace dateofbirth2=dateofbirth3 if dateofbirth2==. & dateofbirth3<date("31/12/2006", "DMY") & dateofbirth3>=date("01/01/1929", "DMY")
* 3 recup
drop dateofbirth3 sdayofbirth3 smonthofbirth3 syearofbirth3 dayofbirth3 monthofbirth3 yearofbirth3 largoidfin



// Variable nueva ID

* gender + ddmmyyy + pais (3dig) + cod centro (3 dig)
count if cobaid2=="" & cobaid3==""
*27.177
codebook gender dateofbirth2 countryofbirth if cobaid2=="" & cobaid3==""
* muchos missings en país de nacimiento. Se decide poner código especial cuando es missing
* Si fecha nac missing, se eliminará
sort cobaid2 cobaid3
gen gender2=gender-1
replace gender2=9 if gender==.
gen countryofbirth2=countryofbirth
replace countryofbirth2=999 if countryofbirth==.
gen nva_id= strofreal(gender2)+strofreal(day(dateofbirth2), "%02.0f")+ strofreal(month(dateofbirth2), "%02.0f")+ ///
	strofreal(year(dateofbirth2), "%04.0f")+ strofreal(countryofbirth2, "%03.0f")+ strofreal(centros, "%03.0f") ///
	if centros!=. & cobaid2=="" & cobaid3=="" & dateofbirth2!=.
drop gender2 countryofbirth2
*mirar repetidores
by nva_id, sort: gen rep=_N if nva_id!="" 
sort rep nva_id


* cbvct_id2 para reemplazar cdo el id propio es unico y no hay cobaid
gen cbvct_id2=ustrregexrf(cbvctidentifier,"-[0-2]","") if centros==6 & ustrregexm(cbvctidentifier, "000")!=1 & ustrregexm(cbvctidentifier, "XX")!=1 &  ustrlen(cbvctidentifier)>=7 & cobaid2=="" & cobaid3=="", after(cobaid3)
replace cbvct_id2=usubstr(cbvct_id2,1,5)+usubstr(cbvct_id2,8,2) if ustrlen(cbvct_id2)==9 & centros==6
replace cbvct_id2=usubstr(cbvct_id2,1,7) if ustrlen(cbvct_id2)==8 & centros==6 & ustrregexm(cbvctidentifier, "[A-Z][0-9][0-9][0-9][0-9][0-9][0-9]0")==1
replace cbvct_id2=ustrregexra(cbvctidentifier,"\.","") if centros==19 & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==22 & cobaid2=="" & cobaid3==""
replace cbvct_id2=ustrregexrf(cbvctidentifier,"CJAS","") if centros==30 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==36 & ustrregexm(cbvctidentifier, "[A-Z]+[0-9]+")==1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=usubstr(cbvct_id2,1,4)+usubstr(cbvct_id2,6,8) if ustrlen(cbvct_id2)==13 & centros==36 & ustrregexm(cbvctidentifier, "[A-Z][A-Z][A-Z][A-Z][0-2][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")==1
replace cbvct_id2=cbvctidentifier if centros==43 & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==51 & ustrregexm(cbvctidentifier, "[A-Z]+[0-9]+")==1 & ustrregexm(cbvctidentifier, "PROVA")!=1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==59 & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==65 & ustrregexm(cbvctidentifier, "-")!=1 & ustrregexm(cbvctidentifier, "/")!=1 &  ustrlen(cbvctidentifier)>=6 & cobaid2=="" & cobaid3==""
replace cbvct_id2=ustrregexra(ustrregexra(ustrregexra(ustrregexra(cbvctidentifier," ",""),"\.",""),"/",""),"-","") if centros==67 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1 & ustrlen(cbvctidentifier)>3 & cobaid2=="" & cobaid3==""
replace cbvct_id2=usubstr(cbvct_id2,1,3)+usubstr(cbvct_id2,5,8) if ustrlen(cbvct_id2)==12 & centros==67 & ustrregexm(cbvct_id2, "[A-Z][A-Z][A-Z]0[0-3][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")==1
replace cbvct_id2=cbvctidentifier if centros==77 & ustrregexm(cbvctidentifier, "00000")!=1 & ustrregexm(cbvctidentifier, "XX")!=1  & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==79 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "XX")!=1 & ustrregexm(cbvctidentifier, "-")!=1  & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==80 & ustrregexm(cbvctidentifier, "[A-Z]+[0-9]+")==1 & ustrregexm(cbvctidentifier, "XX")!=1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=cbvctidentifier if centros==82 & ustrregexm(cbvctidentifier, "[0-9]+[A-Z]+")==1 & ustrregexm(cbvctidentifier, "XX")!=1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=ustrregexra(cbvctidentifier," ","") if centros==83 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1 & ustrlen(cbvctidentifier)>4  & ustrregexm(cbvctidentifier, "XX")!=1 & ustrregexm(ustrregexra(cbvctidentifier," ",""), "00000")!=1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=ustrregexra(ustrregexra(ustrregexra(cbvctidentifier," ",""),"/",""),"-","") if centros==86 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1 & ustrlen(cbvctidentifier)>5 & ustrregexm(cbvctidentifier, "XX")!=1 & ustrregexm(cbvctidentifier, "SIDA")!=1  & ustrregexm(ustrregexra(cbvctidentifier," ",""), "00000")!=1 & cobaid2=="" & cobaid3==""
replace cbvct_id2=ustrregexra(cbvctidentifier,"_","") if centros==87 & ustrregexm(cbvctidentifier, "[A-Z]")==1 & ustrregexm(cbvctidentifier, "[0-9]")==1 & ustrlen(cbvctidentifier)>4  & ustrregexm(cbvctidentifier, "ANON")!=1 & cobaid2=="" & cobaid3==""
by cbvct_id2, sort: gen rep_id2=_N if cbvct_id2!=""

* Cambiar id propio cuando nva id coincide y letras id propio también, pero tienen distinto orden de dígitos (centro 51, 67)
* centro 51
replace cbvct_id2= ustrregexra(cbvct_id2,"[0-9]","")+ strofreal(day(dateofbirth2), "%02.0f")+ strofreal(month(dateofbirth2), "%02.0f")+ ///
	usubstr(strofreal(year(dateofbirth2), "%04.0f"),3,2) if centros==51 & dateofbirth2!=. & cbvct_id2!=""
drop rep_id2
by cbvct_id2, sort: gen rep_id2=_N if cbvct_id2!="" 
sort centros rep nva_id cbvct_id2
*ssc install strgroup 
gen forgroup=ustrregexra(cbvct_id2,"[0-9]","") if centros==51 & rep>1
gen forg1=usubstr(forgroup,1,1) 
gen forg2=usubstr(forgroup,2,1)
gen forg3=usubstr(forgroup,3,1)
gen forg4=usubstr(forgroup,4,1)
ssc install sortrows
sortrows forg1 forg2 forg3 forg4, replace
gen forgroup2= forg1 + forg2 + forg3 + forg4
quietly: bysort nva_id: strgroup forgroup if centros==51 & rep>1 & forgroup!="", gen(strgroup) threshold(0.35) norm(longer)
quietly: bysort nva_id: strgroup forgroup2 if centros==51 & rep>1 & forgroup2!="", gen(strgroup2) threshold(0.35) norm(longer)
sort centros rep nva_id cbvct_id2
duplicates tag strgroup if centros==51 & rep>1 & strgroup!=., gen(dup1)
duplicates tag strgroup2 if centros==51 & rep>1 & strgroup!=., gen(dup2)
bysort nva_id (cbvct_id2): replace cbvct_id2= forgroup[_N]+ strofreal(day(dateofbirth2), "%02.0f")+ strofreal(month(dateofbirth2), "%02.0f")+ ///
	usubstr(strofreal(year(dateofbirth2), "%04.0f"),3,2) if centros==51 & (dup1>0|dup2>0) & rep>1 & strgroup!=.
sort centros rep nva_id cbvct_id2
drop forgroup forg1 forg2 forg3 forg4 forgroup2 strgroup strgroup2 dup1 dup2
drop rep_id2
by cbvct_id2, sort: gen rep_id2=_N if cbvct_id2!="" 
* centro 67
replace cbvct_id2= ustrregexra(cbvct_id2,"[0-9]","")+ strofreal(day(dateofbirth2), "%02.0f")+ strofreal(month(dateofbirth2), "%02.0f")+ ///
	strofreal(year(dateofbirth2), "%04.0f") if centros==67 & dateofbirth2!=. & cbvct_id2!=""
sort centros rep nva_id cbvct_id2
gen forgroup=ustrregexra(cbvct_id2,"[0-9]","") if centros==67 & rep>1
*no cal ordenar
quietly: bysort nva_id: strgroup forgroup if centros==67 & rep>1 & forgroup!="", gen(strgroup) threshold(0.35) norm(longer)
sort centros rep nva_id cbvct_id2
duplicates tag strgroup if centros==67 & rep>1 & strgroup!=., gen(dup1)
quietly: bysort nva_id (cbvct_id2): replace cbvct_id2= forgroup[_N]+ strofreal(day(dateofbirth2), "%02.0f")+ strofreal(month(dateofbirth2), "%02.0f")+ ///
	strofreal(year(dateofbirth2), "%04.0f") if centros==67 & dup1>0 & rep>1 & strgroup!=.
sort centros rep nva_id cbvct_id2
drop forgroup strgroup  dup1 
drop rep_id2
by cbvct_id2, sort: gen rep_id2=_N if cbvct_id2!="" 
sort centros rep nva_id cbvct_id2




// Variable ID final
replace id_fin=cbvct_id2 if cbvct_id2!="" & id_fin==""
replace id_fin=nva_id if nva_id!="" & id_fin==""
codebook id_fin
*557 missing
by id_fin, sort: gen rep_fin=_N if id_fin!="" 
sort rep_fin id_fin centros 
edit  dateofvisit2 cbvctidentifier cobaid cobaid2 cobaid3 cbvct_id2 gender dateofbirth2 countryofbirth rep_fin
bysort centros: count if id_fin==""
* AIDS fondet=247 m; Plate-Forme=78 m; Marolles=31 m.... resto entre 0 y 17 m


** recuperación de missings desde cobaid final
*evaluar si se pueden recuperar missings
codebook  gender dateofbirth2 countryofbirth if id_fin!="" & rep_fin>1
*- gender
sort gender rep_fin id_fin 
sort id_fin gender
bysort id_fin (gender): gen gend_1=gender[1] if rep_fin!=.
sort rep_fin id_fin gender
replace gender=gend_1 if gender==.
* 0 recuperaciones
drop gend_1
*- pais nacimiento
sort countryofbirth rep_fin  id_fin 
sort id_fin countryofbirth
bysort id_fin (countryofbirth): gen count_1=countryofbirth[1] if rep_fin!=.
sort centros rep_fin id_fin countryofbirth
replace countryofbirth=count_1 if countryofbirth==.
* 8 recuperaciones
drop count_1
*- fecha nacimiento
sort dateofbirth2 rep_fin  id_fin 
sort centros id_fin dateofbirth2
bysort id_fin (dateofbirth2): gen fechanac_1=dateofbirth2[1] if rep_fin!=.
sort id_fin dateofbirth2
replace dateofbirth2=fechanac_1 if dateofbirth2==.
* 0 recuperaciones
drop fechanac_1


** ¿qué hacer con id_fin missing? borrarlos
drop if id_fin==""
drop if user_id=="C302"

codebook gender countryofbirth dateofbirth2
* 52 m gender, 5.220 m país, 270 m fechanac

** Personas repetidoras
count if rep_fin>1
*29.896


// PAÍS
drop nom_pais codi_subregio nom_subregio codi_regio nom_regio codi_continent nom_continent
merge m:1 countryofbirth using "country code.dta"
rename *, lower
drop if _merge==2
drop _merge
tab countryofbirth, m

// año visita
gen anyvisit=year(dateofvisit2)

// EDAD
*genvar age
gen ageinyears=.
replace ageinyears= (dateofvisit2 - dateofbirth2) 
replace ageinyears= ageinyears/365.25

*age group2
gen agegroup2=.
replace agegroup2=1 if ageinyears<25 & ageinyears>=13
replace agegroup2=2 if ageinyears>=25 & ageinyears<=110 & ageinyears<.

*genvar agegroup according to ECDC cats
recode ageinyears (65/110=5 ">65") (45/65=4 ">=45-65") (25/45=3 ">=25-45") (16/25=2 ">=16-25") (13/16=1 "<16") (else=.), gen (agegroupecdc) label(dagegroupecdc)

*grups edat DEVO
recode ageinyears (50/max=4 ">50")(35/50=3 ">=36-50")(20/50=2 ">=21-35")(13/20=1 "<20")(else=.), gen (agegroupdevo)label(dagegroupdevo)


// GRUPOS VULNERABLES
**msm y trans
gen msm=.
replace msm=1 if gender==1 & sexwith==1
replace msm=1 if gender==1 & sexwith==3
replace msm=1 if gender==3 & sexwith==1 // trans person sex with men
replace msm=1 if gender==3 & sexwith==3 // trans person sex with men & women
replace msm=2 if gender==2
replace msm=2 if gender==1 & sexwith==2
replace msm=1 if unprotectedmsm==1 & (gender==1|gender==3) & msm==.

**create sw gender
gen swgen=.
replace swgen=1 if gender==1 & sw==1 
replace swgen=2 if gender==2 & sw==1
replace swgen=3 if gender==3 & sw==1



// CASOS CON PRUEBAS PARA MÁS DE UNA ITS
gen hivtest2=inlist(screeninghivtest,1)
gen syphtest2=inlist(syphilistest,1)
gen hcvtest2=inlist(hcvtest,1)
egen float Ntestsinfeccions = rowtotal(hivtest2 syphtest2 hcvtest2) 
egen float Ntestshivsyph = rowtotal(hivtest2 syphtest2) if hcvtest2!=1
egen float Ntestshivsyph2 = rowtotal(hivtest2 syphtest2)
egen float Ntestshivhcv = rowtotal(hivtest2 hcvtest2) if syphtest2!=1
egen float Ntestshivhcv2 = rowtotal(hivtest2 hcvtest2)
egen float Ntestssyphcv = rowtotal(syphtest2 hcvtest2) if hivtest2!=1
egen float Ntestssyphcv2 = rowtotal(syphtest2 hcvtest2)


// CASOS CON MÁS DE UN POSITIVO
gen screeningtestresult2=inlist(screeningtestresult,1)
gen syphscreeningtestresult2=inlist(syphscreeningtestresult,1)
gen hcvscreeningtestresult2=inlist(hcvscreeningtestresult,1)
egen float Nreactiveresults = rowtotal(screeningtestresult2 syphscreeningtestresult2 hcvscreeningtestresult2)
egen float Nreactiveshivsyph = rowtotal(screeningtestresult2 syphscreeningtestresult2) if hcvscreeningtestresult2!=1
egen float Nreactiveshivhcv =  rowtotal(screeningtestresult2 hcvscreeningtestresult2) if syphscreeningtestresult2!=1
egen float Nreactivessyphhcv = rowtotal(syphscreeningtestresult2 hcvscreeningtestresult2) if screeningtestresult2!=1
egen float Nreactiveshivsyph2 = rowtotal(screeningtestresult2 syphscreeningtestresult2)
egen float Nreactiveshivhcv2 =  rowtotal(screeningtestresult2 hcvscreeningtestresult2) 
egen float Nreactivessyphhcv2 = rowtotal(syphscreeningtestresult2 hcvscreeningtestresult2)


// LABELS 
do "label.do"



*********************************************
	
	
	
	
	
 save "COBATEST_long.dta", replace

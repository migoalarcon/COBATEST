use "COBATEST_long.dta", clear

** Edad
codebook ageinyears
tabstat ageinyears , s(mean sd median p25 p75 count)


*tabstat cd4count , s(mean sd median p25 p75 count)

*ssc install tabout
help tabout
quietly tabout  testingsite gender migrant nom_continent tourist risk_exposition unprotected_vaginal_sex ///
	unprotected_anal_sex unprotected_oral_sex broken_condom unprotected_sex_with_sw ///
	partner_tested_positive sharing_injection_material other_risk_exposition for_control_screening ///
	partner_asked before_dropping_condom before_having_baby prenatal_screening regular_control ///
	to_know_health_status other_control_screening window_perioid clinical_symptoms ///
	other_reason_tests come_before friend pamphlet internet other_reason_cbvct evertested ///
	resultlasthiv test12monthscbvct sexwith condomuse sw sti jail unprotectedsw unprotectedidu ///
	unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	hivtestused screeninghivtest screeningtestresult test_result_received post_test_counselling confirmhivtest ///
	confirmhivtestres confirm_hiv_test_res_rec  ///
	linkagehealthcare sypheverdiagnosed syphilistest syphtestused syphscreeningtestresult ///
	syphconfirmatorytest syphconfirmatorytestresult hcveverdiagnosed hcvtest hcvtestused ///
	hcvscreeningtestresult hcvrnatest  hcvconfirmatorytestresult ///
	hepavaccination hepbvaccionation prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06  chemsex_drugs chemsex_which_drugs01 ///
	chemsex_which_drugs02 chemsex_which_drugs03 chemsex_which_drugs04 chemsex_which_drugs05 ///
	agegroupecdc agegroupdevo msm swgen anypos confirmat_vih confirmat_sif confirmat_vhc ///
	using descr_cobatest_mi.xls, oneway cell(freq col) clab(N %) f(0c 1) mi dpcomma replace
	
quietly tabout testingsite gender migrant nom_continent tourist risk_exposition unprotected_vaginal_sex ///
	unprotected_anal_sex unprotected_oral_sex broken_condom unprotected_sex_with_sw ///
	partner_tested_positive sharing_injection_material other_risk_exposition for_control_screening ///
	partner_asked before_dropping_condom before_having_baby prenatal_screening regular_control ///
	to_know_health_status other_control_screening window_perioid clinical_symptoms ///
	other_reason_tests come_before friend pamphlet internet other_reason_cbvct evertested ///
	resultlasthiv test12monthscbvct sexwith condomuse sw sti jail unprotectedsw unprotectedidu ///
	unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	hivtestused screeninghivtest screeningtestresult test_result_received post_test_counselling confirmhivtest ///
	confirmhivtestres confirm_hiv_test_res_rec  ///
	linkagehealthcare sypheverdiagnosed syphilistest syphtestused syphscreeningtestresult ///
	syphconfirmatorytest syphconfirmatorytestresult hcveverdiagnosed hcvtest hcvtestused ///
	hcvscreeningtestresult hcvrnatest  hcvconfirmatorytestresult ///
	hepavaccination hepbvaccionation prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06  chemsex_drugs chemsex_which_drugs01 ///
	chemsex_which_drugs02 chemsex_which_drugs03 chemsex_which_drugs04 chemsex_which_drugs05 ///
	agegroupecdc agegroupdevo msm swgen anypos confirmat_vih confirmat_sif confirmat_vhc ///
	using descr_cobatest.xls, oneway cell(freq col) clab(N %) f(0c 1) dpcomma replace

	
tabstat ageinyears , s(mean sd median p25 p75 count) by(anypos)

* any pos	
quietly tabout  testingsite gender migrant tourist risk_exposition unprotected_vaginal_sex ///
	unprotected_anal_sex unprotected_oral_sex broken_condom unprotected_sex_with_sw ///
	partner_tested_positive sharing_injection_material other_risk_exposition for_control_screening ///
	partner_asked before_dropping_condom before_having_baby prenatal_screening regular_control ///
	to_know_health_status other_control_screening window_perioid clinical_symptoms ///
	other_reason_tests come_before friend pamphlet internet other_reason_cbvct evertested ///
	resultlasthiv test12monthscbvct condomuse sw sti jail unprotectedsw unprotectedidu ///
	unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	hivtestused screeninghivtest screeningtestresult test_result_received post_test_counselling ///
	sypheverdiagnosed syphilistest syphtestused syphscreeningtestresult ///
	hcveverdiagnosed hcvtest hcvtestused hcvscreeningtestresult ///
	hepavaccination hepbvaccionation prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06  chemsex_drugs chemsex_which_drugs01 ///
	chemsex_which_drugs02 chemsex_which_drugs03 chemsex_which_drugs04 chemsex_which_drugs05 ///
	agegroupecdc agegroupdevo msm swgen anypos ///
	using biv_cobatest.xls, cell(freq col) clab(N %) f(0c 1) stats(chi2) dpcomma replace 

tabout confirmat_vih confirmat_sif confirmat_vhc anypos using table1.htm, c(freq col ) clab(N %) ///
f(0c 1) style(htm) font(bold) dpcomma replace
	
* VIH test
quietly tabout  testingsite gender migrant tourist risk_exposition unprotected_vaginal_sex ///
	unprotected_anal_sex unprotected_oral_sex broken_condom unprotected_sex_with_sw ///
	partner_tested_positive sharing_injection_material other_risk_exposition for_control_screening ///
	partner_asked before_dropping_condom before_having_baby prenatal_screening regular_control ///
	to_know_health_status other_control_screening window_perioid clinical_symptoms ///
	other_reason_tests come_before friend pamphlet internet other_reason_cbvct evertested ///
	resultlasthiv test12monthscbvct condomuse sw sti jail unprotectedsw unprotectedidu ///
	unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	hivtestused  test_result_received post_test_counselling  ///
	sypheverdiagnosed syphilistest syphtestused syphscreeningtestresult ///
	syphconfirmatorytest syphconfirmatorytestresult hcveverdiagnosed hcvtest hcvtestused ///
	hcvscreeningtestresult hcvrnatest  hcvconfirmatorytestresult ///
	hepavaccination hepbvaccionation prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06  chemsex_drugs chemsex_which_drugs01 ///
	chemsex_which_drugs02 chemsex_which_drugs03 chemsex_which_drugs04 chemsex_which_drugs05 ///
	agegroupecdc agegroupdevo msm swgen  screeningtestresult if screeningtestresult<3 ///
	using biv_cobatest_hiv.xls, cell(freq col) clab(N %) f(0c 1) stats(chi2) dpcomma replace 

* syph test
quietly tabout testingsite gender migrant tourist risk_exposition unprotected_vaginal_sex ///
	unprotected_anal_sex unprotected_oral_sex broken_condom unprotected_sex_with_sw ///
	partner_tested_positive sharing_injection_material other_risk_exposition for_control_screening ///
	partner_asked before_dropping_condom before_having_baby prenatal_screening regular_control ///
	to_know_health_status other_control_screening window_perioid clinical_symptoms ///
	other_reason_tests come_before friend pamphlet internet other_reason_cbvct evertested ///
	resultlasthiv test12monthscbvct condomuse sw sti jail unprotectedsw unprotectedidu ///
	unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	hivtestused screeninghivtest screeningtestresult test_result_received post_test_counselling confirmhivtest ///
	confirmhivtestres confirm_hiv_test_res_rec  ///
	linkagehealthcare sypheverdiagnosed syphtestused ///
	hcveverdiagnosed hcvtest hcvtestused ///
	hcvscreeningtestresult hcvrnatest  hcvconfirmatorytestresult ///
	hepavaccination hepbvaccionation prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06  chemsex_drugs chemsex_which_drugs01 ///
	chemsex_which_drugs02 chemsex_which_drugs03 chemsex_which_drugs04 chemsex_which_drugs05 ///
	agegroupecdc agegroupdevo msm swgen syphscreeningtestresult if syphscreeningtestresult<3 ///
	using biv_cobatest_syph.xls, show(all) cell(freq col) clab(N %) f(0c 1) stats(chi2) dpcomma replace 
	
	
* HCV test
quietly tabout  testingsite gender migrant tourist risk_exposition unprotected_vaginal_sex ///
	unprotected_anal_sex unprotected_oral_sex broken_condom unprotected_sex_with_sw ///
	partner_tested_positive sharing_injection_material other_risk_exposition for_control_screening ///
	partner_asked before_dropping_condom before_having_baby prenatal_screening regular_control ///
	to_know_health_status other_control_screening window_perioid clinical_symptoms ///
	other_reason_tests come_before friend pamphlet internet other_reason_cbvct evertested ///
	resultlasthiv test12monthscbvct condomuse sw sti jail unprotectedsw unprotectedidu ///
	unprotectedhiv unprotectedmsm pwid syringes_needles spoons_filters pretest_counselling ///
	hivtestused screeninghivtest screeningtestresult test_result_received post_test_counselling confirmhivtest ///
	confirmhivtestres confirm_hiv_test_res_rec  ///
	linkagehealthcare sypheverdiagnosed syphilistest syphtestused syphscreeningtestresult ///
	syphconfirmatorytest syphconfirmatorytestresult hcveverdiagnosed hcvtestused ///
	hepavaccination hepbvaccionation prep_heard prep_taken prep_interested prep_why01 prep_why02 ///
	prep_why03 prep_why04 prep_why05 prep_why06  chemsex_drugs chemsex_which_drugs01 ///
	chemsex_which_drugs02 chemsex_which_drugs03 chemsex_which_drugs04 chemsex_which_drugs05 ///
	agegroupecdc agegroupdevo msm swgen hcvscreeningtestresult if hcvscreeningtestresult<3 ///
	using biv_cobatest_hcv.xls, show(all) cell(freq col) clab(N %) f(0c 1) stats(chi2) dpcomma replace 

*ssc install outreg2
help outreg2


  outreg2 anypos gender migrant msm using bib_long.xls, see lab(proper) replace cross stats(str(anypos gender migrant msm)) comma
  
tabout anypos gender migrant msm using table2.txt, ///
	cells(freq row col) format(0c 1p 1p) clab(_ _ _) ///
	layout(rb) h3(nil) ///
	replace ///
	style(tex) bt font(bold) cl1(2-4) ///
	 topstr(11cm) botstr(nlsw88.dta)

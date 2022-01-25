/* Create training & validation datasets */

/* Sort EMSCAD_final by fraudulent */
proc sort data=capstone.EMSCAD_final;
	by fraudulent;
run;

/* Oversample fraudulent cases */
proc surveyselect data=capstone.EMSCAD_final
				  method=srs n=(2598, 866) seed=6302021
				  out=capstone.development(drop=SelectionProb SamplingWeight);
	strata fraudulent;
run;

/* Verify results */
proc freq data=capstone.development;
	tables fraudulent;
run;

/* Take stratified sample of development dataset */
proc surveyselect data=capstone.development samprate=0.7
				  seed=6302021 out=capstone.sample outall;
	strata fraudulent;
run;

/* Verify results */
proc freq data=capstone.sample;
	tables fraudulent*selected;
run;

/* Split sample into training & validation datasets */
data capstone.training(drop=Selected SelectionProb SamplingWeight)
	 capstone.validation(drop=Selected SelectionProb SamplingWeight);
	set capstone.sample;
	if selected then output capstone.training;
	else output capstone.validation;
run;

/* Create logistic regression models */

/* List of all predictors */
%let all_vars=employment_type required_experience required_education
				company_profile_length description_length requirements_length 
				benefits_length industry_SWOE function_SWOE
			 	from_US money_in_title mentions_salary telecommuting 
			 	has_company_logo has_questions has_email has_phone has_url 
			 	has_fraud_bigram has_legit_bigram;
			 	
/* Determine population proportion of fraudulent job ads */
%global rho1;
proc sql;
	select mean(fraudulent) into: rho1
	from capstone.EMSCAD_final;
run;

/* All variables model */
proc logistic data=capstone.training;
	class employment_type(ref='Unspecified') required_experience(ref='Unspecified')
		  required_education(ref='Unspecified') / param=ref;
	model fraudulent(event='1')=&all_vars;
	score data=capstone.validation priorevent=&rho1 fitstat
		  out=capstone.validation(rename=(p_1=p_allvars) drop=F_fraudulent I_fraudulent p_0);
run;

/* Stepwise selection model */
proc logistic data=capstone.training;
	class employment_type(ref='Unspecified') required_experience(ref='Unspecified')
		  required_education(ref='Unspecified') / param=ref;
	model fraudulent(event='1')=&all_vars / selection=stepwise;
	score data=capstone.validation priorevent=&rho1 fitstat
		  out=capstone.validation(rename=(p_1=p_stepwise) drop=F_fraudulent I_fraudulent p_0);
run;

/* Compare ROC curves */

ods select ROCOverlay;
proc logistic data=capstone.validation;
	model fraudulent(event='1')=p_allvars p_stepwise / nofit;
	roc 'All variables model' p_allvars;
	roc 'Stepwise selection model' p_stepwise;
run;

data capstone.validation;
	set capstone.validation;
	drop p_allvars p_stepwise;
run;
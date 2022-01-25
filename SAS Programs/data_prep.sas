/* Import data */

proc import datafile="&path/EMSCAD.csv"
			dbms=csv
			out=capstone.EMSCAD;
	guessingrows=max;
run;

/* Data sparsity */

/* Create missing/not missing format */
proc format;
	value $missfmt ' '='Missing' other='Not Missing';
	value  missfmt  . ='Missing' other='Not Missing';
run;

/* View missing/not missing count for each variable */
proc freq data=capstone.EMSCAD; 
	format _CHAR_ $missfmt.;
	tables _CHAR_ / missing missprint nocum;
	format _NUMERIC_ missfmt.;
	tables _NUMERIC_ / missing missprint nocum;
run;

/* Overall data sparsity */
%let all_vars=job_id, title, location, department, salary_range, company_profile, description, 
			  requirements, benefits, telecommuting, has_company_logo, has_questions, employment_type, 
			  required_experience, required_education, industry, function, fraudulent;
proc sql;
	select sum(cmiss(&all_vars))/(17880*18) as 'Overall sparsity'n
	from capstone.EMSCAD;
quit;

/* Inspect raw categorical variables */

%let cat_vars=employment_type required_experience required_education industry function;
proc freq data=capstone.EMSCAD order=freq;
	tables &cat_vars;
run;

proc sql;
	select count(distinct industry) as 'Number of industries'n
	from capstone.EMSCAD;
	select count(distinct function) as 'Number of functions'n
	from capstone.EMSCAD;
quit;

/* Data cleaning and reordering categorical variable levels */

/* Clean data */
data capstone.EMSCAD_clean;
	retain job_id country employment_type required_experience required_education industry function 
		   mentions_salary telecommuting has_company_logo has_questions fraudulent;
	length employment_type $15.;
	format employment_type $15.;
	set capstone.EMSCAD;
/* Extract country from location */
	country=scan(location, 1);
/* Salary indicator */
	if missing(salary_range) then mentions_salary=0;
	else mentions_salary=1;
/* Clean categories of required_education */
	if required_education =: 'Vocational' then required_education='Vocational';
	else if required_education =: 'Some High School' then required_education='High School or equivalent';
/* Address missing values */
	array x{*} country &cat_vars;
	do _n_=1 to dim(x);
		if missing(x{_n_}) then x{_n_}='Unspecified';
	end;
/* Drop unnecessary columns */
	drop title location department salary_range company_profile description requirements benefits;
run;

/* Create formats for reordering categorical variable levels */
proc format;
	value etf  1='Full-time'
			   2='Part-time'
			   3='Contract'
			   4='Temporary'
			   5='Other'
			   6='Unspecified';
	value rexf 1='Internship'
			   2='Entry level'
			   3='Associate'
			   4='Mid-Senior level'
			   5='Director'
			   6='Executive'
			   7='Not Applicable'
			   8='Unspecified';
	value redf 1='High School or equivalent'
			   2='Some college coursework'
			   3='Associate Degree'
			   4="Bachelor's Degree"
			   5="Master's Degree"
			   6='Doctorate'
			   7='Professional'
			   8='Vocational'
			   9='Certification'
			   10='Unspecified';
run;

/* Reorder categorical variable levels */
data capstone.EMSCAD_clean;
	retain job_id country employment_type required_experience required_education industry function 
		   mentions_salary telecommuting has_company_logo has_questions fraudulent;
	format employment_type etf.;
	format required_experience rexf.;
	format required_education redf.;
	set capstone.EMSCAD_clean(rename=(employment_type=et
									  required_experience=rex
									  required_education=red));
	select (et);
		when ('Full-time')   employment_type=1;
		when ('Part-time')   employment_type=2;
		when ('Contract')    employment_type=3;
		when ('Temporary')   employment_type=4;
		when ('Other') 		 employment_type=5;
		when ('Unspecified') employment_type=6;
	end;
	select (rex);
		when ('Internship')       required_experience=1;
		when ('Entry level') 	  required_experience=2;
		when ('Associate')   	  required_experience=3;
		when ('Mid-Senior level') required_experience=4;
		when ('Director') 		  required_experience=5;
		when ('Executive') 		  required_experience=6;
		when ('Not Applicable')   required_experience=7;
		when ('Unspecified') 	  required_experience=8;
	end;
	select (red);
		when ('High School or equivalent')  required_education=1;
		when ('Some college coursework')    required_education=2;
		when ('Associate Degree') 			required_education=3;
		when ("Bachelor's Degree") 			required_education=4;
		when ("Master's Degree") 			required_education=5;
		when ('Doctorate') 					required_education=6;
		when ('Professional') 				required_education=7;
		when ('Vocational') 				required_education=8;
		when ('Certification') 				required_education=9;
		when ('Unspecified') 				required_education=10;
	end;
	drop et rex red;
run;

/* Cross tabulation of industry, function, country with fraudulent */

proc freq data=capstone.EMSCAD_clean order=freq;
	tables (industry function country)*fraudulent;
run;

/* United States indicator */

data capstone.EMSCAD_clean;
	set capstone.EMSCAD_clean;
	if country='US' then from_US=1;
	else from_US=0;
run;

/* Industry SWOE */

/* Determine population proportion of fraudulent job ads */
%global rho1;
proc sql;
	select mean(fraudulent) into: rho1
	from capstone.EMSCAD;
run;

/* Count fraudulent job ads per industry */
proc means data=capstone.EMSCAD_clean sum nway;
	class industry;
	var fraudulent;
	output out=work.industry_counts sum=events;
run;

/* Compute industry SWOE */
data work.industry_counts;
	set work.industry_counts;
	industry_SWOE = log((events + &rho1 * 1)/(_FREQ_ - events + (1 - &rho1) * 1));
run;

/* Function SWOE */

/* Count fraudulent job ads per function */
proc means data=capstone.EMSCAD_clean sum nway;
	class function;
	var fraudulent;
	output out=work.function_counts sum=events;
run;

/* Compute function SWOE */
data work.function_counts;
	set work.function_counts;
	function_SWOE = log((events + &rho1 * 1)/(_FREQ_ - events + (1 - &rho1) * 1));
run;

/* Add industry_SWOE and function_SWOE to dataset */

proc sql;
	create table capstone.EMSCAD_clean_SWOE as
		select E.*, I.industry_SWOE, F.function_SWOE
		from capstone.EMSCAD_clean E 
		left join work.industry_counts I
		on E.industry = I.industry 
		left join work.function_counts F
		on E.function = F.function
		order by E.job_id;
quit;

/* Import text mining results */

proc import datafile="&path/text_mining_results.csv"
			dbms=csv
			out=capstone.text_mining_results;
	guessingrows=max;
run;

/* Merge EMSCAD_clean_SWOE and text_mining_results datasets */

%let final_vars=employment_type, required_experience, required_education, 
				company_profile_length, description_length, requirements_length, 
				benefits_length, industry_SWOE, function_SWOE,
			 	from_US, money_in_title, mentions_salary, telecommuting, 
			 	has_company_logo, has_questions, has_email, has_phone, has_url, 
			 	has_fraud_bigram, has_legit_bigram, fraudulent;
proc sql;
	create table capstone.EMSCAD_final as
		select &final_vars
		from capstone.EMSCAD_clean_SWOE E
		join capstone.text_mining_results T
		on E.job_id = T.job_id;
quit;

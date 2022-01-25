/* Create Yes/No format for binary variables */

proc format;
	value yn 1='Yes' 0='No';
run;

/* employment_type plots */

/* distribution */
title 'employment_type Distribution';
proc sgplot data=capstone.EMSCAD_final;
	format fraudulent yn.;
	vbar employment_type / group=fraudulent groupdisplay=stack
						   datalabel seglabel seglabelattrs=(size=4) seglabelfitpolicy=noclip;
	xaxis discreteorder=formatted;
	yaxis label='Frequency' grid;
	keylegend / title='Fraudulent' location=inside position=topright;
run;

/* fraudulent rates */
proc freq data=capstone.EMSCAD_final noprint;
	tables employment_type*fraudulent / out=FreqOut(where=(fraudulent=1)) outpct;
run;

data FreqOut;
	set FreqOut;
	row_proportion=PCT_ROW/100;
	keep employment_type row_proportion;
run;
 
title "employment_type Fraudulent Rates";
proc sgplot data=FreqOut;
	format row_proportion percent6.2;
	vbar employment_type / response=row_proportion datalabel
						   fillattrs=(color=red transparency=0.5);
	xaxis discreteorder=data;
	yaxis label="Fraudulent rate" grid;
run;

/* required_experience plots */

/* distribution */
title 'required_experience Distribution';
proc sgplot data=capstone.EMSCAD_final;
	format fraudulent yn.;
	vbar required_experience / group=fraudulent groupdisplay=stack
						   datalabel seglabel seglabelattrs=(size=4) seglabelfitpolicy=noclip;
	xaxis discreteorder=formatted;
	yaxis label='Frequency' grid;
	keylegend / title='Fraudulent' location=inside position=topleft;
run;

/* fraudulent rates */
proc freq data=capstone.EMSCAD_final noprint;
	tables required_experience*fraudulent / out=FreqOut(where=(fraudulent=1)) outpct;
run;

data FreqOut;
	set FreqOut;
	row_proportion=PCT_ROW/100;
	keep required_experience row_proportion;
run;
 
title "required_experience Fraudulent Rates";
proc sgplot data=FreqOut;
	format row_proportion percent6.2;
	vbar required_experience / response=row_proportion datalabel
						   fillattrs=(color=red transparency=0.5);
	xaxis discreteorder=data;
	yaxis label="Fraudulent rate" grid;
run;

/* required_education plots */

/* distribution */
title 'required_education Distribution';
proc sgplot data=capstone.EMSCAD_final;
	format fraudulent yn.;
	vbar required_education / group=fraudulent groupdisplay=stack
						   datalabel seglabel seglabelattrs=(size=4) seglabelfitpolicy=noclip;
	xaxis discreteorder=formatted;
	yaxis label='Frequency' grid;
	keylegend / title='Fraudulent' location=inside position=topleft;
run;

/* fraudulent rates */
proc freq data=capstone.EMSCAD_final noprint;
	tables required_education*fraudulent / out=FreqOut(where=(fraudulent=1)) outpct;
run;

data FreqOut;
	set FreqOut;
	row_proportion=PCT_ROW/100;
	keep required_education row_proportion;
run;
 
title "required_education Fraudulent Rates";
proc sgplot data=FreqOut;
	format row_proportion percent6.2;
	vbar required_education / response=row_proportion datalabel
						   fillattrs=(color=red transparency=0.5);
	xaxis discreteorder=data;
	yaxis label="Fraudulent rate" grid;
run;

ods graphics / reset;

/* company_profile_length plots */

/* Histogram */
title 'company_profile_length Histogram';
proc sgplot data=capstone.EMSCAD_final;
	histogram company_profile_length / scale=count;
	yaxis label='Frequency' grid;
run;

/* Box plot */
options validvarname=v7;
ods output sgplot=cpl_boxplotdata(rename=(BOX_COMPANY_PROFILE_LENGTH_X___Y=value
									 	  BOX_COMPANY_PROFILE_LENGTH_X__ST=stat
									 	  BOX_COMPANY_PROFILE_LENGTH_X___X=cat));
proc sgplot data=capstone.EMSCAD_final;
	vbox company_profile_length / category=fraudulent;
run;

data cpl_merged;
	format fraudulent cat yn.;
	set capstone.EMSCAD_final 
		cpl_boxplotdata(where=(value ne . and stat in ('MIN' 'Q1' 'MEDIAN' 'Q3' 'MAX' 'MEAN')));
	value=round(value, 0.01);
	run;

title 'company_profile_length Box Plot';
proc sgplot data=cpl_merged noautolegend;
	vbox company_profile_length / category=fraudulent group=fraudulent 
								  fillattrs=(transparency=0.7) meanattrs=(symbol=diamond);
	xaxistable value / x=cat class=stat location=inside;
	yaxis grid;
run;

/* description_length plots */

/* Histogram */
title 'description_length Histogram';
proc sgplot data=capstone.EMSCAD_final;
	histogram description_length / scale=count;
	yaxis label='Frequency' grid;
run;

/* Box plot */
options validvarname=v7;
ods output sgplot=dl_boxplotdata(rename=(BOX_DESCRIPTION_LENGTH_X_FRA___Y=value
									 	 BOX_DESCRIPTION_LENGTH_X_FRA__ST=stat
									 	 BOX_DESCRIPTION_LENGTH_X_FRA___X=cat));
proc sgplot data=capstone.EMSCAD_final;
	vbox description_length / category=fraudulent;
run;

data dl_merged;
	format fraudulent yn.;
	format cat yn.;
	set capstone.EMSCAD_final 
		dl_boxplotdata(where=(value ne . and stat in ('MIN' 'Q1' 'MEDIAN' 'Q3' 'MAX' 'MEAN')));
	value=round(value, 0.01);
	run;

title 'description_length Box Plot';
proc sgplot data=dl_merged noautolegend;
	vbox description_length / category=fraudulent group=fraudulent 
							  fillattrs=(transparency=0.7) meanattrs=(symbol=diamond);
	xaxistable value / x=cat class=stat location=inside;
	yaxis grid;
run;

/* requirements_length plots */

/* Histogram */
title 'requirements_length Histogram';
proc sgplot data=capstone.EMSCAD_final;
	histogram requirements_length / scale=count;
	yaxis label='Frequency' grid;
run;

/* Box plot */
options validvarname=v7;
ods output sgplot=rl_boxplotdata(rename=(BOX_REQUIREMENTS_LENGTH_X_FR___Y=value
									 	 BOX_REQUIREMENTS_LENGTH_X_FR__ST=stat
									 	 BOX_REQUIREMENTS_LENGTH_X_FR___X=cat));
proc sgplot data=capstone.EMSCAD_final;
	vbox requirements_length / category=fraudulent;
run;

data rl_merged;
	format fraudulent yn.;
	format cat yn.;
	set capstone.EMSCAD_final 
		rl_boxplotdata(where=(value ne . and stat in ('MIN' 'Q1' 'MEDIAN' 'Q3' 'MAX' 'MEAN')));
	value=round(value, 0.01);
	run;

title 'requirements_length Box Plot';
proc sgplot data=rl_merged noautolegend;
	vbox requirements_length / category=fraudulent group=fraudulent 
							   fillattrs=(transparency=0.7) meanattrs=(symbol=diamond);
	xaxistable value / x=cat class=stat location=inside;
	yaxis grid;
run;

/* benefits_length plots */

/* Histogram */
title 'benefits_length Histogram';
proc sgplot data=capstone.EMSCAD_final;
	histogram benefits_length / scale=count;
	yaxis label='Frequency' grid;
run;

/* Box plot */
options validvarname=v7;
ods output sgplot=bl_boxplotdata(rename=(BOX_BENEFITS_LENGTH_X_FRAUDU___Y=value
									 	 BOX_BENEFITS_LENGTH_X_FRAUDU__ST=stat
									 	 BOX_BENEFITS_LENGTH_X_FRAUDU___X=cat));
proc sgplot data=capstone.EMSCAD_final;
	vbox benefits_length / category=fraudulent;
run;

data bl_merged;
	format fraudulent yn.;
	format cat yn.;
	set capstone.EMSCAD_final 
		bl_boxplotdata(where=(value ne . and stat in ('MIN' 'Q1' 'MEDIAN' 'Q3' 'MAX' 'MEAN')));
	value=round(value, 0.01);
	run;

title 'benefits_length Box Plot';
proc sgplot data=bl_merged noautolegend;
	vbox benefits_length / category=fraudulent group=fraudulent 
							   fillattrs=(transparency=0.7) meanattrs=(symbol=diamond);
	xaxistable value / x=cat class=stat location=inside;
	yaxis grid;
run;

/* Binary variable distribution & fraudulent rates */

%let binary_var=has_legit_bigram;

/* distribution */
title "&binary_var Distribution";
proc sgplot data=capstone.EMSCAD_final;
	format fraudulent &binary_var yn.;
	vbar &binary_var / group=fraudulent groupdisplay=stack
					   datalabel seglabel seglabelattrs=(size=4) seglabelfitpolicy=noclip;
	yaxis label='Frequency' grid;
	keylegend / title='Fraudulent' location=inside position=topleft;
run;

/* fraudulent rates */
proc freq data=capstone.EMSCAD_final noprint;
	tables &binary_var*fraudulent / out=FreqOut(where=(fraudulent=1)) outpct;
run;

data FreqOut;
	set FreqOut;
	row_proportion=PCT_ROW/100;
	keep &binary_var row_proportion;
run;
 
title "&binary_var Fraudulent Rates";
proc sgplot data=FreqOut;
	format &binary_var yn. row_proportion percent6.2;
	vbar &binary_var / response=row_proportion datalabel
					   fillattrs=(color=red transparency=0.5);
	yaxis label="Fraudulent rate" grid;
run;
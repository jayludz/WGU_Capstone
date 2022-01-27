/* Create CSVs */
proc export data=capstone.emscad_clean_swoe
	outfile="&path/EMSCAD_clean_SWOE.csv"
	dbms=csv;
run;

proc export data=capstone.emscad_final
	outfile="&path/EMSCAD_final.csv"
	dbms=csv;
run;

proc export data=capstone.development
	outfile="&path/development.csv"
	dbms=csv;
run;

proc export data=capstone.training
	outfile="&path/training.csv"
	dbms=csv;
run;

proc export data=capstone.validation
	outfile="&path/validation.csv"
	dbms=csv;
run;
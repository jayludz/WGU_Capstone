# WGU_Capstone

Author: John Ludlum

Date: 1/26/2022

A logistic regression model is created to predict fraudulent job advertisements using the Employment Scam Aegean Dataset (EMSCAD), a public dataset of 17,880 job ads collected by researchers at the University of the Aegean in Greece which can be downloaded [here](http://emscad.samos.aegean.gr/). The project is structured in five parts:

1. The Raw Data folder contains **EMSCAD.csv**, the original EMSCAD.
2. The Text Mining folder contains **EMSCAD_text_mining.ipynb**, a Jupyter notebook to perform natural language processing on the job ads in the EMSCAD. The results are saved in **text_mining_results.csv**.
3. The Clean Data folder contains the following files:
   - **EMSCAD_final.csv**: cleaned EMSCAD merged with text mining results.
   - **development.csv**: development dataset for logistic regression model. Job advertisement scams only represent 4.84% of all ads in the original EMSCAD, so it was oversampled to create a development dataset where job advertisement scams represent 25% of the data.
   - **training.csv**: random 70% of development dataset where the 25% fraudulent rate is maintained. Used to train several logistic regression models.
   - **validation.csv**: remaining 30% of development dataset. Used for model comparison.
4. The SAS Programs folder contains five SAS programs written in SAS Studio:
   - **setup.sas**: sets up a working directory.
   - **data_prep.sas**: prepares the raw EMSCAD for analysis.
   - **visualizations.sas**: generates various data visualizations.
   - **logistic_regression.sas**: creates and evaulates logistic regression models.
   - **csv_conversion.sas**: converts SAS datasets to the CSV files in the Clean Data folder.
5. The Reports folder contains **Executive_Summary.pdf** (a brief summary of the project) and **Capstone_report.pdf** (a more comprehensive report).

This project was the capstone for my M.S. Data Analytics degree at Western Governors University completed in June 2021.

// Project: Social Housing
// Creation Date: 05-09-2023
// Last Update: 22-11-2023
// Author: Laura Arnemann 
// Goal: Merging Social Housing Data and creating binscatter plots 



if c(username) =="maxmonert" {
global TEMP /Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/temp
global IN /Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/raw
global output /Users/maxmonert/Desktop/Research/Projects/SocialHousing/output
global code /Users/maxmonert/Desktop/Research/Projects/SocialHousing/code
}

if c(username) =="laura" {
global TEMP C:/Users/laura/Desktop/SocialHousing/data/temp
global IN C:/Users/laura/Desktop/SocialHousing/data/raw
global output C:/Users/laura/Desktop/SocialHousing/output
global code C:/Users/laura/Desktop/SocialHousing/code
}

if c(username) == "sebastiansiegloch" {
global TEMP "/Users/sebastiansiegloch/Dropbox/projects/Social Housing/data/temp"
global IN "/Users/sebastiansiegloch/Dropbox/projects/Social Housing/data/raw"
global output /Users/sebastiansiegloch/projects/SocialHousing/output
global code /Users/lsebastiansiegloch/projects/SocialHousing/code
}

xxx

********************************************************************************
* Dofiles in the order they should be run 
********************************************************************************
* Preparing the main data set for the analysis 

* Generates Sebastians Command 
* do "${code}/programs.do"

/*
* 1st step: clean and prepare social housing data 
do "${code}/cleaning/01_lors_tocsv.do"

* 2nd step geocode the data and megre them to the plz regions 
* geocoding Python file 

* 2nd : cleaning Immoscout Data on LOR level 
do "${code}/cleaning/02_cleaning_sonderaufbereitung.do"

* 2nd : cleaning Immoscout Data on Object level 
do "${code}/cleaning/03_cleaning_objects.do"

* This file generates hedonic rent prices  
do "${code}/cleaning/04_prep_hedonic.do"

* 3rd step merge immoscout data with lor data
do "${code}/cleaning/05_merging_sonderaufbereitung.do"
*/
/*
* This file drops adjacent and adadjacent neighbors for lors 

* Before running these dofiles we need to run the python file gen_neighbors
do "${code}/cleaning/04_prep_stacking.do"

* This file prepares the data set to run a sythetic control analysis 
* Before running these dofiles we need to run the python file calculating_distance
do "${code}/cleaning/06_synthetic_control_prep.do

do "${code}/cleaning/07_cleaning_treatment_donors.do
*/

* Before running these dofiles we need to run the python file core_vs_periphery

/*
* These files generate the descriptive statistics 
* This dofile generates a descriptive statistics table and some binscatter plots 
do "${code}/analysis/02_descriptives.do" 

* Plots differences between treated and never-treated by treatment cohort
do "${code}/analysis/02_20_treat_descrp.do"

* Regression Analysis for never treated vs. always treated 
do "${code}/analysis/02_31_twfe.do"

* Regression Analysis with robustness for heterogeneous treatment effects 
do "${code}/analysis/02_32_did_robust.do"
*/

* Code to prepare the data for the analysis 
do "${code}/analysis/02_10_analysis_prep.do"

* Code to run the regression analysis with binning on LOR level 
do "${code}/analysis/02_33_binning_lor.do"

* Code to run the regression analysis with binning on Object Level
do "${code}/analysis/02_33_binning_objects.do"

* Code to run the regression analysis with binning on Object Level
do "${code}/analysis/02_34_binning_lor_stack.do"


/*
* === Analysis ====
* analysis prep file
do "${code}/analysis/02_10_analysis_prep.do"


* descriptive statistics describing treatment
do "${code}/analysis/02_20_treat_descrp.do"
*/

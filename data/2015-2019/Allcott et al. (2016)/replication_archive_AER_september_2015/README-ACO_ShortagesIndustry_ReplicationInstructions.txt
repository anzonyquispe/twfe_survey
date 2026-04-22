**********************************************************
***	Notes and instructions on replication backup
***	How Do Electricity Shortages Affect Industry? Evidence from India
*** Hunt Allcott, Allan Collard-Wexler, and Stephen D. O’Connell
***	File date: 22 September 2015
**********************************************************
This document provides guidance on use and navigation of the replication backup files 
for 
***	How Do Electricity Shortages Affect Industry? Evidence from India
*** Hunt Allcott, Allan Collard-Wexler, and Stephen D. O’Connell

These files contain raw data and the programs used to process the data and generate 
analyses used in the manuscript. Folders are organized as follows:

01. Data: 
Contains all raw datasets categorized by source. Relevant notes or source documentation
are kept alongside raw data in these folders. In the instances where we are not authorized 
to release raw data due to purchase/use agreements, we have provided a file manifest showing 
the full set of files that should exist in the folders once acquired by the user.

02. Programs:
Contains all programs to read and process data in preparation for analysis, and programs 
to replicate and output analyses. The programs folder contains subroutines which 
are called within other programs.

03. Simulations and GIS work:
Contains files and programs for completing the model simulations and related tables, as well
as GIS-based work and resulting intermediate files used in later processes.

The user should create the following folders in the main directory:

04. Working:
This is a working folder which is only used during the data processing steps.
It will only have files in it once the full replication code is adjusted and run.

05. Intermediate Datasets:
This is a working folder used to store analysis datasets prepared in the processing phase
It will only have files in it once the full replication code is adjusted and run.

08. Tex/RegResults:
This is an output folder used to save tabular output for the manuscript in TeX format. 
It will only have files in it once the full replication code is adjusted and run.


In order to run the replication code, the user must acquire several datasets 
and place them in the relevant folder in "01. Data". These are:

1) Annual Survey of Industries: 
-1992-93 summary record layout with common factory ID
-1998-99 to 2010-11 detailed record layout with common factory ID (purchased after June, 2013)
(These two data sources are available for purchase:
http://mospi.nic.in/Mospi_New/upload/asi/asi_users_note.html)

-1993-94 to 1997-98 detailed record layout with common factory ID

2) University of Delaware global gridded air temperatures and precipitation.
Available free of charge: http://climate.geog.udel.edu/~climate/html_pages/download.html

3) National Climactic Centre Rainfall and temperature
-Rainfall data 1x1 1951-2007 (plus updates for more recent years)
-Temperature data 1x1 1969-2009 (plus updates for more recent years)
-Data avaliable for purchase: www.imdpune.gov.in/E_%20Products%20of%20NCC.pdf‎


4) World Bank Enterprise Survey
-all datasets, India, 2005-2009
-Data available to researchers free of charge: http://www.enterprisesurveys.org/


After acquiring the above data, the user needs to do the following:

1) Adjust the header in each do-file to correctly refer to the main directory where the
replication folder has been placed -- OR -- set global dbroot in profile.do to point to
the directory above where the main folder is located.

2) Create the folders listed above in the main directory.

3) Run do-files in the main programs folder according to their numeric-alphabetical ordering.
Then run the matlab code found in the "matlab" folder (make_aco_matlab4.sh) to produce the 
simulation results.


Development was done primarily using a 64-bit Windows 7 PC with Stata 11.2 and 4GB RAM. 
Some programs use syntax from earlier Stata releases that may be deprecated already or in the 
future.

The matlab code was run using the NYU HPC General Cluster. All programs used Matlab 2014b. 
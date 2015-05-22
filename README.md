# gettingAndCleaningData
Course project for Getting and Cleaning Data class in the Data Science specialization

### Contents of Repository
This repository contains the files needed to obtain the data and produce the results for the course project.  

  - README.md - this file
  - run_analysis.R - the script to run for the project
  - codebook.md - code book

### Required Packages: 
If any of these are not installed the run_analysis.R script will stop

  - dplyr
  - tidyr
  - R.utils

### What this repository does
The R script (run_analysis) will do the following:

1. Downloads [data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) collected from Samsung Galaxy 5 smartphone accelerometers if not already present. Any directories needed will be created and the file will be unzipped if not previously done. Further descriptions of the raw data are available [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) and in the README file included in the downloaded data.
1. Read file activity_labels.txt into table activityLabels. This is used to provide human-friendly labels (in the second column) for the activity Id's (first column). Some beautification is performed on the label text.
1. Read file features.txt into table features. The second column is a vector which contains the names used for the columns in the training & testing measurement tables.
1. For each of the training and test data sets perform the following steps (the files are in the respective train or test sub-directories):

  1. Read the subjects_\*.txt file into a table (\*Subjects). This has the same number of rows as the corresponding measurement table and identifies the subject Id associated with the corresponding row in the measurement table.
  1. Read the y_\*.txt file into a table (\*Activities). This has the same number of rows as the corresponding measurement table and identified the activity Id associated with the corresponding row in the measurement table.
  1. Read the X_\*.txt file into a data frame (X_\*), using the second column of the features table (loaded above) as the column names.
  1. Add columns for the subject Id and activity to each data frame useing the tables from above
  1. Select only the columns we are interested in. In addition to the two we added in the above step, these are all the columns containing mean or standard deviation data. These are detected by the presence of the strings "mean" or "std" in the feature (column) name.
  
1. Combine the rows from the resulting trainging and testing tables into a new data frame. There is no need to distinguish rows from the training and testing sets, so we do not add a column to indicate the origin of the data.
1. Take following steps to create a tidy data set with the average of each variable for each activity and subject:

  1. Gather all the measurements so there is one measurement per row and the measurement name is a variable
  1. Group by the subject, activity and measurement type and add a column with the average for each grouping.
  1. Add a measurementType variable. Set this to "mean" or "std", depending on the presence of one of these strings in the measurement name.
  1. Remove the ".mean.." and ".std.." strings from the measurement names. At this point the mean and std measurements of the same quantity will have the same name
  1. Spread the measurement value into two columns, according to the measurement type
  
1. Write the resulting data frame to a text file (activity_analysis.txt) in the data directory

### Reading the results
From the working directory, use `read.table("./UCI HAR Dataset/activity_analysis.txt",header=TRUE)`

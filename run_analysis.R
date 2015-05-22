## Steps required in project
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# The working directory is assumed to be the CourseProject directory

# This should run regardless of whether the Samsung data is present or not
# Download/unzip file if not already done
# The data is from:
sourceUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"
dataDir <- "./UCI HAR Dataset"      # This is where the files will be unzipped to

# Make sure we have the needed packages loaded
if ( !(require(dplyr) && require(tidyr) && require(R.utils)) ) {
    stop ("You need to install the dplyr, tidyr and R.utils packages to run this script")
}

if ( !file.exists(zipFile) ) {
    download.file(sourceUrl, zipFile)
}


# unzip the files (will do nothing if we previously did this)
filepaths <- unzip(zipFile)

# Remember our directory and set the wd to the data directory
savedWD <- getwd()
setwd(dataDir)

# Get the activity labels and prettify them
activityLabels <- read.table("activity_labels.txt")
# This will capitalize each label, and change the underscores to spaces
activityLabels$V2 <- capitalize(tolower(gsub("_", " ", activityLabels$V2)))

# First get the feature names to use as the initial column labels
features <- read.table("features.txt")

# Get the training subject and activity id's and data
trainSubjects <- read.table("train/subject_train.txt")
trainActivities <- read.table("train/y_train.txt")
X_train <- tbl_df(read.table("train/X_train.txt", col.names=features$V2))

# Same for the testing subject and activity id's and data
testSubjects <- read.table("test/subject_test.txt")
testActivities <- read.table("test/y_test.txt")
X_test <- tbl_df(read.table("test/X_test.txt", col.names=features$V2))

# Add the subject Id's and activity labels and select only the desired columns
# The desired columns are the mean and standard deviation values (plus the columns we added) - these can be recognized by the correspoinding feature name
# Do this for both sets prior to merge so we don't have to consider the unused columns
trainData <- X_train %>% mutate(subjectId=trainSubjects$V1,
                                activity=activityLabels[trainActivities$V1,2]) %>%
    select( subjectId, activity, contains("mean"), contains("std") )

testData <- X_test %>% mutate(subjectId=testSubjects$V1,
                              activity=activityLabels[testActivities$V1,2]) %>%
    select( subjectId, activity, contains("mean"), contains("std") )


# Merge the training and test sets into one data set
# We do not need to keep track of which set a row came from
ds <- bind_rows( trainData, testData )

# Create the tidy data set with the average of each variable for each activity and each subject.
# Keys will be subject, activity, measurement name
# Values will be the mean and std for that key combo
gb <- ds %>%
    # Put each measurement in it's own row
    gather(measurement, val, -(subjectId:activity))  %>%
    
    # Take average for each subject,activty,measurement
    group_by( subjectId, activity, measurement ) %>%
    summarize(avg=mean(val)) %>%
    
    # Create a measurement type based on the presence of mean or std in the measurement
    # Initialize them all to mean then set the ones with std in the measurement name
    mutate( measurementType="mean" )

# There probably is a way to do this within the chain...
gb[grep("std", gb$measurement, fixed=TRUE),5] = "std"

    # Now that we have the measurement type, remove the mean and std from the measurement names
    # fixed=TRUE needed on the sub to keep the periods from being treated as RegEx wildcards
    # Spread the measurement values - replace val with mean and std columns
result <- gb %>%
    mutate(measurement=sub(".std..", "", sub(".mean..", "", measurement, fixed=TRUE), fixed=TRUE)) %>%
    spread(measurementType, avg)

    # Output to text file - note that this is in the data directory
    write.table(result, file="activity_analysis.txt", row.names=FALSE)

# Restore the orignial wd
setwd(savedWD)
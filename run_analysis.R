## Install packages that are needed
install.packages("RCurl")
install.packages("dplyr")
install.packages("plyr")
library(RCurl)
library(plyr)  ## please import plyr before dplyr or else code will not function correctly
library(dplyr)


## Setting working directory to desktop
setwd("../")
setwd("desktop")

## Downloading dataset from website provided
filename <- "Galaxy_S_Dataset.zip"
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL, filename)

## Unzipping downloaded dataset
if (!file.exists("Galaxy_S_Dataset")) { 
  unzip(filename) 
}

## Reading testing and training datasets
activities_train <- read.table("UCI HAR Dataset/train/Y_train.txt", header = F)
activities_test <- read.table("UCI HAR Dataset/test/Y_test.txt", header = F)
subjects_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = F)
subjects_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = F)

## Reading in activities and features dataset
activities <- read.table("UCI HAR Dataset/activity_labels.txt", header = F )
activities = rename(activities, ActivityID = V1, Activity = V2)
features <- read.table("UCI HAR Dataset/features.txt")
featuresList <- grep(".*mean.*|.*std.*", features$V2)
featuresNames <- features[featuresList,2]

## Text Cleanup on features
featuresNames = gsub("[()-]", "", featuresNames)
featuresNames = gsub("mean", "Mean", featuresNames)
featuresNames = gsub("std", "Std", featuresNames)


## Load the datasets on the mean + STD features 
features_train <- read.table("UCI HAR Dataset/train/X_train.txt", header = F)[featuresList]
features_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = F)[featuresList]

## Merge Datasets by features
train <- cbind(subjects_train, activities_train, features_train)
test <- cbind(subjects_test, activities_test, features_test)
combineDataset <- rbind(train,test)

## Rename labels
colnames(combineDataset) <- c("SubjectID", "ActivityID", featuresNames)

## Associate ActivityID to Activity 
tidyDataSet <- merge(activities, combineDataset, by = "ActivityID")

## (New) Independent Dataset with averages of each variable
tidyDataSet <- ddply(tidyDataSet, c("ActivityID", "Activity", "SubjectID"), numcolwise(mean))

## Rename labels once more
newNames <- names(tidyDataSet)
newNames = gsub("^t|^f", "", newNames)
colnames(tidyDataSet) <- newNames

## Write Tiday Dataset out to tidy.txt file for user
write.table(tidyDataSet, "tidy.txt", row.name=FALSE)



rm(list = ls())
library(dplyr)
library(plyr)
library(data.table)
#downloading datafiles into R
if(!file.exists("./getclean")){dir.create("./getclean")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./getclean/Dataset.zip",method="libcurl")
unzip(zipfile="./getclean/Dataset.zip",exdir="./getclean")
path_data <- file.path("./getclean" , "UCI HAR Dataset")
# check the files 
files<-list.files(path_data, recursive=TRUE)
files
#reading activity files
YTest  <- read.table(file.path(path_data, "test" , "Y_test.txt" ),header = FALSE)
YTrain <- read.table(file.path(path_data, "train", "Y_train.txt"),header = FALSE)
#reading subject files
SubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)
#reading feature files
XTest  <- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
XTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)
Features <- read.table(file.path(path_data, "features.txt"),head=FALSE)
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"), header = FALSE)
setnames(FeaturesNames, names(FeaturesNames), c("featureNum", "featureName"))
dataFeatures <- FeaturesNames$featureName
#reading column name labels 

colnames(XTrain) <- t(Features[2])
colnames(XTest) <- t(Features[2])


XTrain$activities <- YTrain[, 1]
XTrain$participants <- SubjectTrain[, 1]
XTest$activities <- YTest[, 1]
XTest$participants <- SubjectTest[, 1]

#1. Merge the training and the test sets to create one data set.

dat1 <- rbind(XTrain, XTest)
duplicated(colnames(dat1))
dat1 <- dat1[, !duplicated(colnames(dat1))]

#2. Extracts only the measurements on the mean and standard deviation for each measurement.

Mean <- grep("mean()", names(dat1), value = FALSE, fixed = TRUE)
# include 555:559 as they have means and are associated with the gravity terms
Mean <- append(Mean, 471:477)
InstrumentMeanMatrix <- dat1[Mean]
# For STD
STD <- grep("std()", names(dat1), value = FALSE)
InstrumentSTDMatrix <- dat1[STD]

#3. Uses descriptive activity names to name the activities in the data set



dat1$activities <- as.character(dat1$activities)
dat1$activities[dat1$activities == 1] <- "Walking"
dat1$activities[dat1$activities == 2] <- "Walking Upstairs"
dat1$activities[dat1$activities == 3] <- "Walking Downstairs"
dat1$activities[dat1$activities == 4] <- "Sitting"
dat1$activities[dat1$activities == 5] <- "Standing"
dat1$activities[dat1$activities == 6] <- "Laying"
dat1$activities <- as.factor(dat1$activities)

#4. Appropriately labels the data set with descriptive variable names.

names(dat1)  # 



#Using gsub to replace the list

names(dat1) <- gsub("Acc", "Accelerator", names(dat1))
names(dat1) <- gsub("Mag", "Magnitude", names(dat1))
names(dat1) <- gsub("Gyro", "Gyroscope", names(dat1))
names(dat1) <- gsub("^t", "time", names(dat1))
names(dat1) <- gsub("^f", "frequency", names(dat1))
#Replacing participants names

dat1$participants <- as.character(dat1$participants)
dat1$participants[dat1$participants == 1] <- "Participant 1"
dat1$participants[dat1$participants == 2] <- "Participant 2"
dat1$participants[dat1$participants == 3] <- "Participant 3"
dat1$participants[dat1$participants == 4] <- "Participant 4"
dat1$participants[dat1$participants == 5] <- "Participant 5"
dat1$participants[dat1$participants == 6] <- "Participant 6"
dat1$participants[dat1$participants == 7] <- "Participant 7"
dat1$participants[dat1$participants == 8] <- "Participant 8"
dat1$participants[dat1$participants == 9] <- "Participant 9"
dat1$participants[dat1$participants == 10] <- "Participant 10"
dat1$participants[dat1$participants == 11] <- "Participant 11"
dat1$participants[dat1$participants == 12] <- "Participant 12"
dat1$participants[dat1$participants == 13] <- "Participant 13"
dat1$participants[dat1$participants == 14] <- "Participant 14"
dat1$participants[dat1$participants == 15] <- "Participant 15"
dat1$participants[dat1$participants == 16] <- "Participant 16"
dat1$participants[dat1$participants == 17] <- "Participant 17"
dat1$participants[dat1$participants == 18] <- "Participant 18"
dat1$participants[dat1$participants == 19] <- "Participant 19"
dat1$participants[dat1$participants == 20] <- "Participant 20"
dat1$participants[dat1$participants == 21] <- "Participant 21"
dat1$participants[dat1$participants == 22] <- "Participant 22"
dat1$participants[dat1$participants == 23] <- "Participant 23"
dat1$participants[dat1$participants == 24] <- "Participant 24"
dat1$participants[dat1$participants == 25] <- "Participant 25"
dat1$participants[dat1$participants == 26] <- "Participant 26"
dat1$participants[dat1$participants == 27] <- "Participant 27"
dat1$participants[dat1$participants == 28] <- "Participant 28"
dat1$participants[dat1$participants == 29] <- "Participant 29"
dat1$participants[dat1$participants == 30] <- "Participant 30"
dat1$participants <- as.factor(dat1$participants)


#5. Create a tidy data set

dat2 <- data.table(dat1)
glimpse(dat2)
CleanData <- dat2[, lapply(.SD, mean), by = 'participants,activities']
write.table(CleanData, file = "Clean.txt", row.names = FALSE)

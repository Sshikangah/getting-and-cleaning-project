
#Cleaning up workspace

rm(list = ls())

#upload requied packages

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
SubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE )
SubjectTest  <- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)
#reading feature files
XTest  <- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
XTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)
Features <- read.table(file.path(path_data, "features.txt"),colClasses = c("character"))
#reading column labels and setting column labels
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"), col.names = c("ActivityId", "Activity"))
head(activityLabels)

# Assigin column names to the raw data
colnames(YTrain)= "ActivityId"
colnames(YTest)= "ActivityId"
colnames(SubjectTrain)= "SubjectId"
colnames(SubjectTest)= "SubjectId"
colnames(XTest)= Features[,2]
colnames(XTrain)= Features[,2]
colnames(activityLabels)= c("ActivityId", "Activity")

#1. Merge the training and the test sets to create one data set.
# merging training data files
training = cbind(YTrain,SubjectTrain,XTrain)

# merging test data files
test = cbind(YTest,SubjectTest,XTest)


# Combine into one data set
dat1 = rbind(training,test)
#check structure of dataset
glimpse(dat1)

#clean data by removing duplicates
dat2 = dat1[, !duplicated(colnames(dat1))]


# 2. Extract only the measurements on the mean and standard deviation for each measurement.

#create logical vector containing true and false based on selected criteria
mean_stdlogical = grepl("Id+", names(dat2)) |grepl("mean+", names(dat2)) | grepl("Mean+", names(dat2)) |grepl("std+", names(dat2))

#select only the logical vectors with true for measurements on mean and std only

dat3 = dat2[mean_stdlogical==TRUE]

 # 3. Use descriptive activity names to name the activities in the data set

# Merge the dat3 set with the acitivityLabels table to include descriptive activity names
dat3 = merge(dat3,activityLabels,by='ActivityId',all.x=TRUE)


# 4. Appropriately label the data set with descriptive activity names. 
data4 = dat3
# Cleaning up the variable names

names(data4) = gsub("\\()","",names(data4))
names(data4) = gsub("-std$","StdDev",names(data4))
names(data4) = gsub("-mean","Mean",names(data4))
names(data4) = gsub("^(t)","time",names(data4))
names(data4) = gsub("^(f)","frequency",names(data4))
names(data4) = gsub("([Gg]ravity)","Gravity",names(data4))
names(data4) = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",names(data4))
names(data4) = gsub("[Gg]yro","Gyroscope",names(data4))
names(data4) = gsub("AccMag","Accelerator_Magnitude",names(data4))
names(data4) = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",names(data4))
names(data4) = gsub("JerkMag","JerkMagnitude",colnames(data4))
names(data4) = gsub("GyroMag","GyroMagnitude",colnames(data4))
head(data4)

# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Create a new table, data without the activityLabel column
data  = data4[,names(data4) != 'activityLabels']

# calculating mean of each variable for each activity and each subject
cleanData    = aggregate(data[,names(data) != c('ActivityId','SubjectId')],by=list(ActivityId=data$ActivityId,SubjectId= data$SubjectId),mean)

# Merging the cleanData with activityLabels to include descriptive acitvity names
cleanData  = merge(cleanData,activityLabels,by='ActivityId',all.x=TRUE)
# delete variable Activity.x has NAs after calculation of means
cleanData$Activity.x  = NULL
View(cleanData)

# Export the cleanData set 
write.table(cleanData, './cleanData.txt',row.names=TRUE,sep='\t')

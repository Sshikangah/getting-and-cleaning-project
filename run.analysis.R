if(!file.exists("./getclean")){dir.create("./getclean")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./getclean/Dataset.zip",method="libcurl")
unzip(zipfile="./getclean/Dataset.zip",exdir="./getclean")
path_data <- file.path("./getclean" , "UCI HAR Dataset")
files<-list.files(path_data, recursive=TRUE)
files
#reading activity files
ActivityTest  <- read.table(file.path(path_data, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path_data, "train", "Y_train.txt"),header = FALSE)
#reading subject files
SubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)
#reading feature files
FeaturesTest  <- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)
FeaturesNames <- read.table(file.path(path_data, "features.txt"),head=FALSE)
setnames(FeaturesNames, names(FeaturesNames), c("featureNum", "featureName"))
dataFeatures <- FeaturesNames$featureName
#reading column name labels 
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"), header = FALSE)
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))
#looking at data
str(ActivityTest)
str(ActivityTrain)
str(SubjectTest)
View(ActivityTest)
View(SubjectTest)
View(FeaturesNames)



#1. merge Activity data, Subject data, Feature data
Activity <- rbind(ActivityTest, ActivityTrain)
Subject <- rbind(SubjectTest, SubjectTrain)
Features <- rbind(FeaturesTest, FeaturesTrain)
#Set variable names
setnames(Activity, "V1", "activity")
setnames(Subject, "V1", "subject")
#check variable names dataset
names(Activity)
names(Subject)
names(Features)
#combine by columns
dat1<- cbind(Subject, Activity)
dat2 <- cbind(dat1, Features)
View(dat2)
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
dataMeanStd <- grep("mean\\(\\)|std\\(\\)",FeaturesNames$featureName,value=TRUE)
#subset
# Taking only measurements for the mean and standard deviation and add "subject","activityNum"

selectedNames<-c(as.character(dataMeanStd), "subject", "activityNum" )
Data<-subset.matrix(dat2, select = dataMeanStd, drop = FALSE)
View(Data)
#3. Uses descriptive activity names to name the activities in the data set


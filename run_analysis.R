#A full description is available at the site where the data was obtained:
  
#  http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

#Here are the data for the project:
  
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

#You should create one R script called run_analysis.R that does the following.

#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement.
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names.
#From the data set in step 4, creates a second, independent tidy data set with the average 
#of each variable for each activity and each subject.

# see https://rpubs.com/ninjazzle/DS-JHU-3-4-Final

########################################################################3

### INITIAL SET UP WORKSPACE
# load needed libraries
library (dplyr)

# set working directory
directory<-Sys.getenv("directory")
setwd(directory)

# download archive and extract files 
if (!file.exists("data_archive.zip"))
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data_archive.zip")
if (file.exists("data_archive.zip"))
  unzip("data_archive.zip")

# read files into data frames
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test<-read.table("UCI HAR Dataset/test/subject_test.txt")
measurement_test <- read.table("UCI HAR Dataset/test/X_test.txt")
measurement_train <- read.table("UCI HAR Dataset/train/X_train.txt")
activity_test <- read.table("UCI HAR Dataset/test/y_test.txt")
activity_train <- read.table("UCI HAR Dataset/train/y_train.txt")
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("ActivityID", "Activity"))

features <- read.table("UCI HAR Dataset/features.txt", col.names=c("rowNum","varName")) 

# clean up features
features$varName <- gsub("\\()","",features$varName )


### STEP 1:  merge test and train datasets; 
measurement_combo<-rbind(measurement_test, measurement_train)
names(measurement_combo)<-features$varName

subject_combo<- rbind(subject_test, subject_train)
names(subject_combo)<-"Subject"

# add descriptive labels to activity datasets
activity_train<-merge(activity_train, activity_labels)
activity_test<-merge(activity_test, activity_labels)
# merge test and train activity datasets
activity_combo<-rbind(activity_test, activity_train)
# remove numeric ActivityID column
activities<-subset(activity_combo, select=-ActivityID)

data<-cbind(subject_combo, activities, measurement_combo)

### STEP2: extract only measurements of mean and standard deviation from data 

desired_cols<- grep("mean\\-|std\\-|mean$|std$|Subject|Activity", colnames(data))

reduced_data<-data[,desired_cols]

### STEP 3:  Assign descriptive names to activities in dataset
# done as part of step 1

### STEP 4 :  assign variable names to columns in dataset
# done as part of step 1

#  Write the dataset to file
write.table(reduced_data,"mean_and_std_deviation_dataset.txt")

### STEP 5:  From the data set in step 4, create a second, independent tidy data set 
### with the average of each variable for each activity and each subject.

#activity_subject_groups<-group_by(reduced_data, Activity, Subject)
#summary<-summarise_each(activity_subject_groups, funs(mean()), rm.)
mean_summary<-reduced_data
final<-mean_summary %>%
  group_by(Activity, Subject) %>%
  summarise_all("mean")

write.table(final, "mean_summary_data.txt", row.name=FALSE)

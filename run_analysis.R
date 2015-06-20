# Coursera Getting and Cleaning Data - Course Project
# Marcelo Ferreira Londero
# Getting and cleaning data from the accelerometers from the Samsung Galaxy S smartphone


## 1 - Merges the training and the test sets to create one data set

#---------------- reading
#reading the test data set
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#reading the training data set
xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

#reading the features
features <- read.table("./UCI HAR Dataset/features.txt")

#reading the activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

#---------------- merging 
#merging the x data sets
x <- rbind(xtest, xtrain)

#merging the y (labels) data sets
y <- rbind(ytest, ytrain)

#merging the subject data sets
subject <- rbind(subject_test, subject_train)

#merging the labels, the subjects and the data set 
merged_data <- cbind(y, subject, x)


## 2 - Extracts only the measurements on the mean and standard deviation for each measurement

mean_sd_data <- merged_data[, c(1, 2, grep("mean", features$V2)+2, #subsetting just the variable names which contains 'mean' and 'std'
               grep("std", features$V2)+2)]

## 3 - Uses descriptive activity names to name the activities in the data set

mean_sd_data <- merge(activity_labels, mean_sd_data, by = "V1", all = TRUE) #getting the activities names from the activity_labels.txt file

## 4 - Appropriately labels the data set with descriptive variable names 

features[,3] <- as.character(features[,2]) #creating a new column with the variable names as character

for (i in 1:nrow(features)) #replacing some words, turning the variable names clearer 
{
  features[i,3] <- gsub("-std", "_sdDev",
                            gsub("\\()", "",
                                 gsub("-mean", "_mean",
                                      gsub("^(t)","time_",    
                                           gsub("^(f)","freq_",
                                                gsub("GyroMag", "GyroMagnitude",
                                                     gsub("JerkMag", "JerkMagnitude",  
                                                          gsub("Bodyaccjerkmag", "BodyAccelJerkMagnitude",
                                                              gsub("AccMag", "AccelMagnitude",                
                                                                   gsub("BodyBody", "Body",
                                                                        features[i,3]))))))))))                       
}
  

names(mean_sd_data) <- c("code_activity",
                         "activity",
                         "subject",
                         features[c(grep("mean", features$V2),grep("std", features$V2)),3]) #attributing the variable names to the data


## 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

mean_sd_data_without_activity <- mean_sd_data[,names(mean_sd_data) != 'activity'] #creating a object without the variable 'activity'

tidyData <- aggregate(mean_sd_data_without_activity[,names(mean_sd_data_without_activity) != c('code_activity','subject')],
                     by = list(code_activity = mean_sd_data_without_activity$code_activity,
                               subject = mean_sd_data_without_activity$subject),
                     mean) #creating the tidy data, calculating the mean of each variable for each activity and each subject

names(activity_labels) <- c("code_activity", "activity") #naming the activity labels columns

tidyData <- merge(activity_labels, tidyData, by = "code_activity", all = TRUE) #getting the activities names from the activity_labels object


#export the tidy data
write.table(tidyData, "tidyData.txt", row.name=FALSE) 

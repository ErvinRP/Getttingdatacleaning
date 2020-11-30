# Proyecto final "Getting and cleaning Data"
# -------------------------------------------------------------------------------
# Descargar el archivo y luego descomprimir
url<-'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
datzip <- 'Dataset.zip'
if(!file.exists(datzip)) {
  download.file(url,datzip)}
datauci <- 'UCI HAR Dataset'
if(!file.exists(datauci)) {
  unzip(datzip)
}

library(data.table)
library(dplyr)

path<-getwd()
SubjTrain <- data.table(read.table(file.path(path, datauci, 'train', 'subject_train.txt')))
SubjTest <- data.table(read.table(file.path(path, datauci, 'test', 'subject_test.txt')))
Subj <- rbind(SubjTrain, SubjTest)
names(Subj) <- c('Subject')
remove(SubjTrain,SubjTest)

ActTrain <- data.table(read.table(file.path(path, datauci, 'train','Y_train.txt')))
ActTest <- data.table(read.table(file.path(path,datauci,'test','Y_test.txt')))
Act <- rbind(ActTrain,ActTest)
names(Act) <- c('Activity')
remove(ActTrain,ActTest)

Subj <- cbind(Subj,Act)
remove(Act)

Train <- data.table(read.table(file.path(path,datauci,'train','X_train.txt')))
Test <- data.table(read.table(file.path(path,datauci,'test','X_test.txt')))
dt <- rbind(Train,Test)
remove(Train,Test)

dt <- cbind(Subj,dt)
setkey(dt,Subject,Activity)
remove(Subj)

Feats <- data.table(read.table(file.path(path,datauci,'features.txt'))) 
names(Feats) <- c('ftNum','ftName')
Feats <- Feats[grepl("mean\\(\\)|std\\(\\)",ftName)]
Feats$ftCode <- paste('V', Feats$ftNum, sep = "")

dt <- dt[,c(key(dt), Feats$ftCode),with=F]

setnames(dt, old=Feats$ftCode, new=as.character(Feats$ftName))

dtActNames <- data.table(read.table(file.path(path, datauci, 'activity_labels.txt')))
names(dtActNames) <- c('Activity','ActivityName')
dt <- merge(dt,dtActNames,by='Activity')
remove(dtActNames)

dtTidy <- dt %>% group_by(Subject, ActivityName) %>% summarise_each(funs(mean))
dtTidy$Activity <- NULL

names(dtTidy) <- gsub('^t', 'time', names(dtTidy))
names(dtTidy) <- gsub('^f', 'frequency', names(dtTidy))
names(dtTidy) <- gsub('Acc', 'Accelerometer', names(dtTidy))
names(dtTidy) <- gsub('Gyro','Gyroscope', names(dtTidy))
names(dtTidy) <- gsub('mean[(][)]','Mean',names(dtTidy))
names(dtTidy) <- gsub('std[(][)]','Std',names(dtTidy))
names(dtTidy) <- gsub('-','',names(dtTidy))

write.table(dtTidy,"tidy.txt")  

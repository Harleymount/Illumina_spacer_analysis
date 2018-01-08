#====================================================================
#get the input csv files and skip the last file, which is actually this R script
args = commandArgs(trailingOnly=TRUE)
dir=args[1]

files <- list.files(path=dir, pattern="*.csv", full.names=T, recursive=FALSE)
files<-tail(files, -1)
#====================================================================



#====================================================================
#FOR DEBUGGING
#dir<-'/Users/Harley/Desktop/test_illumina/split_files'
#files <- list.files(path=dir, pattern="*.csv", full.names=T, recursive=FALSE)
#files<-tail(files, -1)
#====================================================================

#====================================================================
#Make the dataframe for spacer storage
length_dataframe=read.csv(files[1], header=F)
length_dataframe$V2<-as.numeric(length_dataframe$V2)
column_name<-paste(unlist(strsplit(files[1], '\\.'))[grep('part', unlist(strsplit(files[1], '\\.')))])
colnames(length_dataframe)<-c('spacer',column_name)
#====================================================================

#====================================================================
#populate the dataframe

for (i in tail(files,-1)){
    new_data=read.csv(i, header=F)
    column_name<-paste(unlist(strsplit(i, '\\.'))[grep('part', unlist(strsplit(i, '\\.')))])
    length_dataframe<-cbind(length_dataframe, new_data$V2)
    colnames(length_dataframe)[which(names(length_dataframe) == 'new_data$V2')]<-column_name}
#====================================================================

#====================================================================
#to binary-ize the matrix want to convert dataframe to a matrix of values instead, need to properly format the 
#rows column though and get spacers column out of the matrix
row_names<-length_dataframe$spacer
rownames(length_dataframe)<-row_names
length_dataframe$spacer<-NULL
length_dataframe_matrix<-as.matrix(length_dataframe)


#====================================================================
#denny's filtering criteria for spacer presence/absence 
length_dataframe_matrix[length_dataframe_matrix > 0.60 ] <- 1
length_dataframe_matrix[length_dataframe_matrix < 0.60 ] <- 0
#====================================================================




#====================================================================
#put data back into a dataframe for downstream processing
filtered_data<-as.data.frame(length_dataframe_matrix)
filtered_data <- cbind(spacer = rownames(filtered_data), filtered_data)
write.csv(filtered_data, "matrix_output.csv")
#====================================================================


#====================================================================
#add code to transpose and sort matrix and output that as well 
target<-c("3'flank", 'Sp1', 'Sp7', 'Sp15', 'Sp21', 'Sp29', 'Sp36', 'Sp43',"5'flank")
filtered_data_sorted<-filtered_data[match(target, filtered_data$spacer),]
transposed_data<-t(filtered_data_sorted)
transposed_data_2<-as.data.frame(transposed_data)
transposed_data_2<-transposed_data_2[transposed_data_2$`3'flank` != 0,]
transposed_data_2<-transposed_data_2[transposed_data_2$`5'flank` != 0,]
write.table(transposed_data_2, "matrix_output_transpose.csv", sep=',', col.names=F, quote=F)
#====================================================================


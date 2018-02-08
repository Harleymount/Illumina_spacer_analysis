"""
Created on Sat Oct 28 08:20:14 2017

@author: Harley
"""

#python script to iterate over all of the bedtools .tdt files and determine the 
#average coverage for each .bam file in each spacer 
#make sure to put the spacers.bed file in the same directry as the tdt files 


import sys
import glob
import multiprocessing
import os 

provided_input=sys.argv[1:]

list_of_spacers=[]
regions=open(provided_input[0]+'/flankspacers.bed', 'r')

region=regions.readline()

while region != '':
    region=region.strip().split('\t')
    list_of_spacers.append((region[1], region[2], region[3]))
    region=regions.readline()


def average_coverage(filename):
    #for filename in os.listdir(os.getcwd())[:]:  # will comment this out, to try not looping over every file, will also change the function to take a thing called filename
        if str(filename)!= '.DS_Store' and str(filename) !='flankspacers.bed' and str(filename) !='average_coverage.py' and str(filename) !='merge_csv.R' and str(filename) !='analyze_reads.py'and str(filename) !='.Rhistory' and str(filename) !='plot_crossovers.R'and str(filename) !='plot_losses.R' and str(filename) !='heatmap_matrix_maker.R':
            coverage_file=open(filename, 'r')
            line=coverage_file.readline()
            cov_dict={}
            count_dict={}
            line_list=[]
            while line != '':
                line=line.strip().split('\t')
                line_list.append(line)
                for item in list_of_spacers:
                    if int(line[1]) >= int(item[0]) and int(line[1]) <= int(item[1]):
                        if item[2] not in cov_dict:
                            cov_dict[item[2]]=int(line[2])
                        elif item[2] in cov_dict:
                            cov_dict[item[2]] += int(line[2])
                line=coverage_file.readline()
            sample_average_coverage=[]
            for item in list_of_spacers:
                distance=(int(item[1])-int(item[0])+1)
                count_dict[item[2]]=distance
            for key, value in cov_dict.items():
                if key in count_dict:
                    sample_average_coverage.append((key, cov_dict[key]/count_dict[key]))
            import csv
            with open(filename+'.csv', 'w') as csv_file:
                writer = csv.writer(csv_file)
                writer.writerows(sample_average_coverage)
            

p = multiprocessing.Pool()
for f in glob.glob("*.tdt"):
    # launch a process for each file (ish).
    # The result  be approximately one process per CPU core available.
    p.apply_async(average_coverage, [f]) 

p.close()

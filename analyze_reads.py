# -*- coding: utf-8 -*-
"""
Created on Sun Oct 29 12:40:35 2017

@author: Harley
"""


import sys 
provided_input=sys.argv[1:]
matrix_file_path=provided_input[0]
matrix_file=open(matrix_file_path,'r')

line=matrix_file.readline().strip()
line=matrix_file.readline().strip()
read_name=line.split(',')[0]
read_info=line.split(',')[1:]
read_info_list=[]

while read_name !='':
    previous_item=999
    zero_length=0
    zero_stretches=0
    stretch_lengths=[]
    for item in read_info[1:-1]:
        if float(item) == 0.0  and float(previous_item) != 0.0: #when you have a spacer that is 0, and the last spacer wasn't a zero 
            zero_length+=1
            zero_stretches+=1
        elif float(item) == 0.0  and float(previous_item) == 0.0:
            zero_length+=1
        elif float(item) != 0.0 and float(previous_item) == 0.0:
            stretch_length=zero_length
            stretch_lengths.append((stretch_length,zero_stretches))
            zero_length=0#if the the next spacer is covered but the last one wasnt record how long the stretch of absence was
            #reset the stretch lengths back to 0, and also record the stretch number, i.e. first zero stretch.  This is stored in stretch_lengths as a tuple to be used later        
        previous_item=item
    if zero_length != 0:
        stretch_lengths.append((zero_length,zero_stretches))
    read_info_list.append((read_name,zero_stretches,stretch_lengths))
    line=matrix_file.readline().strip()
    read_name=line.split(',')[0]
    read_info=line.split(',')[1:]


full_length=0
continuous=[]
discontinuous=[]

    
    
for item in read_info_list:
    if item[1]==0:
        full_length+=1
    elif item[1] == 1:
        continuous.append((item[0],item[2][0]))
    elif item[1] >= 2:
        discontinuous.append((item[0], item[1]))


continuous_output=[]
for item in continuous:
    continuous_output.append((item[0],item[1][0]))
    


output_file=open('output_report.txt', 'w')

output_file.writelines("Nanopore Spacer Loss Analysis Version 1.0 \n")
output_file.writelines('Full Length Reads Detected:' + str(full_length) + '\n')
output_file.writelines('Continuous Losses Detected (read name, length) : \n')
for item in continuous_output:
    output_file.writelines(item[0] + '          '+str(item[1]) + '\n')
output_file.writelines('Discontinuous Losses Detected (read name, # of Crossovers) : \n')
for item in discontinuous:
    output_file.writelines(item[0] + '          '+str(item[1])+'\n')
    
    




import csv
with open('discontinuous_hist.csv', 'w') as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(['read_name','crossovers'])
    writer.writerows(discontinuous)
            
            
with open('continuous_hist.csv', 'w') as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(['read_name','loss_length'])
    writer.writerows(continuous_output)
            
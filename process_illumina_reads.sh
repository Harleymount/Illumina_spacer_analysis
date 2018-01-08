#!/bin/bash
#get command line options ----------------------------------------
for arg in "$@"; do
  shift
  case "$arg" in
    "--reference") set -- "$@" "-r" ;;
    "--spacer_bed") set -- "$@" "-x" ;;
	"--directory")   set -- "$@" "-z" ;;
	"--read_1")   set -- "$@" "-q" ;;
	"--read_2")   set -- "$@" "-s" ;;
    *)        set -- "$@" "$arg"
  esac
done


while getopts r:x:z:q:s: option
do
 case "${option}"
 in
 r) reference=${OPTARG};;
 x) spacer_bed=${OPTARG};;
 z) dir=$OPTARG;;
 q) read_1=${OPTARG};;
 s) read_2=${OPTARG};;
 esac
done

cd $dir;
#not adding quality filtering at this point, if necessary can be implemenbted here at a later point

#---------------------------------------------------------------------

#interleave reads
shuffleSequences_fastq.pl $read_1 $read_2 merged.fastq;

#rm read_1
#rm read_2

#now split reads into individual files for processing

mkdir split_files
cp merged.fastq split_files
cp average_coverage.py split_files
cp merge_csv_illumina.R split_files
cp $spacer_bed split_files
cd split_files
perl /usr/local/bin/fastq-splitter.pl --part-size 2 --measure count merged.fastq
rm merged.fastq

gmap_build -d pLENS.genome $reference

ls | grep -E '\.fastq$' | parallel -j 0 'gmap -d pLENS.genome -A {} -f samse > {}.sam';

find . -name '*.fastq' -print0 | xargs -0 rm;

ls | grep -E '\.sam$' | parallel -j 0 'Picard SamFormatConverter I={} O={}.bam';
find . -name '*.sam' -print0 | xargs -0 rm;


ls | grep -E '\.bam$' | parallel -j 0 'Picard AddOrReplaceReadGroups I={} O={}_sorted.bam SORT_ORDER=coordinate RGLB=NA RGPL=Nanopore RGPU=NA RGSM=NA';
find . -name '*.sam.bam' -print0 | xargs -0 rm;



ls | grep -E '\_sorted.bam$' | parallel -j 0 'bedtools genomecov -d -split -ibam {} > {}.tdt';
find . -name '*_sorted.bam' -print0 | xargs -0 rm;


#now run my average coverage python script 
python average_coverage.py $dir

find . -name '*.tdt' -print0 | xargs -0 rm;

#added to remove empty files that will throw errors in processing with R. 
find . -size 0 -delete

Rscript merge_csv_illumina.R $dir/split_files






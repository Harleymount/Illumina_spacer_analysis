#!/bin/bash
#analyze reads 
for arg in "$@"; do
  shift
  case "$arg" in
    "--matrix") set -- "$@" "-r" ;;
	"--directory")   set -- "$@" "-z" ;;
    *)        set -- "$@" "$arg"
  esac
done


while getopts r:z: option
do
 case "${option}"
 in
 r) file=${OPTARG};;
 z) dir=$OPTARG;;
 esac
done

cd $dir;

python analyze_reads.py $file;


Rscript plot_crossovers.R $dir discontinuous_hist.csv;
Rscript plot_losses.R $dir continuous_hist.csv;
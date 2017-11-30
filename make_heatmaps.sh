#!/bin/bash
#analyze reads 
for arg in "$@"; do
  shift
  case "$arg" in
    "--matrix") set -- "$@" "-r" ;;
	"--continuous_hist_output")   set -- "$@" "-z" ;;
	"--discontinuous_hist_output")   set -- "$@" "-a" ;;
	"--directory")   set -- "$@" "-x" ;;	
    *)        set -- "$@" "$arg"
  esac
done


while getopts r:z:a:x: option
do
 case "${option}"
 in
 r) raw=${OPTARG};;
 z) cont=${OPTARG};;
 a) discont=${OPTARG};;
 x) dir=$OPTARG;;
 esac
done

cd $dir;

Rscript heatmap_matrix_maker.R $raw $discont $cont;
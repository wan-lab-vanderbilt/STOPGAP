#!/usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## stopgap_initialize_folder.sh
# Bash script for initializing default STOPGAP folders for various tasks.
#
# To use, run this script with the appropriate task as input.
# Tasks are: 'subtomo', 'tm', 'pca', 'vmap'
#
# WW 07-2017



# Parse input arguments
args=("$@")
task=${args[0]}


# Initialize folder by task
if [[ ${task} == 'subtomo' ]]; then
    echo "Initializing subtomogram averaging folder..."
    mkdir -p params temp comm raw ref masks lists fsc subtomograms meta

elif [[ ${task} == 'tm' ]]; then
    echo "Initializing template matching folder..."
    mkdir -p params temp comm lists tmpl masks maps meta

elif [[ ${task} == 'pca' ]]; then
    echo "Initializing PCA folder..."
    mkdir -p params temp comm raw ref masks lists subtomograms rvol pca meta
elif [[ ${task} == 'vmap' ]]; then
    echo "Initializing variance map folder..."
    mkdir -p params temp comm raw ref masks lists subtomograms meta
else
    echo "ACHTUNG!!! Unsupported task!!! Tasks are: 'subtomo' 'tm' 'pca' 'vmap'"
    exit 1
fi

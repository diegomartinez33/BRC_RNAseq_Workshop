#!/bin/bash
# Building an Index for HISAT2

#Make a new folder your HISAT2 index
mkdir -p ~/03_hisat2
mkdir -p ~/03_hisat2/hisat2_index 

#Change directory into folder
cd ~/03_hisat2/hisat2_index

#Check that your genome is located in the correct path
hisat2-build ~/genome/*.fna genome_index &>> HISAT2_build.log

#!/bin/bash
# Run HISAT2 for each sample

# Make a log directory
mkdir -p ~/03_hisat2/log

# --dta This option is needed to later run StringTie.
# -x This is the folder where you built your genome index. 
# -1 This is a list of your forward reads.
# -2 These are your reverse reads.
# -S This is an output and is a SAM alignment file for each read.
# log.txt This is your alignment summary/log.
# -p This is the number of threads to run your process on. 

hisat2 --dta -x ~/03_hisat2/hisat2_index/genome_index \
-1 ~/02_trimreads/SRR19736866_R1_paired.fastq \
-2 ~/02_trimreads/SRR19736866_R2_paired.fastq \
-S ~/03_hisat2/SRR19736866.sam \
-p 3 \
 &>> ~/03_hisat2/log/SRR19736866_log.txt

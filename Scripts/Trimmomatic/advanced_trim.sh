#!/bin/bash

# Define the location of programs and folders with variables
TRIMMOMATIC="/home/ubuntu/Trimmomatic-0.36"
INPUT_DIR="/home/ubuntu/01_fastqfiles"
OUTPUT_DIR="/home/ubuntu/02_trimreads"
LOG_DIR="/home/ubuntu/02_trimreads/logs"

# Make these directories
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Trimmomatic command
java -jar "$TRIMMOMATIC/trimmomatic-0.36.jar" PE "$INPUT_DIR/SRR19736866_1.fastq" "$INPUT_DIR/SRR19736866_2.fastq" \
  "$OUTPUT_DIR/SRR19736866_R1_paired.fastq" "$OUTPUT_DIR/SRR19736866_R1_unpaired.fastq" \
  "$OUTPUT_DIR/SRR19736866_R2_paired.fastq" "$OUTPUT_DIR/SRR19736866_R2_unpaired.fastq" \
  ILLUMINACLIP:"$TRIMMOMATIC/adapters/TruSeq3-PE-2.fa":2:30:10:2:keepBothReads LEADING:3 TRAILING:3 MINLEN:75 \
  &>> "$LOG_DIR/Trimmomatic_SRR19736866.log"

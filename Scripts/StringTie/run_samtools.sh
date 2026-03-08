#!/bin/bash

# Define variables
INPUT_DIR="/home/ubuntu/03_hisat2sam"
OUTPUT_DIR="/home/ubuntu/04_sortedbam"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through all SAM files in the input directory
for SAM in "$INPUT_DIR"/*.sam
do
    # Extract the filename without path or extension
    BASENAME=$(basename "$SAM" .sam)

    # Tell me which sample is running
    echo "Processing $BASENAME..."

    # Convert SAM to BAM
    samtools view -bS "$SAM" > "$OUTPUT_DIR/$BASENAME.bam"

    # Sort BAM file
    samtools sort "$OUTPUT_DIR/$BASENAME.bam" -o "$OUTPUT_DIR/$BASENAME.sorted.bam"

done

echo "All done."
date

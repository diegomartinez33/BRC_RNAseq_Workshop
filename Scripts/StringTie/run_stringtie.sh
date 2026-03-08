#!/bin/bash

# Variables ----

# Define paths to programs, input, and output
# Can call program from shared directory
STRINGTIE_DIR="/home/workshop/stringtie"
GENOME_DIR="/home/workshop/genome"

INPUT_DIR="/home/ubuntu/04_sortedbam"
OUTPUT_DIR="/home/ubuntu/05_stringtie"
LOG_DIR="/home/ubuntu/05_stringtie/logs"

# Set number of threads
THREADS=3 

# Define annotation and prepDE script
ANNOTATION_GFF="$GENOME_DIR/genomic.gff"
PREPDE="$STRINGTIE_DIR/prepDE.py3"

# Create output and log directories ----
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Bash functions for each part of the StringTie pipeline ----

run_stringtie_before_merge() {
    echo "Starting StringTie before merge..."

    for BAM in "$INPUT_DIR"/*.sorted.bam
    do
        BASENAME=$(basename "$BAM" .sorted.bam)

        echo "Processing $BASENAME..."

        "$STRINGTIE_DIR/stringtie" "$BAM" \
            -o "$OUTPUT_DIR/$BASENAME.gtf" \
            -G "$ANNOTATION_GFF" \
            -A "$OUTPUT_DIR/$BASENAME.abund.tab" \
            -C "$OUTPUT_DIR/$BASENAME.cov_refs.gtf" \
            -p "$THREADS" \
            &>> "$LOG_DIR/$BASENAME.firstpass.log"
    done

    echo "StringTie before merge complete."
	date
}

run_stringtie_merge() {
    echo "Running StringTie merge..."

    "$STRINGTIE_DIR/stringtie" --merge \
        -G "$ANNOTATION_GFF" \
        -o "$OUTPUT_DIR/merged_transcripts.gtf" \
        "$OUTPUT_DIR"/*.gtf \
        &>> "$LOG_DIR/stringtie_merge.log"

    echo "StringTie merge complete."
	date
}

run_stringtie_after_merge() {
    echo "Starting StringTie after merge..."

    for BAM in "$INPUT_DIR"/*.sorted.bam
    do
        BASENAME=$(basename "$BAM" .sorted.bam)

        mkdir -p "$OUTPUT_DIR/$BASENAME"

        echo "Re-processing $BASENAME with merged transcripts..."

        "$STRINGTIE_DIR/stringtie" "$BAM" \
            -e -B \
            -G "$OUTPUT_DIR/merged_transcripts.gtf" \
            -o "$OUTPUT_DIR/$BASENAME/$BASENAME.merged.gtf" \
            -A "$OUTPUT_DIR/$BASENAME/$BASENAME.abund_merged.tab" \
            -p "$THREADS" \
            &>> "$LOG_DIR/$BASENAME.stringtie2.log"
    done

    echo "StringTie after merge complete."
	date
}

main() {
    run_stringtie_before_merge
    run_stringtie_merge
    run_stringtie_after_merge
}

main "$@"

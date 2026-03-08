#!/bin/bash

# Variables ----
# Define paths to programs, input, and output
INPUT_DIR="/home/ubuntu/04_sortedbam"
OUTPUT_DIR="/home/ubuntu/05_stringtie"
STRINGTIE_DIR="/home/ubuntu/stringtie"
PREPDE="$STRINGTIE_DIR/prepDE.py3"

generate_counts_table() {

    echo "Generating count matrix"

    SAMPLE_LIST="$OUTPUT_DIR/sample_lst.txt"

    # Create or clear the sample list
    > "$SAMPLE_LIST"

    # Find all merged GTF files and build sample list
    for FILE in "$OUTPUT_DIR"/*/*.merged.gtf
    do
        BASENAME=$(basename "$FILE" .merged.gtf)
        echo "$BASENAME $FILE" >> "$SAMPLE_LIST"
    done

    # Run prepDE.py3
    (
        cd "$OUTPUT_DIR" || exit 1
        python3 "$PREPDE" -i sample_lst.txt
    )

    echo "Count matrix generation complete."

}

generate_counts_table "$@"

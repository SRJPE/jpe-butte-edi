#!/bin/bash

# Read in the CSV file
input_file="data-raw/version_log.csv"
second_last_row=$(tail -2 $input_file | head -1)

# Extract the value of the first column
filename=$(echo $second_last_row | cut -d ',' -f 1)
extension=".xml"

# Export the value
export FULL_FILE_NAME="$filename$extension"

# Use the value in git rm
git rm "$FULL_FILE_NAME"
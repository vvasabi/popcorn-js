#!/bin/bash
# Custom Builder for Popcorn.js
#
# Use this script to build a custom-made download build of the seleced
# Popcorn.js plug-ins, parsers and players.
# Note that this script is intended to be run by the main Makefile.
#
# Usage: custom.sh <version> <parts> <output>
# <version> is the current version number
# <parts> is space-separated list of parts to be included
# <output> is the destination file to build to

if [ ! $# -eq 3 ]; then
  echo "Usage: $0 <version> <parts> <output>"
  exit 1
fi

# Variables for the script.
version=$1
parts=$2
output=$3

# Empty output.
echo "" > $output

# Loop through each part.
for i in $parts; do
  file=$i

  # File needs to be a file or a directory.
  if [ ! -f "$file" -a ! -d "$file" ]; then
    echo "File $file was not found."
    exit 1
  fi

  # Append file content directly.
  if [ -f "$file" ]; then
    sed -e 's/@VERSION/'$version'/' $file >> $output
    echo -e "\n" >> $output
  fi

  # Get the JS file(s) from the directory.
  if [ -d "$file" ]; then
    files=`ls $file/*.js | grep -v unit`
    for j in $files; do
      sed -e 's/@VERSION/'$version'/' $j >> $output
      echo -e "\n" >> $output
    done
  fi
done

exit 0


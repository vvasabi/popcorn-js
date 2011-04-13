#!/bin/bash
# Archive Packager for Popcorn.js
#
# Use this script to build a custom-made download package of seleced
# Popcorn.js plug-ins.
#
# Usage: packager.sh <base> <output> <input1> <input2> ...
# <base> is where minified code resides, e.g. dist/
# <output> is the target archive filename, relative to <base>
# <input#>'s are files to be included 

# Config parameters.
archiver="tar -czf"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <base> <output> <input1> <input2> ..."
  exit 1
fi

# Variables for the script.
base=$1
output=$2
files=""

# Shift parameters, leaving only input files.
shift
shift

cd $base
for i in $*; do
  # Strip ../ for security
  file=`echo $i | sed 's/\.\.\///'`

  # File needs to be a file or a directory.
  if [ ! -f "./$file" -a ! -d "./$file" ]; then
    echo "File $file was not found."
    exit 1
  fi
  
  files="$files $file"
done

# Produce the output.
$archiver $output $files
exit 0


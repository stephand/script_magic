#!/bin/bash
#
# Renames scientific papers to meaningfulfiles and updates the paper metadata
# to identical values.
#
# Shortens >2 authors to lead author + "et al", removes spaces and special
# characters for easier shell handling.
#
# Usage:
#
#   paper_mv_meta.sh paper123.pdf 2015 "Stephan Diestelhorst, Peter Krause, Diddi Meyer" "Testing Paper Titles"
#
# Result:
#   2015-Diestelhorst,etal-Testing_Paper_Titles.pdf (with fixed meta information, too)
#
#
# Author:  Stephan Diestelhorst <stephan.diestelhorst@gmail.com>
# Date:    201508-16
# License: MIT
#

FILE=${1:?filename}
YEAR=${2:?year}
AUTHORS=${3:?authors}
TITLE=${4:?title}

if [[ ! -f "$FILE" ]]; then
    echo "$FILE" does not exist.
    exit 1
fi

# Use exiftool to change the meta-data
EXIF=$(which exiftool)
if [[ ! -x "$EXIF" ]]; then
    echo "Could not find executable exiftool. Please install!"
    exit 1
fi

# Convert new lines to comma separated list
AUTHORS=$(sed -n '1h;2,$H;${g;s/\n/, /g;p}' <<< "$AUTHORS")
# Remove all new lines in title
TITLE=$(sed -n '1h;2,$H;${g;s/\n/ /g;p}' <<< "$TITLE")

# Read the authors into an array
IFS="," read -ra AA <<< "$AUTHORS"

MAXA=2
for idx in "${!AA[@]}"; do
    # String twiddling: prefix / suffix space removal
    T=${AA[$idx]}
    T=$(sed -e 's/^ *//' <<< "$T")
    T=$(sed -e 's/ *$//' <<< "$T")
    N=$(sed -e 's/^\([^ ]* \)*\([^ ]\+\)$/\2/' <<< "$T")

    #echo "N: $N T: $T"
    if [[ $(( idx + 1)) -eq $MAXA ]] && [[ ${#AA[@]} -gt $MAXA ]]; then
        echo "Got ${#AA[@]} authors, shortening to $MAXA."
        NLIST="$NLIST,etal"
        #echo "XX: "$NLIST
    elif [[ $idx -lt $MAXA ]]; then
        NLIST="${NLIST}${NLIST:+,}$N"
        #echo "YY: "$NLIST
    fi
    ALIST="${ALIST}${ALIST:+, }$T"
    #echo $ALIST
done
DEST="${YEAR}-${NLIST}-${TITLE}.pdf"
DEST=$(tr ' ' '_' <<< "$DEST")
DEST=$(tr -d '\n' <<< "$DEST")
DEST=$(sed -e 's/[^-:a-zA-Z 0-9._,]/_/g' <<< "$DEST")
cp -i "$FILE" "$DEST"
exiftool -q -overwrite_original -title="$TITLE" -author="$ALIST" "$DEST"
rm -i "$FILE"

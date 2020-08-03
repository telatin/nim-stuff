#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
BIN=$DIR/../bin/seqfu_$(uname)
FILES=$DIR/../input/

iInterleaved=$FILES/interleaved.fq.gz
iPair1=$FILES/illumina_1.fq.gz
iPair2=$FILES/illumina_2.fq.gz
iAmpli=$FILES/filt.fa.gz

echo "# Minimal test suite"

# Binary works
$BIN > /dev/null|| { echo "Binary not working"; exit 1; }
echo "OK: Running"

# Dereiplicate
if [[ $($BIN derep $iAmpli  | grep -c '>') -eq "18664" ]]; then
	echo "OK: Dereplicate"
else
	echo "ERR: Dereplicate"
fi

if [[ $($BIN derep $iAmpli -m 10000 2>/dev/null | grep -c '>') -eq "1" ]]; then
	echo "OK: Dereplicate, min size"
else
	echo "ERR: Dereplicate, min size"
fi

# Interleave 
if [[ $($BIN ilv -1 $iPair1 -2 $iPair2 | wc -l) == $(cat $iPair1 $iPair2 | gzip -d | wc -l ) ]]; then
	echo "OK: Interleave"
else
	echo "ERR: Interleave $($BIN ilv -1 $iPair1 -2 $iPair2 | wc -l) -eq $(cat $iPair1 $iPair2| gzip -d | wc -l )"
fi

# Deinterleave
$BIN dei $iInterleaved -o testtmp_
if [[ $(cat testtmp_* | wc -l) == $(cat $iInterleaved | gzip -d | wc -l ) ]]; then
	echo "OK: Deinterleave"
else
	echo "ERR: Deinterleave"
fi
rm testtmp_*

# Count
if [[ $($BIN count $iAmpli | cut -f 2) == $(cat $iAmpli | gzip -d | grep -c '>' ) ]]; then
	echo "OK: Count"
else
	echo "ERR: Count"
fi

if [[ $($BIN count $iPair1  $iPair2 | wc -l) -eq 1 ]]; then
	echo "OK: Count pairs"
else
	echo "ERR: Count pairs"
fi

if [[ $($BIN count -u $iPair1  $iPair2 | wc -l) -eq 2 ]]; then
	echo "OK: Count pairs, split"
else
	echo "ERR: Count pairs, split"
fi
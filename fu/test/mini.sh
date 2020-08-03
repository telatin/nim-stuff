#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
BIN=$DIR/../bin/sfu
FILES=$DIR/../input/

iInterleaved=$FILES/interleaved.fq.gz
iPair1=$FILES/illumina_1.fq.gz
iPair2=$FILES/illumina_2.fq.gz
iAmpli=$FILES/filt.fa.gz

# Binary works
$BIN > /dev/null|| { echo "Binary not working"; exit 1; }
echo "OK: Running"

# Dereiplicate
if [[ $($BIN derep $iAmpli  | grep -c '>') -eq "18664" ]]; then
	echo "OK: Dereplicate"
else
	echo "ERR: Dereplicate"
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


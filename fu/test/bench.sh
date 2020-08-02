#!/bin/bash
set -euxo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

NIM="$DIR/../sfu"
PERL="$DIR/interleafq.pl"

# interleave
#Usage: interleave_fastq.sh f.fastq r.fastq > interleaved.fastq

PAIR1="$DIR/../input/illumina_1.fq.gz"
PAIR2="$DIR/../input/illumina_2.fq.gz"
hyperfine -w 2 -m 15 --export-markdown $DIR/interleave.md \
	"$NIM  ilv   $PAIR1 $PAIR2 > /tmp/nim.fq" \
	"bash $DIR/deinterleave.sh $PAIR1 $PAIR2 > /tmp/bash.fq" \
	"$PERL $PAIR1 $PAIR2 > /tmp/perl.fq" 


# deinterleave
INTERLEAVED_GZ="$DIR/../input/interleaved.fq.gz"
# deinterleave_fastq.sh < interleaved.fastq f.fastq r.fastq [compress]

hyperfine -w 2 -m 15 --export-markdown $DIR/deinterleave.md \
	"$NIM  dei   -o /tmp/nim_ $INTERLEAVED_GZ" \
	"cat $INTERLEAVED_GZ | gzip -d | bash $DIR/deinterleave.sh /tmp/bash_1 /tmp/bash_2" \
	"$PERL $INTERLEAVED_GZ -o /tmp/perl_" 

perl -i -p -e "s|\/\S+/||g" test/*md
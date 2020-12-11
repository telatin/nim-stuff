#!/bin/bash
set -euo pipefail
OLDWD=$PWD

PLATFORM=$(uname)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


nim --version >/dev/null 2>&1       || { echo "nim compiler not found."; exit 1; }
nim c -w:on --opt:speed -d:release -p:$DIR/../lib $DIR/derep.nim || { echo "Compilation failed."; exit 1; }

mv derep bin/derep_$(uname)


# SOME TEST
if [[ $(./bin/derep_$(uname) input/test.fa  | grep -c '>') -eq 5 ]]; then
  echo " *** OK PASS"
else
  echo " --- Test failed"
fi
hyperfine --version || exit
perl $DIR/test/uniq.pl --version || exit

exit; 
set -x pipefail
cd $DIR
hyperfine --export-markdown "$DIR/doc/bench.md" --min-runs 20 --warmup 2 \
    "perl ./test/uniq.pl ./input/*.fa*"  \
    "./bin/derep_$(uname) ./input/*.fa*" 

hyperfine --export-markdown "$DIR/doc/single_file.md" --min-runs 24 --warmup 2 \
    "vsearch --derep_fulllength ./input/filt.fa.gz --output /tmp/vsearch.fa" \
    "./bin/derep_$(uname) ./input/filt.fa.gz > /tmp/derep.fa" \
    "perl ./test/uniq.pl ./input/filt.fa.gz > /tmp/uniq.fa " 
    
sed -i 's/..bin.//'  "$DIR/doc/bench.md"
sed -i 's/..test.//'  "$DIR/doc/bench.md"

VERSION=$(grep const\ version derep.nim | grep -o \\d\[^\"\]\\+)
BENCH=$(cat $DIR/doc/bench.md)

perl -e '
  $BENCH=`cat doc/bench.md`;
  $VERSION=shift(@ARGV);
  $BIN=shift(@ARGV);
  $SPLASH=`$BIN --help 2>&1`;
  $TEMPLATE=shift(@ARGV);
  open(I, "<", $TEMPLATE);
  while (<I>) {
   while ( $_=~/\{\{ (\w+) \}\}/g ) {
      $repl=${$1};
      $match=$1;
      $_=~s/\{\{\s*$match\s*\}\}/$repl/g;
   }
   print;
  }
' "$VERSION" "$DIR/bin/derep_$(uname)" "README.raw" > README.md

cd $OLDWD
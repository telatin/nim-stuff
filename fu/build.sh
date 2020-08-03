#!/bin/bash
set -exuo pipefail
OLDWD=$PWD

PLATFORM=$(uname)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


nim --version >/dev/null 2>&1       || { echo "nim compiler not found."; exit 1; }
nim c -w:on  --opt:speed -d:release -p:$DIR/../lib -o:bin/sfu $DIR/sfu.nim || { echo "Compilation failed."; exit 1; }

bash $DIR/test/mini.sh


VERSION=$(grep return version.nim | grep -o \\d\[^\"\]\\+)


perl -e '
   
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
' "$VERSION" "$DIR/bin/sfu" "README.raw" > README.md


#!/bin/bash
set -exuo pipefail
OLDWD=$PWD


# building directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# program name
PROGNAME=$(basename $DIR)
echo "Building $PROGNAME"
if [ $(uname) == 'Darwin' ]; then
 SUFFIX='_mac';
else
 SUFFIX='';
fi

nim --version >/dev/null 2>&1       || { echo "nim compiler not found."; exit 1; }

RELEASE=""
if [ "${NIM_RELEASE+x}" ]; then
 RELEASE=" -d:release ";
fi

nim c -w:on  -d:ssl --opt:speed $RELEASE  -o:bin/${PROGNAME}${SUFFIX} $DIR/main.nim || { echo "Compilation failed."; exit 1; }

if [ -e "$DIR/test/mini.sh" ]; then
  bash $DIR/test/mini.sh;
else
  echo "test/mini.sh NOT found: skipping";
fi

VERSION=$(grep return pkg_utils.nim | grep -o \\d\[^\"\]\\+ | head -n 1)
echo "Version: $VERSION"

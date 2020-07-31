#!/bin/bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


nim --version >/dev/null 2>&1       || { echo "nim compiler not found."; exit 1; }
nim c --opt:speed -d:release -p:$DIR/../lib $DIR/derep.nim || { echo "Compilation failed."; exit 1; }

if [[ $(uname) == 'Darwin' ]]; then
 mv derep bin/derep_mac
else
 mv derep bin/derep
fi

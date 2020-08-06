#!/bin/bash
set -exuo pipefail
mkdir -p input/
curl -o input/pagecounts.gz "https://dumps.wikimedia.org/other/pagecounts-raw/2016/2016-01/pagecounts-20160101-000000.gz"
gunzip input/pagecounts


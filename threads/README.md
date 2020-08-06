# Threads

Parser multithreads from _Nim in action_ by _Dominik Picheta_.

* `get_data.sh` will download the required input file from Wikipedia (pageCounts)
* `threads.nim` requires as first argument the _pageCounts_ input file and optionally the number of threads.

**NOTE**: Some bits of syntax seemed incompatible with Nim 1.2.4:
```
buffer[0 .. <oldBufferLen] = buffer[readSize - oldBufferLen .. ^1]
#   this----^
```

## Benchmark

| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `./parse.mac input/en.txt 8` | 0.357 ± 0.006 | 0.350 | 0.371 | 1.00 |
| `./parse.mac input/en.txt 1` | 1.599 ± 0.032 | 1.549 | 1.657 | 4.48 ± 0.12 |
| `perl perlparse.pl input/en.txt` | 1.620 ± 0.069 | 1.535 | 1.758 | 4.54 ± 0.21 |
| `grep ^en input/en.txt \| sort -nr -k 3  \|head -n4` | 18.045 ± 0.374 | 17.502 | 18.588 | 52.28 ± 1.36 |

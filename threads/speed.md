| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `./parse input/en.txt 1` | 1.628 ± 0.071 | 1.571 | 1.767 | 4.72 ± 0.22 |
| `./parse input/en.txt 8` | 0.345 ± 0.005 | 0.338 | 0.355 | 1.00 |
| `grep ^en input/en.txt \| sort -nr -k 3  \|head -n4` | 18.045 ± 0.374 | 17.502 | 18.588 | 52.28 ± 1.36 |
| `./perlparse.pl input/en.txt` | 1.553 ± 0.048 | 1.476 | 1.635 | 4.50 ± 0.15 |

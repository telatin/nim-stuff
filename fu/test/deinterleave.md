| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `sfu  dei   -o nim_ interleaved.fq.gz` | 8.9 ± 0.7 | 7.2 | 12.1 | 1.00 |
| `cat interleaved.fq.gz \| gzip -d \| bash deinterleave.sh bash_1 bash_2` | 22.7 ± 1.4 | 20.8 | 35.5 | 2.56 ± 0.26 |
| `interleafq.pl interleaved.fq.gz -o perl_` | 396.2 ± 28.2 | 372.8 | 463.8 | 44.71 ± 4.76 |

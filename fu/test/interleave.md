| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `sfu  ilv   illumina_1.fq.gz illumina_2.fq.gz > nim.fq` | 7.5 ± 0.8 | 6.2 | 10.7 | 1.00 |
| `bash deinterleave.sh illumina_1.fq.gz illumina_2.fq.gz > bash.fq` | 21.8 ± 1.0 | 20.1 | 29.6 | 2.90 ± 0.33 |
| `interleafq.pl illumina_1.fq.gz illumina_2.fq.gz > perl.fq` | 371.9 ± 10.6 | 359.8 | 399.5 | 49.54 ± 5.24 |

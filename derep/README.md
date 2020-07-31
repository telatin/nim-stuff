# FASTA/FASTQ Dereplication

Dereplicate sequence files, supporting gzipped input files. 
If sequence names contains the `;size=INT` string, it will be used in the count (see example input)

```
derep

Dereplicate FASTA (and FASTQ) files, print dereplicated sorted by cluster size with ';size=NNN' decoration.

Usage:
  derep [options] inputfile

Arguments:
  inputfile        FASTX file (gzip supported)

Options:
  -k, --keep-name            Do not rename sequence, but use the first sequence name
  -i, --ignore-size          Do not count 'size=INT;' annotations (they will be stripped in any case)
  -m, --min-size=MIN_SIZE    Print clusters with size equal or bigger than INT sequences (default: 0)
  -p, --prefix=PREFIX        Sequence name prefix (default: seq)
  -s, --separator=SEPARATOR  Sequence name separator (default: .)
  -w, --line-width=INT       Specify length of FASTA line (default: 0, meaning unlimited)
  -h, --help                 Show this help
```


### Benchmark
 
Compared with a similar Perl script:

| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `./bin/derep filt.fa filt.fa` | 2.908 ± 0.098 | 2.797 | 3.065 | 1.00 |
| `perl uniq.pl	 filt.fa filt.fa` | 23.694 ± 0.339 | 23.283 | 24.187 | 8.15 ± 0.30 |

![benchmark plot](examples/bench_small.png| width=100)

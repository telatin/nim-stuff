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
| `./derep filt.fa filt.fa` | 6.626 ± 0.322 | 6.312 | 7.208 | 1.00 |
| `./uniq.pl filt.fa filt.fa` | 25.588 ± 0.708 | 24.634 | 26.689 | 3.86 ± 0.22 |

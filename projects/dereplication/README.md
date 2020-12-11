# FASTA/FASTQ Dereplication

![Commit](https://img.shields.io/github/last-commit/telatin/nim-stuff)
![Version 0.6.0](https://img.shields.io/badge/version-0.6.0-blue)

Dereplicate sequence files, supporting gzipped input files. 
If sequence names contains the `;size=INT` string, it will be used in the count (see example input)

```
derep

Dereplicate FASTA (and FASTQ) files, print dereplicated sorted by cluster size with ';size=NNN' decoration.

Usage:
  derep [options] [inputfile ...]

Arguments:
  [inputfile ...]

Options:
  -k, --keep-name            Do not rename sequence, but use the first sequence name
  -i, --ignore-size          Do not count 'size=INT;' annotations (they will be stripped in any case)
  -v, --verbose              Print verbose messages
  -m, --min-size=MIN_SIZE    Print clusters with size equal or bigger than INT sequences (default: 0)
  -p, --prefix=PREFIX        Sequence name prefix (default: seq)
  -s, --separator=SEPARATOR  Sequence name separator (default: .)
  -w, --line-width=LINE_WIDTH
                             FASTA line width (0: unlimited) (default: 0)
  -l, --min-length=MIN_LENGTH
                             Discard sequences shorter than MIN_LEN (default: 0)
  -x, --max-length=MAX_LENGTH
                             Discard sequences longer than MAX_LEN (default: 0)
  -c, --size-as-comment      Print cluster size as comment, not in sequence name
  -h, --help                 Show this help
Missing arguments.

```

### Input

A set of FASTA or FASTQ files. If the sequence name contains the `size=INT` flag, it will be counted.
Example: [test.fasta](input/test.fa)


### Benchmark
 
Compared with a similar Perl script:

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `perl uniq.pl ./input/*.fa*` | 935.7 ± 38.4 | 886.1 | 1027.9 | 8.39 ± 0.36 |
| `derep_Darwin ./input/*.fa*` | 111.5 ± 1.6 | 108.9 | 115.1 | 1.00 |


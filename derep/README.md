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
  -h, --help                 Show this help
```



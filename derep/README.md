# FASTA/FASTQ Dereplication

Dereplicate sequence files, supporting gzipped input files. 
If sequence names contains the `;size=INT` string, it will be used in the count (see example input)

```
fxderep

Dereplicate FASTA (and FASTQ) files

Usage:
  fxderep [options] inputfile

Arguments:
  inputfile        FASTX file (gzip supported)

Options:
  -r, --rename               Rename sequence
  -p, --prefix=PREFIX        Sequence prefix (default: seq)
  -s, --separator=SEPARATOR  Sequence separator (default: .)
  -h, --help                 Show this help
```



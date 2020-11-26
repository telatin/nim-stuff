# Virfinder Contigs

## Goal

To make a program extracting contigs having score or p-value in a user specified range.

## Input files

- VirFinder output (CSV)
- Contigs file (Fasta)

Virfinder output is a CSV file like:

```
"","name","length","score","pvalue"
"1","k141_35347 flag=1 multi=4.0000 len=333",333,0.280906820724776,0.382859980139027
"2","k141_2357 flag=1 multi=3.0000 len=355",355,0.242019791104967,0.4293545183714
"3","k141_42415 flag=1 multi=3.0000 len=364",364,0.243776801137825,0.427070506454816
```

## Required libraries

 - A CSV parser (parsecsv)
 - A FASTA parser (nimbioseq)
 - A command line arguments parser (docopt)

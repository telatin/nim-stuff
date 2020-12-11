import strutils

var
 strings = @["file_R1.fq", "RANDOM.fq", "file_R3.fq", "id_1.fastq"]
 patterns = @["_R1.", "_1."]

for s in strings:
  for p in patterns:
    var base = split(s, p)
    echo s, "\t:\t", p, "\t -> ", base, len(base)

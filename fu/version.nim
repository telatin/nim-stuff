import klib
proc version*(): string =
  return "0.1.0"


proc echoVerbose*(msg: string, print: bool) =
  if print:
    stderr.writeLine(" * ", msg)


# Common variables for switches
var
   verbose*:        bool    # verbose mode
   check*:          bool    # enable basic checks
   stripComments*:  bool    # strip comments in output sequence


proc format_dna*(seq: string, format_width: int): string =
  if format_width == 0:
    return seq
  for i in countup(0,seq.len - 1,format_width):
    #let endPos = if (seq.len - i < format_width): seq.len - 1
    #            else: i + format_width - 1
    if (seq.len - i <= format_width):
      result &= seq[i..seq.len - 1]
    else:
      result &= seq[i..i + format_width - 1] & "\n"


proc print_seq*(record: FastxRecord, outputFile: File, stripComment: bool) =
  var name = record.name
  if not stripComment:
    name.add(" " & record.comment)

  if len(record.seq) != len(record.qual):
    stderr.writeLine("Sequence <", record.name, ">: quality and sequence length mismatch.")
    return 

  if outputFile == nil:
    echo "@", name, "\n", record.seq, "\n+\n", record.qual
  else:
    outputFile.writeLine("@", name, "\n", record.seq, "\n+\n", record.qual)
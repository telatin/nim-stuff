import klib
import re
import strutils
#[ Versions
- 0.2.0   Improved 'count' with PE support
          Initial refactoring
- 0.1.2   Added 'count' stub
- 0.1.1   Added 'derep' to dereplicate
- 0.1.0   Initial release
    
   

]#

proc version*(): string =
  return "0.1.2"
  

proc echoVerbose*(msg: string, print: bool) =
  if print:
    stderr.writeLine(" * ", msg)


# Common variables for switches
var
   verbose*:        bool    # verbose mode
   check*:          bool    # enable basic checks
   stripComments*:  bool    # strip comments in output sequence
   forceFasta*:     bool
   forceFastq*:     bool
   lineWidth*       = 0


proc extractTag*(filename: string, patternFor: string, patternRev: string): (string, string) =
    if patternFor == "auto":
        # automatic guess
        if match(filename, re".+_R1\..+"):  
            var basename = split(filename, "_R1.")
            return (basename[0], "R1")
        elif match(filename, re".+_1\..+"):  
            var basename = split(filename, "_1.")          
            return (basename[0], "R1")
    else:
        if match(filename, re(patternFor)):
            var basename = split(filename, patternFor)
            return (basename[0], "R1")

    if patternRev == "auto":
        # automatic guess
        if match(filename, re".+_R2\..+"):           
            var basename = split(filename, "_R2.")
            return (basename[0], "R2")
        elif match(filename, re".+_2\..+"):            
            var basename = split(filename, "_2.")
            return (basename[0], "R2")
    else:
        if match(filename, re(patternRev)):
            var basename = split(filename, patternRev)
            return (basename[0], "R2")
    
    return (filename, "SE")
 
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
    if forceFasta:
        echo ">", name, "\n", record.seq
    else:
        echo "@", name, "\n", record.seq, "\n+\n", record.qual
  else:
    outputFile.writeLine("@", name, "\n", record.seq, "\n+\n", record.qual)
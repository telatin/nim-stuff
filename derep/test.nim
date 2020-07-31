import klib
import re
import argparse
import tables, strutils
from os import fileExists

const prog = "derep"
const version = "0.3"
#[
  # v.0.3
    - added "-c" to print size as comment rather than in sequence name
    - added "-m" to print sequences if their cluster size is >= INT
  # v.0.2
    - Added "-k" to keep sequence names (first found as cluster name)
    - Added "-i" to ignore counts (default behaviour is to use it)
  # v.0.1
    - Initial release with regex for ";size=\d+

]#


var p = newParser(prog):
  help("Dereplicate FASTA (and FASTQ) files, print dereplicated sorted by cluster size with ';size=NNN' decoration.")
  flag("-k", "--keep-name", help="Do not rename sequence, but use the first sequence name")
  flag("-i", "--ignore-size", help="Do not count 'size=INT;' annotations (they will be stripped in any case)")
  option("-m", "--min-size", help="Print clusters with size equal or bigger than INT sequences", default="0")
  option("-p", "--prefix", help = "Sequence name prefix", default = "seq")
  option("-s", "--separator", help = "Sequence name separator", default = ".")
  flag("-c", "--size-as-comment", help="Print cluster size as comment, not in sequence name")
  arg("inputfile", help="FASTX file (gzip supported)", nargs=-1)



proc main() =

  try:
    var opts = p.parse(commandLineParams()) 

    let sizePattern = re";?size=(\d+);?";
    let sizeCapture = re".*;size=(\d+);?.*"


    
    echo " -> ", opts.inputfile
   
  except:
    echo p.help
    quit(0)
  

main()

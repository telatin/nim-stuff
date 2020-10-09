# A script to import a GFA file converting it into a "grim" graph

import grim
import sequtils
import strutils
import argparse
const prog = "readGFA"
const version = "0.1.0"

 
var p = newParser(prog):
  help("Simple parser for GFA files")
  #flag("-k", "--keep-name", help="Do not rename sequence, but use the first sequence name")
  #option("-m", "--min-size", help="Print clusters with size equal or bigger than INT sequences", default="0")
  #arg("inputfile",  nargs = -1)
  option("-n", "--node", help="Print node info")
  arg("inputfile", nargs = -1)

proc negateSymbol(symbol: string): string =
  case symbol:
    of "+":
      return "-"
    of "-":
      return "+"
    else:
      return "0"

proc parseLine(line: string, graph: Graph): bool {.discardable.} =
  let fields = split(line, "\t")
  case fields[0]:
    of "L":
      #L	283	+	6	+	81M 
      let From = graph.node(fields[1])
      let To   = graph.node(fields[3])
      let Edge1= graph.addEdge(From, To,   "link", %(From: fields[2], To: fields[4])                             )
      #let Edge2= graph.addEdge(To,   From, "link", %(From: negateSymbol(fields[4]), To: negateSymbol(fields[2]) ))   
    of "S":
      #ID, Seq, 	LN:i:4149	RC:i:248525 
      let node = graph.addNode(fields[1],  %(Type: fields[0], Id: fields[1], seq: fields[2]), oid=fields[1])
    else:
      let node = graph.addNode("Unsupported", %(Type: fields[0], Line: line))
  return true

#[
=........1=........2=........3=........4=........5=........612345
ACAGCGTACGTGATCGACGTAGCTAGCTGACGAGCTAGCTACACACGATCGTAGCTGGTACACGT
   A  B                  B   A

   +  +   ===> --->   <--- <===   - -  
   +  -   ===> <---   ---> <===   + - 
   -  -   <=== <---   ---> ===>   + + 
   -  +   <=== --->   <--- ===>   - + 

]#

proc main(args: seq[string]) =
  var opts = p.parse(commandLineParams()) 
  var line: string

  if len(opts.inputfile) < 1:
    echo "Missing argument."
    quit(2)
  if not existsFile(opts.inputfile[0]):
    echo "File not found ", opts.inputfile[0]
    quit(1)

  let f = open(opts.inputfile[0])
  defer: f.close()
  var g = newGraph(opts.inputfile[0])
  while f.readLine(line):
    parseLine(line,g)

 
  if opts.node != "":
    for node in g.neighbors(opts.node, direction=OutIn):
      echo  g.node(node), ": ", node
      for edge in g.edgesBetween(node, opts.node):
        echo ">", edge.label, ": ", edge
      for edge in g.edgesBetween(opts.node, node):
        echo "<", edge.label, ": ", edge
  else:
    stderr.writeLine($g)
    for n in g.nodes:
      echo " - ", n.oid
      for node in g.neighbors(n.label):
        echo "    - ", node

    for edge in g.edges:
      echo "E.", edge.label, ": ", edge



when isMainModule:
  main(commandLineParams())
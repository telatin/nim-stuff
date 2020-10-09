import grim
import sequtils

proc get_a_node_with_label(graph: Graph, label: string): Node =
  for node in graph.nodes:
    if node.label == label:
      return node

var g = newGraph("graph")
let n1 =  g.addNode("n1", %(Name: "first"))
let n2 =  g.addNode("n2", %(Name: "second"))

var aNode = get_a_node_with_label(g, "n2")


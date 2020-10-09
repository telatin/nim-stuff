import grim/dsl

graph g "People":
  nodes:
    Person:
      "alice":
        name: "Alice"
      "bob":
        name: "Bob"
      "charlie":
        name: "Charlie"
  edges:
    "alice" -> "bob":
      KNOWS
    "bob" -> "charlie":
      KNOWS
    "bob" -> "charlie":
      KNOWS  

var pc = g.navigate("Person")    # PathCollection

import os
import argparse

proc main(args: seq[string]) =
  var par = newParser("My Program"):
    option("--arg1")
    arg("files", nargs = -1)

  var opts = par.parse(args)
  echo "Opts: ", opts.arg1
  echo "Files: ", opts.files
  # For a command like `cmd --arg1=X file1 file2, echoes
  # Opts: X
  # Files: @[file1, file2]

when isMainModule:
  main(commandLineParams())

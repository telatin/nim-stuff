import parseopt
import os
from strutils import parseint


proc writeVersion() =
  echo getAppFilename().extractFilename(), "0.1.0"

proc writeHelp() =
  writeVersion()
  echo """

  Allowed arguments:
  -h, --help        : show help
  -v, --version     : show version
  -s, --string STR  : Message
  -t, --times INT   : Repeat message INT times
  """
  quit()

proc cli() =
  # Directly accessing the app name and parameters
  echo "# Program name: ", getAppFilename().extractFilename()
  echo "# Number of Parameters: ", paramCount()

  for ii in 1 .. paramCount():    # 1st param is at index 1
    echo "# Raw param: ", ii, ": ", paramStr(ii)
 
  echo ""
 
  # Using parseopt module to extract short and long options and arguments
  var
    argCtr : int
    message: string
    times = 1
    i = 0
 
  for kind, key, value in getOpt():
    case kind
    # Positional arguments
    of cmdArgument:
      echo "# Positional argument ", argCtr, ": \"", key, "\""
      argCtr.inc

    # Switches
    of cmdLongOption, cmdShortOption:
      case key
      of "v", "version":
        writeVersion()
        quit()
      of "h", "help":
        writeHelp()
      of "m", "message":
        message = value
      of "t", "times":
        times = parseInt(value)
      else:
        echo "Unknown option: ", key
 
    of cmdEnd:
      discard

  if len(message) == 0:
    echo "No message specified :("

  while i < times:
    echo message
    i += 1

when isMainModule:
  cli()
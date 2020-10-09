import  docopt
const doc = """
CoolSeq - a program to do things

Usage:
  args_docopt status
  args_docopt list
  args_docopt analyse <directory> <database> [-o|--output=<outputFile>]

Options:
  status                      Check API Status
  list                        Check Result List
  convert                     Upload Images, convert to PDF and download result.pdf
  <directory>                 Specify directory with input files
  <database>                  Reference database
  -o, --output=<outputFile>   Output filename [default: result.bam]
"""

proc main() =
  let args = docopt(doc, version = "1.0")
  if args["status"]:
    echo "So you want to know the status! OK!"
  if args["list"]:
    echo "This is the list... finished!"
  if args["analyse"]:
    echo "CONVERTING:"
    echo "Directory: ", $args["<directory>"]
    echo "Reference: ", $args["<database>"]
    echo "Output:    ", $args["--output"]

when isMainModule:
  main()
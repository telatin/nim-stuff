import strutils, os

proc seqSummary(query, db: string, kmer = 8, complement = false) =
  let progName = split(getAppFilename(), "/")[getAppFileName().count("/")]
  
  if query != "" and db != "":
    echo "Query: ", query
    echo "Database: ", db
    echo "K-mer size: ", kmer
    echo "Complement: ", complement
  else:
    echo "ERROR\n", progName, " needs query and target filenames..."

when isMainModule: import cligen;dispatch(seqSummary)

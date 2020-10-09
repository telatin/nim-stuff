import docopt
import ../pkg_utils
import asyncdispatch
import httpclient
import json
from os import fileExists, dirExists

#-d:ssl

proc downloadData(uri: string): string {.discardable.} =
  try:
    let client   = newAsyncHttpClient()
    let response = waitFor client.get(uri) 
    if $response.status == "200 OK":
      result = waitFor response.body
    else:
      stderr.writeLine("Unable to fetch data, anaconda.org replied with ", response.status, " from: ", uri)
      return ""
  except:
    stderr.writeLine("Exceptions during data download. Unrecoverable.")
    return ""

proc downloadUriToFile(uri, file: string): bool {.discardable.} = 
  let downloadedText = downloadData(uri)
  if (len(downloadedText) == 0):
    return false
  else:
    try:
      writeFile(file, downloadedText)
    except:
      stderr.writeLine("Exceptions writing to file: ", file, " Unrecoverable.")
      return false
  return true

proc mod_build_cache(argv: var seq[string]): int {.gcsafe.} =
  let args = docopt("""
Usage: build_cache [options] 

This module is for development only and not supported,
please check 'update' to download the latest packages

Options:
  -o, --outdir PATH       Path to the cache directory
  -t, --tempdir PATH      Path to temporary directory [default: /tmp/]
  -f, --force             Force download of bioconda.json
  -d, --debug

  """, version=version(), argv=argv)

  let 
    debug = args["--debug"]
    tmpdir = $args["--tempdir"]
    forceDownload = args["--force"]
    biocondaURL  = "https://api.anaconda.org/packages/bioconda"
    baseURL  = "https://api.anaconda.org/package/bioconda"

  var
    outdir: string

  if args["--outdir"]:
    outdir = $args["--outdir"]
  else:
    outdir = joinPath(appInfo.progDir, "cache")

  # Check output directory
  if not dirExists(outdir):
    try:
      echoVerbose("Trying to create " & outdir, debug)
      createDir(outdir)
    except:
      stderr.writeLine("Output directory not found: ", outdir)
      quit(1)
  if not dirExists(tmpdir):
    stderr.writeLine("Temporary directory not found: ", tmpdir)
    quit(1)
      
  # Download bioconda
  var
    packageJsonText: string
    biocondaJsonFile = joinPath(outdir, "bioconda.json")

  if (not fileExists(biocondaJsonFile) or forceDownload):
    if downloadUriToFile(biocondaURL, biocondaJsonFile):
      echoVerbose("Downloaded data to " & biocondaJsonFile, debug)
    else:
      echo "ERROR: Unable to download data to ", biocondaJsonFile
      quit(1)
  else:
    echoVerbose("Bioconda.json found: skipping", debug)

  var packages = parseFile(biocondaJsonFile)
  for package in packages:
    if package["name"].getStr() != "seqfu":
      continue
    echoVerbose("Processing " & package["name"].getStr(), debug)
    echo package["latest_version"].getStr()
    echo package["url"].getStr()
    echo package["home"].getStr()
    for plat in  package["conda_platforms"]:
      echo " - ", plat.getStr()
      echo downloadData(baseURL & "/" & package["name"].getStr())

    #let dt = parse("2000-01-01", "yyyy-MM-dd")

    # id
    # name
    # latest_version
    # license
    # uri: home, dev_url, html_url, license_url
    # summary, description
    # @versions
    # @conda_platforms  ["linux-64","osx-64"],  ["noarch"]



  
#[
 
    # Download bioconda.json
    let client   = newAsyncHttpClient()
    let response = waitFor client.get("https://api.anaconda.org/package/bioconda/seqfu") 
    echo response.type
    # for each package
    # - download json
    # - download extra info

    # prepare sqlite database
 
  ]#
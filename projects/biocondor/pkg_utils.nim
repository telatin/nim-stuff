
import  strutils, os
proc version*(): string =
  return "0.2.0"


#[ Versions
- 0.3.0   Added 'stats'
- 0.2.1   Added 'head'
- 0.2.0   Improved 'count' with PE support
          Initial refactoring
- 0.1.2   Added 'count' stub
- 0.1.1   Added 'derep' to dereplicate
- 0.1.0   Initial release

]#






proc echoVerbose*(msg: string, print: bool) =
  if print:
    stderr.writeLine(" * ", msg)


type
  DirRecord* = tuple[appFile, homeDir, progDir, comment: string, status, lastChar: int]

# Common variables for switches
var
  verbose*:        bool    # verbose mode
  cacheDir*:       string
  appInfo*:           DirRecord

proc getDirectories*(r: var DirRecord): bool {.discardable.} =
  r.appFile = getAppFilename()
  r.homeDir = getHomeDir()
  var
    appDirArray = splitFile(r.appFile) 
  r.progDir = appDirArray[0]

getDirectories(appInfo)


proc thisPkgEventHandler() {.noconv.} =
  echoVerbose("User requested termination", verbose)
  quit 0

setControlCHook(thisPkgEventHandler)



# Cache dir:
# On boot is either from '~/.biocondor.json':
#{
#  "cacheDir" : "/path/to/cache",
#}
# or, by default "../cache" relative to binary

proc loadConfiguration() {.discardable.} = 
  echo "OK"
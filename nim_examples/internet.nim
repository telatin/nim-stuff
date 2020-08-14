import asyncdispatch
import httpclient
import json
#-d:ssl

#The httpclient module defines the asynchronous HTTP client and related procedures.
#Creates a new instance of the AsyncHttpClient type
let client   = newAsyncHttpClient()

let response = waitFor client.get("https://api.anaconda.org/package/bioconda/seqfu") 
echo("response version: ", response.version)
echo("response status:  ",response.status)
#echo(waitFor response.body)
let packageData = waitFor response.body
let package = parseJson(packageData)

#echo packageData

echo $package["name"], " ", $package["latest_version"]
echo package["summary"]
echo "ID:   ",package["id"]
echo "Home: ", package["home"]
if package["name"].getStr() == "seqfu":  
  echo "OK"
else:
  echo "Expected <seqfu>, but got <", package["name"], ">"

echo package["name"].type
# bioconda https://api.anaconda.org/packages/bioconda
# package  https://api.anaconda.org/package/bioconda/{}

let bioconda = parseFile("bioconda.json")

for pkg in bioconda:
  echo pkg["name"].getStr()
  for v in pkg["versions"]:
    echo " - ", v
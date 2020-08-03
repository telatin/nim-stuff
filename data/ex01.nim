# Simple demostration of join

import nimdata

let dfA = DF.fromSeq(@[
  (name: "John", age: 99)
])

let dfB = DF.fromSeq(@[
  (name: "John", height: 1.80),
  (name: "John", height: 1.50),
  (name: "Bill", height: 1.50),
])

let joined = joinTheta(
  dfA,
  dfB,
  (a, b) => a.name == b.name,
  (a, b) => mergeTuple(a, b, ["name"])
)

joined.show()

# Most importantly: With a working nimsuggest setup the
# inferred result type can even be seen from auto-completion:
echo joined.collect()[0].name
echo ""
let dfRawText = DF.fromFile("Bundesliga.csv")
echo dfRawText.count()
dfRawText.take(5).show()

const schema = [
  strCol("index"),
  strCol("homeTeam"),
  strCol("awayTeam"),
  intCol("homeGoals"),
  intCol("awayGoals"),
  intCol("round"),
  intCol("year"),
  dateCol("date", format="yyyy-MM-dd hh:mm:ss")
]
let df = dfRawText.map(schemaParser(schema, ','))
                  .map(record => record.projectAway(index))
                  .cache()

echo df.count()
# => 14018

df.take(5).show()

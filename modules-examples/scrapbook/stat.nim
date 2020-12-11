import statistics, tables
var t1 = @[13, 13, 13, 13, 14, 14, 16, 18, 21]

echo "statistics: ", t1.average()
for i in 1..10:
  echo i, " ", t1.quantiles(i)

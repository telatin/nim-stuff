import db_sqlite, math
# edited from https://stackoverflow.com/questions/33202488/using-nim-to-connect-to-a-sqlite-database
let dbObject = open("mytest.db", "", "", "") # Open mytest.db

dbObject.exec(sql"DROP TABLE if exists table_1")

# Create table
dbObject.exec(sql("""CREATE TABLE table_1 (
    Id    INTEGER PRIMARY KEY,
    Name  VARCHAR(50) NOT NULL,
    i     INT(11),
    f     DECIMAL(18,10))"""
))

# Insert

echo ">> INSERT"
dbObject.exec(sql"BEGIN")
for i in 1..22:
 dbObject.exec(sql"INSERT INTO table_1 (name,i,f) VALUES (?,?,?)",
       "ItemID_" & $i, i, sqrt(i.float))
dbObject.exec(sql"COMMIT")

echo ">> SELECT"
# Select
for x in dbObject.fastRows(sql"select * from table_1"):
 stderr.writeLine("got: ", $x)
 echo x[0], "  |  ", x[1], "  |  ", x[2]

echo ">> INSERT 2"
let id = dbObject.tryInsertId(sql"INSERT INTO table_1 (name,i,f) VALUES (?,?,?)",
     "ItemID_Special", 1024, sqrt(1024.0))
echo "Inserted item: ", dbObject.getValue(sql"SELECT name FROM table_1 WHERE id=?", id)

dbObject.close()

type
  FastqRecord* = object
    name*, seq*, qual*: string
    tailLen: int

# Add a tail of A (default size: 20)
# We will see the 'repeat' function to avoid the loop ;)
proc polyA*(a: var FastqRecord, tailSize = 20) =
  var c = 0;
  while c < tailSize:
    a.seq &= 'A'
    a.tailLen += 1 
    c += 1

proc tailTooLong*(a: FastqRecord): bool =
  result = a.tailLen > 30

var seq1: FastqRecord

seq1 = FastqRecord(name : "seq1",
              seq : "CAGATA")

let seq2 = FastqRecord(name : "seq2",
                 seq : "GATTACA")

# Print sequence and tail length, and if tail is too long!
echo seq1.seq, " (", seq1.tailLen, ") ", seq1.tailTooLong()

# Add tail (default len)
seq1.polyA()
echo seq1.seq, " (", seq1.tailLen, ") ",  seq1.tailTooLong()

# Add tail (custom len)
seq1.polyA(18)
echo seq1.seq, " (", seq1.tailLen, ") ", seq1.tailTooLong()

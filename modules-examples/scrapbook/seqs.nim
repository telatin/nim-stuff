var
  sequences : seq[string]
  Bases = @['A', 'C', 'G', 'T']
  Codons = newSeq[string](64)           # seq of strings, 64 slots
  i = 0

# Sequences

sequences.add("GAGGA")
sequences.add("GCAA")
sequences.add("GAGGATT")
let firstItem = sequences[0]

echo "Total sequences: ", len(sequences), " the first is ", firstItem

#Looping through indexes and values
for index, value in sequences:
  echo ">Seq_", index, "\n", value

# Codons
echo "The empty Codons array has size: ", len(Codons)

for first in Bases:
  for second in Bases:
    for third in Bases:
      Codons[i] = first & second & third
      stdout.write Codons[i]
      i += 1

      if i mod 8 != 0:
        stdout.write " "
      else:
        stdout.write "\n"


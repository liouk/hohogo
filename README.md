# hohogo
A simple go program to calculate Secret Santa pairings, written in Ruby. The solution to the problem is naive; create random assignments, and if the constraints are not fulfilled, repeat until they are. Try running this with a large dataset `O_o`.

```
./hohogo.rb [options]

  -i, --input           Specify the input file (default: './input.txt')

  -f, --write-to-files  Write the results to individual .txt files per participant (default: false)
                        Optional: supply prefix for the .txt files (default: 'Secret_Santa_for_')

  -s, --separator       Define the participant separator for the input file (default: ' ')

  -v, --verbose         Show the computation steps (default: false)

  -h, --help            Display this help message
```

## Input
Each participant in the Secret Santa raffle should be placed in a new line. If a participant appears in multiple lines, it will only count as a single participation. Every line can contain multiple names, which will be considered illegal pairings with the name in the beginning of the line. The names should be separated by a single space, unless specified otherwise with the `-s` flag.

### Input with no constraints
Everybody can be paired with everybody else.
```
Abed
Annie
Britta
Jeff
Shirley
Troy
Pierce
Chang
```

### Input with constraints
Any participants placed next to a name will not be allowed in a pairing with the first name of the line. In the following, the pairing `Abed -> Chang` is illegal and therefore will not appear.
```
Abed Chang
Annie
...
```

Multiple constraints can be either added in the same line, or multiple lines.
```
Abed Chang
Abed Pierce
...
```

## `main.go`
This is the first version of the Secret Santa, which receives a list of names in the CLI arguments and returns the pairings, by greedily trying to create the assignments. If the cycle of Santas is not closed, and somebody remains without an assignment, it retries.

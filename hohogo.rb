#!/usr/bin/env ruby -w
require 'getoptlong'

# help text
$help = <<-EOF
Calculate Secret Santa pairings.

./hohogo.rb [options]

  -i, --input           Specify the input file (default: './input.txt')

  -f, --write-to-files  Write the results to individual .txt files per participant (default: false)
                        Optional: supply prefix for the .txt files (default: 'Secret_Santa_for_')

  -s, --separator       Define the participant separator for the input file (default: ' ')

  -v, --verbose         Show the computation steps (default: false)

  -h, --help            Display this help message
EOF

# cli args
$input = "input.txt"
$prefix = "Secret_Santa_for_"
$writeToFiles = false
$separator = " "
$verbose = false

# stats
$maxNameLen = 0
$completed = false
$iterations = 0

# results
$illegal = {}
$santas = []
$assigned = []

def parseOpts
  opts = GetoptLong.new(
    ["--input", "-i", GetoptLong::REQUIRED_ARGUMENT],
    ["--write-to-files", "-f", GetoptLong::OPTIONAL_ARGUMENT],
    ["--separator", "-s", GetoptLong::REQUIRED_ARGUMENT],
    ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
    ["--help", "-h", GetoptLong::NO_ARGUMENT],
  )

  opts.each do |opt, arg|
    case opt
    when "--help"
      puts $help
      exit
    when "--input"
      $input = arg
    when "--write-to-files"
      $writeToFiles = true
      if arg != ''
        $prefix = arg
      end
    when "--separator"
      $separator = arg
    when "--verbose"
      $verbose = true
    end
  end
end

def parseInput
  File.open($input).read.each_line do |line|
    parts = line.split($separator)
    main = parts[0]
    $maxNameLen = [$maxNameLen, main.length].max

    $santas.push(main)
    $illegal[main] = [] if !$illegal.key?(main)
    $illegal[main].concat(parts)
    $illegal[main].uniq!
  end
  $santas.uniq!
  $santas.sort!
  dbg("Santas: " + $santas.join(", "))
end

def raffle
  dbg("Iteration #%d" % [$iterations])
  $iterations += 1
  $assigned = $santas.shuffle

  $santas.length.times do |i|
    bad = $illegal[$santas[i]]
    if bad.include?($assigned[i])
      if $verbose
        case $assigned[i]
          when "Britta"
            dbg("This pairing was Britta'd: %s ~> %s" % [$santas[i], $assigned[i]])
          when "Chang"
            dbg("CHANG- the pairing: %s ~> %s" % [$santas[i], $assigned[i]])
          when "Abed"
            dbg("Illegal pairing. Cool! Cool, cool, cool: %s ~> %s" % [$santas[i], $assigned[i]])
          else
            dbg("Illegal pairing: %s ~> %s" % [$santas[i], $assigned[i]])
        end
        dbg("All illegal pairings for %s: %s" % [$santas[i], bad.join(", ")])
      end

      return
    end
  end

  dbg("Iteration is valid!")
  $completed = true
end

def writeResults
  if !$writeToFiles
    puts "\nAssignments\n"
    $santas.length.times do |i|
      s = "  " + $santas[i].rjust($maxNameLen) + " ~> " + $assigned[i]
      puts s
    end
    return
  end

  $santas.length.times do |i|
    k = $santas[i]
    v = $assigned[i]
    name = "%s%s.txt" % [$prefix, k]
    dbg("Writing file for %s: '%s'" % [k, name])

    txt = "Hello %s! Your Secret Santa is\n\n  *<|:-)\t %s\n\nHO HO HO! MERRY CHRISTMAS!!!" % [k, v]
    File.open(name, "w") { |file| file.write(txt) }
  end
end

def printStats
  stats = "participants ".rjust(14) + $santas.length.to_s + "\n"
  stats += "iterations ".rjust(14) + $iterations.to_s + "\n"
  stats += "time ".rjust(14) + sprintf("%.2fms", $dt) + "\n"
  puts stats
end

def dbg(msg)
  return if !$verbose
  puts "[dbg] %s" % [msg]
end

def main
  parseOpts

  t = Time.now
  parseInput

  loop do
    raffle
    break if $completed
  end

  writeResults
  $dt = (Time.now.to_f - t.to_f)*1000.0

  puts "\n"
  printStats
  puts "\n*<|:-)"
end

main

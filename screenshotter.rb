#!/usr/bin/env ruby

FILE1 = ARGV[0]
FILE2 = ARGV[1]
N = (ARGV[2] || 10).to_i

if(!FILE2)
  puts("Usage: screenshotter.rb <FILE1> <FILE2> [number of snaps]")
  exit
end

REAL_LENGTH1 = `ffmpeg -i "#{FILE1}" 2>&1 | grep "Duration"`.scan(/Duration: ([0-9]+:[0-9]+:[0-9]+)/).pop.pop
REAL_LENGTH2 = `ffmpeg -i "#{FILE2}" 2>&1 | grep "Duration"`.scan(/Duration: ([0-9]+:[0-9]+:[0-9]+)/).pop.pop

LENGTH1 = REAL_LENGTH1.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b }
LENGTH2 = REAL_LENGTH2.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b }


puts "Comparing #{N} shots from:"
puts "* #{FILE1} -- #{REAL_LENGTH1} -- #{LENGTH1}s"
puts "* #{FILE2} -- #{REAL_LENGTH2} -- #{LENGTH2}s"
puts

if(REAL_LENGTH1 != REAL_LENGTH2)
  puts
  puts("** Warning: videos are not the same length, probably due to different frame rates. YMMV!")
  puts
  puts "(press enter to continue)"
  gets
end

0.upto(N-1) do
  timestamp = Time.at(rand([LENGTH1, LENGTH2].min)).utc.strftime("%H:%M:%S")

  name = "#{timestamp}-a.png".gsub(/:/, '-')
  puts "Snapping #{FILE1} @ #{timestamp} -> #{name}"
  `ffmpeg -ss #{timestamp} -i "#{FILE1}" -vframes 1 "#{name}" 2>&1 > /dev/null`

  name = "#{timestamp}-b.png".gsub(/:/, '-')
  puts "Snapping #{FILE2} @ #{timestamp} -> #{name}"
  `ffmpeg -ss #{timestamp} -i "#{FILE2}" -vframes 1 "#{name}" 2>&1 > /dev/null`
end

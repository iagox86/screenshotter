#!/usr/bin/env ruby

N = (ARGV[0]).to_i

FILES = ARGV[1..-1]

if(FILES.length == 0)
  puts("Usage: screenshotter.rb <Number of snaps> <FILE1> [<FILE2> ...]")
  exit
end

REAL_LENGTHS = FILES.map do |f|
  `ffmpeg -i "#{f}" 2>&1 | grep "Duration"`.scan(/Duration: ([0-9]+:[0-9]+:[0-9]+)/).pop.pop
end

LENGTHS = REAL_LENGTHS.map do |l|
  l.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b }
end

puts "Taking #{N} shots from:"
0.upto(FILES.length - 1) do |i|
  puts "* #{FILES[i]} -- #{REAL_LENGTHS[i]} -- #{LENGTHS[i]}s"
end
puts

1.upto(FILES.length - 1) do |i|
  if(REAL_LENGTHS[i - 1] != REAL_LENGTHS[i])
    puts("** Warning: videos are not the same length, probably due to different frame rates. YMMV!")
    puts
    puts "(press enter to continue)"
    $stdin.gets
  end
end

0.upto(N-1) do
  timestamp = Time.at(rand(LENGTHS.min)).utc.strftime("%H:%M:%S")

  0.upto(FILES.length - 1) do |i|
    name = "#{timestamp}-#{(0x61 + i).chr}.png".gsub(/:/, '-')
    puts "Snapping #{FILES[i]} @ #{timestamp} -> #{name}"
    `ffmpeg -ss #{timestamp} -i "#{FILES[i]}" -vframes 1 "#{name}" 2>&1 > /dev/null`
  end
  puts
end

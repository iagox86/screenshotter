#!/usr/bin/env ruby

N = (ARGV[0]).to_i

FILES = ARGV[1..-1].map { |f| "file:#{f}" }

if(FILES.length == 0)
  puts("Usage: screenshotter.rb <Number of snaps> <FILE1> [<FILE2> ...]")
  exit
end

REAL_LENGTHS = FILES.map do |f|
  `ffmpeg -i "#{f}" 2>&1 | grep "Duration"`.scan(/Duration: ([0-9]+:[0-9]+:[0-9]+\.[0-9]+)/).pop.pop
end

LENGTHS = REAL_LENGTHS.map do |l|
  h, m, s, cs = l.scan(/([0-9]+):([0-9]+):([0-9]+)\.([0-9]+)/).pop

  cs.to_i*10 + s.to_i*1000 + m.to_i*60000 + h.to_i*3600000
end

RATIOS = FILES.map do |f|
  `ffprobe -v error -show_format -show_streams '#{f}'  | grep display_aspect_ratio`.split(/=/)[1].chomp.split(/:/).map { |i| i.to_i }
end

WIDTHS = FILES.map do |f|
  `ffprobe -v error -show_format -show_streams '#{f}'  | grep '^width='`.split(/=/)[1].chomp.to_i
end


puts "Taking #{N} shots from:"
0.upto(FILES.length - 1) do |i|
  puts "* #{REAL_LENGTHS[i]} -- #{LENGTHS[i]}ms -- #{FILES[i]} "
end
puts

1.upto(FILES.length - 1) do |i|
  if(LENGTHS[i - 1] != LENGTHS[i])
    puts("** Warning: videos are not the same length, probably due to different frame rates. YMMV!")
    puts
    puts "(press enter to continue)"
    $stdin.gets
  end
end

0.upto(N-1) do
  base_timestamp = rand(LENGTHS.min)

  0.upto(FILES.length - 1) do |i|
    ms = base_timestamp

    h  = ms / 3600000
    ms = ms % 3600000

    m  = ms / 60000
    ms = ms % 60000

    s  = ms / 1000
    ms = ms % 1000

    formatted = "%02d:%02d:%02d.%02d" % [h, m, s, ms / 10]


    name = "#{formatted}-#{(0x61 + i).chr}.png".gsub(/:/, '-')
    puts "Snapping #{FILES[i]} @ #{formatted} -> #{name}"

    width = WIDTHS[i]
    height = width * RATIOS[i][1] / RATIOS[i][0]

    command = "ffmpeg -ss #{formatted} -i '#{FILES[i]}' -vframes 1 -vf scale=#{width}x#{height} '#{name}' 2>&1 > /dev/null"
    puts command
    `#{command}`
  end
  puts
end

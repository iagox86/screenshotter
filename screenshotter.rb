#!/usr/bin/env ruby

N = (ARGV[0]).to_i

FILES = ARGV[1..-1]

if(FILES.length == 0)
  puts("Usage: screenshotter.rb <Number of snaps> <FILE1> [<FILE2> ...]")
  exit
end

INFO = FILES.map do |f|
  {
    filename:   f,
    framecount: `mediainfo --Output='Video;%FrameCount%' '#{f}'`.chomp.to_i,
    framerate: `mediainfo --Output='Video;%FrameRate%' '#{f}'`.chomp.to_f,
    ratio:      `ffprobe -v error -show_format -show_streams 'file:#{f}'  | grep display_aspect_ratio`.split(/=/)[1].chomp.split(/:/).map { |i| i.to_i },
    width:      `ffprobe -v error -show_format -show_streams 'file:#{f}'  | grep '^width='`.split(/=/)[1].chomp.to_i,
  }
end

puts "Taking #{N} shots from:"
puts INFO
puts

1.upto(FILES.length - 1) do |i|
  if(INFO[i - 1][:framecount] != INFO[i][:framecount])
    puts("** Warning: videos are not the same length, probably due to different frame rates. YMMV!")
    puts
    puts "(press enter to continue)"
    $stdin.gets
  end
end

0.upto(N-1) do |c|
  location = rand()

  0.upto(FILES.length - 1) do |i|
    frame = (location * INFO[i][:framecount]).floor

    name = "shot#{c}-#{(0x61 + i).chr}.png".gsub(/:/, '-')
    puts "Snapping #{INFO[i][:filename]} @ #{frame} -> #{name}"

    width = INFO[i][:width]
    height = width * INFO[i][:ratio][1] / INFO[i][:ratio][0]

    command = "yes|ffmpeg -ss '#{location * INFO[i][:framecount] / INFO[i][:framerate]}' -i 'file:#{INFO[i][:filename]}' -vframes 1 -vf 'scale=#{width}x#{height}'  '#{name}' 2>&1 > /dev/null"
    puts "#{command}..."
    `#{command}`
  end
  puts
end

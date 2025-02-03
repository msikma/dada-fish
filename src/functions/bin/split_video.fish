#!/usr/bin/env fish

set curr (dirname (status --current-filename))
source "$curr/../../lib/os.fish"

set USAGE 'usage: split_video FILE [SEGMENT [SEGMENT …]]'

function main
  ! _require_cmd "ffmpeg"; and return 1

  set input_file $argv[1]
  set timestamps $argv[2..-1]
  set last_item (math (count $timestamps) + 1)

  for i in (seq 1 (math (count $timestamps) + 1))
    set start_time $timestamps[(math max (math $i - 1), 1)]
    set end_time $timestamps[$i]
    set output_file (string replace -r '\.([^.]*)$' "__$i.\$1" $input_file)

    if test "$output_file" = "$input_file"
      # In case we have a weird filename, like no extension.
      set output_file "$input_file""__$i.mp4"
    end
  
    if test $i -eq 1
      # First segment.
      ffmpeg -i "$input_file" -to "$end_time" -c copy "$output_file"
    else if test $i -eq $last_item
      # Last segment.
      ffmpeg -ss "$start_time" -i "$input_file" -c copy "$output_file"
    else
      # Middle segments.
      ffmpeg -ss "$start_time" -to "$end_time" -i "$input_file" -c copy "$output_file"
    end
  end
end

main $argv

#_dada_fish _register_dependency "brew" "ffmpeg" "ffmpeg"
#_dada_fish _register_bin regular "split_video" "fn ts…" "split_video.fish" "Splits a video up into segments"

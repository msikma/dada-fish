# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _yt_split_usage
  echo "usage: yt_split [-h|--help] FILE…"
  echo ""
  echo "Arguments:"
  echo "  --help, -h    prints usage information"
  echo "  FILE          path to the file to split"
  echo ""
  echo "Designed to be used with the output from yt_archive."
  echo "yt_split will use the .description.txt file in the same direcory for timestamps."
end

function _yt_extract_chapters --argument filename
  set -l result
  set -l saw_timestamp 0
  set -l non_timestamp_lines 0

  for line in (cat $filename)
    set line (string trim "$line")

    # Match timestamp at the end of the line, e.g. 0:00, 1:01:20.
    if string match -qr '\b([0-9]{1,2}:)?[0-5]?[0-9]:[0-5][0-9]$' -- "$line"
      # Reset counters; we're inside of the timestamps section.
      set non_timestamp_lines 0
      set saw_timestamp 1

      # Extract timestamp (last word) and label (rest of line).
      set -l timestamp (string match -r '([0-9]{1,2}:)?[0-5]?[0-9]:[0-5][0-9]$' -- "$line")
      set -l label (string replace "$timestamp" "" -- "$line" | string trim)

      set -a result "$label" "$timestamp"
    else if test $saw_timestamp -eq 1
      # After we've seen at least one timestamp, count non-timestamp lines;
      # we'll break after 2, as it means we're definitely out of the timestamps list.
      # This prevents us from accidentally picking up additional timestamps
      # from the regular part of the description.
      set non_timestamp_lines (math "$non_timestamp_lines + 1")
      if test $non_timestamp_lines -ge 2
        break
      end
    end
  end

  # Verify that the list starts with 0:00 (or some variation).
  # If not, these are not real Youtube chapters.
  if test (count $result) -ge 2
    set -l first_timestamp $result[2]
    if not string match -qr '^(0|00):00(:00)?$' -- $first_timestamp
      return 1
    end
  else
    return 1
  end

  for n in (seq 1 (count $result))
    echo $result[$n]
  end
end

function _yt_split_by_chapters --argument-names input_file description_file
  set segments (_yt_extract_chapters "$description_file")
  set basedir (dirname "$input_file")
  set file (basename "$input_file")
  set ext (_file_ext "$file")

  pushd "$basedir"

  set idx 1
  set count (count $segments)
  set last (math (count $segments) / 2)

  # We should always get a multiple of 2. If not, timestamp extraction failed.
  if test (math "floor($last)") -ne "$last"
    return 1
  end

  mkdir -p "chapters"

  # Iterate over all chapter segments and slice out the timestamp.
  for n in (seq 1 2 "$count")
    set label $segments[$n]
    set timestamp $segments[(math $n + 1)]

    set basename (_sanitize_filename_part (printf "%03d -" "$idx")" $label")
    set output_file "chapters/$basename.$ext"

    set start_time $timestamp
    set end_time $segments[(math min (math $n + 3), "$count")]

    if test $idx -eq 1
      ffmpeg -y -i "$input_file" -to "$end_time" -c copy "$output_file"
    else if test $idx -eq $last
      ffmpeg -y -ss "$start_time" -i "$input_file" -c copy "$output_file"
    else
      ffmpeg -y -ss "$start_time" -to "$end_time" -i "$input_file" -c copy "$output_file"
    end

    set idx (math $idx + 1)
  end

  popd
end

function yt_split --description "Splits Youtube timestamps"
  ! _require_cmd "ffmpeg"; and return 1

  if test (count $argv) -ne 1
    _yt_split_usage
    return 1
  end

  if contains -- "-h" $argv || contains -- "--help" $argv
    _yt_split_usage
    return 0
  end

  set input_file "$argv[1]"
  if ! test -f "$input_file"
    echo "yt_split: error: given argument is not a file"
    return 1
  end
  set description_file (find . \( -iname "*.description.txt" -o -iname "*.description" \) -maxdepth 1 -mindepth 1)
  set description_file "$description_file[1]"
  if ! test -f "$description_file"
    echo "yt_split: error: no description file found"
    return 1
  end
  
  _yt_split_by_chapters "$input_file" "$description_file"
end

_register_command archiving "yt_split" "fn…"
_register_dependency "brew" "ffmpeg" "ffmpeg"

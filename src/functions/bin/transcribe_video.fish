#!/usr/bin/env fish

set curr (dirname (status --current-filename))
source "$curr/../../lib/os.fish"

set USAGE 'usage: transcribe_video FILE'
set MODEL "medium"

function _transcribe_video_file --argument-names filepath tempdir task
  if [ ! -e "$filepath" ]
    echo "transcribe_video: cannot find file: $filepath"
    return 1
  end

  set orig_name (basename "$filepath")
  set orig_ext (string match -r '\.[^.]*$' "$orig_name")
  set orig_base (basename "$orig_name" "$orig_ext")
  set orig_path (dirname "$filepath")
  if string match -q "*_transcribed" "$orig_base"
    echo (set_color red)"Skipping"(set_color normal) (set_color -d red)"("(set_color reset)(set_color magenta)"$task"(set_color -d red)")"(set_color red):(set_color normal) (set_color yellow)"$filepath"(set_color normal)
    return 1
  end

  echo (set_color cyan)"Processing"(set_color normal) (set_color -d cyan)"("(set_color reset)(set_color magenta)"$task"(set_color -d cyan)")"(set_color cyan):(set_color normal) (set_color yellow)"$filepath"(set_color normal)
  echo

  # If we're processing a .webm file, we can't use .srt. We'll use WebVTT instead.
  set sub_ext "srt"
  set sub_codec "mov_text"
  if [ "$orig_ext" = ".webm" ]
    set sub_ext "vtt"
    set sub_codec "webvtt"
  end

  # Extract audio to a wav file.
  ffmpeg -i "$filepath" \
    -hide_banner \
    -loglevel error \
    -ar 16000 \
    -ac 1 \
    -c:a pcm_s16le \
    -y \
    "$tempdir/outfile.wav"
  
  # Run Whisper on the output file.
  whisper \
    --model "$MODEL" \
    --output_dir "$tempdir" \
    --output_format "$sub_ext" \
    --task "$task" \
    "$tempdir/outfile.wav"
  
  set sub_file "$tempdir/outfile.$sub_ext"
  
  if [ ! -e "$sub_file" ]
    echo "transcribe_video: could not transcribe video file (whisper failure): $filepath"
    return 1
  end
  
  if ffmpeg -i "$filepath" \
    -hide_banner \
    -loglevel error \
    -i "$sub_file" \
    -c copy \
    -c:s "$sub_codec" \
    -disposition:s:0 default \
    -y \
      "$tempdir/outfile$orig_ext"
    mv "$tempdir/outfile$orig_ext" "$orig_path/$orig_base""_transcribed$orig_ext"
  else
    return 1
  end
end

function main
  ! _require_cmd "whisper"; and return 1
  ! _require_cmd "ffmpeg"; and return 1

  # Check if any files are passed.
  if not set -q argv[1]
    echo $USAGE
    return 1
  end

  # Default to "translate" task; if -t is set, use "transcribe" task.
  set task "translate"
  if [ "$argv[1]" = "-t" ]
    set task "transcribe"
    set argv $argv[2..-1]
  end

  # Work in a temp directory (will be deleted after).
  set tempdir (mktemp -d)
  if [ ! -n "$tempdir" ]
    echo "transcribe_video: could not create temporary directory"
    return 1
  end

  set count 0
  for filepath in $argv
    if time _transcribe_video_file "$filepath" "$tempdir" "$task"
      set count (math "$count" + 1)
    end
    echo
  end

  if [ -e "$tempdir" ]
    rm -rf "$tempdir"
  end

  echo -n (set_color cyan)"Done. Processed "(set_color reset)
  echo (test $count -eq 1; and echo (set_color yellow)"$count"(set_color cyan)" file"; or echo (set_color yellow)"$count"(set_color cyan)" files")
end

main $argv

#_dada_fish _register_dependency "brew" "whisper" "openai-whisper"
#_dada_fish _register_dependency "brew" "ffmpeg" "ffmpeg"
#_dada_fish _register_bin regular "transcribe_video" "[-t] fn…" "transcribe_video.fish" "Adds subtitles to a video file"

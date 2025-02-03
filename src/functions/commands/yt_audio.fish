# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function yt_audio --description "Archives audio from Youtube"
  ! _require_cmd "yt-dlp"; and return 1

  # If the first argument is not a URL, assume it's the audio format.
  # Default to 'best' audio (variable output extension).
  if string match -q "http*" $argv[1]
    set audio_format "best"
    set urls $argv
  else
    set audio_format $argv[1]
    set urls $argv[2..-1]
  end

  # Check whether this is a playlist or not.
  # If so, include the playlist_index variable in the filename.
  set tpl_playlist "%(playlist_index)s - %(title)s [%(id)s].%(ext)s"
  set tpl_single "%(autonumber)02d %(title)s (%(upload_date>%Y-%m-%d)s) [%(id)s].%(ext)s"
  for n in (seq (count $urls))
    set url $urls[$n]
    if begin string match -qr -- ".+?playlist\?list.+?" $url; \
      or string match -qr -- ".+?&list=.+?" $url; end
      set tpl $tpl_playlist
      echo (set_color magenta)"Downloading in playlist mode"(set_color normal)
    else
      set tpl $tpl_single
    end
    
    yt-dlp -i --format "bestaudio" -x --convert-thumbnail jpg --add-metadata --embed-metadata --embed-thumbnail --autonumber-start "$n" --audio-format $audio_format -o $tpl $url
  end
end

_register_command archiving "yt_audio" "url…"
_register_dependency "brew" "yt-dlp" "yt-dlp"

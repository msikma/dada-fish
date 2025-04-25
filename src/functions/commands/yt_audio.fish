# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _yt_audio_usage
  echo "usage: yt_audio [-h|--help] [-na] [-nc] URL…"
  echo ""
  echo "Arguments:"
  echo "  --help, -h    prints usage information"
  echo "  -na           no download archive check (redownload)"
  echo "  -nc           no browser cookies"
end

function yt_audio --description "Archives audio from various sites"
  set yt_archive_file "$DADA_CACHE/yt_audio_archive.txt"
  set arg_dl_archive "--download-archive" "$yt_archive_file"
  if contains -- "-na" $argv
    set arg_dl_archive
  end
  set arg_cookies "--cookies-from-browser" "firefox"
  if contains -- "-nc" $argv
    set arg_cookies
  end
  for n in (seq (count $argv))
    set arg $argv[$n]
    if string match -q -- "-*" "$arg"
      continue
    end
    yt-dlp --ignore-errors --format "bestaudio" --extract-audio \
      --convert-thumbnail jpg --add-metadata --embed-metadata \
      --embed-thumbnail --autonumber-start "$n" --audio-format "best" \
      $arg_dl_archive \
      $arg_cookies \
      "$arg"
  end
end

_register_command archiving "yt_audio" "url…"
_register_dependency "brew" "yt-dlp" "yt-dlp"
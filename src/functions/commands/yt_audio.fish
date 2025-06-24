# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _yt_audio_usage
  echo "usage: yt_audio [-h|--help] [-na] [-nc] [-fo] URL…"
  echo ""
  echo "Arguments:"
  echo "  --help, -h    prints usage information"
  echo "  -na           no download archive check (redownload)"
  echo "  -nc           no browser cookies"
  echo "  -fo           file only (no archiving files)"
end

function yt_audio --description "Archives audio from various sites"
  set yt_archive_file "$DADA_CACHE/yt_audio_archive.txt"

  # Unless the user's arguments include -fo, we will simply call yt_archive to do the work.
  # yt_archive is designed to include a bunch of additional data for archiving purposes.
  if ! contains -- "-fo" $argv
    set args
    set -a args "-a"
    set -a args "-ar:$yt_archive_file"
    if contains -- "-na" $argv; set -a args "-na"; end
    if contains -- "-nc" $argv; set -a args "-nc"; end
    if test -z $argv[1]
      _yt_audio_usage
      return 1
    end
    set files
    for n in (seq (count $argv))
      if ! string match -q -- "-*" "$argv[$n]"
        set -a args "$argv[$n]"
        set -a files "$argv[$n]"
      end
    end
    if test -z $files[1]
      _yt_audio_usage
      return 1
    end
    yt_archive $args
    return
  end

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

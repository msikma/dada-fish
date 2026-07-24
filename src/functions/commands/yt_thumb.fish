# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _yt_thumb_usage
  echo "usage: yt_thumb URL…"
end

function yt_thumb --description "Downloads a video thumbnail"
  ! _require_cmd "yt-dlp"; and return 1

  if test (count $argv) -eq 0
    _yt_thumb_usage
    return 1
  end
  
  if contains -- "-h" $argv || contains -- "--help" $argv
    _yt_thumb_usage
    return 0
  end

  for arg in $argv
    if string match -r '^-' -- "$arg" >/dev/null
      continue
    end

    yt-dlp --write-thumbnail --skip-download "$arg"
  end
end

_register_command archiving "yt_thumb" "url…"
_register_dependency "brew" "yt-dlp" "yt-dlp"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function yt_archive --description "Archives videos from Youtube"
  ! _require_cmd "yt-dlp"; and return 1

  if test (count $argv) -eq 0
    echo "usage: yt_archive URL…"
    return 1
  end

  yt-dlp --ignore-errors --add-metadata --write-description --write-info-json \
    --write-annotations --write-subs --write-thumbnail --embed-thumbnail --all-subs \
    --embed-subs --download-archive "$DADA_CACHE/yt_archive.txt" --sub-langs all --get-comments \
    --parse-metadata "%(title)s:%(meta_title)s" \
    --parse-metadata "%(uploader)s:%(meta_artist)s" \
    $argv
end

_register_command archiving "yt_archive" "url…"
_register_dependency "brew" "yt-dlp" "yt-dlp"

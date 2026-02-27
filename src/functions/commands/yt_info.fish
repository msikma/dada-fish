# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function yt_info --description "Prints JSON info about a URL"
  ! _require_cmd "yt-dlp"; and return 1
  ! _require_cmd "jq"; and return 1
  yt-dlp -J "$argv[1]" | jq
end

_register_command archiving "yt_info" "url"
_register_dependency "brew" "yt-dlp" "yt-dlp"
_register_dependency "brew" "jq" "jq"

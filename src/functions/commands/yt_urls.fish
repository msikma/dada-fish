# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function yt_urls --description "Lists a URL's archivable items"
  ! _require_cmd "yt-dlp"; and return 1
  yt-dlp --flat-playlist --print "%(webpage_url)s" "$argv[1]"
end

_register_command archiving "yt_urls" "url"
_register_dependency "brew" "yt-dlp" "yt-dlp"

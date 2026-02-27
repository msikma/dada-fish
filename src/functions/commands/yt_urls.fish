# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _yt_urls_usage
  echo "usage: yt_urls [-s] URL"
  echo ""
  echo "Arguments:"
  echo "  -s         sort by title"
  echo "  URL        URL to list archivable URLs for"
end

function yt_urls --description "Lists a URL's archivable items"
  ! _require_cmd "yt-dlp"; and return 1

  if test "$argv[1]" = "-s"
    if test (count $argv) -lt 2
      _yt_urls_usage
      return 1
    end
    yt-dlp --flat-playlist --print "%(title)s ###___### %(webpage_url)s # %(title)s" "$argv[2]" | sort | sed 's/.*###___### //'
  else
    if test -z "$argv[1]"
      _yt_urls_usage
      return 1
    end
    yt-dlp --flat-playlist --print "%(webpage_url)s # %(title)s" "$argv[1]"
  end
end

_register_command archiving "yt_urls" "[-s] url"
_register_dependency "brew" "yt-dlp" "yt-dlp"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function scrape_media --description "Grabs media files from a website" --argument-names url
  set wget_args $argv[2..-1]
  echo (set_color yellow)Downloading media files from(set_color green)" $url"
  printf (set_color yellow)"Media files we'll download: "
  for ext in $_media_exts
    printf (set_color cyan)"$ext "
  end
  printf (set_color normal)"\n"
  wget --mirror --level 15 --no-directories --span-hosts --page-requisites --tries 30 --retry-connrefused --wait 1 --execute robots=off --accept (string join , $_media_extensions) $wget_args "$url"
end

_register_command archiving "scrape_media" "url"
_register_dependency "brew" "wget" "wget"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function scrape_url --description "Mirrors a website using wget" --argument-names url
  ! _require_cmd "wget"; and return 1
  
  set wget_args $argv[2..-1]
  echo (set_color yellow)Mirroring website:(set_color green)" $url"(set_color normal)
  wget --mirror --convert-links --page-requisites --adjust-extension --level 15 --tries 30 --retry-connrefused --wait 1 $wget_args "$url"
end

_register_command archiving "scrape_url" "url"
_register_dependency "brew" "wget" "wget"

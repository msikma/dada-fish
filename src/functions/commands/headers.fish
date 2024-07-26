# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function headers --argument-names url --description "Displays response headers for URL"
  ! _require_cmd "pygmentize"; and return 1

  curl -kLsD- -o /dev/null "$url" | pygmentize -l http
end

_register_command script "headers" "url"
_register_dependency "brew" "pygments" "pygmentize"
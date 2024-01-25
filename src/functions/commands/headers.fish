# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function headers --argument-names url --description "Displays response headers for URL"
  curl -kLsD- -o /dev/null "$url" | pygmentize -l http
end

_register_command script "headers" "url"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function iad --argument-names url --description "Download an item from the IA"
  set id (_ia_id "$url")
  if test "$status" -eq 1
    echo "iad: error: not a valid URL or identifier: $url"
    return 1
  end

  ia download --exclude-source derivative -- "$id"
end

_register_command archiving "iad" "…"
_register_dependency "brew" "internetarchive" "ia"

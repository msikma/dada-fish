# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function indent_json --description "Indents a JSON file in place" --argument-names fn
  ! _require_cmd "jq"; and return 1
  if [ -z "$fn" ]
    echo "indent_json: usage: indent_json FN"
    return 1
  end
  set tmp (mktemp)
  cat "$fn" | jq > "$tmp" 2>&1
  set errcode $status
  if [ $status -ne 0 ]
    set err (cat "$tmp")
    rm "$tmp"
    echo "indent_json: error: $err"
    return $errcode
  end
  rm "$fn"
  mv "$tmp" "$fn"
end

_register_command media "indent_json" "fn"
_register_dependency "brew" "jq" "jq"

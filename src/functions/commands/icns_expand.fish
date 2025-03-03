# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function icns_expand --argument-names infile --description "Converts: .icns → .iconset"
  ! _require_cmd "iconutil"; and return 1
  if not test -e "$infile" || test -z "$infile"
    echo "icns_expand: usage: icns_expand ICNS"
    return 1
  end
  set base (basename "$infile" .icns)
  iconutil --convert iconset "$infile" --output "./$base.iconset"
end

_register_command conversion "icns_expand" "fn"

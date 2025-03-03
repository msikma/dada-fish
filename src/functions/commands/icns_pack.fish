# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function icns_pack --argument-names infile --description "Converts: .iconset → .icns"
  ! _require_cmd "iconutil"; and return 1
  if not test -d "$infile" || test -z "$infile"
    echo "icns_pack: usage: icns_pack ICONSET"
    return 1
  end
  set base (basename "$infile" .iconset)
  iconutil --convert icns "$infile"
end

_register_command conversion "icns_pack" "fn"

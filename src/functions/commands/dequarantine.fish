# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function dequarantine --argument-names infile --description "Removes Apple quarantine attribute"
  ! _require_cmd "xattr"; and return 1
  if [ -z "$infile" ]
    echo "usage: dequarantine FILE"
    return
  end
  xattr -r -d com.apple.quarantine "$infile"
end

_register_command script "dequarantine" "fn"

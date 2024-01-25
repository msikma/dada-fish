# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function dmg2iso --argument-names infile outfile --description "Converts: .dmg → .iso"
  ! _require_cmd "hdiutil"; and return 1
  if [ -z "$infile" ]
    echo "usage: dmg2iso infile [outfile]"
    return
  end
  if [ -z "$outfile" ]
    set outfile (fn_base "$infile")".iso"
  end
  hdiutil makehybrid -iso -joliet -o "$outfile" "$infile"
end

_register_command conversion "dmg2iso" "fn"

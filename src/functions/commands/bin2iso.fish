# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function bin2iso --argument-names cuefile outfile --description "Converts: .bin/.cue → .iso"
  ! _require_cmd "bchunk"; and return 1
  
  if [ -z "$cuefile" ]
    echo "usage: bincue2iso cuefile [outfile]"
    return
  end

  if [ ! (file "$cuefile" | grep -i ": ASCII text") ]
    echo "bin2iso: error: .cue file does not appear to be ASCII text"
    return 1
  end
  
  set entries (sed -nE 's/^file "(.*)" binary/\1/pI' "$cuefile")

  if [ (count "$entries") -gt 1 ]
    echo "bin2iso: error: .cue file contains multiple binary FILE entries; using only the first"
  end
  # Note: seems there can be a carriage return in the output, so strip it.
  set entry (echo "$entries[1]" | tr -d '\r')

  if [ -z "$outfile" ]
    set outfile (_file_base "$cuefile")".iso"
  end

  bchunk -v "$entry" "$cuefile" "$outfile"
end

_register_command conversion "bin2iso" "fn"

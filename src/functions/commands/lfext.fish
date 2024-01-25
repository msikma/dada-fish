# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function lfext --description "Finds files of a given extension" --argument-names dir ext
  if [ -z "$ext" ]
    echo "lfext: usage: lfext DIR EXT"
    return 1
  end
  if [ ! -d $dir ]
    echo "lfext: error: can't find directory: $dir"
    return 1
  end
  find "$dir" -maxdepth 1 -mindepth 1 -type f -name "*.$ext"
end

_register_command helpers "lfext" "dir ext"

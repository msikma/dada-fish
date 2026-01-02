# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function crc32sum --description "Calculates CRC32 sum"
  ! _require_cmd "crc32"; and return 1

  set fn "$argv[1]"
  if [ -z "$fn" ]
    echo "crc32sum: usage: crc32sum FILENAME"
    return 1
  end
  if [ ! -f "$fn" ]
    echo "crc32sum: error: file \"$fn\" does not exist"
    return 1
  end
  
  set crc (crc32 "$fn" | string sub -e 8 | string upper)
  echo "$crc"
end

_register_command media "crc32sum" "fn"

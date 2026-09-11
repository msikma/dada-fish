# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function hashes --description "Calculates file hashes"
  ! _require_cmd "crc32"; and return 1
  ! _require_cmd "shasum"; and return 1
  ! _require_cmd "md5sum"; and return 1

  set -l upper 0
  set -l args $argv
  if contains -- -u $args
    set upper 1
    set args (string match -v -- -u $args)
  end

  set fn "$args[1]"
  if test -z "$fn"
    echo "hashes: usage: hashes [-u] FILENAME"
    return 1
  end
  if test ! -f "$fn"
    echo "hashes: error: file \"$fn\" does not exist"
    return 1
  end

  set -l size (stat -f %z "$fn")
  set -l mtime (stat -f %m "$fn")
  
  set crc (crc32 "$fn" | string sub -e 8)
  set md5 (md5sum "$fn" | string split ' ' | head -n1)
  set sha1 (shasum -a 1 "$fn" | string split ' ' | head -n1)
  set sha256 (shasum -a 256 "$fn" | string split ' ' | head -n1)

  if test "$upper" -eq 1
    set crc (string upper $crc)
    set md5 (string upper $md5)
    set sha1 (string upper $sha1)
    set sha256 (string upper $sha256)
  end
  
  echo "; $size $mtime $fn"
  echo "CRC32:   $crc"
  echo "MD5:     $md5"
  echo "SHA-1:   $sha1"
  echo "SHA-256: $sha256"
end

_register_command media "hashes" "[-u] fn"

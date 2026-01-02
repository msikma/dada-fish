# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _file_crc_verify --argument-names fn
  set crc_fn (echo "$fn" | sed -n 's/.*\[\([0-9A-Fa-f]\{8\}\)\].*/\1/p')
  set crc_calc (crc32 "$fn" | string sub -e 8 | string upper)
  set is_ok ""
  if test "$crc_fn" != "$crc_calc"
    set is_ok "! "
  end
  printf "%s%s\t%s\n" "$is_ok" "$crc_calc" "$fn"
end

function crc_verify --description "Verified CRC32 sum in filename"
  ! _require_cmd "crc32"; and return 1

  set fn "$argv[1]"
  if test -z "$fn"
    echo "crc_verify: usage: crc_verify FILENAME"
    return 1
  end
  if test ! -f "$fn" -a ! -d "$fn"
    echo "crc_verify: error: file \"$fn\" does not exist"
    return 1
  end
  
  if test -d "$fn"
    for f in (find . -type f -iname '*\[[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\]*' | sort)
      _file_crc_verify "$f"
    end
  else
    _file_crc_verify "$fn"
  end
end

_register_command media "crc_verify" "fn"

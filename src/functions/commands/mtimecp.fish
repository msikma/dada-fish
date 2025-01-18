# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function mtimecp --description "Copies mtime from src to dst file" --argument-names src dst
  if [ -z "$src" ]
    echo "mtimecp: usage: mtimecp SRC DST"
    return 1
  end
  set mod_time (stat -f "%m" "$src")
  set acc_time (stat -f "%a" "$src")
  touch -m -t (date -r "$mod_time" +"%Y%m%d%H%M.%S") "$dst"
  touch -a -t (date -r "$acc_time" +"%Y%m%d%H%M.%S") "$dst"
end

_register_command helpers "mtimecp" "src dst"

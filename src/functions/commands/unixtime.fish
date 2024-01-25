# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function unixtime --description "Displays Unix time as date"
  if [ (_is_macos) ]
    date -r "$argv[1]"
  else
    gdate -d "@$argv[1]"
  end
end

_register_command helpers "unixtime" "ts"

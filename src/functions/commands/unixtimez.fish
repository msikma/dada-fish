# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function unixtimez --description "Displays Unix time as UTC date"
  if [ (_is_macos) ]
    date -u -r "$argv[1]"
  else
    gdate -u -d "@$argv[1]"
  end
end

_register_command helpers "unixtimez" "ts"

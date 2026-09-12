# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function parsetime --description "Parses string as Unix time" --argument-names ts
  ruby -r date -e 'puts DateTime.parse(ARGV[0]).to_time.to_i' "$ts"
end

_register_command helpers "parsetime" "ts"

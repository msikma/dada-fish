# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function parsetime --description "Parses string as Unix time" --argument-names ts
  if not set -q ts[1]
    date +%s
  else
    ruby -r date -e 'puts DateTime.parse(ARGV[0]).to_time.to_i' "$ts"
  end
end

_register_command helpers "parsetime" "ts"

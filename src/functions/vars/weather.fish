# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Cache the current weather.
function _gen_weather_vars_cache --argument-names filepath
  begin
    set -l IFS
    set current_weather (_get_current_weather)
  end

  for var in "current_weather"
    printf "set %s %s\n" "$var" (string escape "$$var") >> "$filepath"
  end
end

## Prints out the current weather, only for the current location.
function _get_current_weather
  curl --connect-timeout 4 -s "wttr.in" | sed -n '3,7 p'
end

#_register_cache_vars "weather" "_gen_weather_vars_cache" "15" "1"

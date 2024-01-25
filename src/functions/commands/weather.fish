# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function weather --description "Queries wttr.in for the weather"
  #       .-.      Drizzle
  #      (   ).    13 °C
  #     (___(__)   ↗ 7 km/h
  #      ‘ ‘ ‘ ‘   10 km
  #     ‘ ‘ ‘ ‘    0.0 mm
  # Note: for help, run "curl wttr.in/:help" - or visit <https://github.com/chubin/wttr.in>.
  echo "$_weather_loc"
  curl -s "wttr.in/$_weather_loc" \
    -H "Accept-Language: $dada_acceptlang" \
    | \
    ghead -n -2
end

_register_command script "weather"

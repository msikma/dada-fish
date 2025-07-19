# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Duration of various time units in seconds.
set -g year_l 31536000
set -g month_l 2628000
set -g week_l 604800
set -g day_l 86400
set -g hour_l 3600
set -g minute_l 60

# Globals used for the timer.
set -g a_secs
set -g a_ms

## Saves the current time in ms to compare later.
function _timer_start
  set a_secs (gdate +%s)
  set a_ms (gdate +%N)
end

## Prints the difference between timer_start and now.
function _timer_end
  if [ -z "$a_secs" ]
    echo "(unknown)"
    return
  end
  set b_secs (gdate +%s)
  set b_ms (gdate +%N)

  awk "BEGIN{ print $b_secs.00$b_ms - $a_secs.00$a_ms; }"
end

## Prints out a humanized duration of a time in seconds.
function _duration_humanized --argument-names sec
  if [ "$sec" = "(unknown)" ]
    echo $sec
    return
  end
  _time_unit $sec
end

## Returns an ISO 8601 timestamp string.
function _timestamp_iso8601 --argument-names timestamp
  if [ -z "$timestamp" ]
    set timestamp "@"(gdate -u +"%s")
  end
  gdate -u -d "$timestamp" +"%Y-%m-%d %H:%M:%S.%3N"
end

## Returns a timestamp string with timezone.
function _timestamp_tz --argument-names timestamp
  if [ -z "$timestamp" ]
    set timestamp "@"(gdate -u +"%s")
  end
  gdate -d "$timestamp" +"%Y-%m-%d %H:%M:%S %z"
end

## Returns a relative time from a given timestamp string.
function _relative_timestamp --argument-names timestamp
  set now (date +%s)
  set timestamp (gdate -u -d "$timestamp" +"%s")
  set diff (math "$now - $timestamp")

  if [ $diff -eq 0 ]
    echo "just now"
    return
  end

  set value # amount in time units
  set unit # e.g. "minute"
  set dir # future or past

  if [ $diff -lt 0 ]
    set dir "future"
    set diff (math "-$diff")
  else
    set dir "past"
  end

  if [ $diff -lt 60 ]
    set unit "second"
    set value "$diff"
  else if [ $diff -lt 3600 ]
    set unit "minute"
    set value (math "$diff / 60")
  else if [ $diff -lt 86400 ]
    set unit "hour"
    set value (math "$diff / 3600")
  else if [ $diff -lt 604800 ]
    set unit "day"
    set value (math "$diff / 86400")
  else if [ $diff -lt 2592000 ]
    set unit "week"
    set value (math "$diff / 604800")
  else if [ $diff -lt 31536000 ]
    set unit "month"
    set value (math "$diff / 2592000")
  else
    set unit "year"
    set value (math "$diff / 31536000")
  end
  
  set value (math "round $value")
  if [ $value -ne 1 ]
    set unit "$unit""s"
  end
  
  if [ $dir = "future" ]
    echo "in $value $unit"
  else
    echo "$value $unit ago"
  end
end

## Converts seconds to a longer time unit.
function _time_unit --argument-names sec
  set years (math "floor($sec / $year_l)")
  if [ $years -gt 0 ]
    _time_unit_echo $years "year" "years"
    return
  end
  set months (math "floor($sec / $month_l)")
  if [ $months -gt 0 ]
    _time_unit_echo $months "month" "months"
    return
  end
  set weeks (math "floor($sec / $week_l)")
  if [ $weeks -gt 0 ]
    _time_unit_echo $weeks "week" "weeks"
    return
  end
  set days (math "floor($sec / $day_l)")
  if [ $days -gt 0 ]
    _time_unit_echo $days "day" "days"
    return
  end
  set hours (math "floor($sec / $hour_l)")
  if [ $hours -gt 0 ]
    _time_unit_echo $hours "hour" "hours"
    return
  end
  set minutes (math "floor($sec / $minute_l)")
  if [ $minutes -gt 0 ]
    _time_unit_echo $minutes "minute" "minutes"
    return
  end
  set ms (math "floor($sec * 1000)")
  if [ $ms -lt 1000 ]
    if [ $ms -lt 1 ]
      echo -n ">"
      _time_unit_echo "1" "ms" "ms"
    else
      _time_unit_echo $ms "ms" "ms"
    end
    return
  end

  _time_unit_echo $sec "second" "seconds"
end

# Prints out a single time unit, either using the singular or the plural word.
function _time_unit_echo --argument-names value singular plural
  echo -n $value
  if [ "$value" -eq 1 ]
    echo -n " $singular"
  else
    echo -n " $plural"
  end
end

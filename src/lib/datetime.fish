# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

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
  set dir # "ago" or "from now"

  if [ $diff -lt 0 ]
    set dir "from now"
    set diff (math "-$diff")
  else
    set dir "ago"
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
  
  echo "$value $unit $dir"
end

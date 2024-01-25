# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns an ISO 8601 timestamp string.
function _timestamp_iso8601 --argument-names timestamp
  if [ -z "$timestamp" ]
    gdate -u +'%Y-%m-%d %H:%M:%S.%3N'
  else
    gdate -u -d "$timestamp" +"%Y-%m-%d %H:%M:%S.%3N"
  end
end

## Returns a relative time from a given Unix time value.
function _relative_timestamp --argument-names timestamp
  set now (date +%s)
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
  else
    set unit "month"
    set value (math "$diff / 2592000")
  end

  set value (math "round $value")
  if [ $value -ne 1 ]
    set unit "$unit""s"
  end
  
  echo "$value $unit $dir"
end

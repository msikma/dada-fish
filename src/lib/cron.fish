# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Functions for running cron scripts.

## Default time we wait to run scripts, if not specified in the script itself.
set _cron_default_time 3600

## Finds all cron scripts in the ~/.cron directory.
function _find_cron_scripts
  mkdir -p "$DADA_CRON"
  find "$DADA_CRON" -type f -iname "*.sh"
end

## Runs all cron scripts in the ~/.cron directory.
function _run_cron_scripts
  set -l scripts (_find_cron_scripts)
  for script in $scripts
    set base (basename "$script")
    set script_last_run (_get_cron_time "$base")
    set script_interval (_get_cron_variable "$script" "interval" "$_cron_default_time")
    if _should_run_cron_script "$script_last_run" "$script_interval"
      echo "["(date +"%Y-%m-%d %H:%M:%S %Z")"] dada-fish: running cron script: $script (last run: $script_last_run; interval: $script_interval)"
      source $script
      _set_cron_time_now "$base"
    end
  end
end

## Checks whether a script should be run right now.
function _should_run_cron_script --argument-names last_run interval
  if [ $last_run = "-" ]
    return 0
  end
  if [ $interval -eq 0 ]
    return 0
  else
    set -l now (date +%s)
    set -l diff (math "$now - $last_run")
    if [ $diff -ge $interval ]
      return 0
    else
      return 1
    end
  end
end

## Each cron script has a phrase such as "_cron_interval 1800" in it;
## or other variables, like "_cron_description".
## Find this value and return the value.
function _get_cron_variable --argument-names script arg_name default_value
  if not set -q arg_name
    echo "$default_value"
    return
  end
  set -l value (grep -o "_cron_$arg_name [\"'A-Za-z0-9 ]*" $script | cut -d' ' -f2-)
  if test -z "$value"
    echo "$default_value"
  else
    echo "$value"
  end
end

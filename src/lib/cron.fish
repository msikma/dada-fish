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
    set script_interval (_get_cron_interval "$script")
    if _should_run_scron_script "$script_last_run" "$script_interval"
      echo "dada-fish: running cron script: $script"
      source $script
      _set_cron_time_now "$base"
    end
  end
end

## Checks whether a script should be run right now.
function _should_run_scron_script --argument-names last_run interval
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

## Each cron script has a phrase such as "_cron_interval 1800" in it.
## Find this phrase and return the interval in seconds.
function _get_cron_interval --argument-names script
  set -l interval (grep -o "_cron_interval [0-9]*" $script | cut -d' ' -f2)
  if [ -z "$interval" ]
    echo $_cron_default_time
  else
    echo $interval
  end
end

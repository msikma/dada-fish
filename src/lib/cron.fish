# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Functions for running cron scripts.

## Finds all cron scripts in the ~/.cron directory.
function _find_cron_scripts
  mkdir -p "$DADA_CRON"
  find "$DADA_CRON" -type f -iname "*.sh"
end

## Runs all cron scripts in the ~/.cron directory.
function _run_cron_scripts
  set -l scripts (_find_cron_scripts)
  for script in $scripts
    echo "dada-fish: running cron script: $script"
    source $script
  end
end

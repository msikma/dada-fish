# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Initializes the main system.
function _dada_base_init
  _setup_env
  _setup_plugins
  _setup_hooks
  _setup_commands
  _setup_backup_scripts
  _setup_backup_plugins
  _setup_db_inits
  _setup_vars
  _setup_bins
  _setup_aliases
end

## Initializes the system for regular use by the user.
function _dada_interactive_init
  _dada_base_init
  _set_prompt_vars
end

## Initializes only the things needed for a daemon run.
function _dada_daemon_init
  ! _require_cmd "gdate"; and return 1
  _dada_base_init
  _ensure_cache_vars
  _ensure_db
  _ensure_bin_cache
  _run_cron_scripts
end

## Runs a dependency check.
function _dada_deps_init
  _dada_base_init
  _check_deps
end

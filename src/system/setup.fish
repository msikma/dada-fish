# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Sources the env files
function _setup_env
  source "$DADA_FISH/env/common.fish"
  # todo: add other systems.
end

## Sources all env plugins.
function _setup_plugins
  set env_plugins (_get_env_plugins)
  for plugin in $env_plugins
    source $plugin
  end
end

## Sources all hooks.
function _setup_hooks
  set hooks (_get_hooks)
  for hook in $hooks
    source $hook
  end
end

## Sources all commands.
function _setup_commands
  set commands (_get_commands)
  for cmd in $commands
    source $cmd
  end
end

## Sources all backup scripts.
function _setup_backup_scripts
  set scripts (_get_backup_scripts)
  for scr in $scripts
    source $scr
  end
end

## Sources all backup plugins.
function _setup_backup_plugins
  set backup_plugins (_get_backup_plugins)
  for plugin in $backup_plugins
    source $plugin
  end
end

## Sources all commands.
function _setup_db_inits
  set inits (_get_db_inits)
  for init in $inits
    source $init
  end
end

## Sources all commands.
function _setup_vars
  set vars (_get_vars)
  for var in $vars
    source $var
  end
end

## Sources all init commands for bin files.
function _setup_bins
  _source_init_cache "bin"
end

## Assigns all aliases.
function _setup_aliases
  set aliases_visible $_DADA_FUNCTIONS
  set aliases_hidden $_DADA_FUNCTIONS_HIDDEN
  set bins $_DADA_BINS
  set aliases $aliases_visible $aliases_hidden $bins
  
  for n in (seq 1 5 (count $aliases))
    set name $aliases[(math "$n" + 1)]
    set cmd $aliases[(math "$n" + 3)]

    # Since aliases and regular functions are in the same array, some will have an empty
    # cmd value. These are regular functions, not aliases, so we're skipping them here.
    if [ "$cmd" = "-" ]
      continue
    end

    alias "$name" "$cmd"
  end
end

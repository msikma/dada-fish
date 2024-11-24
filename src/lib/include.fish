# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns all env plugins as a list of .fish files we can source.
function _get_env_plugins
  ls "$DADA_FISH/env/plugins/"*".fish"
end

## Returns all function plugins as a list of .fish files we can source.
function _get_hooks
  ls "$DADA_FISH/functions/hooks/"*".fish"
end

## Returns all commands as a list of .fish files we can source.
function _get_commands
  ls "$DADA_FISH/functions/commands/"*".fish"
end

## Returns all database initializers as a list of .fish files we can source.
function _get_db_inits
  ls "$DADA_FISH/functions/db/"*".fish"
end

## Returns all cacheable var definitions as a list of .fish files we can source.
function _get_vars
  ls "$DADA_FISH/functions/vars/"*".fish"
end

## Returns all bin files that we can register.
function _get_bins
  ls "$DADA_FISH/functions/bin/"*".fish"
end

## Returns all backup scripts that we can register.
function _get_backup_scripts
  ls "$DADA_FISH/backup/"*".fish"
  ls "$DADA_FISH/backup/external/"*".fish"
end

## Returns all backup script plugins.
function _get_backup_plugins
  ls "$DADA_FISH/backup/plugins/"*".fish"
end

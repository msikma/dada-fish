# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set -g _DADA_FUNCTIONS
set -g _DADA_FUNCTIONS_HIDDEN
set -g _DADA_FUNCTION_TYPES
set -g _DADA_BINS
set -g _DADA_DB_INITS
set -g _DADA_CACHE_VARS
set -g _DADA_DEPS
set -g _DADA_BACKUP_SCRIPTS
set -g _DADA_BACKUP_TYPES
set -g _DADA_BACKUP_DIRS_OPTIONAL

## Checks whether a description is within the limit of what can be displayed.
function _check_description_size --argument-names type name description size
  set desc_length (string length "$description")
  if [ "$size" = "small" ]
    set width "$DADA_RIGHT_COL_SIZE"
  else
    set width "$DADA_RIGHT_COL_SIZE_LARGE"
  end
  if [ "$desc_length" -gt "$width" ]
    _log_error "$type \"$name\" has a description that is too long ($desc_length chars, must be <= $width)"
  end
end

## Registers an alias, allowing it to be displayed in the help list.
function _register_alias --argument-names type name arg cmd description
  _check_description_size "Alias" "$name" "$description" "small"
  set -a _DADA_FUNCTIONS "$type" "$name" "$arg" "$cmd" "$description"
end

## Registers an alias, but keeps it hidden from the help list.
function _register_hidden_alias --argument-names type name arg cmd description
  _check_description_size "Alias" "$name" "$description" "small"
  set -a _DADA_FUNCTIONS_HIDDEN "$type" "$name" "$arg" "$cmd" "$description"
end

## Registers a function type, which is used to group together functions in the help list.
function _register_function_type --argument-names name color
  set -a _DADA_FUNCTION_TYPES "$name" "$color"
end

## Registers a function type, which is used to group together functions in the help list.
function _register_db_init --argument-names name
  set -a _DADA_DB_INITS "$name"
end

## Registers a function type, which is used to group together functions in the help list.
function _register_cache_vars --argument-names name func max_age_mins only_desktop
  if [ -z "$only_desktop" ]
    set only_desktop "0"
  end
  set -a _DADA_CACHE_VARS "$name" "$func" "$max_age_mins" "$only_desktop"
end

## Registers a command.
function _register_command --argument-names type name arg
  if [ -z "$arg" ]
    set arg "-"
  end
  if not functions -q "$name"
    _log_error "Could not register command \"$name\": function does not exist"
    return
  end
  # Since this is a command, we can get its description dynamically.
  set description (_get_function_description "$name")
  _check_description_size "Command" "$name" "$description" "small"
  set -a _DADA_FUNCTIONS "$type" "$name" "$arg" "-" "$description"
end

## Registers a backup script.
function _register_backup_script --argument-names type name
  if not functions -q "$name"
    _log_error "Could not register backup script \"$name\": function does not exist"
    return
  end
  set description (_get_function_description "$name")
  _check_description_size "Backup script" "$name" "$description" "small"
  set -a _DADA_BACKUP_SCRIPTS "$type" "$name" "$description"
end

## Registers a backup type, which is used to group together functions in the backup scripts list.
function _register_backup_type --argument-names name label color
  set -a _DADA_BACKUP_TYPES "$name" "$label" "$color"
end

## Registers a binary.
function _register_bin --argument-names type name arg cmd description in_help
  if [ -z "$arg" ]
    set arg "-"
  end
  if [ "$in_help" = "1" ]
    set size "small"
  else
    set size "large"
  end
  
  _check_description_size "Binary" "$name" "$description" "$size"

  # Depending on whether we want this to show up in "help" or in "scripts",
  # we either add it to the regular functions list or to the bins list.
  # Both are aliased in _setup_aliases.
  if [ "$in_help" = "1" ]
    # Note: $cmd is not passed on here so that it doesn't show up in the "aliases" command.
    set -a _DADA_FUNCTIONS "$type" "$name" "$arg" "-" "$description"
  else
    set -a _DADA_BINS "$type" "$name" "$arg" "$cmd" "$description"
  end
end

## Registers a dependency.
function _register_dependency --argument-names type pkgname cmd
  set -a _DADA_DEPS "$type" "$pkgname" "$cmd"
end

## Registers an optional backup directory.
function _register_backup_dir --argument-names type name dir
  set -a _DADA_BACKUP_DIRS_OPTIONAL "$type" "$name" "$dir"
end

## Registers a mandatory backup directory.
function _register_required_backup_dir --argument-names type name dir
  set -a _DADA_BACKUP_DIRS "$type" "$name" "$dir"
end

## Returns all backup dirs for a given type.
function _get_backup_dirs_for_type --argument-names type
  set types $_DADA_BACKUP_DIRS_OPTIONAL
  for n in (seq 1 3 (count $types))
    set backup_type $types[$n]
    if [ "$backup_type" != "$type" ]
      continue
    end
    set name $types[(math "$n" + 1)]
    set dir $types[(math "$n" + 2)]
    echo "$backup_type"
    echo "$name"
    echo "$dir"
  end
end

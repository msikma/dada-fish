# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns when a given backup type has last run as Unix timestamp.
function _get_backup_time --argument-names name
  _query \
    ".param init" \
    ".param set :name "(_sql_escape "$name") \
    "select coalesce((select last_run from backup_log where name = :name), '-');"
end

## Sets the last run value of a given backup type using a Unix timestamp.
function _set_backup_time --argument-names name last_run
  _query \
    ".param init" \
    ".param set :name "(_sql_escape "$name") \
    ".param set :last_run "(_sql_escape "$last_run") \
    "insert or replace into backup_log (name, last_run) values (:name, :last_run);
  "
end

## Sets the last run value of a given backup type to now.
function _set_backup_time_now --argument-names name
  _set_backup_time "$name" (date +%s)
end

## Ensures that the backup table exists.
function _ensure_backup_table
  _query "
    create table if not exists backup_log (
      name text unique,
      last_run text
    );
  "
end

_register_db_init "_ensure_backup_table"

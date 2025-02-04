# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns when a given cron script has last run as Unix timestamp.
function _get_cron_time --argument-names name
  _query \
    ".param init" \
    ".param set :name "(_sql_escape "$name") \
    "select coalesce((select last_run from cron_log where name = :name), '-');"
end

## Sets the last run value of a given cron script using a Unix timestamp.
function _set_cron_time --argument-names name last_run
  _query \
    ".param init" \
    ".param set :name "(_sql_escape "$name") \
    ".param set :last_run "(_sql_escape "$last_run") \
    "insert or replace into cron_log (name, last_run) values (:name, :last_run);
  "
end

## Sets the last run value of a given cron script to now.
function _set_cron_time_now --argument-names name
  _set_cron_time "$name" (date +%s)
end

## Ensures that the cron table exists.
function _ensure_cron_table
  _query "
    create table if not exists cron_log (
      name text unique primary key,
      last_run text
    );
  "
end

_register_db_init "_ensure_cron_table"

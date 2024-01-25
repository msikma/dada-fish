# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns when a given backup type has last run.
function _log_query
  begin
    set -l IFS
    set value (string join \n -- $argv)
  end
  sqlite3 "$DADA_DB" \
    ".param init" \
    ".param set :query "(_sql_escape "$value") \
    ".param set :timestamp "(_sql_escape (_timestamp_iso8601)) \
    "insert into query_log (query, timestamp) values (:query, :timestamp);"
end

## Sets the last run value of a given backup type.
function _get_last_queries
  _query_unlogged "
    select * from (
      select id, query, timestamp
      from query_log
      where timestamp >= datetime('now', '-1 day')
      order by timestamp desc
      limit 30
    )
    order by timestamp asc;
  " -box
end

## Ensures that the query log table exists.
function _ensure_log_table
  _query "
    create table if not exists query_log (
      id integer primary key,
      query text,
      timestamp text
    );
  "
end

_register_db_init "_ensure_log_table"

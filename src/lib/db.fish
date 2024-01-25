# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Runs a query on our database.
function _query
  sqlite3 "$DADA_DB" $argv
  _log_query $argv
end

## Runs a query on our database without logging it
function _query_unlogged
  sqlite3 "$DADA_DB" $argv
end

## Escapes a string for use in a SQL query
## This wraps the string in double quotes.
function _sql_escape
  # Note: this uses Fish's escape mechanism, followed by replacing "\ " to " ".
  begin
   set -l IFS
   set escaped (string escape -n $argv | gsed 's/\\\\ / /g')
  end
  
  echo "\"$escaped\""
end

## Returns 1 if a given table exists, 0 otherwise.
function _table_exists --argument-names table
  set res (_query \
    ".param init" \
    ".param set :name "(_sql_escape "$table") \
    "select tbl_name from sqlite_master where type=\"table\" and name=:name;"
  )
  if [ "$res" = "$table" ]
    echo 1
  else
    echo 0
  end
end

## Ensures that all relevant parts of the database are created.
function _ensure_db
  if [ ! -e "$DADA_DB" ]
    _setup_db
  end
end

## Sets up the database. Only should be run if needed.
function _setup_db
  set inits $_DADA_DB_INITS
  for n in (seq 1 (count $inits))
    set fn $inits[$n]
    $fn
  end
end

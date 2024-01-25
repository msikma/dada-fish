# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function recache --description "Refreshes the cache"
  _ensure_cache_vars
  _ensure_db
  _ensure_bin_cache
end

_register_command system "recache"

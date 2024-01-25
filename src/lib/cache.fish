# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Sources a cache file.
function _source_init_cache --argument-names name
  set initfile "$DADA_CACHE/init_$name.fish"
  if [ -e "$initfile" ]
    source "$initfile"
  end
end

## Whether a cache file needs to be updated.
function _cache_vars_needs_update --argument-names filepath max_age_mins
  if [ ! -e "$filepath" ]
    echo 1
    return
  else
    if test (find "$filepath" -mmin +"$max_age_mins")
      echo 1
      return
    end
  end
  echo 0
end

## Retrieves all bin activation codes and stores them in a cache file.
function _ensure_bin_cache
  mkdir -p "$DADA_CACHE"

  set name "bin"
  set filepath "$DADA_CACHE/init_$name.fish"
  set tmp_filepath (mktemp)
  printf "# %s\n" (gdate -u) >> "$tmp_filepath"

  set bins (_get_bins)
  for bin in $bins
    for line in (cat "$bin" | string match -rg "^#_dada_fish.(.*)")
      echo "$line" >> "$tmp_filepath"
    end
  end

  rm -f "$filepath"
  mv "$tmp_filepath" "$filepath"
  rm -f "$tmp_filepath"
end

## Ensures that all cache vars files are up to date.
function _ensure_cache_vars
  mkdir -p "$DADA_CACHE"

  set cache_vars $_DADA_CACHE_VARS

  for n in (seq 1 4 (count $cache_vars))
    set name $cache_vars[$n]
    set func $cache_vars[(math "$n + 1")]
    set max_age_mins $cache_vars[(math "$n + 2")]
    set only_desktop $cache_vars[(math "$n + 3")]

    set filepath "$DADA_CACHE/vars_$name.fish"
    set update (_cache_vars_needs_update "$filepath" "$max_age_mins")

    # Ensure the file always exists, so source commands never fail.
    if [ ! -e "$filepath" ]
      touch "$filepath"
    end

    # Some cache items only need to happen on desktop (e.g. the weather report).
    if [ "$only_desktop" -eq 1 -a "$DADA_FISH_ENV" != "desktop" ]
      return
    end

    if [ "$update" -eq 1 ]
      # Create a temporary file, let the cache function write to it, then replace the target file.
      set tmp_filepath (mktemp)
      printf "# %s\n" (gdate -u) >> "$tmp_filepath"
      "$func" "$tmp_filepath"
      rm -f "$filepath"
      mv "$tmp_filepath" "$filepath"
      rm -f "$tmp_filepath"
    end
  end
end

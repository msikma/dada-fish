# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function npmv --description "Lists current package versions" --argument-names pkg_path
  ! _require_cmd "npm" "npmv: error: npm is not installed"; and return 1
  ! _require_cmd "gdate"; and return 1
  ! _require_cmd "jq"; and return 1

  if [ -z "$pkg_path" ]
    set pkg_path "."
  end

  if [ -e "$pkg_path/package.json" ]
    set pkg_name (jq -r ".name" < "$pkg_path/package.json")
    set pkg_description (jq -r ".description" < "$pkg_path/package.json")
    set pkg_version (jq -r ".version" < "$pkg_path/package.json")
  end

  if [ -z "$pkg_name" -o "$pkg_name" = "null" ]
    echo "npmv: error: could not find package name"
    return 1
  end

  # Retrieve publication time and version information for the package.
  set time_info (npm view "$pkg_name" time --json 2> /dev/null)
  if [ $status -ne 0 ]
    echo "npmv: error: package does not exist"
    return 1
  end
  set version_info (npm view "$pkg_name" versions --json 2> /dev/null)
  set latest_version (npm view "$pkg_name" version)

  set created_xt (echo "$time_info" | jq -r ".created" | xargs -I {} gdate -d {} +%s)
  set created_ts (_timestamp_tz "@$created_xt")
  set created_tsr (_relative_timestamp "@$created_xt")

  set old_c1 (set_color black)
  set old_c2 (set_color brblack)
  set old_c3 (set_color black)
  set new_c1 (set_color yellow)
  set new_c2 (set_color reset)
  set new_c3 (set_color cyan)
  
  echo ""
  echo (set_color red)"$pkg_name "(set_color magenta)"($pkg_version, Node)"(set_color reset)
  echo (set_color green)"$pkg_description"(set_color reset)
  echo (set_color yellow)"Latest version: $latest_version; created: $created_ts ($created_tsr)"(set_color reset)
  echo ""
  for item_version in (echo "$version_info" | jq -r ".[]")
    set version_xt (echo "$time_info" | jq -r '.["'"$item_version"'"]' | xargs -I {} gdate -d {} +%s)
    set version_ts (_timestamp_tz "@$version_xt")
    set version_tsr (_relative_timestamp "@$version_xt")

    if [ "$item_version" = "$latest_version" ]
      set c1 "$new_c1"
      set c2 "$new_c2"
      set c3 "$new_c3"
    else
      set c1 "$old_c1"
      set c2 "$old_c2"
      set c3 "$old_c3"
    end

    echo • $c1"$pkg_name "(set_color reset)$c2"$item_version "$c3"$version_ts ($version_tsr)"(set_color reset)
  end
  echo ""
end

_register_command pkg "npmv"
_register_dependency "brew" "node" "npm"
_register_dependency "brew" "jq" "jq"
_register_dependency "brew" "coreutils" "gdate"

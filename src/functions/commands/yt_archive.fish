# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _yt_archive_usage
  echo "usage: yt_archive [-h|--help] [-na] [-nc] URL…"
  echo ""
  echo "Arguments:"
  echo "  --help, -h    prints usage information"
  echo "  -na           no download archive check (redownload)"
  echo "  -nc           no browser cookies"
end

function yt_archive --description "Archives videos from various sites"
  ! _require_cmd "yt-dlp"; and return 1
  ! _require_cmd "ffmpeg"; and return 1
  ! _require_cmd "jq"; and return 1
  ! _require_cmd "perl"; and return 1

  if test (count $argv) -eq 0
    _yt_archive_usage
    return 1
  end
  if contains -- "-h" $argv || contains -- "--help" $argv
    _yt_archive_usage
    return 0
  end

  # Disables the download archive in case we want to redownload something.
  set arg_dl_archive "--download-archive" "$DADA_CACHE/yt_archive.txt"
  if contains -- "-na" $argv
    set arg_dl_archive
  end
  # Disables browser cookies.
  set arg_cookies "--cookies-from-browser" "firefox"
  if contains -- "-nc" $argv
    set arg_cookies
  end

  # Run yt-dlp on all given urls.

  for arg in $argv
    if string match -q -- "-*" "$arg"
      continue
    end
    
    set temp (mktemp -d)
    ! _require_temp_dir "$temp"; and return 1

    set orig_dir (pwd)

    pushd "$temp"

    echo "[yt_archive] Timestamp: "(date +"%Y-%m-%d %H:%M:%S %Z") > "_log.txt"
    yt-dlp --ignore-errors --add-metadata --write-description --write-info-json \
      --write-annotations --write-subs --write-thumbnail --embed-thumbnail --all-subs \
      --embed-subs --sub-langs all --get-comments --color always \
      --parse-metadata "%(title)s:%(meta_title)s" \
      --parse-metadata "%(uploader)s:%(meta_artist)s" \
      $arg_dl_archive \
      $arg_cookies \
      "$arg" 2>&1 | tee -a "_log.txt"

    # Strip colors and convert carriage returns for the logfile.
    perl -pe 's/\e\[[0-9;]*[mGKH]//g' "_log.txt" | tr '\r' '\n' > "log.txt"
    rm "_log.txt"
  
    if grep -q "has already been recorded in the archive" "log.txt"
      popd
      if [ -d "$temp" ]
        rm -rf "$temp"
      end
      continue
    end
    if test $status -ne 0
      echo "yt_archive: error: yt-dlp command failed with status code $status" 1>&2
      echo "temp directory is preserved: $temp"
      popd
      continue
    else
      # Reformat the json files.
      for n in (find . -type f -maxdepth 1 -mindepth 1 -iname "*.json")
        set json (basename "$n")
        mv "$json" "_$json"
        cat "_$json" | jq > "$json"
        rm "_$json"
      end

      # Create a filename for the target directory.
      set info_json (find . -type f -maxdepth 1 -mindepth 1 -iname "*.info.json" | head -n 1)
      if [ -z "$info_json" -o ! -e "$info_json" ]
        echo "yt_archive: error: yt-dlp did not produce an .info.json file" 1>&2
        echo "temp directory is preserved: $temp"
        popd
        continue
      end
      set yt_dirname (_ytdlp_get_name "$info_json")

      # Move all files into the target directory.
      mkdir "$yt_dirname"
      find . -type f -maxdepth 1 -mindepth 1 -exec mv {} "$yt_dirname" \;
      mv "$yt_dirname" "$orig_dir"
      popd
      if [ -d "$temp" ]
        rm -rf "$temp"
      end
    end
  end
end

_register_command archiving "yt_archive" "url…"
_register_dependency "brew" "yt-dlp" "yt-dlp"
_register_dependency "brew" "ffmpeg" "ffmpeg"
_register_dependency "brew" "jq" "jq"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set -g YT_ARCHIVE_VERSION "1.0.1"

function _yt_archive_usage
  echo "usage: yt_archive [-h|--help] [-a] [-na] [-nc] URL…"
  echo ""
  echo "Arguments:"
  echo "  --help, -h    prints usage information"
  echo "  -a            downloads audio streams only"
  echo "  -na           no download archive check (redownload)"
  echo "  -nc           no browser cookies"
end

function yt_archive --description "Archives videos from various sites"
  ! _require_cmd "yt-dlp"; and return 1
  ! _require_cmd "ffmpeg"; and return 1
  ! _require_cmd "jq"; and return 1
  ! _require_cmd "perl"; and return 1

  set has_errored "0"

  if test (count $argv) -eq 0
    _yt_archive_usage
    return 1
  end
  if contains -- "-h" $argv || contains -- "--help" $argv
    _yt_archive_usage
    return 0
  end

  # Disables the download archive in case we want to redownload something.
  set yt_archive_file "$DADA_CACHE/yt_archive.txt"
  set arg_dl_archive "--download-archive" "$yt_archive_file"
  if contains -- "-na" $argv
    set arg_dl_archive
  end
  # Disables browser cookies.
  set arg_cookies "--cookies-from-browser" "firefox"
  if contains -- "-nc" $argv
    set arg_cookies
  end
  # Download files either as video or as audio.
  set arg_format "--format" "bestvideo*+bestaudio/best"
  set arg_convert_thumbnail
  if contains -- "-a" $argv
    set arg_format "--format" "bestaudio"
    # Also, convert the thumbnail to jpg, which is more compatible.
    set arg_convert_thumbnail "--convert-thumbnail" "jpg"
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

    echo "[yt_archive v$YT_ARCHIVE_VERSION] Start: "(date +"%Y-%m-%d %H:%M:%S %Z") > "_log.txt"
    yt-dlp -v --ignore-errors --add-metadata --write-description --write-info-json \
      --write-annotations --write-subs --write-thumbnail --embed-thumbnail --all-subs \
      --embed-subs --sub-langs all --get-comments --no-playlist --color always \
      $arg_dl_archive \
      $arg_cookies \
      $arg_format \
      $arg_convert_thumbnail \
      "$arg" 2>&1 | tee -a "_log.txt"

    # Strip colors and convert carriage returns for the logfile.
    perl -pe 's/\e\[[0-9;]*[mGKH]//g' "_log.txt" | \
      tr '\r' '\n' | \
      string replace -a "$yt_archive_file" "<\$download_archive>" | \
      string replace -a ~ "<\$homedir>" > "log.txt"
    rm "_log.txt"
  
    if grep -q "has already been recorded in the archive" "log.txt"
      echo "yt_archive: info: This video has already been downloaded."
      echo "If you want to download it again, run the following:"
      echo (set_color blue)"yt_archive"(set_color cyan)" -na "(set_color yellow)"\"$arg\""(set_color normal)
      popd
      if [ -d "$temp" ]
        rm -rf "$temp"
      end
      continue
    end
    if test $status -ne 0
      echo "yt_archive: error: yt-dlp command failed with status code $status" 1>&2
      echo "temp directory is preserved: $temp"
      set has_errored "1"
      popd
      continue
    else
      # Reformat the json files.
      for file in (find . -type f -maxdepth 1 -mindepth 1 -iname "*.json")
        set json (basename "$file")
        set json_temp (mktemp)
        if jq . "$file" > "$json_temp" 2>/dev/null
          mv "$json_temp" "$json"
        else
          rm "$json_temp"
        end
      end

      # Create a filename for the target directory.
      set info_json (_ytdlp_find_info_json ".")
      if [ -z "$info_json" -o ! -e "$info_json" ]
        echo "yt_archive: error: yt-dlp did not produce an .info.json file" 1>&2
        echo "temp directory is preserved: $temp"
        set has_errored "1"
        popd
        continue
      end
      set yt_dirname (_ytdlp_get_name "$info_json")

      # Create a .webloc file with the original url. Borrow the info_json filename for it.
      set info_basename (basename "$info_json" .info.json)
      _write_webloc "$arg" "$info_basename"

      # Rename .description to .description.txt, purely for ease of use.
      for file in (find . -type f -maxdepth 1 -mindepth 1 -iname "*.description")
        mv "$file" "$file.txt"
      end

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

  if test "$has_errored" -eq "1"
    return 1
  end
end

_register_command archiving "yt_archive" "url…"
_register_dependency "brew" "yt-dlp" "yt-dlp"
_register_dependency "brew" "ffmpeg" "ffmpeg"
_register_dependency "brew" "jq" "jq"

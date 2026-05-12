#!/usr/bin/env fish

set USAGE 'usage: fix_music_dir URL'

function check_dependencies
  for cmd in 'yt-dlp' 'jq'
    if not command -v $cmd > /dev/null
      echo "fix_music_dir: error: required command is missing: $cmd"
      exit 1
    end
  end
end

function sanitize_filename
  string replace -a -r '[/:*?"<>|]' '_' $argv[1]
end

function find_webloc_url
  set webloc (find . -type f -mindepth 1 -maxdepth 1 -iname "*.webloc" | head -n 1)
  set url (plutil -convert json TeeLopes.webloc -o - | jq -r ".URL")
  echo "$url" | sed 's/\/videos/\/playlists/'
end

function fix_music_dir --argument-names user_url
  if test -z "$user_url"
    set suggested_url (find_webloc_url)
    echo "fix_music_dir: error: no URL entered (consider: $suggested_url)"
    return 1
  end

  set -g playlist_json (yt-dlp --flat-playlist -J "$user_url")
  set uploader (echo "$playlist_json" | jq -r ".uploader")
  set entries_n (echo "$playlist_json" | jq -r ".entries | length")

  set -g seen_ids

  # Populate seen_ids with ids of music files that have already been moved.
  set moved_files (find . -type f -mindepth 2 -iname "*\[*\]*")
  for moved_file in $moved_files
    set video_id (echo "$moved_file" | awk 'match($0, /\[[_\-A-Za-z0-9]{11}]/) {print substr($0, RSTART + 1, RLENGTH - 2)}')
    set -a seen_ids "$video_id"
  end

  for n in (seq 0 (math "$entries_n" - 1))
    set entry (echo "$playlist_json" | jq ".entries[$n]")
    
    set playlist_url (echo "$entry" | jq -r ".url")
    set playlist_id (echo "$entry" | jq -r ".id")
    set playlist_title (echo "$entry" | jq -r ".title")
    set album_dir_name (sanitize_filename "$uploader - $playlist_title [$playlist_id]")
    
    if test -d "$album_dir_name"
      echo "fix_music_dir: playlist already made: "(set_color magenta)"$album_dir_name"(set_color normal)" - skipping"
      continue
    end
    
    # Note: don't include unavailable videos in the output, since they are guaranteed to not be here.
    set video_ids (yt-dlp --flat-playlist --print "%(id)s" --compat-options "no-youtube-unavailable-videos" $playlist_url)

    set all_files_present 1
    set missing_ids
    set files_to_move

    for video_id in $video_ids
      set matching_files (find . -mindepth 1 -maxdepth 1 -type f -name "*\[$video_id\]*")
      for matching_file in $matching_files
        set -a files_to_move "$matching_file"
        set -a seen_ids "$video_id"
      end
      if test -z "$matching_files"
        set moved_file (find . -mindepth 2 -type f -name "*\[$video_id\]*" | head -n 1)
        if contains -- "$video_id" $seen_ids
          echo (set_color green)"Warning:"(set_color normal)" video ID is in a different playlist already:"
          echo "  Existing:  "(set_color red)"$moved_file"(set_color normal)
          echo "  Requested: "(set_color red)"$album_dir_name"(set_color normal)
        else
          set all_files_present 0
          set -a missing_ids "$video_id"
        end
      end
    end
    
    if test "$all_files_present" -eq 0
      echo "----"
      echo (set_color yellow)"Warning:"(set_color normal)" not all files are present for the following playlist:"
      echo "  Title: "(set_color red)"$playlist_title"(set_color normal)
      echo "  URL:   "(set_color blue)"$playlist_url"(set_color normal)
      echo "  Missing IDs: "(set_color blue)"$missing_ids"(set_color normal)
      echo "The files have not been moved. You can fix this manually later."
      echo "----"
      continue
    end
    
    mkdir -p "$album_dir_name"
    for file in $files_to_move
      mv "$file" "$album_dir_name"
    end
  end
end

fix_music_dir "$argv[1]"

#_dada_fish _register_bin regular "fix_music_dir" "url" "fix_music_dir.fish" "Organizes music files per account playlists"
#_dada_fish _register_dependency "brew" "yt-dlp" "yt-dlp"
#_dada_fish _register_dependency "brew" "jq" "jq"

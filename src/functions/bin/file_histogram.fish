#!/usr/bin/env fish

function _get_files_by_interval --argument-names dir interval
  for fileinfo in (find "$dir" -type f -exec stat -f "%m %N" {} +)
    set unixtime (string split " " "$fileinfo" -f 1)
    set filepath (string split " " "$fileinfo" -f 2)
    set filedate (date -r "$unixtime" $interval)
    echo "$filedate"
  end
end

function _print_file --argument-names label fileinfo
  set unixtime (string split " " "$fileinfo" -f 1)
  set filepath (string split " " "$fileinfo" -f 2)
  set filedate (date -r "$unixtime" "+%Y-%m-%d %H:%M:%S")
  echo "$label: "(set_color yellow)"$filedate "(set_color green)"$filepath"(set_color normal)
end

function file_histogram --argument-names dir
  if [ -z "$dir" ]
    set dir "."
  end
  set oldest_file (find "$dir" -type f -exec stat -f "%m %N" {} + | sort -n | head -n 1)
  set newest_file (find "$dir" -type f -exec stat -f "%m %N" {} + | sort -nr | head -n 1)
  
  set files_per_month (_get_files_by_interval "$dir" "+%Y-%m" | sort | uniq -c)
  set files_per_year (_get_files_by_interval "$dir" "+%Y" | sort | uniq -c)
  
  echo "Path: "(set_color green)(pwd)/"$dir"(set_color normal)
  _print_file "Oldest" "$oldest_file"
  _print_file "Newest" "$newest_file"
  echo "Histogram by month:"
  for file in $files_per_month
    echo "$file"
  end
  echo "Histogram by year:"
  for file in $files_per_year
    echo "$file"
  end
end

file_histogram $argv[1]

#_dada_fish _register_bin regular "file_histogram" "path" "file_histogram.fish" "Prints file date histogram for a given path"

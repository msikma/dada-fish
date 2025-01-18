#!/usr/bin/env fish

set USAGE 'usage: recover_img IMG_FILE'

function continue_recovery --argument-names img_filepath base_dir
  pushd "$base_dir/recovery"
  photorec /d session
  popd
end

function start_recovery --argument-names img_filepath base_dir
  set filebase (basename "$img_filepath" ".img")

  mkdir -p "$base_dir/recovery"
  pushd "$base_dir/recovery"
  photorec /log /logname ./photorec.log /d files /cmd "$img_filepath" blocksize,512,fileopt,txt,disable,options,paranoid,keep_corrupted_file,freespace,search
  popd
end

function recover_img --argument-names img_file
  if [ -z "$img_file" -o ! -e "$img_file" ]
    echo "$USAGE"
    return 1
  end

  set img_filepath (pwd)"/$img_file"
  set base_dir (pwd)"/"(dirname "$img_file")

  if [ -d "$recovery" ]
    continue_recovery "$img_filepath" "$base_dir"
  else
    start_recovery "$img_filepath" "$base_dir"
  end
end

recover_img $argv

#_dada_fish _register_dependency "brew" "photorec" "testdrive"
#_dada_fish _register_bin regular "recover_img" "fn" "recover_img.fish" "Recovers lost files from .img file"

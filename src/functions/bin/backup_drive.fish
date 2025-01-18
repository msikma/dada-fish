#!/usr/bin/env fish

set USAGE 'usage: backup_drive DRIVE OUTPUT_NAME'

if test (count $argv) -ne 2
  echo "$USAGE"
  exit 1
end

set disk_number $argv[1]
set backup_name $argv[2]
set device "/dev/$disk_number"
if not test -e $device
  echo "backup_drive: error: device $device does not exist"
  exit 1
end

set backup_dir "./$backup_name""_backup"
mkdir -p $backup_dir

set img_path "$backup_dir/$backup_name.img"
set log_path "$backup_dir/$backup_name.log"

echo "Backing up $device to $backup_name..."
sudo ddrescue -f $device $img_path $log_path

if test $status -eq 0
  echo "Backup completed successfully."
  echo "Backup image: $img_path"
  echo "Log file: $log_path"
else
  echo "backup_drive: error: ddrescue encountered an issue: $log_path"
end

#_dada_fish _register_dependency "brew" "ddrescue" "ddrescue"
#_dada_fish _register_bin regular "backup_drive" "disk fn" "backup_drive.fish" "Backs up a drive using ddrescue"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Filesystem
##
## Functions for simplifying common filesystem tasks.

set _tab (echo -e "\t")

## Prints the size of a file in bytes
function _filesize_b --argument-names filepath
  stat -f%z "$filepath"
end

## Prints a human readable filesize
function _filesize --argument-names filepath
  du -sh "$filepath" | string trim | cut -f1 -d"$_tab"
end

## Returns number of lines in a file as an integer
function _file_lines --argument-names filepath
  wc -l < "$filepath" | tr -d '[:space:]'
end

## Prints the extension part of a filename (without leading dot)
function _file_ext --argument-names filepath
  # Note: for 'foo.bar.js', returns 'js'.
  echo "$filepath" | sed -E 's/.+\.([^.]+)$/\1/g'
end

## Prints the basename part of a filename (without trailing dot)
function _file_base --argument-names filepath
  # Note: for 'foo.bar.js', returns 'foo.bar'.
  echo "$filepath" | sed -E 's/\.[^.]+$//g'
end

## Prints the last modified Unix time for a given path
function _get_last_modified --argument-names filepath
  if not test -e "$filepath"
    echo "0"
    return
  end

  gstat -c %Y $filepath
end

## Prints the EFI device, e.g. disk0s1.
function _find_efi_device
  # Determine what the boot device is.
  set boot_dev (diskutil info / | awk -F: '/Device Identifier/ {gsub(/ /,"",$2); print $2}')

  if test -z "$boot_dev"
    echo "_find_efi_device: could not determine boot device" >&2
    return 1
  end

  # Follow APFS physical stores.
  while true
    set phys (diskutil info "$boot_dev" | awk -F: '/APFS Physical Store/ {gsub(/ /,"",$2); print $2}')
    if test -n "$phys"
      set boot_dev "$phys"
      continue
    end
    break
  end

  # Find the physical disk.
  set disk (diskutil info "$boot_dev" | awk -F: '/Part of Whole/ {gsub(/ /,"",$2); print $2}')
  if test -z "$disk"
    set disk (echo "$boot_dev" | sed -E 's/s[0-9]+$//')
  end

  if test -z "$disk"
    echo "_find_efi_device: could not determine physical disk for $boot_dev" >&2
    return 1
  end

  set efi (diskutil list "$disk" | awk '/EFI/ {print $NF; exit}')

  if test -z "$efi"
    echo "_find_efi_device: no EFI partition found on $disk" >&2
    return 1
  end

  echo $efi
end

## Returns disk usage in human readable format
function _get_disk_usage
  # Note: get all information in 1024kb blocks for easier arithmetic.
  set amount (df -k / | tail -n1)
  set total (echo $amount | awk '{print $2}')
  set avail (echo $amount | awk '{print $4}')
  set usage (math -s 1 "(" 1 - "$avail" / "$total" ")" "*" 100)"%"

  set avail_h (math --scale=1 "(($avail) * 1024) / 1000000000")
  set total_h (math --scale=1 "(($total) * 1024) / 1000000000")

  echo "$usage ($avail_h/$total_h GB available)"
end

## Checks that a temporary directory we made exists and is writable.
function _require_temp_dir --argument-names dirpath
  if [ ! -d $dirpath ]
    echo "error: can't access temp directory: "$dirpath
    return 1
  end

  return 0
end

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function mount_efi --description "Mounts EFI partition"
  set efi_disk (_find_efi_device)
  if test $status -ne 0
    echo "mount_efi: could not determine EFI device" >&2
    return 1
  end
  sudo diskutil mount "$efi_disk"
end

_register_command script "mount_efi"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function unmount_efi --description "Unmounts EFI partition"
  set efi_disk (_find_efi_device)
  if test $status -ne 0
    echo "unmount_efi: could not determine EFI device" >&2
    return 1
  end
  sudo diskutil unmount "$efi_disk"
end

_register_command script "unmount_efi"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Cache a number of system values that we want to print during login.
function _gen_sys_vars_cache --argument-names filepath
  set os_version (_get_os_version)
  set kernel_version (_get_kernel_version)
  set git_version (_git_version_formatted)
  set git_timestamp (_git_timestamp_formatted)
  set local_ip (_get_local_ip)
  set disk_usage (_get_disk_usage)
  set sys_hostname (_get_hostname)
  set user_hostname (whoami)"@$hostname"

  for var in "os_version" "kernel_version" "git_version" "git_timestamp" "local_ip" "disk_usage" "sys_hostname" "user_hostname"
    printf "set %s %s\n" "$var" (string escape "$$var") >> "$filepath"
  end
end

_register_cache_vars "sys" "_gen_sys_vars_cache" "1" "0"

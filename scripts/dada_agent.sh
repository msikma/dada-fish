#!/usr/bin/env fish

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Script for configuring the Dada Fish daemon. This ensures certain cache is
## always refreshed and ready to go in the interactive session.
## It also does backups.

set script_name "dada_agent.sh"

set daemon_name "com.dada.fish"
set daemon_plist ~/"Library/LaunchAgents/$daemon_name.plist"
set daemon_template (realpath (dirname (status --current-filename))"/../resources/$daemon_name.plist.template")

## Returns whether the current system is macOS
function is_macos
  set os_type (uname)
  test "$os_type" = "Darwin"
end

## Checks whether the daemon is installed
function is_daemon_installed
  set active (launchctl list | grep "$daemon_name")
  if [ (count $active) -eq 0 ]
    echo "$script_name: launch daemon is not installed"
    return 1
  else
    echo "$script_name: launch daemon is installed"
    return 0
  end
end

## Unloads and removes the daemon from the system
function _unload_daemon
  launchctl unload "$daemon_plist"
  rm -f "$daemon_plist"
end

## Loads the daemon (after replacing variables in the template) and copies it to the LaunchAgents directory
function _load_daemon
  set fish_bin (which fish)
  set cache_path ~/".cache"
  set config_path ~/".config"
  
  cat "$daemon_template" | sed -e "s@{{fish_bin}}@$fish_bin@g" -e "s@{{cache_path}}@$cache_path@g" -e "s@{{config_path}}@$config_path@g" > "$daemon_plist"
  launchctl load "$daemon_plist"
end

## Ensures that the launch daemon is installed
## If the daemon was already installed before, it will be unloaded and removed before reinstalling.
function install_daemon
  if [ -e "$daemon_plist" ]
    _unload_daemon
  end

  _load_daemon
  echo "$script_name: installed launch daemon: "(set_color yellow)"$daemon_plist"(set_color normal)
end

## Ensures that the launch daemon is removed
function uninstall_daemon
  if [ -e "$daemon_plist" ]
    _unload_daemon
  end
  echo "$script_name: removed launch daemon: "(set_color yellow)"$daemon_plist"(set_color normal)
end

## Prints out the program usage synopsis
function usage --argument-names exit_code
  echo "$script_name: usage: $script_name {install, uninstall, status}"
  exit "$exit_code"
end

## Checks command line arguments and runs the given command
function main
  if [ ! is_macos ]
    echo "$script_name: this script can only run on macOS"
    exit 1
  end
  switch "$argv[1]"
    case "install"
      install_daemon
    case "uninstall"
      uninstall_daemon
    case "status"
      is_daemon_installed
    case "-h"
      usage 0
    case "--help"
      usage 0
    case ""
      usage 1
    case '*'
      usage 1
  end
end

main $argv

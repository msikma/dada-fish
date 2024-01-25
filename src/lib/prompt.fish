# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Displays the greeting when a new terminal is opened.
function fish_greeting
  return
  # Retrieve cached values that we'll use to display the welcome message.
  source "$DADA_CACHE/vars_sys.fish"
  source "$DADA_CACHE/vars_weather.fish"

  # Print the weather.
  _print_weather "$current_weather" "70"

  # Display the gray uname section.
  set_color brblack
  echo $kernel_version
  echo (uptime)
  echo

  printf "%s %s\n" "🌿" (set_color green)"Dada Fish"(set_color 2b4e03)" on "(set_color green)"$os_version"(set_color normal)
  printf "%s %s\n" (set_color 2b4e03)"Type"(set_color green)" help "(set_color 2b4e03)"to see available commands"(set_color normal)
  echo
  
  # Display columns containing user and theme information.
  set main_cols \
    "User:"             "$sys_hostname ("$local_ip")" \
    "Disk usage:"       "$disk_usage" \

  set theme_cols \
    "Theme version:"    "$git_version" \
    "Last commit:"      "$git_timestamp" \

  # Retrieves dates for when we last backed up important data.
  set backup_cols \
    "MySQL backup:"     "unknown" \
    "Music backup:"     "unknown" \
    "Source backup:"    "unknown" \
    "Files backup:"     "unknown" \
  
  set all_cols
  set -a all_cols (_add_col_color "yellow" $main_cols)
  set -a all_cols (_add_col_color "blue" $theme_cols)

  if [ "$DADA_FISH_ENV" = "desktop" ]
    set -a all_cols (_add_col_color "magenta" $backup_cols)
    _draw_kv_columns 2 $all_cols
  end

  if [ "$DADA_FISH_ENV" = "server" ]
    # On Ubuntu we have access to an additional sysinfo tool.
    if type -q landscape-sysinfo
      landscape-sysinfo | read -d \n -z info
      set uptime_val (uptime | sed 's/^.*load/load/' | cut -d':' -f2 | string sub -s 2)
      set mem (echo $info | sed '3q;d' | string sub -s 26)
      set swap (echo $info | sed '4q;d' | string sub -s 26)
      set proc (echo $info | sed '5q;d' | string sub -s 26)
      
      set info_cols \
        "System load:"    "$uptime_val" \
        "Memory usage:"   "$mem" \
        "Swap usage:"     "$swap" \
        "Processes:"      "$proc"
      
      set -a all_cols (_add_col_color "red" $info_cols)
      _draw_kv_columns 2 $all_cols
    end
  end
  
  printf "\n"

  # Run the "welcome" script to finalize our environment.
  set welcome $DADA"env/welcome/$DADA_FISH_ENV.fish"
  if [ -e "$welcome" ]
    source "$welcome"
  end
end

## Writes out the left side prompt.
function fish_prompt
  if [ -n "$STY" ]
    set dada_screen_prompt (set_color yellow)"($STY) "(set_color normal)
  end
  if set -q VIRTUAL_ENV
    set venv (basename "$VIRTUAL_ENV")
    set dada_vf_prompt (set_color yellow)"◰ "(set_color red)"$venv"(set_color normal)" "
  end
  echo -n -s $_dada_left_prompt_prefix $dada_vf_prompt $dada_screen_prompt "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" (_in_vcs_repo) "$__fish_prompt_normal" '> '
end

## Writes out the right side prompt.
function fish_right_prompt
  set -l exit_code $status
  set -l datestr (date +"%a, %b %d %Y %X")
  if test $exit_code -ne 0
    echo -n "⚠️  [$status] "
  end

  set_color 222
  echo $datestr
  set_color normal
end

## Does a bunch of setup once. These variables remain the same for the lifetime of the TTY.
function _set_prompt_vars
  set -g __fish_git_prompt_showdirtystate 1
  set -g __fish_git_prompt_showstashstate 1
  set -g __fish_git_prompt_showuntrackedfiles 1
  set -g __fish_git_prompt_describe_style 'branch'
  set -g __fish_git_prompt_showcolorhints 1
  set -g __fish_git_prompt_show_informative_status 1

  set -g __fish_git_prompt_char_stateseparator ' '
  set -g __fish_git_prompt_char_dirtystate '+'
  set -g __fish_git_prompt_char_invalidstate '×'
  set -g __fish_git_prompt_char_untrackedfiles '…'
  set -g __fish_git_prompt_char_stagedstate '*'
  set -g __fish_git_prompt_char_cleanstate '✓'

  set -g __fish_git_prompt_color_prefix yellow
  set -g __fish_git_prompt_color_suffix yellow
  set -g __fish_git_prompt_color_branch yellow
  set -g __fish_git_prompt_color_cleanstate green

  set -g __fish_prompt_cwd (set_color cyan)
  set -g __fish_prompt_normal (set_color normal)

  # This disablse the virtualenv prompt prefix added by bin/activate.fish.
  set -g VIRTUAL_ENV_DISABLE_PROMPT "1"

  # Display the hostname in the prompt if we're running on a server.
  if [ "$DADA_IS_SERVER" = "1" ]
    set -gx _dada_left_prompt_prefix "$DADA_HOSTNAME "
  end
end

function _print_weather --argument-names wtr col
  # Don't do anything if the weather file is empty.
  # This happens if the server is down.
  if [ -z "$wtr" ]
    return
  end
  # It can also contain an HTML error, or an error if the service ran out of API calls.
  if string match -q -- "*nginx*" $wtr
    return
  end
  if string match -q -- "*default city*" $wtr
    return
  end

  # Display the weather at the right place.
  set wtr_lines (string split \n "$wtr")
  for n in (seq (count $wtr_lines))
    set -l m (math $n + 1)
    echo -ne "\033[$m;""$col""H"
    echo $wtr_lines[$n]
  end
  # Move the cursor back to the start position.
  echo -ne "\033[2;0H"
end

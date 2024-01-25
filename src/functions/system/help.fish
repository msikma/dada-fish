# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function help --description "Prints a list of commands"
  echo
  echo "The following commands are available:"
  echo
  _list_commands "2col" "commands" $_DADA_FUNCTIONS
  echo
end

function aliases --description "Lists all aliases in use"
  _list_commands "1col" "aliases" $_DADA_FUNCTIONS $_DADA_FUNCTIONS_HIDDEN
end

function scripts --description "Shows available scripts"
  echo
  echo "The following scripts are available:"
  echo
  _list_commands "1colwide" "aliases" $_DADA_BINS
  echo
end

function backup --description "Shows backup scripts"
  echo
  echo "Backup commands and status for "(set_color green)(_get_hostname)(set_color reset)":"
  _list_backup_scripts $_DADA_BACKUP_SCRIPTS
  echo
end

## Prints a list of backup scripts
function _list_backup_scripts
  set lines
  set reset (set_color reset)
  set scripts $argv[1..-1]
  set types $_DADA_BACKUP_TYPES
  
  for m in (seq 1 3 (count $types))
    set type $types[$m]
    set label $types[(math "$m" + 1)]
    set color $types[(math "$m" + 2)]
    
    set -a lines "%s %s %s" "" "" ""
    set -a lines (set_color black)"%-"(math $DADA_LEFT_COL_SIZE + $DADA_RIGHT_COL_SIZE - 1)"s""%s""$reset "(set_color black)"%-"$DADA_RIGHT_COL_SIZE"s""$reset" "$label" "" "Last run"

    for n in (seq 1 3 (count $scripts))
      set item_type $scripts[$n]
      if [ "$item_type" != "$type" ]
        continue
      end
      set name $scripts[(math "$n" + 1)]
      set description $scripts[(math "$n" + 2)]
      set last_run (_get_backup_time "$name")
      if [ "$last_run" != "-" ]
        set last_run (_relative_timestamp "$last_run")
      end

      set -a lines "$color""%s""$reset""%-"$DADA_RIGHT_COL_SIZE"s""$reset""%-"$DADA_RIGHT_COL_SIZE"s" (_backup_script_label_padded "$name" "$color" "$DADA_LEFT_COL_SIZE") "$description" "$last_run"
      #set -a lines "$color""%s""$reset""%-"$DADA_RIGHT_COL_SIZE_LARGE"s " (_command_label_padded "$name" "$arg" "$color" "$DADA_LEFT_COL_SIZE") "$description"
    end
  end

  for n in (seq 1 4 (math (count $lines)))
    set template $lines[$n]
    set name $lines[(math "$n + 1")]
    set description $lines[(math "$n + 2")]
    set last_run $lines[(math "$n + 3")]
    printf "$template\n" "$name" "$description" "$last_run"
  end
end

## Prints out the label for a backup script.
function _backup_script_label --argument-names name color
  echo -n "$color"
  echo -n "$name"
end

## Prints out the label for a help command, padded to the correct length.
function _backup_script_label_padded --argument-names name color size
  set label (_backup_script_label "$name" "$color")
  set width (string length -V "$label")
  set remainder (math "$size - $width")
  echo -n "$label"
  string repeat -Nn "$remainder" " "
end

## Prints a two column list of commands
## list_type must be "1col", "1colwide" or "2col". cmd_type must be "aliases" or "commands".
function _list_commands --argument-names list_type cmd_type
  set lines
  set reset (set_color reset)

  set commands $argv[3..-1]
  set types $_DADA_FUNCTION_TYPES

  if [ (count $commands) -eq 0 ]
    return
  end

  for m in (seq 1 2 (count $types))
    set type $types[$m]
    set color $types[(math "$m" + 1)]
    for n in (seq 1 5 (count $commands))
      set item_type $commands[$n]
      if [ "$item_type" != "$type" ]
        continue
      end

      set name $commands[(math "$n" + 1)]
      set arg $commands[(math "$n" + 2)]
      if [ $arg = "-" ]
        set arg ""
      end
      set cmd $commands[(math "$n" + 3)]
      if [ $cmd_type = "aliases" -a $cmd = "-" ]
        continue
      end
      set description $commands[(math "$n" + 4)]
      
      switch $list_type
      case "2col"
        set -a lines "$color""%s""$reset""%-"$DADA_RIGHT_COL_SIZE"s " (_command_label_padded "$name" "$arg" "$color" "$DADA_LEFT_COL_SIZE") "$description"
      case "1col"
        set -a lines "$color""%s""$reset""%-"$DADA_RIGHT_COL_SIZE"s " (_command_label_padded "$name" "$arg" "$color" "$DADA_LEFT_COL_SIZE") "$description"
      case "1colwide"
        set -a lines "$color""%s""$reset""%-"$DADA_RIGHT_COL_SIZE_LARGE"s " (_command_label_padded "$name" "$arg" "$color" "$DADA_LEFT_COL_SIZE_LARGE") "$description"
      end
    end
  end

  if [ $list_type = "1col" -o $list_type = "1colwide" ]
    for n in (seq 1 3 (math (count $lines)))
      set template $lines[$n]
      set name $lines[(math "$n + 1")]
      set description $lines[(math "$n + 2")]
      printf "$template\n" "$name" "$description"
    end
  end
  if [ $list_type = "2col" ]
    set line_items (math (count $lines) / 3)
    set column_lines (math 'ceil('$line_items / 2')')
    for n in (seq 0 (math "$column_lines - 1"))
      set left_idx (math "$n * 3 + 1")
      set right_idx (math "($n * 3) + ($column_lines * 3) + 1")
      for idx in $left_idx $right_idx
        set template $lines[$idx]
        set name $lines[(math "$idx" + 1)]
        set description $lines[(math "$idx" + 2)]
        printf "$template" "$name" "$description"
      end
      printf "\n"
    end
  end
end

## Prints out the label for a help command, including any arguments it may have.
function _command_label --argument-names name arg color
  echo -n "$color"
  echo -n "$name"
  if [ ! -z "$arg" ]
    for n in (string split " " $arg)
      echo -n "$color"
      echo -n " "(set_color -ud)"$n"(set_color reset)
    end
  end
end

## Prints out the label for a help command, padded to the correct length.
function _command_label_padded --argument-names name arg color size
  set label (_command_label "$name" "$arg" "$color")
  set width (string length -V "$label")
  set remainder (math "$size - $width")
  echo -n "$label"
  string repeat -Nn "$remainder" " "
end

_register_command system "help"
_register_command system "aliases"
_register_command system "scripts"
_register_command system "backup"

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function prn2pdf --description "Converts: .prn → .pdf"
  ! _require_cmd "ps2pdf"; and return 1
  # Note: if a directory is entered, all .prn files are converted.
  # By default we convert all .prn files in the current directory.
  if [ -z "$argv" ]
    set argv[1] (pwd)
  end
  
  for entry in $argv
    if [ -d "$entry" ]
      set files (find . -type f -iname "*.prn")
    else if [ -e "$entry" ]
      set files "$entry"
    end
    if [ (count $files) -eq 0 ]
      echo "prn2pdf: error: no .prn files found in: $entry"
      return 1
    end

    for file in $files
      echo (set_color yellow)"prn2pdf: "(set_color cyan)"$f"(set_color reset)
      ps2pdf "$f"
    end
  end

  echo (set_color yellow)"prn2pdf: done"(set_color reset)
end

_register_command conversion "prn2pdf" "fn"
_register_dependency "brew" "ghostscript" "ps2pdf"

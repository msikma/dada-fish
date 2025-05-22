# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function move_scratch --description "Refiles a project's scratch dir"
  set code_base (realpath "$DADA_CODE_BASE")
  set scratch_base (realpath "$DADA_SCRATCH_BASE")
  set project (realpath (pwd))
  set local_scratch ".scratch"
  set local_source "_source"

  # Check if project is inside the code base directory.
  if not string match -q "$code_base*" "$project"
    echo "move_scratch: error: directory must be inside the following path: $DADA_CODE_BASE"
    return 1
  end

  # Check if we have a scratch or _source directory.
  if not test -d "$local_source"
    echo "move_scratch: error: no $local_source directory found in current project"
    return 1
  end

  # Determine where we need to save this scratch directory to.
  # e.g. if this is in Code/@dada78641/someplace, we will put the scratch directory
  # in Projects/Scratch/Code/@dada78641/someplace.
  set relative_path (string replace -r "^$code_base/?(.*)" '$1' "$project")
  set project_name (basename "$relative_path")
  set project_path (dirname "$relative_path")

  set target_dir "$scratch_base/$project_path"
  set target_path "$target_dir/$project_name"

  if test -d "$target_path"
    echo "move_scratch: error: this scratch directory already exists: $project_path/$project_name"
    return 1
  end

  mkdir -p "$target_dir"
  mv "$local_source" "$target_path"
  ln -s "$target_path" "$local_scratch"

  if ! test -d "$target_path"
    echo "move_scratch: error: we tried, but could not create the scratch directory for some reason."
    return 1
  end
  echo "Converted local "(set_color red)"$local_source"(set_color normal)" directory to a scratch directory and symlinked it to "(set_color yellow)"$local_scratch"(set_color normal)"."
  ls -la -d --color=always "$local_scratch"
end

_register_command pkg "move_scratch"

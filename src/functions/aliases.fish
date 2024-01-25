# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

_register_alias regular "tree" "-" "eza -Tla --git-ignore -I .git" "Displays the directory tree"
_register_alias regular "latest" "-" "ls -lah --git -s old --color=always | head -11" "Shows the latest files"
#ccd2iso
#mdf2iso
#ps2pdf

_register_alias git "g" "-" "git status" "Displays git status"
_register_alias git "gb" "-" "echo todo" "Shows last commits per branch"
_register_alias git "gd" "-" "git diff --cached" "Shows diff of staged changes"

_register_hidden_alias helpers "strip_color" "-" "gsed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'" "Strips color sequences"
_register_hidden_alias helpers "lowercase" "-" "tr '[:upper:]' '[:lower:]'" "Converts text to lowercase"
_register_hidden_alias helpers "uppercase" "-" "tr '[:lower:]' '[:upper:]'" "Converts text to uppercase"
_register_hidden_alias helpers "fn_base" "fn" "_file_base" "Prints filename without extension"
_register_hidden_alias helpers "fn_ext" "fn" "_file_ext" "Prints filename extension"

_register_dependency "brew" "eza" "eza"
_register_dependency "brew" "git" "git"
_register_dependency "gnu-sed" "gsed"

# ghelp           Displays all Git commands         gr              Shows the repo's current remotes  
# g               Git status                        gclone <dir>    Prints a clone command for a repo 
# gb              Shows last Git commits per branch gru             Shows the repo remote origin URL  
# gd              Runs 'git diff --cached'          gsl             Git short log (one liners)        
# gl              Git log with merge lines          git summary     Summary of repo and authors       
# glb             Shows list of local-only branches jira            Lists Jira issue branches         
# glist           One-line Git log with merge lines open_repo       Opens the repo's homepage         
# glog            Git log with extra information  

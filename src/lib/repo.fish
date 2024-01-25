# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _git_hash
  git --git-dir "$DADA_FISH_REPO" rev-parse HEAD
end

function _git_unix_time
  git --git-dir "$DADA_FISH_REPO" log -1 --format=%ct HEAD
end

function _git_timestamp
  git --git-dir "$DADA_FISH_REPO" log -n 1 --date=format:%s --pretty=format:%cd --date=short
end

function _git_timestamp_rel
  git --git-dir "$DADA_FISH_REPO" log -n 1 --pretty=format:%cd --date=relative
end

function _git_branch
  git --git-dir "$DADA_FISH_REPO" rev-parse --abbrev-ref --short HEAD
end

function _git_count
  git --git-dir "$DADA_FISH_REPO" rev-list --count HEAD
end

function _git_version_formatted
  set hash (string sub -l 7 (_git_hash))
  set branch (_git_branch)
  set count (_git_count)
  echo "$branch-$count [$hash]"
end

function _git_timestamp_formatted
  set date (_git_timestamp)
  set rel (_git_timestamp_rel)
  echo "$date ($rel)"
end

# A slightly optimized helper function for VCS.
# Displaying the VCS part of the prompt is quite slow,
# so we check to see if .git exists in the current dir or two dirs down.
# If not, we exit early. This is a decent trade-off for the extra speed
# in most cases. (Works for most regular repos and monorepos.)
function _in_vcs_repo
  # Speed up non-Git folders a bit
  if not test -d ./.git; and not test -d ../.git; and not test -d ../../.git
    return
  end
  __fish_vcs_prompt
end

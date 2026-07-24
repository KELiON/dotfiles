_gco() {
  local -aU branches
  branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null)"})
  branches=(${branches:#*/HEAD})
  branches=(${branches#origin/})
  if [[ $words[CURRENT] != -* ]] && compadd -M 'l:|=* r:|=*' -a branches; then
    return
  fi
  local service=git
  words=(git checkout "${(@)words[2,-1]}")
  (( CURRENT++ ))
  _git
}

_gb() {
  local service=git
  words=(git branch "${(@)words[2,-1]}")
  (( CURRENT++ ))
  _git
}

if (( $+functions[compdef] )); then
  compdef _gco gco
  compdef _gb gb
fi

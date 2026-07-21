function env-switch() {
  if [[ $# -eq 0 ]]; then
    local profile="${ENV_PROFILE:-<none>}"
    local file="$HOME/.secrets/${profile}.env-switch"
    echo "env-switch: profile '${profile}'"
    if [[ -f "$file" ]]; then
      echo "variables:"
      _env_extract_vars "$file" | sed 's/^/  /'
    else
      echo "  (no secrets file at ${file})"
    fi

    local dir_file
    dir_file=$(_env_dir_file)
    if [[ -n "$dir_file" ]]; then
      echo "local: ${dir_file}"
      if [[ -n "$_ENV_SWITCH_LOADED_LOCAL_VARS" ]]; then
        echo "local variables:"
        local v
        for v in ${=_ENV_SWITCH_LOADED_LOCAL_VARS}; do
          echo "  $v"
        done
      fi
    fi
    return 0
  fi

  local cmd="$1"
  shift

  case "$cmd" in
    refresh)
      local profile="${1:-$ENV_PROFILE}"
      local template="$ZSH/env-switch/${profile}.env-switch"
      local output="$HOME/.secrets/${profile}.env-switch"

      if [[ ! -f "$template" ]]; then
        echo "env-switch: no template found for profile '${profile}' at ${template}"
        return 1
      fi

      mkdir -p "$HOME/.secrets"
      chmod 700 "$HOME/.secrets"

      local account
      account=$(grep '^# account:' "$template" | awk '{print $3}')

      if [[ -n "$account" ]]; then
        op inject --account="$account" -i "$template" -o "$output"
      else
        op inject -i "$template" -o "$output"
      fi

      chmod 600 "$output"
      echo "env-switch: refreshed '${profile}'"
      ;;

    local)
      local profile=""
      local pin=0
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --pin) pin=1; shift ;;
          *) profile="$1"; shift ;;
        esac
      done

      if [[ -z "$profile" ]]; then
        echo "usage: env-switch local [--pin] <profile>"
        return 1
      fi

      export ENV_PROFILE="$profile"

      if [[ ! -f "$HOME/.secrets/${profile}.env-switch" ]]; then
        env-switch refresh "$profile" || return 1
      fi

      _env_unset_loaded
      source "$HOME/.secrets/${profile}.env-switch"
      export _ENV_SWITCH_LOADED_VARS="$(_env_extract_vars "$HOME/.secrets/${profile}.env-switch" | tr '\n' ' ')"

      _env_unset_local
      _env_load_local

      if (( pin )); then
        echo "profile: $profile" > "$PWD/.env-switch"
        echo "env-switch: using '${profile}' (local, pinned to ${PWD})"
      else
        echo "env-switch: using '${profile}' (local)"
      fi
      ;;

    global)
      local profile="$1"
      if [[ -z "$profile" ]]; then
        echo "usage: env-switch global <profile>"
        return 1
      fi

      echo "$profile" > "$HOME/.secrets/.active-profile"
      env-switch local "$profile"
      echo "env-switch: set '${profile}' as global default"
      ;;

    *)
      echo "usage: env-switch <refresh|local|global> [profile]"
      return 1
      ;;
  esac
}

function _env_extract_vars() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -E '^[[:space:]]*export[[:space:]]+' "$file" \
    | sed -E 's/^[[:space:]]*export[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)=.*/\1/'
}

function _env_unset_loaded() {
  [[ -z "$_ENV_SWITCH_LOADED_VARS" ]] && return 0
  local v
  for v in ${=_ENV_SWITCH_LOADED_VARS}; do
    unset "$v"
  done
  unset _ENV_SWITCH_LOADED_VARS
}

function _env_unset_local() {
  [[ -z "$_ENV_SWITCH_LOADED_LOCAL_VARS" ]] && return 0
  local v
  for v in ${=_ENV_SWITCH_LOADED_LOCAL_VARS}; do
    unset "$v"
  done
  unset _ENV_SWITCH_LOADED_LOCAL_VARS
}

function _env_dir_file() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.env-switch" ]]; then
      echo "$dir/.env-switch"
      return 0
    fi
    dir="${dir:h}"
  done
  return 1
}

function _env_parse_profile() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  local p
  p=$(grep -E '^[[:space:]]*profile:' "$file" | head -n1 \
      | sed -E 's/^[[:space:]]*profile:[[:space:]]*//; s/[[:space:]]+$//')
  if [[ -n "$p" ]]; then
    echo "$p"
    return 0
  fi

  local content
  content=$(grep -v -E '^[[:space:]]*(#|$)' "$file" 2>/dev/null)
  if [[ -n "$content" ]] \
     && [[ $(echo "$content" | wc -l | tr -d ' ') -eq 1 ]] \
     && [[ "$content" != *"="* ]] \
     && [[ "$content" != *"export"* ]]; then
    echo "${content// /}"
  fi
}

function _env_parse_account() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep '^# account:' "$file" | awk '{print $3}'
}

function _env_file_has_exports() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  grep -qE '^[[:space:]]*export[[:space:]]+' "$file"
}

function _env_local_cache_path() {
  local dir_file="$1"
  local hash
  hash=$(echo -n "$dir_file" | md5)
  echo "$HOME/.secrets/local/${hash}.env-switch"
}

function _env_inject_local() {
  local dir_file="$1"
  local cache_file="$2"

  mkdir -p "${cache_file:h}"
  chmod 700 "$HOME/.secrets/local"

  if [[ -f "$cache_file" ]]; then
    local src_mtime cache_mtime
    src_mtime=$(stat -f %m "$dir_file" 2>/dev/null)
    cache_mtime=$(stat -f %m "$cache_file" 2>/dev/null)
    if [[ -n "$src_mtime" && -n "$cache_mtime" && "$src_mtime" -le "$cache_mtime" ]]; then
      return 0
    fi
  fi

  local account
  account=$(_env_parse_account "$dir_file")

  if [[ -n "$account" ]]; then
    grep -v -E '^[[:space:]]*profile:' "$dir_file" \
      | op inject --account="$account" -o "$cache_file"
  else
    grep -v -E '^[[:space:]]*profile:' "$dir_file" \
      | op inject -o "$cache_file"
  fi

  chmod 600 "$cache_file"
}

function _env_load_local() {
  local dir_file
  dir_file=$(_env_dir_file) || return 0
  _env_file_has_exports "$dir_file" || return 0

  local cache_file
  cache_file=$(_env_local_cache_path "$dir_file")
  _env_inject_local "$dir_file" "$cache_file" || return 1

  source "$cache_file"
  export _ENV_SWITCH_LOADED_LOCAL_VARS="$(_env_extract_vars "$cache_file" | tr '\n' ' ')"
}

function _env_chpwd() {
  local new_profile=$(_env_resolve_profile)
  if [[ "$new_profile" != "$ENV_PROFILE" ]]; then
    env-switch local "$new_profile"
  else
    _env_unset_local
    _env_load_local
  fi
}

function _env_resolve_profile() {
  local f
  f=$(_env_dir_file)
  if [[ -n "$f" ]]; then
    local p
    p=$(_env_parse_profile "$f")
    if [[ -n "$p" ]]; then
      echo "$p"
      return 0
    fi
  fi
  cat "$HOME/.secrets/.active-profile" 2>/dev/null || echo "personal"
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _env_chpwd

_default_profile=$(_env_resolve_profile)
export ENV_PROFILE="${ENV_PROFILE:-$_default_profile}"
unset _default_profile

if [[ -f "$HOME/.secrets/${ENV_PROFILE}.env-switch" ]]; then
  _env_unset_loaded
  source "$HOME/.secrets/${ENV_PROFILE}.env-switch"
  export _ENV_SWITCH_LOADED_VARS="$(_env_extract_vars "$HOME/.secrets/${ENV_PROFILE}.env-switch" | tr '\n' ' ')"
else
  echo "env-switch: no secrets loaded for '${ENV_PROFILE}' — run: env-switch refresh"
fi

_env_load_local

alias reload!='. ~/.zshrc'
alias clear_zsh='sudo rm /private/var/log/asl/*.asl'
alias clear_skype='sudo sqlite3 "$HOME/Library/Application Support/Skype/subbotin.alexandr/main.db" "vacuum; reindex;"'
alias clear_git="git gc --aggressive"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

# ai                 → plain claude
# ai <name> [args]   → named session + tmux window renamed to <name>
# ai --continue ...  → flags pass straight through to claude, no naming
ai() {
  if [[ -n "$1" && "$1" != -* ]]; then
    local name="$1"; shift
    [[ -n "$TMUX" ]] && tmux rename-window "$name"
    claude --dangerously-skip-permissions --name "$name" "$@"
    [[ -n "$TMUX" ]] && tmux set-option -w automatic-rename on
  else
    claude --dangerously-skip-permissions "$@"
  fi
}

cc() {
  [[ -n "$SSH_CONNECTION" ]] && security unlock-keychain ~/Library/Keychains/login.keychain-db
  if [[ -n "$1" ]]; then
    # named session: attach if it exists, otherwise create it
    tmux attach -d -t "$1" 2>/dev/null || tmux new -A -s "$1"
  else
    # no argument: attach to the most recently used session (take over)
    local target
    target=$(tmux list-sessions -F '#{session_last_attached} #{session_name}' 2>/dev/null | sort -n | tail -1 | awk '{print $2}')
    if [[ -n "$target" ]]; then
      tmux attach -d -t "$target"
    else
      tmux new -A -s code
    fi
  fi
}

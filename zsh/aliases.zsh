alias reload!='. ~/.zshrc'
alias clear_zsh='sudo rm /private/var/log/asl/*.asl'
alias clear_skype='sudo sqlite3 "$HOME/Library/Application Support/Skype/subbotin.alexandr/main.db" "vacuum; reindex;"'
alias clear_git="git gc --aggressive"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

alias ai='claude --dangerously-skip-permissions'

cc() {
  [[ -n "$SSH_CONNECTION" ]] && security unlock-keychain ~/Library/Keychains/login.keychain-db
  tmux new -A -s "${1:-code}"
}

alias reload!='. ~/.zshrc'
alias clear_zsh='sudo rm /private/var/log/asl/*.asl'
alias clear_skype='sudo sqlite3 "$HOME/Library/Application Support/Skype/subbotin.alexandr/main.db" "vacuum; reindex;"'
alias clear_git="git gc --aggressive"
alias ibrew='arch -x86_64 /usr/local/bin/brew'

function ai() {
  if [[ "$PWD" == "$HOME/projects/"*raycast* ]]; then
    claude --dangerously-skip-permissions "$@"
  else
    ANTHROPIC_API_KEY=$(op read "op://Private/.dotfiles/ANTHROPIC_API_KEY" --account=my.1password.com) claude --dangerously-skip-permissions "$@"
  fi
}

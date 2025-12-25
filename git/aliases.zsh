# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
hub_path=$(which hub)
if [[ -f $hub_path ]]
then
  alias git=$hub_path
fi

alias g="lazygit"

alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"

alias hb="hub browse"

alias gpo="git push origin \$(gcb)"
alias gpl="git pull --rebase origin \$(gcb)"

alias gb="git branch"
alias gs="git status"
alias gco="git checkout"
alias gc="git commit"

# git current branch
alias gcb="git rev-parse --abbrev-ref HEAD"

# update current branch from main branch
alias gupd="main_branch=\$(git remote show origin | sed -n '/HEAD branch/s/.*: //p'); echo \"rebasing origin/\$main_branch\"...; git fetch origin && git rebase origin/\$main_branch"

# .g shortcuts
alias .ga=".g add"
alias .gd=".g diff"
alias .glog=".g log"

# Create a git worktree and start AI coding session
aw() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: Not inside a git repository"
    return 1
  fi

  local suffix=""
  local base_branch=""
  local skip_deps=false
  local skip_ai=false
  local open_editor=false

  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-deps) skip_deps=true; shift ;;
      --no-ai) skip_ai=true; shift ;;
      --editor|-e) open_editor=true; shift ;;
      --base|-b) base_branch="$2"; shift 2 ;;
      --help|-h)
        echo "Usage: aw [options] [suffix]"
        echo ""
        echo "Options:"
        echo "  -b, --base <branch>  Base branch (default: current)"
        echo "  -e, --editor         Open in \$EDITOR after setup"
        echo "  --no-deps            Skip dependency installation"
        echo "  --no-ai              Skip launching AI"
        echo "  -h, --help           Show this help"
        return 0
        ;;
      *) suffix="$1"; shift ;;
    esac
  done

  if [[ -z "$suffix" ]]; then
    read -p "Enter worktree suffix: " suffix
    [[ -z "$suffix" ]] && { echo "Error: Suffix cannot be empty"; return 1; }
  fi

  local project_name
  project_name=$(basename "$(git rev-parse --show-toplevel)")
  local worktree_path="$HOME/projects/${project_name}-${suffix}"

  [[ -d "$worktree_path" ]] && { echo "Error: Worktree exists at $worktree_path"; return 1; }

  mkdir -p "$HOME/projects"

  # Fetch latest
  echo "📡 Fetching latest..."
  git fetch --quiet

  # Create worktree
  echo "🌳 Creating worktree at $worktree_path..."
  if [[ -n "$base_branch" ]]; then
    git worktree add "$worktree_path" -b "$suffix" "$base_branch" || return 1
  else
    git worktree add "$worktree_path" -b "$suffix" || return 1
  fi

  cd "$worktree_path" || return 1

  echo "✓ Worktree created at $worktree_path"
  echo "✓ Branch '$suffix' created"

  # Install dependencies
  if [[ "$skip_deps" == false ]]; then
    if [[ -f ".aw-setup" ]]; then
      echo "📦 Running custom setup..."
      source .aw-setup
    elif [[ -f "Gemfile" ]]; then
      echo "📦 Installing Ruby dependencies..."
      bundle install
    elif [[ -f "package-lock.json" ]]; then
      echo "📦 Installing Node dependencies..."
      npm install
    elif [[ -f "yarn.lock" ]]; then
      echo "📦 Installing Node dependencies..."
      yarn install
    elif [[ -f "pnpm-lock.yaml" ]]; then
      echo "📦 Installing Node dependencies..."
      pnpm install
    elif [[ -f "requirements.txt" ]]; then
      echo "📦 Installing Python dependencies..."
      pip install -r requirements.txt
    elif [[ -f "pyproject.toml" ]]; then
      echo "📦 Installing Python dependencies..."
      pip install -e .
    fi
  fi

  # Open editor
  if [[ "$open_editor" == true ]] && [[ -n "$EDITOR" ]]; then
    echo "📝 Opening editor..."
    $EDITOR .
  fi

  # Start AI
  if [[ "$skip_ai" == false ]]; then
    echo "🤖 Starting AI session..."
    ai
  fi
}

# List worktrees for current project
awl() {
  git worktree list
}

# Delete a worktree
awd() {
  local suffix="$1"
  if [[ -z "$suffix" ]]; then
    echo "Usage: awd <suffix>"
    git worktree list
    return 1
  fi

  local project_name
  project_name=$(basename "$(git rev-parse --show-toplevel)")
  local worktree_path="$HOME/projects/${project_name}-${suffix}"

  if [[ ! -d "$worktree_path" ]]; then
    echo "Error: Worktree not found at $worktree_path"
    return 1
  fi

  echo "Removing worktree at $worktree_path..."
  git worktree remove "$worktree_path"

  # Optionally delete the branch too
  read -p "Delete branch '$suffix'? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git branch -d "$suffix" 2>/dev/null || git branch -D "$suffix"
  fi
}

# Jump to a project worktree
awj() {
  local suffix="$1"
  if [[ -z "$suffix" ]]; then
    echo "Usage: awj <suffix>"
    git worktree list
    return 1
  fi

  local project_name
  project_name=$(basename "$(git rev-parse --show-toplevel)")
  local worktree_path="$HOME/projects/${project_name}-${suffix}"

  if [[ ! -d "$worktree_path" ]]; then
    echo "Error: Worktree not found at $worktree_path"
    return 1
  fi

  cd "$worktree_path"
}

# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
set hub_path (which hub)
if test -f $hub_path
  alias git=$hub_path
end

alias g="git"

# The rest of my fun git aliases
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gtracker="git log --pretty=format:'%Cred%h%Creset %C(yellow)%ad%Creset %s' --author='Alexandr Subbotin'"
alias gp='git push origin HEAD'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gstandup="git log --since '1 day ago' --oneline --author kelionweb@gmail.com"

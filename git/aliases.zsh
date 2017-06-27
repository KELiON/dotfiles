# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
hub_path=$(which hub)
if [[ -f $hub_path ]]
then
  alias git=$hub_path
fi

alias g="git"

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

# .g shortcuts
alias .ga=".g add"
alias .gd=".g diff"
alias .glog=".g log"
autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git=$commands[git]
else
  git=/usr/bin/git
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  st=$($git status 2>/dev/null | tail -n 1)
  if [[ $st == "" ]]
  then
    echo ""
  else
    if [[ "$st" =~ ^nothing ]]
    then
      echo "on %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "on %{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}


symbol() {
  hour=$(date +%H)
  day=$(date +%u)
  if [[ $(echo $day | grep -E '0|6') != "" ]]
  then
    echo '🍺'
  else
    if [[ $(echo $hour | grep -E '14') != "" ]]
    then
      echo '🍲'
    else
      if [[ $(echo $hour | grep -E '1[0-9]') != "" ]]
      then
        echo '☀'
      else
        if [[ $(echo $hour | grep -E '(19|2[0-3])') != "" ]] then
          echo '🍺'
        fi
      fi
    fi
  fi
}

directory_name(){
  echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

export PROMPT=$'$(directory_name) $(git_dirty)$(symbol)  '

precmd() {
  title "zsh" "%m" "%55<...<%~"
}
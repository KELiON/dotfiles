if test "$1" == "show"
then
  git show $(.g log | head -c7)
elif test "$1" == "log"
then
  git log --oneline | fzf --reverse
elif test "$1" == "fixup"
then
  git commit --fixup=$(.g log | head -c7)
elif test "$1" == "rebase"
then
  git rebase -i $(.g log | head -c7)
elif test "$1" == "add"
then
  git add $(git status -s | fzf -m --reverse | cut -c 4-)
elif test "$1" == "diff"
then
  git diff $(git status --porcelain | fzf | cut -c 4-)
fi
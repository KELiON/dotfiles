set -g PROJECTS ~/projects
set -g FISH $HOME/.config/fish
set -g DOTFILES $HOME/.dotfiles

#prevent recursion
for file in (ls $DOTFILES/**/*.fish | grep -v /fish/); . $file; end;
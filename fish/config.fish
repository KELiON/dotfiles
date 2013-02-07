set -g PROJECTS ~/projects
set -g FISH $HOME/.config/fish
set -g DOTFILES $HOME/.dotfiles

set fish_greeting ""

for file in (ls $DOTFILES/**/*.fish | grep -v /fish/); . $file; end;

true
# https://github.com/rtomayko/dotfiles/blob/rtomayko/bin/headers
function headers
  curl -sv "$argv" 2>&1 >/dev/null |
    grep -v "^\*" |
    grep -v "^}" |
    cut -c3-
end
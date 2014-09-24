alias be='bundle exec'
alias migrate='bundle exec rake db:migrate'
alias migrate:undo='bundle exec rake db:rollback'
alias migrate:redo='bundle exec rake db:redo'
alias rs='r s'
alias rc='r c'
alias rg='r g'

# Shortcut for `bundle exec rails` and `bundle exec rake`.
# If script/rails and script/rake are available, use them instead as they are much
# faster to execute than `bundle exec`.
# got from https://github.com/st8998/environment/blob/master/.bash_profile
function r() {
  if [[ "g|generate|c|console|s|server|db|dbconsole|new" =~ $1 ]]; then
    if [ -x script/rails ]; then
      script/rails $@
    else
      if [ -x bin/rails ]; then
        bin/rails $@
      else
        bundle exec rails $@
      fi
    fi
  else
    if [ -x script/rake ]; then
      script/rake $@
    else
      if [ -x bin/rake ]; then
        bin/rake $@
      else
        bundle exec rake $@
      fi
    fi
  fi
}
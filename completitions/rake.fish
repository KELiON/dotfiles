function __cache_or_get_rake_completion -d "Create rake completions"
    mkdir -p "/tmp/rake_completion_cache_for_$USER"
  set -l hashed_pwd (md5 -q -s (pwd))
  set -l rake_cache_file "/tmp/rake_completion_cache_for_$USER/$hashed_pwd"

  if not test -f "$rake_cache_file"
    bundle exec rake -T 2>&1 | sed -e "/^(/d" -e "s/^rake \([a-z:_0-9!\-]*\).*/\1/" > "$rake_cache_file"
  end

  cat "$rake_cache_file"
end

function rake_cache_clear
  set -l hashed_pwd (md5 -q -s (pwd))
  set -l rake_cache_file "/tmp/rake_completion_cache_for_$USER/$hashed_pwd"
  unlink $rake_cache_file
end

complete -x -c rake -a "(__cache_or_get_rake_completion)" --description 'Rake Task'
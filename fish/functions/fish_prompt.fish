function fish_prompt
  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -l red (set_color -o red)
  set -l blue (set_color -o blue)
  set -l normal (set_color normal)

  set -l arrow "$red> $normal"
  set -l cwd $cyan(prompt_pwd)

  set -l time (date +%H)
  set -l day (date +%u)

  set -l symbol '🌙'

  if [ (echo $day | grep -E '0|6') ]
    set symbol '🍺'
  else
    if [ (echo $time | grep -E '14') ]
      set symbol '🍲'
    else
      if [ (echo $time | grep -E '1[0-9]') ]
        set symbol '☀'
      else
        if [ (echo $time | grep -E '(19|2[0-3])') ]
          set symbol '🍺'
        end
      end
    end
  end

  echo -s $cwd $normal " $symbol  "
end
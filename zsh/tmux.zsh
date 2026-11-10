# Ghostty → last-used tmux session.
# Skip: already in tmux, SSH, non-interactive, not Ghostty.
# The latest session is the target even if a client holds it:
#   phone/SSH clients (non-Ghostty) are detached — the Mac wins.
#   another Ghostty window keeps it — this window stays a plain shell.
if [[ -o interactive && -z "$TMUX" && -z "$SSH_CONNECTION" && "$TERM_PROGRAM" == "ghostty" ]]; then
  if command -v tmux >/dev/null 2>&1; then
    if tmux has-session 2>/dev/null; then
      _ghostty_tmux_target="$(
        tmux list-sessions -F '#{session_last_attached} #{session_name}' \
          | sort -n \
          | tail -1 \
          | awk '{ print $2 }'
      )"
      if [[ -n "$_ghostty_tmux_target" ]]; then
        # detach phone/SSH clients on the target session (Mac takes over)
        tmux list-clients -t "$_ghostty_tmux_target" -F '#{client_tty} #{client_termname}' 2>/dev/null \
          | awk '$2 != "xterm-ghostty" { print $1 }' \
          | while read -r _tty; do tmux detach-client -t "$_tty" 2>/dev/null; done
        # attach only if no Ghostty window still holds the session
        if ! tmux list-clients -t "$_ghostty_tmux_target" -F '#{client_termname}' 2>/dev/null | grep -q xterm-ghostty; then
          exec tmux attach -t "$_ghostty_tmux_target"
        fi
      fi
      unset _ghostty_tmux_target
    else
      exec tmux new-session
    fi
  fi
fi

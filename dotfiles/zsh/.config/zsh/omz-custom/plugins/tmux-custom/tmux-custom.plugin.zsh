# This plugin overrides how the tmux plugin creates and attached to sessions
declare -r TMUX_CMD="$(command -pv tmux)"

function _zsh_tmux_custom_attach() {
  local -r sess_name="${1:-${ZSH_TMUX_SESSION_NAME:-ohmyzsh}}"
  # This could mismatch sessions names like "foo" and "foobar" since we want to
  # attempt to match the first session which has no "-<index>" suffix
  local -r match_sess="#{m:${sess_name}*,#{session_name}}"
  local -r detached="#{?session_attached,0,1}"
  local -r condition="#{&&:${match_sess},${detached}}"
  local -r detached_sessions_fmt="#{?${condition},#{session_name},}"

  local took_session=false
  for cand in $("${TMUX_CMD}" ls -F "${detached_sessions_fmt}"); do
    if [ ! -z "${cand}" ] && "${TMUX_CMD}" attach-session -t ${cand}; then
      return
    fi
  done
  false
}
# Alias for "tmux join"
alias tj='_zsh_tmux_custom_attach'

# Wrapper function for tmux.
function _zsh_tmux_custom_run() {
  if [[ -n "$@" ]]; then
    ${TMUX_CMD} "$@"
    return $?
  fi

  [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]] || return

  # Attempt to attach to an existing session if possible
  local -r sess_name="${ZSH_TMUX_SESSION_NAME:-ohmyzsh}"
  local -a tmux_extra_args=()

  [[ "$ZSH_TMUX_ITERM2" == "true" ]] && tmux_extra_args+=(-CC)
  [[ "$ZSH_TMUX_UNICODE" == "true" ]] && tmux_extra_args+=(-u)

  if ! _zsh_tmux_custom_attach "${sess_name}"; then
    # Otherwise start a new session with the configured name, fixing the
    # terminal if we've been told to do so
    if [[ "$ZSH_TMUX_FIXTERM" == "true" ]]; then
      tmux_extra_args+=(-f "$_ZSH_TMUX_FIXED_CONFIG")
    elif [[ -e "$ZSH_TMUX_CONFIG" ]]; then
      tmux_extra_args+=(-f "$ZSH_TMUX_CONFIG")
    fi
    "${TMUX_CMD}" "${tmux_extra_args[@]}" new-session -t "${sess_name}"
  fi

  if [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]]; then
    exit
  fi
}

# Use the completions for tmux for our function
compdef _tmux _zsh_tmux_custom_run
# Alias tmux to our wrapper function.
alias tmux="_zsh_tmux_custom_run"

# Autostart if not already in tmux and enabled.
if [[ -z "$TMUX" && "$ZSH_TMUX_CUSTOM_AUTOSTART" == "true" && "$ZSH_TMUX_AUTOSTART" != "true" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" ]]; then
  # Actually don't autostart if we already did and multiple autostarts are disabled.
  if [[ "$ZSH_TMUX_AUTOSTART_ONCE" == "false" || "$ZSH_TMUX_AUTOSTARTED" != "true" ]]; then
    export ZSH_TMUX_AUTOSTARTED=true
    _zsh_tmux_custom_run
  fi
fi

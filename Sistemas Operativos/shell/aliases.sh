# =============================================================================
# Biblioteca — aliases comunes para sh (POSIX)
# Fuente: https://github.com/P3M-ACTF/Biblioteca
# Uso: . ~/.biblioteca-aliases.sh   (o añade el source a ~/.shrc / ~/.profile)
# =============================================================================
# Sintaxis estrictamente POSIX. Sin [[ ]], sin arrays, sin local (en algunos sh).
# Carga con: . archivo   (no uses "source" si tu sh no lo tiene)
# =============================================================================

# --- Navegación y listados --------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias ll='ls -lah'
alias la='ls -A'
alias lt='ls -lahtr'

# Crear ruta completa y entrar (función POSIX)
mkcd() {
  mkdir -p -- "$1" || return
  cd -- "$1" || return
}

# --- Seguridad básica / higiene ---------------------------------------------
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias df='df -h'
alias du='du -h'

# --- Red --------------------------------------------------------------------
alias myip='curl -fsS https://ifconfig.me; echo'
alias ports='ss -tulpn'
alias ping='ping -c 4'
alias headers='curl -fsSI'
alias get='curl -fsSL'

# --- Procesos ---------------------------------------------------------------
alias psg='ps aux | grep -v grep | grep -i'
alias meminfo='free -h'
alias kill9='kill -9'

# --- Logs -------------------------------------------------------------------
alias jctl='journalctl -xe'
alias jctlf='journalctl -f'
alias syslog='tail -n 100 /var/log/syslog'

# --- Systemd ----------------------------------------------------------------
alias sctl='systemctl'
alias sstatus='systemctl status'
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'

# --- Permisos ---------------------------------------------------------------
alias perms='stat -c "%a %A %n"'
alias getacl='getfacl'
alias setacl='setfacl'

# --- Git --------------------------------------------------------------------
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -n 20'
alias gd='git diff'

# --- Búsqueda ---------------------------------------------------------------
alias grep='grep --color=auto'

ff() {
  find . -iname "*$1*" 2>/dev/null
}

# --- Utilidades -------------------------------------------------------------
alias now='date "+%Y-%m-%d %H:%M:%S %Z"'

extract() {
  if [ ! -f "$1" ]; then
    echo "No existe: $1" >&2
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.zip)     unzip "$1" ;;
    *)         echo "Formato no reconocido: $1" >&2; return 1 ;;
  esac
}

if [ "${BIBLIOTECA_ALIASES_QUIET:-0}" != "1" ]; then
  echo "[Biblioteca] aliases.sh cargados. Silenciar: BIBLIOTECA_ALIASES_QUIET=1"
fi

# =============================================================================
# Biblioteca — aliases comunes para zsh
# Fuente: https://github.com/P3M-ACTF/Biblioteca
# Uso: source ~/.biblioteca-aliases.zsh   (o añade el source a ~/.zshrc)
# =============================================================================
# Pensado para zsh. Usa sintaxis compatible; no depende de plugins (oh-my-zsh).
# =============================================================================

# --- Seguridad: no sobrescribir por defecto ---------------------------------
setopt noclobber 2>/dev/null || true

# --- Navegación y listados --------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ls con colores (GNU ls o BSD ls)
if ls --color=auto / >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
  alias lt='ls -lahtr --color=auto'
  alias lsd='ls -lahd --color=auto -- */'
elif ls -G / >/dev/null 2>&1; then
  alias ls='ls -G'
  alias ll='ls -lahG'
  alias la='ls -AG'
  alias lt='ls -lahtrG'
else
  alias ll='ls -lah'
  alias la='ls -A'
  alias lt='ls -lahtr'
fi

# Crear ruta completa y entrar
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# --- Seguridad básica / higiene ---------------------------------------------
if rm --help 2>&1 | grep -q -- '--preserve-root'; then
  alias rm='rm -I --preserve-root'
else
  alias rm='rm -i'
fi
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

if chmod --help 2>&1 | grep -q -- '--preserve-root'; then
  alias chmod='chmod --preserve-root'
  alias chown='chown --preserve-root'
  alias chgrp='chgrp --preserve-root'
fi

if df -hT / >/dev/null 2>&1; then
  alias df='df -hT'
else
  alias df='df -h'
fi
alias du='du -h'
alias dus='du -h --max-depth=1 2>/dev/null | sort -h'

if command -v sha256sum >/dev/null 2>&1; then
  alias sha256='sha256sum'
else
  alias sha256='shasum -a 256'
fi
if command -v md5sum >/dev/null 2>&1; then
  alias md5='md5sum'
elif command -v md5 >/dev/null 2>&1; then
  alias md5='md5'
fi

# --- Red --------------------------------------------------------------------
alias myip='curl -fsS https://ifconfig.me; echo'
alias localip="hostname -I 2>/dev/null || ip -4 addr show scope global | awk '/inet /{print \$2}'"
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn'
alias listening='ss -tulpn 2>/dev/null || netstat -tulpn'
alias connections='ss -tpn 2>/dev/null || netstat -tpn'
alias ping='ping -c 4'
alias digs='dig +short'
alias flushdns='resolvectl flush-caches 2>/dev/null || dscacheutil -flushcache 2>/dev/null || true'

alias headers='curl -fsSI'
alias get='curl -fsSL'

# --- Procesos y recursos ----------------------------------------------------
alias psg='ps aux | grep -v grep | grep -i --color=auto'
alias topmem='ps aux --sort=-%mem | head -n 20'
alias topcpu='ps aux --sort=-%cpu | head -n 20'
alias meminfo='free -h 2>/dev/null || vm_stat'
alias cpuinfo='lscpu 2>/dev/null || sysctl -n machdep.cpu.brand_string'

alias kill9='kill -9'

# --- Logs y journald --------------------------------------------------------
alias jctl='journalctl -xe'
alias jctlf='journalctl -f'
alias jctlu='journalctl -u'
alias syslog='tail -n 100 /var/log/syslog 2>/dev/null || tail -n 100 /var/log/messages'
alias dmesg='dmesg -T'

# --- Systemd / servicios ----------------------------------------------------
alias sctl='systemctl'
alias sstatus='systemctl status'
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'
alias sfailed='systemctl --failed'

# --- Permisos y ACLs --------------------------------------------------------
alias perms='stat -c "%a %A %n" 2>/dev/null || stat -f "%Lp %Sp %N"'
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
alias gco='git checkout'
alias gb='git branch'

# --- Edición y búsqueda -----------------------------------------------------
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

ff() { find . -iname "*$1*" 2>/dev/null; }

# --- Docker -----------------------------------------------------------------
if (( $+commands[docker] )); then
  alias d='docker'
  alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dpa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias di='docker images'
  alias dlog='docker logs -f --tail=100'
fi

# --- Utilidades varias ------------------------------------------------------
alias path='echo -e ${(F)path}'                           # PATH línea a línea (zsh)
alias now='date "+%Y-%m-%d %H:%M:%S %Z"'
alias week='date +%V'
alias reloadzsh='source ~/.zshrc && echo "zshrc recargado"'

extract() {
  if [[ ! -f "$1" ]]; then
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
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.zip)     unzip "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Formato no reconocido: $1" >&2; return 1 ;;
  esac
}

if [[ "${BIBLIOTECA_ALIASES_QUIET:-0}" != "1" ]]; then
  echo "[Biblioteca] aliases.zsh cargados. Silenciar: export BIBLIOTECA_ALIASES_QUIET=1"
fi

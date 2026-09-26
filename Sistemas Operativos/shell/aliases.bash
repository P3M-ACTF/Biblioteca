# =============================================================================
# Biblioteca — aliases comunes para bash
# Fuente: https://github.com/P3M-ACTF/Biblioteca
# Uso: source ~/.biblioteca-aliases.bash   (o añade el source a ~/.bashrc)
# =============================================================================
# Compatible con bash 4+. No asume GNU/Linux puro: marca [GNU] lo que lo sea.
# =============================================================================

# --- Seguridad: no sobrescribir por defecto ---------------------------------
# Activa noclobber para no pisar ficheros con > (usa >| si lo necesitas).
set -o noclobber 2>/dev/null || true

# --- Navegación y listados --------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'                    # vuelve al directorio anterior

# ls con colores si el binario lo soporta
if ls --color=auto / >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'    # listado largo legible (human)
  alias la='ls -A --color=auto'      # incluye ocultos, sin . y ..
  alias lt='ls -lahtr --color=auto'  # por fecha, más reciente al final
  alias lsd='ls -lahd --color=auto -- */'  # solo directorios
else
  alias ll='ls -lah'
  alias la='ls -A'
  alias lt='ls -lahtr'
fi

if command -v tree >/dev/null 2>&1; then
  alias tree1='tree -L 1'
  alias tree2='tree -L 2'
fi

# Crear ruta completa y entrar
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# --- Seguridad básica / higiene ---------------------------------------------
# Confirmación antes de borrar o sobrescribir
alias rm='rm -I --preserve-root'     # -I pide confirmación si >3 ficheros
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# chmod/chown más seguros (no operan sobre / por error tipográfico)
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias chgrp='chgrp --preserve-root'

# No ejecutar find peligroso por accidente sobre /
alias df='df -hT'
alias du='du -h'
alias dus='du -h --max-depth=1 2>/dev/null | sort -h'  # [GNU] resumen por carpeta

# Hash rápidos
alias sha256='sha256sum'
alias md5='md5sum'

# --- Red --------------------------------------------------------------------
alias myip='curl -fsS https://ifconfig.me; echo'          # IP pública
alias localip="hostname -I 2>/dev/null || ip -4 addr show scope global | awk '/inet /{print \$2}'"
alias ports='ss -tulpn'                                   # puertos en escucha
alias listening='ss -tulpn'
alias connections='ss -tpn'                               # conexiones establecidas
alias ping='ping -c 4'                                    # 4 pings y para
alias traceroute='traceroute -n' 2>/dev/null || true
alias digs='dig +short'                                   # respuesta DNS corta
alias flushdns='resolvectl flush-caches 2>/dev/null || systemd-resolve --flush-caches 2>/dev/null || true'

# HTTP rápido
alias headers='curl -fsSI'                                # solo cabeceras
alias get='curl -fsSL'                                    # GET silencioso con follow

# --- Procesos y recursos ----------------------------------------------------
alias psg='ps aux | grep -v grep | grep -i --color=auto'
alias topmem='ps aux --sort=-%mem | head -n 20'           # [GNU] más memoria
alias topcpu='ps aux --sort=-%cpu | head -n 20'           # [GNU] más CPU
alias meminfo='free -h'
alias cpuinfo='lscpu'

# Matar por nombre (pide confirmación implícita al listar antes; úsalo con cuidado)
# Ejemplo: pkill -f "nombre"
alias kill9='kill -9'

# --- Logs y journald --------------------------------------------------------
alias jctl='journalctl -xe'                               # errores recientes
alias jctlf='journalctl -f'                               # follow
alias jctlu='journalctl -u'                               # journalctl -u servicio
alias syslog='tail -n 100 /var/log/syslog 2>/dev/null || tail -n 100 /var/log/messages'
# Preferir marcas de tiempo legibles si el dmesg local lo soporta (GNU).
# No invocamos dmesg aquí: solo definimos el alias de uso habitual en Linux.
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

# --- Permisos y ACLs (chuleta rápida en terminal) ---------------------------
alias perms='stat -c "%a %A %n"'                          # [GNU] octal + simbólico
alias getacl='getfacl'
alias setacl='setfacl'
# Ejemplo útil: find . -type f -exec perms {} \;

# --- Git (diario) -----------------------------------------------------------
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
alias rgf='rg --files' 2>/dev/null || true

# Buscar fichero por nombre desde el cwd
ff() { find . -iname "*$1*" 2>/dev/null; }

# --- Docker (si está instalado) ---------------------------------------------
if command -v docker >/dev/null 2>&1; then
  alias d='docker'
  alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dpa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias di='docker images'
  alias dlog='docker logs -f --tail=100'
fi

# --- Utilidades varias ------------------------------------------------------
alias path='echo -e "${PATH//:/\\n}"'                     # PATH línea a línea
alias now='date "+%Y-%m-%d %H:%M:%S %Z"'
alias week='date +%V'
alias reloadbash='source ~/.bashrc && echo "bashrc recargado"'

# Extraer archivos según extensión
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
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.zip)     unzip "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Formato no reconocido: $1" >&2; return 1 ;;
  esac
}

# Mensaje al cargar (silencioso si BIBLIOTECA_ALIASES_QUIET=1)
if [ "${BIBLIOTECA_ALIASES_QUIET:-0}" != "1" ]; then
  echo "[Biblioteca] aliases.bash cargados. Silenciar: export BIBLIOTECA_ALIASES_QUIET=1"
fi

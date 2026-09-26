# Aliases de shell (bash / zsh / sh)

Aliases y funciones prácticas de administración de sistemas: navegación, seguridad básica, red, logs, systemd, git y utilidades.

| Fichero | Shell | Destino típico |
|---------|-------|----------------|
| [`aliases.bash`](aliases.bash) | bash | `~/.biblioteca-aliases.bash` + `~/.bashrc` |
| [`aliases.zsh`](aliases.zsh) | zsh | `~/.biblioteca-aliases.zsh` + `~/.zshrc` |
| [`aliases.sh`](aliases.sh) | sh (POSIX) | `~/.biblioteca-aliases.sh` + `~/.shrc` / `~/.profile` |

Silenciar el mensaje al cargar: `export BIBLIOTECA_ALIASES_QUIET=1`.

## Instalación en una línea

Las URLs apuntan a la rama `aliases-chuletas-permisos`. Tras fusionar a `main`, sustituye esa rama por `main` en la URL.

Base raw: `https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/<RAMA>/Sistemas%20Operativos/shell/`

### bash (curl)

```bash
curl -fsSL "https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/aliases-chuletas-permisos/Sistemas%20Operativos/shell/aliases.bash" -o ~/.biblioteca-aliases.bash && grep -q 'biblioteca-aliases.bash' ~/.bashrc 2>/dev/null || echo '[ -f ~/.biblioteca-aliases.bash ] && . ~/.biblioteca-aliases.bash' >> ~/.bashrc && . ~/.biblioteca-aliases.bash
```

### bash (wget)

```bash
wget -qO ~/.biblioteca-aliases.bash "https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/aliases-chuletas-permisos/Sistemas%20Operativos/shell/aliases.bash" && grep -q 'biblioteca-aliases.bash' ~/.bashrc 2>/dev/null || echo '[ -f ~/.biblioteca-aliases.bash ] && . ~/.biblioteca-aliases.bash' >> ~/.bashrc && . ~/.biblioteca-aliases.bash
```

### zsh (curl)

```bash
curl -fsSL "https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/aliases-chuletas-permisos/Sistemas%20Operativos/shell/aliases.zsh" -o ~/.biblioteca-aliases.zsh && grep -q 'biblioteca-aliases.zsh' ~/.zshrc 2>/dev/null || echo '[ -f ~/.biblioteca-aliases.zsh ] && . ~/.biblioteca-aliases.zsh' >> ~/.zshrc && . ~/.biblioteca-aliases.zsh
```

### zsh (wget)

```bash
wget -qO ~/.biblioteca-aliases.zsh "https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/aliases-chuletas-permisos/Sistemas%20Operativos/shell/aliases.zsh" && grep -q 'biblioteca-aliases.zsh' ~/.zshrc 2>/dev/null || echo '[ -f ~/.biblioteca-aliases.zsh ] && . ~/.biblioteca-aliases.zsh' >> ~/.zshrc && . ~/.biblioteca-aliases.zsh
```

### sh (curl)

```sh
curl -fsSL "https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/aliases-chuletas-permisos/Sistemas%20Operativos/shell/aliases.sh" -o ~/.biblioteca-aliases.sh && touch ~/.shrc && grep -q 'biblioteca-aliases.sh' ~/.shrc 2>/dev/null || echo '[ -f ~/.biblioteca-aliases.sh ] && . ~/.biblioteca-aliases.sh' >> ~/.shrc && . ~/.biblioteca-aliases.sh
```

### sh (wget)

```sh
wget -qO ~/.biblioteca-aliases.sh "https://raw.githubusercontent.com/P3M-ACTF/Biblioteca/aliases-chuletas-permisos/Sistemas%20Operativos/shell/aliases.sh" && touch ~/.shrc && grep -q 'biblioteca-aliases.sh' ~/.shrc 2>/dev/null || echo '[ -f ~/.biblioteca-aliases.sh ] && . ~/.biblioteca-aliases.sh' >> ~/.shrc && . ~/.biblioteca-aliases.sh
```

> En algunos sistemas `sh` solo lee `~/.profile`. Si `~/.shrc` no se carga solo, añade también:  
> `[ -f ~/.shrc ] && . ~/.shrc` en `~/.profile`.

## Actualizar

Repite el mismo one-liner: descarga de nuevo el fichero y recarga. La línea de `source` en `.bashrc` / `.zshrc` / `.shrc` no se duplica (el `grep` lo evita).

## Categorías incluidas

- **Navegación**: `..`, `...`, `ll`, `la`, `lt`, `mkcd`
- **Seguridad básica**: `rm`/`mv`/`cp` interactivos, `chmod`/`chown` con `--preserve-root`
- **Red**: `myip`, `ports`, `ping`, `headers`, `get`, `digs`
- **Logs / systemd**: `jctl`, `jctlf`, `sstatus`, `sfailed`
- **Permisos**: `perms`, `getacl`, `setacl`
- **Git y utilidades**: `gs`, `gl`, `extract`, `ff`

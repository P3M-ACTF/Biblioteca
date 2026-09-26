# Chuleta: variables de entorno y PATH

Variables de entorno, dónde se definen y cómo se resuelven los comandos vía `PATH`.

---

## 1. Idea básica

Una **variable de entorno** es un valor con nombre que heredan los procesos hijos (shell → comando).

```bash
echo "$HOME"
echo "$USER"
env                          # listar
printenv PATH
```

Asignación temporal (solo proceso actual / hijo):

```bash
export EDITOR=vim
VAR=valor comando            # solo para ese comando
```

---

## 2. Variables habituales

| Variable | Uso |
|----------|-----|
| `HOME` | Directorio home |
| `USER` / `LOGNAME` | Usuario |
| `SHELL` | Shell de login |
| `PATH` | Dónde buscar ejecutables |
| `LANG` / `LC_*` | Locale |
| `EDITOR` / `VISUAL` | Editor por defecto |
| `PAGER` | `less`, `more`… |
| `PWD` | Directorio actual |
| `OLDPWD` | Directorio anterior (`cd -`) |
| `TERM` | Tipo de terminal |
| `XDG_CONFIG_HOME` | Config usuario (por defecto `~/.config`) |
| `http_proxy` / `HTTPS_PROXY` | Proxies (convenciones varían) |

---

## 3. PATH — resolución de comandos

`PATH` es una lista de directorios separados por `:`:

```bash
echo "$PATH"
# /usr/local/bin:/usr/bin:/bin:…
```

```bash
which ping
type ping
command -v ping
hash -r                          # olvidar caché de localizaciones (bash)
```

Orden: gana el **primer** ejecutable encontrado. Un directorio malicioso al inicio de `PATH` es un riesgo (hijacking).

```bash
export PATH="$HOME/.local/bin:$PATH"     # anteponer (usuario)
export PATH="$PATH:/opt/herramienta/bin" # posponer
```

Evitar `.` (directorio actual) dentro de `PATH`.

---

## 4. Dónde se definen (orden típico)

| Momento / fichero | Cuándo aplica |
|-------------------|---------------|
| `/etc/environment` | Entorno de pam/login (clave=valor) |
| `/etc/profile` + `/etc/profile.d/*.sh` | Shells de login |
| `~/.profile` / `~/.bash_profile` / `~/.zprofile` | Login del usuario |
| `~/.bashrc` / `~/.zshrc` | Shell interactivo no-login (según setup) |
| systemd `Environment=` / `EnvironmentFile=` | Servicios |
| `sudo` | Por defecto **limpia** mucho el entorno (`env_reset`) |

```bash
bash -l -c 'echo $PATH'      # simular login
bash -c 'echo $PATH'         # no login
sudo env | grep PATH
```

---

## 5. export, entorno y scripts

| Forma | Efecto |
|-------|--------|
| `VAR=1` | Solo shell actual (no exportada) |
| `export VAR=1` | Visible para hijos |
| `unset VAR` | Eliminar |

En scripts: declarar lo necesario; no asumir el `PATH` interactivo del admin (usar rutas absolutas en cron/systemd si hace falta).

---

## 6. Problemas frecuentes

| Síntoma | Causa probable |
|---------|----------------|
| `command not found` | no está en `PATH` o no instalado |
| “En mi shell sí, en cron no” | entorno mínimo de cron |
| `sudo comando` no encuentra binario | `secure_path` de sudo |
| Versión incorrecta de Python/Java | otro binario antes en `PATH` |
| Espacios / comillas rotas | export mal citado |

```bash
type -a python3              # todas las coincidencias en PATH
ls -l "$(command -v python3)"
```

---

## 7. Checklist

| Objetivo | Acción |
|----------|--------|
| Ver PATH | `printenv PATH` |
| Añadir binarios de usuario | `~/.local/bin` + export en rc/profile |
| Depurar “no encontrado” | `type -a`, `echo $PATH` |
| Servicio systemd | `Environment=` / `EnvironmentFile=` |
| Evitar sorpresas | no poner `.` en PATH; cuidado con directorios escribibles al inicio |

---

*Biblioteca — Sistemas Operativos · entorno / PATH*

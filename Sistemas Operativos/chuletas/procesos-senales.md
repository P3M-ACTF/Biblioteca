# Chuleta: procesos, señales y prioridad

Referencia rápida de `ps`/`top`, señales (`kill`), prioridad (`nice`/`renice`) y jobs de shell.

---

## 1. Ver procesos

```bash
ps aux                     # estilo BSD: todos
ps -ef                     # estilo System V
ps -u ana                  # de un usuario
ps aux --sort=-%mem | head
ps aux --sort=-%cpu | head
pgrep -a nginx
pidof sshd
```

| Campo `ps aux` | Significado |
|----------------|-------------|
| USER | Propietario |
| PID | Identificador |
| %CPU / %MEM | Uso relativo |
| STAT | Estado (ver §2) |
| COMMAND | Comando |

Interactivo:

```bash
top
htop                       # si está instalado
```

---

## 2. Estados (STAT) frecuentes

| Código | Significado |
|--------|-------------|
| `R` | Running / runnable |
| `S` | Sleeping (interruptible) |
| `D` | Uninterruptible sleep (I/O; no matar con facilidad) |
| `Z` | Zombie (espera a que el padre haga wait) |
| `T` | Detenido (job control / señal STOP) |
| `I` | Idle kernel thread |
| `<` | Alta prioridad (not nice) |
| `N` | Nice (baja prioridad) |
| `s` | Session leader |
| `l` | Multi-threaded |
| `+` | En foreground process group |

---

## 3. Señales y kill

```bash
kill PID                   # SIGTERM (15) — cierre ordenado
kill -15 PID
kill -TERM PID
kill -9 PID                # SIGKILL — forzar (último recurso)
kill -HUP PID              # 1: recargar config (daemons clásicos)
kill -INT PID              # 2: Ctrl+C
kill -KILL PID             # 9
kill -STOP PID             # 19: pausar
kill -CONT PID             # 18: reanudar

killall nombre             # por nombre (cuidado)
pkill -u ana               # por criterio
pkill -f 'python.*app'     # patrón de línea de comando
```

| Señal | Nº | Uso típico |
|-------|----|------------|
| HUP | 1 | Recarga / desconexión terminal |
| INT | 2 | Interrumpir (Ctrl+C) |
| QUIT | 3 | Quit + core (si aplica) |
| KILL | 9 | Forzar; no se puede capturar |
| TERM | 15 | Terminación amable (por defecto) |
| CONT | 18 | Continuar |
| STOP | 19 | Pausar; no se puede capturar |

Orden recomendado: **TERM → esperar → KILL**.

```bash
kill -l                    # listar señales
```

---

## 4. Prioridad: nice y renice

Rango nice: **-20** (más prioridad) … **19** (menos). Por defecto 0.

```bash
nice -n 10 comando         # lanzar con nice 10
sudo nice -n -5 comando    # subir prioridad (suele requerir root)
renice -n 15 -p PID
renice -n 10 -u ana
ps -o pid,ni,cmd -p PID
```

---

## 5. Jobs de shell (foreground / background)

```bash
comando &                  # background
jobs                       # listar jobs de la sesión
fg %1                      # traer al foreground
bg %1                      # continuar en background
Ctrl+Z                     # suspender (SIGTSTP) → luego bg/fg
disown %1                  # desligar del shell (no SIGHUP al salir)
nohup comando &            # sobrevive al cierre del terminal
```

---

## 6. Árbol y sesión

```bash
pstree -p
ps -ejH                    # jerarquía
systemctl status PID       # si es unidad systemd (a veces)
```

---

## 7. Checklist

| Objetivo | Acción |
|----------|--------|
| Quién come CPU/RAM | `ps` ordenado o `top`/`htop` |
| Parar limpio | `kill PID` (TERM) |
| Forzar | `kill -9 PID` si TERM no basta |
| Bajar prioridad | `renice -n 10 -p PID` |
| Dejar tarea al salir | `nohup` o systemd user service |

---

*Biblioteca — Sistemas Operativos · procesos / señales*

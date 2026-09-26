# Chuleta: systemd y journalctl

Referencia rápida de unidades, `systemctl`, temporizadores frente a cron y filtros del journal.

---

## 1. Unidades habituales

| Tipo | Extensión | Rol |
|------|-----------|-----|
| Servicio | `.service` | Proceso o demonio |
| Temporizador | `.timer` | Dispara otra unidad (suele ser un `.service`) |
| Socket | `.socket` | Activación bajo demanda |
| Mount / Automount | `.mount` / `.automount` | Montajes gestionados |
| Target | `.target` | Grupo de unidades (análogo a runlevels) |
| Path | `.path` | Dispara al cambiar un path |

Rutas típicas:

| Ámbito | Directorio |
|--------|------------|
| Sistema (paquete) | `/lib/systemd/system/` o `/usr/lib/systemd/system/` |
| Sistema (admin) | `/etc/systemd/system/` (prioridad) |
| Usuario | `~/.config/systemd/user/` |

---

## 2. systemctl — día a día

```bash
systemctl status ssh
systemctl start|stop|restart|reload NOMBRE
systemctl enable|--now NOMBRE     # habilitar (y arrancar)
systemctl disable|--now NOMBRE
systemctl is-active|is-enabled NOMBRE
systemctl list-units --type=service --state=running
systemctl --failed
systemctl daemon-reload           # tras editar unit files
systemctl cat NOMBRE              # unidad efectiva
systemctl edit NOMBRE             # drop-in en /etc
systemctl show NOMBRE -p FragmentPath -p ActiveState
```

Ámbito usuario (sesión):

```bash
systemctl --user status …
loginctl enable-linger $USER      # servicios user sin login interactivo
```

---

## 3. Timers frente a cron

| | **systemd timer** | **cron** |
|--|-------------------|----------|
| Integración | Unidades, dependencias, logs en journal | Independiente |
| Calendario | `OnCalendar=` (calendario systemd) | sintaxis cron clásica |
| Persistencia | `Persistent=true` recupera disparos perdidos | no (salvo anacron) |
| Entorno | Definido en la unit | limitado; `crontab` del usuario |
| Inspección | `systemctl list-timers` | `crontab -l` |

```bash
systemctl list-timers --all
systemctl status nombre.timer
systemctl start nombre.timer
```

Ejemplo de calendario (`man systemd.time`):

```
OnCalendar=*-*-* 03:15:00
OnCalendar=Mon..Fri 09:00
OnBootSec=5min
OnUnitActiveSec=1h
```

Preferir timers cuando el trabajo debe integrarse con servicios, reinicios o journal; cron sigue siendo válido para tareas simples y portables.

---

## 4. journalctl — filtros útiles

```bash
journalctl                         # todo (paginado)
journalctl -b                      # arranque actual
journalctl -b -1                   # arranque anterior
journalctl -u ssh                  # unidad
journalctl -u nginx -u php-fpm
journalctl -f                      # follow
journalctl -xe                     # fin + explicación
journalctl --since "1 hour ago"
journalctl --since "2026-09-01" --until "2026-09-02 12:00"
journalctl -p err..alert           # prioridad (0=emerg … 7=debug)
journalctl -p 3 -xb                # errores del boot
journalctl _PID=1234
journalctl _UID=1000
journalctl CONTAINER_NAME=web
journalctl -k                      # kernel (dmesg)
journalctl --disk-usage
journalctl --vacuum-size=500M
journalctl --vacuum-time=14d
```

Salida legible / máquina:

```bash
journalctl -u ssh -o short-iso
journalctl -u ssh -o json-pretty
journalctl -u ssh -n 50 --no-pager
```

---

## 5. Prioridades syslog

| Nº | Nombre | Uso |
|----|--------|-----|
| 0 | emerg | Sistema inutilizable |
| 1 | alert | Acción inmediata |
| 2 | crit | Condiciones críticas |
| 3 | err | Errores |
| 4 | warning | Avisos |
| 5 | notice | Normal pero significativo |
| 6 | info | Informativo |
| 7 | debug | Depuración |

---

## 6. Checklist operativo

| Objetivo | Comando / acción |
|----------|------------------|
| Ver fallos recientes | `systemctl --failed` + `journalctl -xe` |
| Logs de un servicio | `journalctl -u NOMBRE -b --no-pager` |
| Tras editar unit | `daemon-reload` → `restart` |
| Listar timers | `systemctl list-timers --all` |
| Recortar journal | `--vacuum-size` / `--vacuum-time` |

---

*Biblioteca — Sistemas Operativos · systemd / journalctl*

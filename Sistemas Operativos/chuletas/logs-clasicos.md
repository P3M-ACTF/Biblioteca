# Chuleta: logs clásicos en `/var/log`

Qué fichero mirar según el problema y nociones de rotación (alto nivel). Complementa `journalctl` en sistemas con systemd.

---

## 1. Dónde mirar primero

| Síntoma | Fichero / ubicación típica |
|---------|----------------------------|
| Auth / SSH / sudo | `auth.log` (Debian) · `secure` (RHEL) |
| Syslog general | `syslog` (Debian) · `messages` (RHEL) |
| Kernel | `kern.log` · también `dmesg` / `journalctl -k` |
| Cron | `cron.log` o líneas en `syslog`/`messages` |
| Correo | `mail.log` / `maillog` |
| Arranque | `boot.log` (si existe) · journal `-b` |
| Apt | `/var/log/apt/history.log`, `term.log` |
| DNF/Yum | `/var/log/dnf.log`, `yum.log` |
| Nginx | `/var/log/nginx/access.log`, `error.log` |
| Apache | `/var/log/apache2/` o `/var/log/httpd/` |
| MySQL/MariaDB | `/var/log/mysql/` o `mysqld.log` |

Con systemd muchos daemons solo escriben al **journal**; `/var/log` puede estar vacío o ser un puente (`rsyslog`/`syslog-ng`).

```bash
ls -la /var/log
journalctl -u ssh -n 50 --no-pager
```

---

## 2. Ficheros habituales (mapa)

| Ruta | Contenido |
|------|-----------|
| `/var/log/syslog` | Mensajes generales (Debian/Ubuntu) |
| `/var/log/messages` | General (familia RHEL) |
| `/var/log/auth.log` | Autenticación (Debian/Ubuntu) |
| `/var/log/secure` | Autenticación (RHEL) |
| `/var/log/kern.log` | Kernel |
| `/var/log/faillog` / `btmp` | Fallos de login (binarios; `lastb`) |
| `/var/log/wtmp` / `lastlog` | Logins (`last`, `lastlog`) |
| `/var/log/*.log` de apps | Cada servicio su convención |

```bash
sudo tail -n 100 /var/log/auth.log
sudo less /var/log/syslog
sudo grep -i error /var/log/syslog | tail
sudo last -n 20
sudo lastb -n 20                # intentos fallidos (si btmp existe)
```

---

## 3. Lectura rápida

```bash
sudo tail -f /var/log/syslog    # follow
sudo journalctl -f              # equivalente moderno
sudo grep -E 'Failed|Invalid' /var/log/auth.log
sudo zgrep -i timeout /var/log/syslog*.gz   # rotados comprimidos
```

Permisos: muchos logs son solo root → `sudo`. No hace falta `chmod` amplio “para verlos”.

---

## 4. Rotación (alto nivel)

| Pieza | Rol |
|-------|-----|
| **logrotate** | Renombra/comprime/borra según `/etc/logrotate.conf` y `/etc/logrotate.d/*` |
| Frecuencia | daily/weekly; `rotate N` = cuántas generaciones |
| `compress` | `.gz` de históricos |
| `postrotate` | señal al demonio para reabrir ficheros (p. ej. nginx) |
| journald | retención propia (`SystemMaxUse=`, `vacuum`) |

```bash
cat /etc/logrotate.conf
ls /etc/logrotate.d/
sudo logrotate -d /etc/logrotate.conf    # dry-run / depuración
```

Síntoma “el servicio dejó de loguear tras rotar”: falta `postrotate` o el proceso mantiene inode borrado → reiniciar/reload del servicio.

---

## 5. journal frente a ficheros

| | **journald** | **ficheros en /var/log** |
|--|--------------|---------------------------|
| Consulta | `journalctl` con filtros | `tail`/`grep`/`less` |
| Metadatos | unidad, PID, prioridad | texto plano (variable) |
| Persistencia | `/var/log/journal/` si está configurado | según logrotate |
| Apps legacy | pueden seguir a fichero vía syslog | típico en stacks antiguos |

En hosts modernos: **journal primero** para unidades systemd; `/var/log` para stacks clásicos y apps que aún escriben ficheros.

---

## 6. Checklist

| Objetivo | Acción |
|----------|--------|
| Fallos de login | `auth.log` / `secure` + `lastb` |
| Servicio systemd | `journalctl -u nombre` |
| Kernel / hardware | `kern.log` / `journalctl -k` |
| Espacio en disco por logs | `du -sh /var/log/*` + política logrotate/vacuum |
| Histórico comprimido | `zgrep` / `zless` sobre `*.gz` |

---

*Biblioteca — Sistemas Operativos · logs clásicos*

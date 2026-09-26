# Chuleta: cron frente a systemd timers

Cuándo usar `crontab` y cuándo un `.timer` de systemd.

---

## 1. Comparación rápida

| | **cron** | **systemd timer** |
|--|----------|-------------------|
| Integración | Independiente | Units, deps, journal |
| Calendario | sintaxis cron clásica | `OnCalendar=` / monotonic |
| Logs | mail/syslog (variable) | `journalctl -u …` |
| Si el equipo estaba apagado | suele perderse (salvo anacron) | `Persistent=true` puede recuperar |
| Portabilidad | muy alta | depende de systemd |

Relacionado: [systemd-journalctl](systemd-journalctl.md).

---

## 2. cron — lo esencial

```bash
crontab -l
crontab -e
sudo crontab -u usuario -l
ls /etc/cron.d/ /etc/cron.daily/   # system crons
```

Formato usuario (`crontab -e`):

```
# min hora dia mes dow comando
15 3 * * * /usr/local/bin/backup.sh
0 */6 * * * /usr/local/bin/tarea.sh
```

| Campo | Valores |
|-------|---------|
| min | 0–59 |
| hora | 0–23 |
| día mes | 1–31 |
| mes | 1–12 |
| dow | 0–7 (0 y 7 = domingo) |

Entorno de cron es mínimo: usa rutas absolutas y define `PATH`/`MAILTO` si hace falta.

---

## 3. systemd timers — lo esencial

```bash
systemctl list-timers --all
systemctl status nombre.timer
systemctl cat nombre.timer
systemctl cat nombre.service      # unidad disparada
sudo systemctl enable --now nombre.timer
```

Ejemplos `OnCalendar=`:

```
OnCalendar=*-*-* 03:15:00
OnCalendar=Mon..Fri 09:00
OnBootSec=10min
OnUnitActiveSec=1h
```

`Persistent=true` en el `.timer`: si se perdió un disparo por apagado, se ejecuta al volver.

---

## 4. Cuándo usar cada uno

| Elige **cron** si… | Elige **timer** si… |
|--------------------|---------------------|
| Script simple y portable entre sistemas | Quieres deps de units / After=network |
| Ya hay ecosistema cron en el host | Necesitas journal unificado y `systemctl status` |
| Contenedor/minimal sin timers | Recuperar disparos perdidos (`Persistent=`) |
| Tarea de usuario sin root vía `crontab -e` | Servicio de sistema gestionado como unit |

---

## 5. Checklist

| Objetivo | cron | timer |
|----------|------|-------|
| Listar | `crontab -l` | `systemctl list-timers` |
| Logs | syslog / mail | `journalctl -u nombre.service` |
| Probar | ejecutar el comando a mano | `systemctl start nombre.service` |
| Rutas | absolutas | absolutas en `ExecStart=` |

---

*Biblioteca — Sistemas Operativos · cron / timers*

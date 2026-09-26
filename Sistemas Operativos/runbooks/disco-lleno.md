# Runbook: disco lleno

Orden de diagnóstico cuando `df` muestra el filesystem al límite o la app falla por ENOSPC.

## 1. Confirmar el montaje afectado

```bash
df -hT
df -hi          # ¿inodos?
findmnt
```

Anota **TARGET** (p. ej. `/`, `/var`) y tipo. No borres a ciegas.

Chuleta: [fhs-montajes](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/fhs-montajes.md) · [disco-lvm](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/disco-lvm.md)

## 2. Localizar directorios grandes

```bash
sudo du -xh --max-depth=1 /var 2>/dev/null | sort -h
sudo du -xh --max-depth=1 / 2>/dev/null | sort -h | tail
```

Candidatos habituales: `/var/log`, `/var/lib/docker`, homes, backups locales, `/tmp`.

## 3. Journals

```bash
journalctl --disk-usage
# Solo si la política lo permite y has confirmado retención:
# sudo journalctl --vacuum-size=500M
# sudo journalctl --vacuum-time=14d
```

Chuleta: [systemd-journalctl](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/systemd-journalctl.md)

## 4. Logs clásicos

```bash
sudo du -sh /var/log/* | sort -h
# Revisar rotación antes de truncar a mano
ls /etc/logrotate.d/
```

Preferir rotación/vacuum frente a `rm` masivo. Si un log crece sin parar, mirar el servicio que escribe.

Chuleta: [logs-clasicos](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/logs-clasicos.md)

## 5. Ficheros borrados aún abiertos

Si `du` y `df` no cuadran:

```bash
sudo lsof +L1 2>/dev/null | head
```

Reinicia o recarga el proceso que mantiene el inode; el espacio se libera al cerrar el fd.

## 6. Contenedores / paquetes (si aplica)

- Imágenes y volúmenes Docker/Podman huérfanos  
- Caché de paquetes (`apt clean` / `dnf clean all`) — chuleta [paquetes](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/paquetes.md)

## 7. Contención y seguimiento

- [ ] Espacio liberado suficiente para operar  
- [ ] Causa raíz anotada (log sin rotar, dump, crecimiento de datos)  
- [ ] ¿Hace falta ampliar LV/disco? → planificar, no improvisar en caliente  

---

*Biblioteca — runbook · disco lleno*

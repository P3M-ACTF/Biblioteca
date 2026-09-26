# Runbook: servicio no arranca

Cuando `systemctl start` / enable falla o el servicio queda `failed` / `inactive` tras el boot.

## 1. Estado de la unit

```bash
systemctl status NOMBRE.service
systemctl is-active NOMBRE
systemctl is-enabled NOMBRE
systemctl cat NOMBRE
```

Anota: `ActiveState`, `SubState`, exit code, path del unit file.

Chuleta: [systemd-journalctl](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/systemd-journalctl.md)

## 2. Journal del servicio

```bash
journalctl -u NOMBRE.service -b --no-pager
journalctl -u NOMBRE.service -xe
journalctl -u NOMBRE.service --since "1 hour ago"
```

Busca: `Failed`, `permission denied`, `Address already in use`, `ExecStart`, dependencias (`Requires`/`After`).

## 3. Proceso y puerto

```bash
ss -tulpn | grep -E 'PID|puerto'
ps aux | grep -i NOMBRE
```

¿Otro proceso ocupa el socket? ¿El binario existe y es ejecutable?

Chuleta: [procesos-senales](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/procesos-senales.md)

## 4. Permisos y paths del unit

Comprobar en el unit / drop-ins:

| Elemento | Revisar |
|----------|---------|
| `ExecStart=` | ruta absoluta, existe, `+x` |
| Usuario/Grupo | cuenta existe; home/dirs escribibles si hace falta |
| Ficheros de config | legibles por el User= de la unit |
| WorkingDirectory= | existe |
| SELinux/AppArmor | denegados recientes (no desactivar a ciegas) |

```bash
ls -l $(systemctl show -p FragmentPath --value NOMBRE)
namei -l /ruta/del/binario
```

Chuletas: [permisos-posix](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/permisos-posix.md) · [selinux-apparmor](https://github.com/P3M-ACTF/Biblioteca/blob/dev/Sistemas%20Operativos/chuletas/selinux-apparmor.md)

## 5. Tras editar la unit

```bash
sudo systemctl daemon-reload
sudo systemctl restart NOMBRE
systemctl status NOMBRE
```

## 6. Criterio de cierre

- [ ] Servicio `active (running)` o degradación explicada  
- [ ] Causa anotada (config, puerto, permiso, dependencia, política MAC)  
- [ ] Sin “atajos” permanentes (p. ej. permisos 777, desactivar SELinux)  

---

*Biblioteca — runbook · servicio no arranca*

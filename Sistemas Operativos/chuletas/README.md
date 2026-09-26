# Chuletas — Sistemas Operativos

Referencias rápidas, escaneables, nivel chuleta.

| Documento | Contenido |
|-----------|-----------|
| [Permisos POSIX](permisos-posix.md) | rwx, octal, simbólico, setuid/setgid/sticky, ACLs |
| [Permisos NTFS](permisos-ntfs.md) | DACL, herencia, derechos, `icacls` |
| [systemd / journalctl](systemd-journalctl.md) | unidades, systemctl, timers frente a cron, filtros |
| [Usuarios, grupos y sudo](usuarios-grupos-sudo.md) | useradd/usermod, sudoers.d, id, getent |
| [FHS y montajes](fhs-montajes.md) | FHS, mount/findmnt, df/du/lsblk |
| [Procesos y señales](procesos-senales.md) | ps/top, kill, nice/renice, jobs |
| [SSH admin](ssh-admin.md) | config, claves, agent, endurecimiento habitual |
| [Paquetes (apt/dnf)](paquetes.md) | consulta, instalar, actualizar, buscar |
| [Logs clásicos](logs-clasicos.md) | `/var/log`, qué mirar, rotación |
| [Disco y LVM](disco-lvm.md) | particiones, lsblk, PV/VG/LV |
| [Entorno y PATH](entorno-path.md) | variables de entorno y PATH |
| [Windows: usuarios y grupos](windows-usuarios-grupos.md) | net user, grupos, UAC |
| [Windows: servicios y eventos](windows-servicios-eventos.md) | services, Visor de eventos, Get-WinEvent |
| [SELinux / AppArmor](selinux-apparmor.md) | modos y lectura de denegados |
| [Git diario](git-diario.md) | clone, status, commit, branch, pull/push, stash |
| [Cron y timers](cron-timers.md) | crontab frente a systemd timers |

Relacionado: [aliases de shell](../shell/README.md) · [runbooks](../runbooks/README.md) · [plantillas](../plantillas/README.md).

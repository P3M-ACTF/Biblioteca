# Runbook: máquina nueva (Linux)

Checklist de alta a alto nivel: cuentas, SSH, actualizaciones y firewall. No sustituye el estándar de tu organización.

> [!NOTE]
> Detalle de comandos en las chuletas enlazadas. Aquí solo el **orden** y las decisiones.

## 1. Inventario mínimo

- [ ] Hostname, IP/CIDR, gateway, DNS
- [ ] Rol del host (bastión, app, DB…)
- [ ] Quién administra y canal de acceso de emergencia

## 2. Cuentas y privilegios

1. Crear usuario nominativo con home y shell.  
2. Añadir al grupo `sudo` / `wheel` según distro.  
3. Evitar login diario como root; sudo acotado si puedes.

Chuleta: [usuarios-grupos-sudo](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/usuarios-grupos-sudo.md) · plantilla: [sudoers.d](https://github.com/P3M-ACTF/Biblioteca/blob/dev/Sistemas%20Operativos/plantillas/sudoers.d-ejemplo)

## 3. SSH

1. Clave Ed25519 del admin en `authorized_keys`.  
2. Probar login por clave **antes** de cerrar la sesión actual.  
3. Endurecer `sshd_config` (passwords off cuando las claves estén listas, root limitado, AllowUsers/Groups).  
4. `sshd -t` y reload.

Chuleta: [ssh-admin](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/ssh-admin.md) · plantilla: [sshd_config](https://github.com/P3M-ACTF/Biblioteca/blob/dev/Sistemas%20Operativos/plantillas/sshd_config.ejemplo)

## 4. Actualizaciones

1. Actualizar índices e instalar parches de seguridad.  
2. Anotar si hace falta reinicio (kernel).  
3. Definir cadencia (manual o unattended según política).

Chuleta: [paquetes](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/paquetes.md)

## 5. Firewall (alto nivel)

1. Política entrante restrictiva; saliente según necesidad.  
2. Abrir solo puertos del rol (p. ej. 22 desde red de admin).  
3. Documentar excepciones.

Plantilla: [nftables base](https://github.com/P3M-ACTF/Biblioteca/blob/dev/Sistemas%20Operativos/plantillas/nftables-base.nft) · contexto: [bastionado-linux](https://github.com/P3M-ACTF/Biblioteca/blob/main/Ciberseguridad/chuletas/bastionado-linux.md)

## 6. Observabilidad mínima

- [ ] Tiempo sincronizado (NTP/chrony)
- [ ] Saber dónde mirar logs (`journalctl`, `/var/log`)
- [ ] Backup / snapshot según criticidad

Chuletas: [systemd-journalctl](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/systemd-journalctl.md) · [logs-clasicos](https://github.com/P3M-ACTF/Biblioteca/blob/main/Sistemas%20Operativos/chuletas/logs-clasicos.md) · [copias-seguridad](https://github.com/P3M-ACTF/Biblioteca/blob/main/Ciberseguridad/chuletas/copias-seguridad.md)

## 7. Cierre

- [ ] Acceso por clave verificado desde otra máquina
- [ ] `ss -tulpn` revisado (solo lo esperado en listen)
- [ ] Credenciales de bootstrap rotadas o eliminadas

---

*Biblioteca — runbook · máquina nueva*

# Chuleta: bastionado Linux (alto nivel)

Actualizaciones, SSH, cortafuegos (nftables a alto nivel), cuentas y logs. Lista de control defensiva, no guía de ataque.

---

## 1. Principios

| Principio | Práctica |
|-----------|----------|
| Superficie mínima | Menos paquetes, menos servicios escuchando |
| Mínimo privilegio | sudo acotado, roles, sin root diario |
| Parcheo | Actualizaciones oportunas |
| Defensa en profundidad | host + red + app + backups |
| Observabilidad | logs centralizados / retenidos |

---

## 2. Actualizaciones

```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade

# RHEL/Fedora
sudo dnf upgrade
```

- Habilitar actualizaciones de seguridad automáticas si encaja (`unattended-upgrades`, etc.).
- Reiniciar cuando el kernel o `libc` lo requieran (`needrestart`, `dnf needs-restarting`).
- Inventario: qué hay instalado y para qué.

---

## 3. SSH (resumen endurecido)

Ver también [ssh-admin](../../Sistemas%20Operativos/chuletas/ssh-admin.md).

| Control | Orientación |
|---------|-------------|
| Acceso | claves; desactivar passwords cuando sea seguro |
| Root | `PermitRootLogin no` o solo clave |
| Usuarios | `AllowUsers` / `AllowGroups` |
| Exposición | no público si basta VPN/bastión |
| Puerto | cambiar puerto ≠ seguridad fuerte; ayuda poco solo |

---

## 4. Servicios y escucha local

```bash
ss -tulpn
systemctl list-units --type=service --state=running
systemctl disable --now servicio_innecesario
```

Todo lo que escucha en `0.0.0.0` / `::` es superficie. Preferir `127.0.0.1` si solo es local.

---

## 5. Cortafuegos — nftables (alto nivel)

Política habitual en host: **denegar entrante por defecto**, permitir saliente según necesidad, abrir solo puertos de servicio.

```bash
sudo nft list ruleset
# frameworks de alto nivel (distro):
#   firewalld (zones) · ufw (Ubuntu) · nftables “a pelo”
```

Conceptos:

| Concepto | Rol |
|----------|-----|
| Tabla / chain | Organizan reglas (`filter`/`input`…) |
| Política default | `drop` en input es habitual en bastionado |
| Regla allow | puerto/protocolo/origen acotado |
| Logs | registrar drops relevantes (sin inundar) |

Ejemplos de intención (no sustituyen el diseño de tu red):

- Allow: SSH desde red de administración, HTTP/HTTPS públicas si aplica.
- Deny: resto de entrante.
- NAT/forward: solo en routers/hosts que enruten de verdad.

---

## 6. Cuentas

| Control | Acción |
|---------|--------|
| Usuarios | nominativos; sin cuentas compartidas |
| Shells | `nologin` en cuentas de servicio |
| sudo | drop-ins en `/etc/sudoers.d`, acotado |
| Caducidad / lock | `chage`, bloquear cuentas huérfanas |
| MFA | donde el acceso lo permita (IdP, PAM, etc.) |

```bash
awk -F: '$7 !~ /nologin|false/ {print}' /etc/passwd
sudo -l
```

---

## 7. Logs y tiempo

| Qué | Dónde / cómo |
|-----|----------------|
| Sistema | `journalctl`, `/var/log/` |
| Auth | `journalctl -u ssh` / `auth.log` / `secure` |
| Tiempo | NTP/chrony (certificados y correlación) |
| Retención | vacuum journal + rotación; enviar a SIEM si hay |

Alertas mínimas: fallos de auth repetidos, cambios en sudoers, nuevos listeners, errores de disco.

---

## 8. Checklist rápido

| Área | Hecho |
|------|-------|
| Parches al día | ☐ |
| Solo servicios necesarios en listen | ☐ |
| SSH por clave + usuarios limitados | ☐ |
| Firewall con default drop entrante | ☐ |
| Cuentas revisadas / sudo acotado | ☐ |
| Logs retenidos y hora sincronizada | ☐ |
| Backups probados | ☐ |

---

*Biblioteca — Ciberseguridad · bastionado Linux*

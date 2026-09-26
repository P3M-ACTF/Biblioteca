# Chuleta: SELinux y AppArmor

Modos de operación y cómo **leer** un denegado. No incluye guías para desactivar o saltarse el MAC.

---

## 1. Idea

**MAC** (Mandatory Access Control) limita procesos más allá de usuario/grupo POSIX. Un denegado suele ser la política protegiendo el sistema — investiga antes de ampliar permisos.

| Sistema | Distros típicas |
|---------|-----------------|
| **SELinux** | RHEL, Fedora, CentOS Stream… |
| **AppArmor** | Ubuntu, SLES, Debian (según perfil) |

---

## 2. SELinux — modos

| Modo | Efecto |
|------|--------|
| **enforcing** | Niega y registra |
| **permissive** | Solo registra (no niega) |
| **disabled** | Off (evitar como “atajo” permanente) |

```bash
getenforce
sestatus
# Config persistente (solo lectura/consulta aquí): /etc/selinux/config
```

Contexto de un fichero/proceso:

```bash
ls -Z /var/www/html
ps -eZ | head
id -Z
```

---

## 3. SELinux — leer un denegado

Buscar AVC en el audit/journal:

```bash
sudo ausearch -m avc -ts recent 2>/dev/null
sudo journalctl -t setroubleshoot --since "1 hour ago"
sudo grep -i 'avc:.*denied' /var/log/audit/audit.log | tail
```

Campos útiles en el mensaje: `scontext` (origen), `tcontext` (destino), `tclass` (tipo de objeto), `comm` / `name` (proceso/recurso).

Herramientas de ayuda (si están instaladas): `sealert`, `audit2why` — **interpretan**; no las uses a ciegas para generar reglas amplias en producción.

---

## 4. AppArmor — modos de perfil

| Estado | Efecto |
|--------|--------|
| **enforce** | Niega lo no permitido + log |
| **complain** | Solo registra |
| **unconfined** | Sin perfil efectivo |

```bash
sudo aa-status
sudo aa-enabled
ls /etc/apparmor.d/
```

---

## 5. AppArmor — leer un denegado

```bash
sudo journalctl -k --since "1 hour ago" | grep -i apparmor
sudo dmesg | grep -i apparmor | tail
sudo grep -i 'apparmor.*DENIED' /var/log/syslog | tail   # según distro
```

Campos típicos: perfil, operación (`open`, `exec`…), nombre del fichero, `requested_mask` / `denied_mask`.

---

## 6. Respuesta sensata ante un denegado

| Paso | Acción |
|------|--------|
| 1 | Confirmar que el modo es enforcing/enforce (esperado en prod) |
| 2 | Identificar proceso + recurso en el log |
| 3 | ¿Path/contexto incorrecto tras un cambio de app? |
| 4 | Ajustar **etiqueta/perfil** con el procedimiento de tu distro |
| 5 | No “arreglar” con `chmod 777` ni desactivar MAC de forma permanente |

---

## 7. Checklist

| Objetivo | SELinux | AppArmor |
|----------|---------|----------|
| ¿Activo? | `getenforce` | `aa-status` |
| Ver denegados | `ausearch` / audit.log | journal/dmesg DENIED |
| Contexto/perfil | `ls -Z` / `ps -eZ` | perfil en aa-status |

---

*Biblioteca — Sistemas Operativos · SELinux / AppArmor*

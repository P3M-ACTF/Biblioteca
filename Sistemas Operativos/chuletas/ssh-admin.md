# Chuleta: SSH para administración

Referencia de configuración de cliente (`~/.ssh/config`), claves, `ssh-agent` y opciones seguras habituales. Enfoque **admin / endurecimiento**, no ofensivo.

---

## 1. Ficheros del cliente

| Ruta | Rol | Permisos típicos |
|------|-----|------------------|
| `~/.ssh/` | Directorio | `700` |
| `~/.ssh/config` | Config por host | `600` |
| `~/.ssh/id_ed25519` | Clave privada | `600` |
| `~/.ssh/id_ed25519.pub` | Clave pública | `644` |
| `~/.ssh/authorized_keys` | (servidor) claves permitidas | `600` |
| `~/.ssh/known_hosts` | Huellas de servidores | `644` |

---

## 2. Claves

```bash
# Generar (Ed25519 recomendada hoy)
ssh-keygen -t ed25519 -a 100 -C "ana@portatil"

# RSA solo si hay requisito de compatibilidad (bits altos)
ssh-keygen -t rsa -b 4096 -C "ana@portatil"

ssh-copy-id -i ~/.ssh/id_ed25519.pub usuario@servidor
# equivalente manual: añadir la .pub a ~/.ssh/authorized_keys en el servidor
```

Buena práctica: **una clave por máquina/rol**; passphrase en la privada; preferir clave a contraseña en servidores.

---

## 3. ~/.ssh/config — plantilla útil

```sshconfig
Host *
  IdentitiesOnly yes
  AddKeysToAgent yes
  HashKnownHosts yes
  ServerAliveInterval 60
  ServerAliveCountMax 3

Host proxmox
  HostName 192.0.2.10
  User root
  IdentityFile ~/.ssh/id_ed25519_proxmox
  Port 22

Host jump
  HostName bastion.ejemplo.org
  User ana
  IdentityFile ~/.ssh/id_ed25519

Host interno
  HostName 10.0.0.5
  User ana
  ProxyJump jump
  IdentityFile ~/.ssh/id_ed25519
```

```bash
ssh proxmox
ssh -G interno              # ver config efectiva
```

---

## 4. ssh-agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l                  # listar
ssh-add -D                  # borrar todas del agent
```

En entornos de escritorio el agent suele estar ya activo; `AddKeysToAgent yes` en config evita añadir a mano cada vez.

---

## 5. Opciones de cliente habituales

```bash
ssh -v usuario@host         # depuración (-vvv más detalle)
ssh -L 8080:127.0.0.1:80 usuario@host   # túnel local
ssh -N -L ...               # túnel sin shell
ssh -J bastion usuario@interno          # ProxyJump en línea
scp fichero usuario@host:/ruta/
sftp usuario@host
```

---

## 6. Servidor — endurecimiento habitual (sshd_config)

Cambios típicos en `/etc/ssh/sshd_config` o drop-in en `/etc/ssh/sshd_config.d/` (validar con `sshd -t` antes de recargar):

| Directiva | Valor orientativo | Motivo |
|-----------|-------------------|--------|
| `PasswordAuthentication` | `no` | Solo claves (cuando ya hay claves desplegadas) |
| `PermitRootLogin` | `prohibit-password` o `no` | Evitar root con password |
| `PubkeyAuthentication` | `yes` | Claves públicas |
| `PermitEmptyPasswords` | `no` | Obligatoria |
| `X11Forwarding` | `no` | Si no se necesita |
| `AllowUsers` / `AllowGroups` | lista acotada | Mínimo privilegio |
| `MaxAuthTries` | `3`–`6` | Limitar intentos |

```bash
sudo sshd -t
sudo systemctl reload ssh    # o sshd
```

No cortes tu propia sesión: mantén una conexión abierta al probar.

---

## 7. known_hosts y huellas

```bash
ssh-keygen -lf ~/.ssh/known_hosts
ssh-keygen -R hostname              # quitar entrada obsoleta
ssh -o StrictHostKeyChecking=accept-new user@host   # aceptar solo si es nuevo
```

Ante aviso de **REMOTE HOST IDENTIFICATION HAS CHANGED**: verificar fuera de banda (reinstalación legítima vs MITM) antes de borrar la entrada.

---

## 8. Checklist

| Objetivo | Acción |
|----------|--------|
| Acceso sin password | clave Ed25519 + `authorized_keys` |
| Varios hosts | `~/.ssh/config` + `IdentitiesOnly yes` |
| Host detrás de bastión | `ProxyJump` |
| Agent | `ssh-add` / `AddKeysToAgent` |
| Servidor | desactivar passwords cuando las claves estén listas |

---

*Biblioteca — Sistemas Operativos · SSH admin*

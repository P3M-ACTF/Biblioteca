# Chuleta: usuarios, grupos y sudo

Referencia rápida de cuentas locales, grupos, inspección (`id`/`getent`) y privilegios con `/etc/sudoers.d`.

---

## 1. Conceptos

| Concepto | Significado |
|----------|-------------|
| **UID / GID** | Identificadores numéricos de usuario / grupo |
| **Usuario de sistema** | Suele UID bajo; daemons (sin login interactivo) |
| **Grupo primario** | El de `/etc/passwd` (campo GID) |
| **Grupos suplementarios** | `/etc/group` / `usermod -aG` |
| **sudo** | Ejecutar como otro usuario (casi siempre root) con reglas |

Ficheros clave:

| Fichero | Rol |
|---------|-----|
| `/etc/passwd` | Cuentas (público) |
| `/etc/shadow` | Hashes de contraseña (root) |
| `/etc/group` | Grupos |
| `/etc/sudoers` + `/etc/sudoers.d/*` | Reglas sudo |

---

## 2. Crear y modificar usuarios

```bash
# Crear usuario con home y shell
sudo useradd -m -s /bin/bash ana
sudo passwd ana

# Opciones frecuentes de useradd
# -m  crear home
# -s  shell
# -G  grupos suplementarios (lista)
# -u  UID fijo
# -r  cuenta de sistema

sudo usermod -aG sudo ana          # añadir a grupo (no sustituir)
sudo usermod -s /bin/zsh ana
sudo usermod -L ana                # bloquear cuenta
sudo usermod -U ana                # desbloquear
sudo usermod -d /home/nueva -m ana # mover home

sudo userdel -r ana                # borrar usuario y home (-r)
```

Grupos:

```bash
sudo groupadd desarrolladores
sudo groupmod -n nuevo_nombre antiguo
sudo gpasswd -a ana desarrolladores
sudo gpasswd -d ana desarrolladores
sudo groupdel desarrolladores
```

En Debian/Ubuntu el grupo admin interactivo suele ser `sudo`; en RHEL/Fedora, `wheel`.

---

## 3. Inspección: id, getent, who

```bash
id
id ana
id -u; id -g; id -Gn              # UID, GID primario, nombres de grupos

getent passwd ana
getent group sudo
getent passwd | cut -d: -f1       # listar usuarios
getent group

who; w; last -n 20
whoami
```

---

## 4. sudo y /etc/sudoers.d

**Nunca** edites `/etc/sudoers` a mano sin `visudo`. Preferir drop-ins:

```bash
sudo visudo -f /etc/sudoers.d/ana
```

Permisos del drop-in: `0440`, propietario root.

### Sintaxis mínima

```
usuario  hosts=(runas)  etiquetas: comandos
```

Ejemplos:

```
# ana puede todo, con contraseña
ana ALL=(ALL:ALL) ALL

# grupo sudo (Debian) / wheel (RHEL)
%sudo ALL=(ALL:ALL) ALL
%wheel ALL=(ALL:ALL) ALL

# sin contraseña solo para systemctl restart nginx (acotar siempre)
ana ALL=(root) NOPASSWD: /bin/systemctl restart nginx

# alias de comandos
Cmnd_Alias SERVICIOS = /bin/systemctl start nginx, /bin/systemctl stop nginx
ana ALL=(root) SERVICIOS
```

Comprobar:

```bash
sudo -l                    # reglas efectivas del usuario actual
sudo -U ana -l             # reglas de ana
sudo -k                    # invalidar timestamp de credencial
visudo -c                  # sintaxis OK
```

---

## 5. Buenas prácticas

| Práctica | Motivo |
|----------|--------|
| Un fichero por persona/equipo en `sudoers.d` | Cambios auditables y reversibles |
| Evitar `NOPASSWD: ALL` | Demasiado amplio |
| Preferir grupo + membresía | Menos reglas individuales |
| Cuentas de servicio sin shell de login | ` -s /usr/sbin/nologin` |
| Revisar `last` / journal tras altas | Detectar uso inesperado |

---

## 6. Checklist

| Objetivo | Acción |
|----------|--------|
| Alta rápida | `useradd -m -s /bin/bash` + `passwd` + grupo |
| Ver privilegios | `id` + `sudo -l` |
| Añadir a sudo | `usermod -aG sudo\|wheel` |
| Regla acotada | drop-in en `/etc/sudoers.d/` con `visudo -f` |
| Validar | `visudo -c` |

---

*Biblioteca — Sistemas Operativos · usuarios / grupos / sudo*

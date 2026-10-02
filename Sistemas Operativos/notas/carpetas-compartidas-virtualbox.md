# Nota: carpetas compartidas de VirtualBox

Una carpeta del anfitrión montada en el invitado Linux. Hace falta el módulo `vboxsf`, que instala [Guest Additions](guest-additions-virtualbox.md).

## 1. Definir el recurso en VirtualBox

Con la VM apagada: **Configuración → Carpetas compartidas → Añade una**. Anota el **Nombre de la carpeta** (por ejemplo `datos`). Ese nombre es el que usa `mount`, no la ruta del anfitrión.

## 2. Grupo `vboxsf`

El instalador de las Additions crea el grupo. Tu usuario tiene que pertenecer a él:

```bash
sudo usermod -aG vboxsf "$USER"
```

Cierra la sesión y vuelve a entrar. `id` debe listar `vboxsf`.

Si activaste **Automontar**, el invitado la publica en `/media/sf_datos` (prefijo `sf_` más el nombre del recurso).

## 3. Montaje manual

```bash
sudo mkdir -p /mnt/datos
sudo mount -t vboxsf -o uid=1000,gid=1000 datos /mnt/datos
```

Sustituye `1000` por el uid/gid de tu usuario (`id -u`, `id -g`) y `datos` por el nombre del recurso.

## 4. Dejarlo en fstab

```fstab
datos  /mnt/datos  vboxsf  uid=1000,gid=1000,nofail,x-systemd.automount  0  0
```

`nofail` evita caer a emergencia si el recurso no está. `x-systemd.automount` espera a que `vboxguest` esté cargado, que en el arranque temprano todavía no lo está.

```bash
sudo systemctl daemon-reload
sudo mount /mnt/datos
findmnt /mnt/datos
```

## Si falla

| Síntoma | Qué revisar |
|---------|-------------|
| `No such device` | Guest Additions sin instalar, o `lsmod` no muestra `vboxsf` |
| `Protocol error` / permiso denegado | El usuario no está en `vboxsf`, o el nombre del recurso no coincide |
| Monta y no puedes escribir | Falta `uid=` / `gid=` con tu usuario |
| No está en el arranque y sí a mano | La línea de fstab monta antes del módulo; usa las opciones del paso 4 |

---

*Biblioteca — Sistemas Operativos · carpetas VirtualBox*
